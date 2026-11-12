[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)] [string] $Region,
    [Parameter(Mandatory)] [ValidatePattern('^\d{12}$')] [string] $AccountId,
    [Parameter(Mandatory)] [string] $Repository,
    [Parameter(Mandatory)] [ValidatePattern('^[0-9a-f]{7,64}$')] [string] $ImageTag,
    [string] $MavenProfile,
    [switch] $CreateRepository
)

$ErrorActionPreference = 'Stop'
$registry = "$AccountId.dkr.ecr.$Region.amazonaws.com"
$image = "$registry/$Repository`:$ImageTag"

aws ecr describe-repositories --repository-names $Repository --region $Region --output json 2>$null | Out-Null
if ($LASTEXITCODE -ne 0) {
    if (-not $CreateRepository) {
        throw "ECR repository '$Repository' does not exist. Re-run with -CreateRepository after authorization."
    }
    if ($PSCmdlet.ShouldProcess($Repository, 'Create private ECR repository')) {
        aws ecr create-repository --repository-name $Repository --region $Region --image-scanning-configuration scanOnPush=true --encryption-configuration encryptionType=AES256 | Out-Null
        if ($LASTEXITCODE -ne 0) { throw 'ECR repository creation failed.' }
    }
}

if (-not $PSCmdlet.ShouldProcess($image, 'Build and push image')) { return }

$password = aws ecr get-login-password --region $Region
$password | docker login --username AWS --password-stdin $registry
if ($LASTEXITCODE -ne 0) { throw 'ECR login failed.' }

$buildArguments = @('build', '--pull', '--tag', $image)
if ($MavenProfile) { $buildArguments += @('--build-arg', "MAVEN_PROFILE=$MavenProfile") }
$buildArguments += '.'
docker @buildArguments
if ($LASTEXITCODE -ne 0) { throw 'Docker build failed.' }
docker push $image
if ($LASTEXITCODE -ne 0) { throw 'Docker push failed.' }

$digest = aws ecr describe-images --repository-name $Repository --image-ids imageTag=$ImageTag --region $Region --query 'imageDetails[0].imageDigest' --output text
if ($LASTEXITCODE -ne 0 -or -not $digest.StartsWith('sha256:')) { throw 'Published image digest could not be resolved.' }

[pscustomobject]@{
    ImageTag = $image
    ImageDigest = "$registry/$Repository@$digest"
}

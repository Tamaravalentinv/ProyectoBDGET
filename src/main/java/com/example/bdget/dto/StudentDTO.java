
package com.example.bdget.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public class StudentDTO {

    @Pattern(
        regexp = "^[a-zA-Z]+$",
        message = "El nombre solo puede contener letras"
    )
    @Size(
        min = 2,
        max = 50,
        message = "El nombre debe tener entre 2 y 50 caracteres"
    )
    @NotBlank(message = "No puede ingresar un nombre vacio")
    private String name;

    public StudentDTO() {
    }

    public StudentDTO(String name) {
        this.name = name;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }
}

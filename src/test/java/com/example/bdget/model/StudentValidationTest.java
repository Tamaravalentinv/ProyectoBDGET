package com.example.bdget.model;

import static org.junit.jupiter.api.Assertions.assertTrue;

import java.util.Set;

import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

import jakarta.validation.ConstraintViolation;
import jakarta.validation.Validation;
import jakarta.validation.Validator;
import jakarta.validation.ValidatorFactory;

class StudentValidationTest {

    private static ValidatorFactory validatorFactory;
    private static Validator validator;

    @BeforeAll
    static void setUpValidator() {
        validatorFactory = Validation.buildDefaultValidatorFactory();
        validator = validatorFactory.getValidator();
    }

    @AfterAll
    static void closeValidatorFactory() {
        validatorFactory.close();
    }

    @Test
    void acceptsNamesAtLengthBoundaries() {
        assertTrue(validateName("Ab").isEmpty());
        assertTrue(validateName("A".repeat(50)).isEmpty());
    }

    @Test
    void rejectsBlankName() {
        assertTrue(hasMessage(validateName(" "), "No puede ingresar un nombre vacio"));
    }

    @Test
    void rejectsNameShorterThanTwoCharacters() {
        assertTrue(hasMessage(validateName("A"), "El nombre debe tener entre 2 y 50 caracteres"));
    }

    @Test
    void rejectsNameLongerThanFiftyCharacters() {
        assertTrue(hasMessage(validateName("A".repeat(51)), "El nombre debe tener entre 2 y 50 caracteres"));
    }

    @Test
    void rejectsNameContainingNonLetters() {
        assertTrue(hasMessage(validateName("John2"), "El nombre solo puede contener letras"));
    }

    private Set<ConstraintViolation<Student>> validateName(String name) {
        Student student = new Student();
        student.setName(name);
        return validator.validate(student);
    }

    private boolean hasMessage(Set<ConstraintViolation<Student>> violations, String message) {
        return violations.stream().anyMatch(violation -> message.equals(violation.getMessage()));
    }
}

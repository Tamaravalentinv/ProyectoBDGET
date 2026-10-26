
package com.example.bdget.dto;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class StudentDTOTest {

    @Test
    void debeCrearDTOConConstructorVacio() {
        StudentDTO dto = new StudentDTO();

        assertNull(dto.getName());
    }

    @Test
    void debeCrearDTOConNombre() {
        StudentDTO dto = new StudentDTO("Tamara");

        assertEquals("Tamara", dto.getName());
    }

    @Test
    void debeActualizarNombre() {
        StudentDTO dto = new StudentDTO();

        dto.setName("Cristopher");

        assertEquals("Cristopher", dto.getName());
    }
}

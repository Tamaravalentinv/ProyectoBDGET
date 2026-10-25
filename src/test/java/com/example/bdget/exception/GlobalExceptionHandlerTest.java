
package com.example.bdget.exception;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

import java.util.List;
import java.util.Map;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.BeanPropertyBindingResult;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;

class GlobalExceptionHandlerTest {

    private GlobalExceptionHandler handler;

    @BeforeEach
    void setUp() {
        handler = new GlobalExceptionHandler();
    }

    @Test
    void handleRuntimeException_debeRetornar400() {
        RuntimeException exception =
                new RuntimeException("Estudiante no encontrado");

        ResponseEntity<Object> result =
                handler.handleRuntimeException(exception);

        assertEquals(HttpStatus.BAD_REQUEST, result.getStatusCode());

        Map<?, ?> body = (Map<?, ?>) result.getBody();

        assertNotNull(body);
        assertEquals("Estudiante no encontrado", body.get("message"));
        assertEquals(400, body.get("status"));
        assertNotNull(body.get("timestamp"));
    }

    @Test
    void handleValidationException_debeRetornarErrores() {
        MethodArgumentNotValidException exception =
                mock(MethodArgumentNotValidException.class);

        BeanPropertyBindingResult bindingResult =
                new BeanPropertyBindingResult(new Object(), "student");

        bindingResult.addError(
                new FieldError("student", "name", "El nombre es obligatorio")
        );

        when(exception.getBindingResult()).thenReturn(bindingResult);

        ResponseEntity<Object> result =
                handler.handleValidationException(exception);

        assertEquals(HttpStatus.BAD_REQUEST, result.getStatusCode());

        Map<?, ?> body = (Map<?, ?>) result.getBody();

        assertNotNull(body);
        assertEquals(400, body.get("status"));
        assertNotNull(body.get("timestamp"));

        Map<?, ?> errors = (Map<?, ?>) body.get("errors");

        assertNotNull(errors);
        assertEquals("El nombre es obligatorio", errors.get("name"));
    }

    @Test
    void handleGeneralException_debeRetornar500() {
        Exception exception =
                new Exception("Error interno de prueba");

        ResponseEntity<Object> result =
                handler.handleGeneralException(exception);

        assertEquals(
                HttpStatus.INTERNAL_SERVER_ERROR,
                result.getStatusCode()
        );

        Map<?, ?> body = (Map<?, ?>) result.getBody();

        assertNotNull(body);
        assertEquals(500, body.get("status"));
        assertEquals(
                "An unexpected error occurred",
                body.get("message")
        );
        assertEquals("Error interno de prueba", body.get("details"));
        assertNotNull(body.get("timestamp"));
    }
}

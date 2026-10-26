package com.example.bdget.exception;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertInstanceOf;
import static org.junit.jupiter.api.Assertions.assertSame;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.BindingResult;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;

class GlobalExceptionHandlerTest {

    private final GlobalExceptionHandler handler = new GlobalExceptionHandler();

    @Test
    void handlesRuntimeExceptionAsBadRequest() {
        RuntimeException exception = new RuntimeException("Invalid operation");

        ResponseEntity<Object> response = handler.handleRuntimeException(exception);
        Map<?, ?> body = assertInstanceOf(Map.class, response.getBody());

        assertEquals(HttpStatus.BAD_REQUEST, response.getStatusCode());
        assertEquals(400, body.get("status"));
        assertEquals("Invalid operation", body.get("message"));
        assertInstanceOf(LocalDateTime.class, body.get("timestamp"));
    }

    @Test
    void handlesValidationErrorsByField() {
        BindingResult bindingResult = mock(BindingResult.class);
        MethodArgumentNotValidException exception = mock(MethodArgumentNotValidException.class);
        when(exception.getBindingResult()).thenReturn(bindingResult);
        when(bindingResult.getFieldErrors()).thenReturn(List.of(
                new FieldError("student", "name", "Invalid name")));

        ResponseEntity<Object> response = handler.handleValidationException(exception);
        Map<?, ?> body = assertInstanceOf(Map.class, response.getBody());
        Map<?, ?> errors = assertInstanceOf(Map.class, body.get("errors"));

        assertEquals(HttpStatus.BAD_REQUEST, response.getStatusCode());
        assertEquals(400, body.get("status"));
        assertEquals("Invalid name", errors.get("name"));
    }

    @Test
    void handlesUnexpectedExceptionAsInternalServerError() {
        Exception exception = new Exception("Unexpected detail");

        ResponseEntity<Object> response = handler.handleGeneralException(exception);
        Map<?, ?> body = assertInstanceOf(Map.class, response.getBody());

        assertEquals(HttpStatus.INTERNAL_SERVER_ERROR, response.getStatusCode());
        assertEquals(500, body.get("status"));
        assertEquals("An unexpected error occurred", body.get("message"));
        assertEquals("Unexpected detail", body.get("details"));
    }
}

package com.example.bdget.controller;

import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

import java.util.Arrays;
import java.util.Optional;

import com.example.bdget.model.Student;
import com.example.bdget.service.StudentService;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.context.ActiveProfiles;
import tools.jackson.databind.ObjectMapper;

@WebMvcTest(StudentController.class)
@ActiveProfiles("test")
class StudentControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private StudentService service;

    @Autowired
    private ObjectMapper mapper;

    private Student student;

    @BeforeEach
    void setUp() {
        student = new Student();
        student.setId(1L);
        student.setName("John");
    }

    @Test
    void testGetAllStudents() throws Exception {
        when(service.getAllStudents()).thenReturn(Arrays.asList(student));
        mockMvc.perform(get("/students"))
                .andExpect(status().isOk())
                .andExpect(content().json(mapper.writeValueAsString(Arrays.asList(student))));
    }

    @Test
    void testGetStudentById() throws Exception {
        when(service.getStudentById(1L)).thenReturn(Optional.of(student));
        mockMvc.perform(get("/students/1"))
                .andExpect(status().isOk())
                .andExpect(content().json(mapper.writeValueAsString(student)));
    }

    @Test
    void testGetStudentByIdWhenMissing() throws Exception {
        when(service.getStudentById(99L)).thenReturn(Optional.empty());

        mockMvc.perform(get("/students/99"))
                .andExpect(status().isOk())
                .andExpect(content().string("null"));

        verify(service).getStudentById(99L);
    }

    @Test
    void testCreateStudent() throws Exception {
        when(service.createStudent(any(Student.class))).thenReturn(student);
        mockMvc.perform(post("/students")
                .contentType(MediaType.APPLICATION_JSON)
                .content(mapper.writeValueAsString(student)))
                .andExpect(status().isOk())
                .andExpect(content().json(mapper.writeValueAsString(student)));
    }

    @Test
    void testUpdateStudent() throws Exception {
        when(service.updateStudent(eq(1L), any(Student.class))).thenReturn(student);
        mockMvc.perform(put("/students/1")
                .contentType(MediaType.APPLICATION_JSON)
                .content(mapper.writeValueAsString(student)))
                .andExpect(status().isOk())
                .andExpect(content().json(mapper.writeValueAsString(student)));
    }

    @Test
    void testUpdateStudentWhenMissing() throws Exception {
        when(service.updateStudent(eq(99L), any(Student.class))).thenReturn(null);

        mockMvc.perform(put("/students/99")
                .contentType(MediaType.APPLICATION_JSON)
                .content(mapper.writeValueAsString(student)))
                .andExpect(status().isOk())
                .andExpect(content().string(""));

        verify(service).updateStudent(eq(99L), any(Student.class));
    }

    @Test
    void testDeleteStudent() throws Exception {
        mockMvc.perform(delete("/students/1"))
                .andExpect(status().isOk());
        verify(service).deleteStudent(1L);
    }

    @Test
    void testRuntimeExceptionIsHandled() throws Exception {
        when(service.getAllStudents()).thenThrow(new RuntimeException("Repository unavailable"));

        mockMvc.perform(get("/students"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.status").value(400))
                .andExpect(jsonPath("$.message").value("Repository unavailable"))
                .andExpect(jsonPath("$.timestamp").exists());
    }
}

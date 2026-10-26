package com.example.bdget.service;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import com.example.bdget.model.Student;
import com.example.bdget.repository.StudentRepository;

@ExtendWith(MockitoExtension.class)
class StudentServiceImplTest {

    @Mock
    private StudentRepository repository;

    @InjectMocks
    private StudentServiceImpl service;

    private Student student;

    @BeforeEach
    void setUp() {
        student = new Student();
        student.setId(1L);
        student.setName("John");
    }

    @Test
    void testGetAllStudents() {
        List<Student> expected = Arrays.asList(student);
        when(repository.findAll()).thenReturn(expected);
        assertEquals(expected, service.getAllStudents());
        verify(repository).findAll();
    }

    @Test
    void testGetAllStudentsWhenEmpty() {
        when(repository.findAll()).thenReturn(List.of());

        assertTrue(service.getAllStudents().isEmpty());
        verify(repository).findAll();
    }

    @Test
    void testGetStudentById() {
        when(repository.findById(1L)).thenReturn(Optional.of(student));
        assertEquals(Optional.of(student), service.getStudentById(1L));
        verify(repository).findById(1L);
    }

    @Test
    void testGetStudentByIdWhenMissing() {
        when(repository.findById(99L)).thenReturn(Optional.empty());

        assertTrue(service.getStudentById(99L).isEmpty());
        verify(repository).findById(99L);
    }

    @Test
    void testCreateStudent() {
        when(repository.save(student)).thenReturn(student);
        assertEquals(student, service.createStudent(student));
        verify(repository).save(student);
    }

    @Test
    void testCreateStudentPropagatesRepositoryFailure() {
        RuntimeException failure = new RuntimeException("Repository unavailable");
        when(repository.save(student)).thenThrow(failure);

        assertSame(failure, assertThrows(RuntimeException.class, () -> service.createStudent(student)));
    }

    @Test
    void testUpdateStudentExists() {
        when(repository.existsById(1L)).thenReturn(true);
        when(repository.save(student)).thenReturn(student);
        Student result = service.updateStudent(1L, student);
        assertEquals(1L, student.getId());
        assertEquals(student, result);
        verify(repository).existsById(1L);
        verify(repository).save(student);
    }

    @Test
    void testUpdateStudentNotExists() {
        when(repository.existsById(1L)).thenReturn(false);
        assertNull(service.updateStudent(1L, student));
        verify(repository).existsById(1L);
        verify(repository, never()).save(any());
    }

    @Test
    void testDeleteStudent() {
        service.deleteStudent(1L);
        verify(repository).deleteById(1L);
    }

    @Test
    void testDeleteStudentPropagatesRepositoryFailure() {
        RuntimeException failure = new RuntimeException("Repository unavailable");
        doThrow(failure).when(repository).deleteById(1L);

        assertSame(failure, assertThrows(RuntimeException.class, () -> service.deleteStudent(1L)));
    }
}

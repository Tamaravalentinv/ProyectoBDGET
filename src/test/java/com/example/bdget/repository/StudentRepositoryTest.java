package com.example.bdget.repository;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.data.jpa.test.autoconfigure.DataJpaTest;
import org.springframework.test.context.ActiveProfiles;

import com.example.bdget.model.Student;

@DataJpaTest
@ActiveProfiles("test")
class StudentRepositoryTest {

    @Autowired
    private StudentRepository repository;

    @Test
    void savesAndFindsStudent() {
        Student student = new Student();
        student.setName("Alice");

        Student saved = repository.saveAndFlush(student);

        assertNotNull(saved.getId());
        Student found = repository.findById(saved.getId()).orElseThrow();
        assertEquals("Alice", found.getName());
    }

    @Test
    void returnsEmptyWhenStudentDoesNotExist() {
        assertTrue(repository.findById(Long.MAX_VALUE).isEmpty());
    }
}

package com.example.bdget;

import static org.junit.jupiter.api.Assertions.assertNotNull;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.ApplicationContext;
import org.springframework.test.context.ActiveProfiles;

import com.example.bdget.repository.StudentRepository;
import com.example.bdget.service.StudentService;

@SpringBootTest
@ActiveProfiles("test")
class BdgetApplicationTests {

    @Autowired
    private ApplicationContext applicationContext;

    @Test
    void contextLoads() {
        assertNotNull(applicationContext.getBean(StudentService.class));
        assertNotNull(applicationContext.getBean(StudentRepository.class));
    }
}

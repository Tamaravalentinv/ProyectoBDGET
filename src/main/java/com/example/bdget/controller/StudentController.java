
package com.example.bdget.controller;

import com.example.bdget.dto.StudentDTO;
import com.example.bdget.model.Student;
import com.example.bdget.service.StudentService;

import jakarta.validation.Valid;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/students")
@CrossOrigin(origins = {
    "http://localhost:3000",
    "http://localhost:4200"
})
public class StudentController {

    @Autowired
    private StudentService studentService;

    @GetMapping
    public List<Student> getAllStudents() {
        return studentService.getAllStudents();
    }

    @GetMapping("/{id}")
    public Optional<Student> getStudentById(@PathVariable Long id) {
        return studentService.getStudentById(id);
    }

    @PostMapping
    public Student creaStudent(@Valid @RequestBody StudentDTO dto) {
        Student student = new Student();
        student.setName(dto.getName());

        return studentService.createStudent(student);
    }

    @PutMapping("/{id}")
    public Student updateStudent(
            @PathVariable Long id,
            @Valid @RequestBody StudentDTO dto) {

        Student student = new Student();
        student.setName(dto.getName());

        return studentService.updateStudent(id, student);
    }

    @DeleteMapping("/{id}")
    public void deleteStudent(@PathVariable Long id) {
        studentService.deleteStudent(id);
    }
}

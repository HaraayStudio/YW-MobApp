package com.haraay.ywarchitects.controller;


import com.haraay.ywarchitects.dto.ProjectDTO;
import com.haraay.ywarchitects.dto.ProjectLiteDTO;
import com.haraay.ywarchitects.dto.UserDTO;
import com.haraay.ywarchitects.model.User;

import com.haraay.ywarchitects.service.UserService;
import com.haraay.ywarchitects.util.ResponseStructure;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@RestController
@RequestMapping("/api/employees")
public class EmployeeController {

    @Autowired
    private UserService userService;

    @PostMapping("/createemployee")
    public ResponseEntity<ResponseStructure<UserDTO>> createEmployee(@RequestBody User user) {
        return userService.createEmployee(user);
    }

    @GetMapping("/getemployeedata")
    public ResponseEntity<ResponseStructure<UserDTO>> getEmployeeData(@RequestHeader("Authorization") String token) {
        return userService.getEmployeeData(token);
    }
    
    @PutMapping("/updateemployee")
    public ResponseEntity<ResponseStructure<UserDTO>> updateEmployee(@RequestParam Long id, @RequestBody User employee) {
        return userService.updateEmployee(id, employee);
    }

    @PutMapping("/updatemyprofile")
    public ResponseEntity<ResponseStructure<UserDTO>> updateMyProfile(@RequestHeader("Authorization") String token, @RequestBody User employee) {
        return userService.updateMyProfile(token, employee);
    }

    
    @PutMapping(value = "/updatemyprofileimage", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ResponseStructure<?>> updateMyProfileImage(@RequestHeader("Authorization") String token, @RequestPart(value = "profileimage", required = false) MultipartFile profileimage) {
        return userService.updateMyProfileImage(token, profileimage);
    }
    
    @DeleteMapping("/deleteemployee")
    public ResponseEntity<ResponseStructure<String>> softDeleteEmployee(@RequestParam Long id) {
        return userService.softDeleteEmployee(id);
    }

    @GetMapping("/getallemployees")
    public ResponseEntity<ResponseStructure<List<UserDTO>>> getAllEmployees() {
        return userService.getAllEmployees();
    }
    
    @GetMapping("/getallinactiveemployees")
    public ResponseEntity<ResponseStructure<List<UserDTO>>> getallinactiveemployees() {
        return userService.getallinactiveemployees();
    }
    
    @DeleteMapping("/activeemployee")
    public ResponseEntity<ResponseStructure<String>> activeemployee(@RequestParam Long id) {
        return userService.activeemployee(id);
    }
    
    @GetMapping("getmyprojects")
    public ResponseEntity<ResponseStructure<List<ProjectDTO>>> getmyprojects(
    		@RequestHeader("Authorization") String token,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {

        return userService.getmyprojects(token,page, size);
    }

}
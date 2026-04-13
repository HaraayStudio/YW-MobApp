package com.haraay.ywarchitects.exception;


import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;

import com.haraay.ywarchitects.util.ResponseStructure;

@ControllerAdvice
public class GlobalExceptionHandler {

	@ExceptionHandler(ImageUploadException.class)
	public ResponseEntity<ResponseStructure<String>> handleImageUploadException(ImageUploadException ex){
		
		ResponseStructure<String> response = new ResponseStructure<>();
        response.setStatus(HttpStatus.INTERNAL_SERVER_ERROR.value());
        response.setMessage(ex.getMessage());
        response.setData(null);
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
    }
	
	 // Project or User not found
    @ExceptionHandler(ResourceNotFoundException.class)
    public ResponseEntity<ResponseStructure<String>> handleNotFound(ResourceNotFoundException ex) {
    	
        ResponseStructure<String> response = new ResponseStructure<>();
        response.setStatus(HttpStatus.NOT_FOUND.value());
        response.setMessage(ex.getMessage());
        response.setData(null);
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
    }
    
    // User already in project
    @ExceptionHandler(AlreadyExistsException.class)
    public ResponseEntity<ResponseStructure<String>> handleAlreadyExists(AlreadyExistsException ex) {
        ResponseStructure<String> response = new ResponseStructure<>();
        response.setStatus(HttpStatus.CONFLICT.value());
        response.setMessage(ex.getMessage());
        response.setData(null);
        return ResponseEntity.status(HttpStatus.CONFLICT).body(response);
    }
    
    // Any other unexpected error
    @ExceptionHandler(Exception.class)
    public ResponseEntity<ResponseStructure<String>> handleGeneral(Exception ex) {
        ResponseStructure<String> response = new ResponseStructure<>();
        response.setStatus(HttpStatus.INTERNAL_SERVER_ERROR.value());
        response.setMessage("Something went wrong: " + ex.getMessage());
        response.setData(null);
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
    }
}

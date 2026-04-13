package com.haraay.ywarchitects.util;

import org.springframework.stereotype.Component;

@Component
public class ResponseStructure<T> {
	private String message;
	private int status;
	private T data;

	public String getMessage() {
		return message;
	}

	public void setMessage(String message) {
		this.message = message;
	}

	public int getStatus() {
		return status;
	}

	public void setStatus(int status) {
		this.status = status;
	}

	public T getData() {
		return data;
	}

	public void setData(T data) {
		this.data = data;
	}
	
	public ResponseStructure<T> success(T data, String message) {
		this.status = 200; // or HttpStatus.OK.value();
		this.message = message;
		this.data = data;
		return this;
	}
	
	public ResponseStructure<T> error(T data, String message) {
		this.status = 404; // or HttpStatus.OK.value();
		this.message = message;
		this.data = data;
		return this;
	}

}

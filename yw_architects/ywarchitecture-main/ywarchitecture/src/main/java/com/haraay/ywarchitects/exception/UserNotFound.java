package com.haraay.ywarchitects.exception;

public class UserNotFound extends RuntimeException{

	private String message;

	public UserNotFound(String message) {
		super();
		this.message = message;
	}

	@Override
	public String getMessage() {
		return super.getMessage();
	}
}


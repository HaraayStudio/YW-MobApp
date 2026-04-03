package com.haraay.ywarchitects.exception;

public class InCorrectPassword extends RuntimeException{

	private String message;

	public InCorrectPassword(String message) {
		super();
		this.message = message;
	}

	@Override
	public String getMessage() {
		return super.getMessage();
	}
}

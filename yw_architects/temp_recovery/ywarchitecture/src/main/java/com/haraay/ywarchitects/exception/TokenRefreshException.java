package com.haraay.ywarchitects.exception;

public class TokenRefreshException extends RuntimeException{

	private String message;

	public TokenRefreshException(String message) {
		super();
		this.message = message;
	}

	@Override
	public String getMessage() {
		return super.getMessage();
	}
}

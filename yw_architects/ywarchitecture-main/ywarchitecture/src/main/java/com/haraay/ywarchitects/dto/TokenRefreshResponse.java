package com.haraay.ywarchitects.dto;

public class TokenRefreshResponse {
	private String email;
	private String accessToken;
	private String refreshToken;

	

	public TokenRefreshResponse(String email, String accessToken, String refreshToken) {
		super();
		this.email = email;
		this.accessToken = accessToken;
		this.refreshToken = refreshToken;
	}

	// Getters and setters
	
	
	public String getAccessToken() {
		return accessToken;
	}

	public String getEmail() {
		return email;
	}

	public void setEmail(String email) {
		this.email = email;
	}

	public void setAccessToken(String accessToken) {
		this.accessToken = accessToken;
	}

	public String getRefreshToken() {
		return refreshToken;
	}

	public void setRefreshToken(String refreshToken) {
		this.refreshToken = refreshToken;
	}
}

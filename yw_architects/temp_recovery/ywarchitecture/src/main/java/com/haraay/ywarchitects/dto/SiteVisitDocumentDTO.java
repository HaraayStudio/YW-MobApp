package com.haraay.ywarchitects.dto;

import java.time.LocalDateTime;

public class SiteVisitDocumentDTO {

	private Long id;
	private String documentUrl;
	private String documentName;
	private LocalDateTime uploadedAt;

	public SiteVisitDocumentDTO() {
		// TODO Auto-generated constructor stub
	}
	
	
	// Getters & Setters

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public String getDocumentUrl() {
		return documentUrl;
	}

	public void setDocumentUrl(String documentUrl) {
		this.documentUrl = documentUrl;
	}

	public String getDocumentName() {
		return documentName;
	}

	public void setDocumentName(String documentName) {
		this.documentName = documentName;
	}

	public LocalDateTime getUploadedAt() {
		return uploadedAt;
	}

	public void setUploadedAt(LocalDateTime uploadedAt) {
		this.uploadedAt = uploadedAt;
	}
}

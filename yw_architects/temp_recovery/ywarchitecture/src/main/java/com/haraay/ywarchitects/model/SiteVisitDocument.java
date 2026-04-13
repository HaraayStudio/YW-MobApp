package com.haraay.ywarchitects.model;

import java.time.LocalDateTime;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;

@Entity
public class SiteVisitDocument {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	private String documentUrl;
	private String documentName;
	private LocalDateTime uploadedAt;

	@ManyToOne
	@JoinColumn(name = "site_visit_id")
	@JsonIgnoreProperties({"photos", "documents"})
	private SiteVisit siteVisit;

	public SiteVisitDocument() {}

	public Long getId() { return id; }
	public void setId(Long id) { this.id = id; }

	public String getDocumentUrl() { return documentUrl; }
	public void setDocumentUrl(String documentUrl) { this.documentUrl = documentUrl; }

	public String getDocumentName() { return documentName; }
	public void setDocumentName(String documentName) { this.documentName = documentName; }

	public LocalDateTime getUploadedAt() { return uploadedAt; }
	public void setUploadedAt(LocalDateTime uploadedAt) { this.uploadedAt = uploadedAt; }

	public SiteVisit getSiteVisit() { return siteVisit; }
	public void setSiteVisit(SiteVisit siteVisit) { this.siteVisit = siteVisit; }
}
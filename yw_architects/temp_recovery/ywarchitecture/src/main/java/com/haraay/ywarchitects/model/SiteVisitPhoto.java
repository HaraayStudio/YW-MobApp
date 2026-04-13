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
public class SiteVisitPhoto {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	private String imageUrl;
	private String caption;
	private LocalDateTime uploadedAt;

	@ManyToOne
	@JoinColumn(name = "site_visit_id")
	@JsonIgnoreProperties({"photos", "documents"})
	private SiteVisit siteVisit;

	public SiteVisitPhoto() {}

	public Long getId() { return id; }
	public void setId(Long id) { this.id = id; }

	public String getImageUrl() { return imageUrl; }
	public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }

	public String getCaption() { return caption; }
	public void setCaption(String caption) { this.caption = caption; }

	public LocalDateTime getUploadedAt() { return uploadedAt; }
	public void setUploadedAt(LocalDateTime uploadedAt) { this.uploadedAt = uploadedAt; }

	public SiteVisit getSiteVisit() { return siteVisit; }
	public void setSiteVisit(SiteVisit siteVisit) { this.siteVisit = siteVisit; }
}
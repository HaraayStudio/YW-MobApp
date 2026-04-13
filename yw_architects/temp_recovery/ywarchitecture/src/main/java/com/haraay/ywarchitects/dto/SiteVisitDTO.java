package com.haraay.ywarchitects.dto;

import java.time.LocalDateTime;
import java.util.List;

public class SiteVisitDTO {

	private Long id;
	private String title;
	private String description;
	private LocalDateTime visitDateTime;
	private String locationNote;

	private Long projectId;
	private UserLiteDTO createdBy;

	private List<SiteVisitPhotoDTO> photos;
	private List<SiteVisitDocumentDTO> documents;

	public SiteVisitDTO() {
		// TODO Auto-generated constructor stub
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public String getTitle() {
		return title;
	}

	public void setTitle(String title) {
		this.title = title;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public LocalDateTime getVisitDateTime() {
		return visitDateTime;
	}

	public void setVisitDateTime(LocalDateTime visitDateTime) {
		this.visitDateTime = visitDateTime;
	}

	public String getLocationNote() {
		return locationNote;
	}

	public void setLocationNote(String locationNote) {
		this.locationNote = locationNote;
	}

	public Long getProjectId() {
		return projectId;
	}

	public void setProjectId(Long projectId) {
		this.projectId = projectId;
	}

	

	public UserLiteDTO getCreatedBy() {
		return createdBy;
	}

	public void setCreatedBy(UserLiteDTO createdBy) {
		this.createdBy = createdBy;
	}

	public List<SiteVisitPhotoDTO> getPhotos() {
		return photos;
	}

	public void setPhotos(List<SiteVisitPhotoDTO> photos) {
		this.photos = photos;
	}

	public List<SiteVisitDocumentDTO> getDocuments() {
		return documents;
	}

	public void setDocuments(List<SiteVisitDocumentDTO> documents) {
		this.documents = documents;
	}

}

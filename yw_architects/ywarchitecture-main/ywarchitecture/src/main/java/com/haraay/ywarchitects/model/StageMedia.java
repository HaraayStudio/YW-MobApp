package com.haraay.ywarchitects.model;

import java.time.LocalDateTime;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "stage_media")
public class StageMedia {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "project_stage_id", nullable = false)
	@JsonIgnoreProperties({"documents", "mediaFiles", "tasks", "childStages", "parentStage", "project"})
	private ProjectStage projectStage;

	@Column(nullable = false, length = 500)
	private String fileName;

	@Column(nullable = false, length = 1000)
	private String filePath;

	@Enumerated(EnumType.STRING)
	@Column(nullable = false)
	private MediaType mediaType;

	@Column(length = 500)
	private String description;

	@Column
	private Long fileSize; // in bytes

	@Column(length = 100)
	private String mimeType;

	@Column(length = 1000)
	private String thumbnailPath; // For videos and images

	@Column
	private Integer durationSeconds; // For videos/audio

	@Column
	private LocalDateTime capturedAt; // When photo/video was taken

	@Column(length = 500)
	private String location; // GPS or location description

	@Column(nullable = false, updatable = false)
	private LocalDateTime uploadedAt;

	@Column(nullable = false)
	private Long uploadedBy;

	public StageMedia() {
		this.uploadedAt = LocalDateTime.now();
	}

	// Getters and Setters
	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public ProjectStage getProjectStage() {
		return projectStage;
	}

	public void setProjectStage(ProjectStage projectStage) {
		this.projectStage = projectStage;
	}

	public String getFileName() {
		return fileName;
	}

	public void setFileName(String fileName) {
		this.fileName = fileName;
	}

	public String getFilePath() {
		return filePath;
	}

	public void setFilePath(String filePath) {
		this.filePath = filePath;
	}

	public MediaType getMediaType() {
		return mediaType;
	}

	public void setMediaType(MediaType mediaType) {
		this.mediaType = mediaType;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public Long getFileSize() {
		return fileSize;
	}

	public void setFileSize(Long fileSize) {
		this.fileSize = fileSize;
	}

	public String getMimeType() {
		return mimeType;
	}

	public void setMimeType(String mimeType) {
		this.mimeType = mimeType;
	}

	public String getThumbnailPath() {
		return thumbnailPath;
	}

	public void setThumbnailPath(String thumbnailPath) {
		this.thumbnailPath = thumbnailPath;
	}

	public Integer getDurationSeconds() {
		return durationSeconds;
	}

	public void setDurationSeconds(Integer durationSeconds) {
		this.durationSeconds = durationSeconds;
	}

	public LocalDateTime getCapturedAt() {
		return capturedAt;
	}

	public void setCapturedAt(LocalDateTime capturedAt) {
		this.capturedAt = capturedAt;
	}

	public String getLocation() {
		return location;
	}

	public void setLocation(String location) {
		this.location = location;
	}

	public LocalDateTime getUploadedAt() {
		return uploadedAt;
	}

	public void setUploadedAt(LocalDateTime uploadedAt) {
		this.uploadedAt = uploadedAt;
	}

	public Long getUploadedBy() {
		return uploadedBy;
	}

	public void setUploadedBy(Long uploadedBy) {
		this.uploadedBy = uploadedBy;
	}
}
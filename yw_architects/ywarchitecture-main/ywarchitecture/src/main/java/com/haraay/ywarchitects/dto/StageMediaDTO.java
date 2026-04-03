package com.haraay.ywarchitects.dto;

import java.time.LocalDateTime;
import com.haraay.ywarchitects.model.MediaType;

public class StageMediaDTO {

	private Long id;
	private String fileName;
	private String filePath;
	private MediaType mediaType;
	private String description;
	private Long fileSize;
	private String mimeType;
	private String thumbnailPath;
	private Integer durationSeconds;
	private LocalDateTime capturedAt;
	private String location;
	private LocalDateTime uploadedAt;
	private UserLiteDTO uploadedByUser;

	public StageMediaDTO() {
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
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

	public UserLiteDTO getUploadedByUser() {
		return uploadedByUser;
	}

	public void setUploadedByUser(UserLiteDTO uploadedByUser) {
		this.uploadedByUser = uploadedByUser;
	}

}

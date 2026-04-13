package com.haraay.ywarchitects.dto;

import java.time.LocalDateTime;
import com.haraay.ywarchitects.model.DocumentType;

public class StageDocumentDTO {

	private Long id;
	private String fileName;
	private String filePath;
	private DocumentType documentType;
	private String description;
	
	private Boolean isApproved;
	private LocalDateTime approvedAt;
	private String approvalRemarks;
	private Integer version;
	private LocalDateTime uploadedAt;
	private UserLiteDTO uploadedByUser;
	private UserLiteDTO approvedByUser;

	public StageDocumentDTO() {
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

	public DocumentType getDocumentType() {
		return documentType;
	}

	public void setDocumentType(DocumentType documentType) {
		this.documentType = documentType;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	

	public Boolean getIsApproved() {
		return isApproved;
	}

	public void setIsApproved(Boolean isApproved) {
		this.isApproved = isApproved;
	}

	public LocalDateTime getApprovedAt() {
		return approvedAt;
	}

	public void setApprovedAt(LocalDateTime approvedAt) {
		this.approvedAt = approvedAt;
	}

	public String getApprovalRemarks() {
		return approvalRemarks;
	}

	public void setApprovalRemarks(String approvalRemarks) {
		this.approvalRemarks = approvalRemarks;
	}

	public Integer getVersion() {
		return version;
	}

	public void setVersion(Integer version) {
		this.version = version;
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

	public UserLiteDTO getApprovedByUser() {
		return approvedByUser;
	}

	public void setApprovedByUser(UserLiteDTO approvedByUser) {
		this.approvedByUser = approvedByUser;
	}

	// Generate all getters & setters
	// (Keeping short here but you should include full getters/setters like previous
	// DTO)
}

package com.haraay.ywarchitects.dto;

import java.time.LocalDateTime;
import java.util.List;
import com.haraay.ywarchitects.model.StageName;
import com.haraay.ywarchitects.model.StageStatus;

public class ProjectStageDTO {

	private Long id;
	private Long projectId;
	private StageName stageName;
	private String customStageName;
	private StageStatus status;
	private Long parentStageId;

	private Integer progressPercentage;
	private LocalDateTime startedAt;
	private LocalDateTime targetCompletionDate;
	private LocalDateTime actualCompletionDate;

	private String remarks;
	private String internalNotes;
	private Integer displayOrder;
	private Boolean isMandatory;

	private List<ProjectStageDTO> childStages;
	private List<StageDocumentDTO> documents;
	private List<StageMediaDTO> mediaFiles;
	private List<StageTaskDTO> tasks;

	private LocalDateTime createdAt;
	private LocalDateTime updatedAt;
	private UserLiteDTO createdByUser;
	private UserLiteDTO updatedByUser;

	public ProjectStageDTO() {
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public Long getProjectId() {
		return projectId;
	}

	public void setProjectId(Long projectId) {
		this.projectId = projectId;
	}

	public StageName getStageName() {
		return stageName;
	}

	public void setStageName(StageName stageName) {
		this.stageName = stageName;
	}

	public String getCustomStageName() {
		return customStageName;
	}

	public void setCustomStageName(String customStageName) {
		this.customStageName = customStageName;
	}

	public StageStatus getStatus() {
		return status;
	}

	public void setStatus(StageStatus status) {
		this.status = status;
	}

	public Long getParentStageId() {
		return parentStageId;
	}

	public void setParentStageId(Long parentStageId) {
		this.parentStageId = parentStageId;
	}

	public Integer getProgressPercentage() {
		return progressPercentage;
	}

	public void setProgressPercentage(Integer progressPercentage) {
		this.progressPercentage = progressPercentage;
	}

	public LocalDateTime getStartedAt() {
		return startedAt;
	}

	public void setStartedAt(LocalDateTime startedAt) {
		this.startedAt = startedAt;
	}

	public LocalDateTime getTargetCompletionDate() {
		return targetCompletionDate;
	}

	public void setTargetCompletionDate(LocalDateTime targetCompletionDate) {
		this.targetCompletionDate = targetCompletionDate;
	}

	public LocalDateTime getActualCompletionDate() {
		return actualCompletionDate;
	}

	public void setActualCompletionDate(LocalDateTime actualCompletionDate) {
		this.actualCompletionDate = actualCompletionDate;
	}

	public String getRemarks() {
		return remarks;
	}

	public void setRemarks(String remarks) {
		this.remarks = remarks;
	}

	public String getInternalNotes() {
		return internalNotes;
	}

	public void setInternalNotes(String internalNotes) {
		this.internalNotes = internalNotes;
	}

	public Integer getDisplayOrder() {
		return displayOrder;
	}

	public void setDisplayOrder(Integer displayOrder) {
		this.displayOrder = displayOrder;
	}

	public Boolean getIsMandatory() {
		return isMandatory;
	}

	public void setIsMandatory(Boolean isMandatory) {
		this.isMandatory = isMandatory;
	}

	public List<ProjectStageDTO> getChildStages() {
		return childStages;
	}

	public void setChildStages(List<ProjectStageDTO> childStages) {
		this.childStages = childStages;
	}

	public List<StageDocumentDTO> getDocuments() {
		return documents;
	}

	public void setDocuments(List<StageDocumentDTO> documents) {
		this.documents = documents;
	}

	public List<StageMediaDTO> getMediaFiles() {
		return mediaFiles;
	}

	public void setMediaFiles(List<StageMediaDTO> mediaFiles) {
		this.mediaFiles = mediaFiles;
	}

	public List<StageTaskDTO> getTasks() {
		return tasks;
	}

	public void setTasks(List<StageTaskDTO> tasks) {
		this.tasks = tasks;
	}

	public LocalDateTime getCreatedAt() {
		return createdAt;
	}

	public void setCreatedAt(LocalDateTime createdAt) {
		this.createdAt = createdAt;
	}

	public LocalDateTime getUpdatedAt() {
		return updatedAt;
	}

	public void setUpdatedAt(LocalDateTime updatedAt) {
		this.updatedAt = updatedAt;
	}

	public UserLiteDTO getCreatedByUser() {
		return createdByUser;
	}

	public void setCreatedByUser(UserLiteDTO createdByUser) {
		this.createdByUser = createdByUser;
	}

	public UserLiteDTO getUpdatedByUser() {
		return updatedByUser;
	}

	public void setUpdatedByUser(UserLiteDTO updatedByUser) {
		this.updatedByUser = updatedByUser;
	}

}

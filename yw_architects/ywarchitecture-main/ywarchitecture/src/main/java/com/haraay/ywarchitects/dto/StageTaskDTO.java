package com.haraay.ywarchitects.dto;

import java.time.LocalDateTime;

public class StageTaskDTO {

	private Long id;
	private String taskName;
	private String description;
	private Boolean isCompleted;
	private LocalDateTime completedAt;
	private UserLiteDTO completedByUser;
	private Integer displayOrder;
	private Boolean isMandatory;
	private String notes;
	private LocalDateTime createdAt;

	public StageTaskDTO() {
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public String getTaskName() {
		return taskName;
	}

	public void setTaskName(String taskName) {
		this.taskName = taskName;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public Boolean getIsCompleted() {
		return isCompleted;
	}

	public void setIsCompleted(Boolean isCompleted) {
		this.isCompleted = isCompleted;
	}

	public LocalDateTime getCompletedAt() {
		return completedAt;
	}

	public void setCompletedAt(LocalDateTime completedAt) {
		this.completedAt = completedAt;
	}

	public UserLiteDTO getCompletedByUser() {
		return completedByUser;
	}

	public void setCompletedByUser(UserLiteDTO completedByUser) {
		this.completedByUser = completedByUser;
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

	public String getNotes() {
		return notes;
	}

	public void setNotes(String notes) {
		this.notes = notes;
	}

	public LocalDateTime getCreatedAt() {
		return createdAt;
	}

	public void setCreatedAt(LocalDateTime createdAt) {
		this.createdAt = createdAt;
	}

}

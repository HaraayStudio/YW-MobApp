package com.haraay.ywarchitects.dto;

import java.time.LocalDateTime;

public class ProjectLiteDTO {

	private Long projectId;

    private String projectCode;
    private String permanentProjectId;
    private String logoUrl;
    private String projectName;
   
    private String projectStatus;
    private LocalDateTime projectStartDateTime;
    private LocalDateTime projectExpectedEndDate;
    private LocalDateTime projectEndDateTime;
    
    public ProjectLiteDTO() {
		// TODO Auto-generated constructor stub
	}

	public Long getProjectId() {
		return projectId;
	}

	public void setProjectId(Long projectId) {
		this.projectId = projectId;
	}

	public String getProjectCode() {
		return projectCode;
	}

	public void setProjectCode(String projectCode) {
		this.projectCode = projectCode;
	}

	public String getPermanentProjectId() {
		return permanentProjectId;
	}

	public void setPermanentProjectId(String permanentProjectId) {
		this.permanentProjectId = permanentProjectId;
	}

	public String getLogoUrl() {
		return logoUrl;
	}

	public void setLogoUrl(String logoUrl) {
		this.logoUrl = logoUrl;
	}

	public String getProjectName() {
		return projectName;
	}

	public void setProjectName(String projectName) {
		this.projectName = projectName;
	}

	public String getProjectStatus() {
		return projectStatus;
	}

	public void setProjectStatus(String projectStatus) {
		this.projectStatus = projectStatus;
	}

	public LocalDateTime getProjectStartDateTime() {
		return projectStartDateTime;
	}

	public void setProjectStartDateTime(LocalDateTime projectStartDateTime) {
		this.projectStartDateTime = projectStartDateTime;
	}

	public LocalDateTime getProjectExpectedEndDate() {
		return projectExpectedEndDate;
	}

	public void setProjectExpectedEndDate(LocalDateTime projectExpectedEndDate) {
		this.projectExpectedEndDate = projectExpectedEndDate;
	}

	public LocalDateTime getProjectEndDateTime() {
		return projectEndDateTime;
	}

	public void setProjectEndDateTime(LocalDateTime projectEndDateTime) {
		this.projectEndDateTime = projectEndDateTime;
	}
    
    
    
}

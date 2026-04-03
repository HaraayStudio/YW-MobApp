package com.haraay.ywarchitects.dto;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class ProjectDTO {

	private Long projectId;

	private PostSalesIdDTO postSales;

	private String projectCode;
	private String permanentProjectId;
	private String logoUrl;
	private String projectName;
	private String projectDetails;

	// 📍 Location
	private String address;
	private String city;
	private Double latitude;
	private Double longitude;
	private String googlePlace;

	// 📐 Area
	private Double plotArea;
	private Double totalBuiltUpArea;
	private Double totalCarpetArea;

	private LocalDateTime projectCreatedDateTime;
	private String projectStatus;
	private LocalDateTime projectStartDateTime;
	private LocalDateTime projectExpectedEndDate;
	private LocalDateTime projectEndDateTime;
	private String priority;

	// 🏢 Structures
	private List<StructureDTO> structures = new ArrayList<>();

	// 👷 Employees
	private List<UserLiteDTO> workingEmployees = new ArrayList<>();

	// 📊 Stages
	private List<ProjectStageDTO> stages = new ArrayList<>();

	// 📍 Site Visits
	private List<SiteVisitDTO> siteVisits = new ArrayList<>();

	private List<ReraProjectDTO> reraProjects;

	public ProjectDTO() {
	}

	// ======== Getters & Setters ========

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

	public String getProjectDetails() {
		return projectDetails;
	}

	public void setProjectDetails(String projectDetails) {
		this.projectDetails = projectDetails;
	}

	public String getAddress() {
		return address;
	}

	public void setAddress(String address) {
		this.address = address;
	}

	public String getCity() {
		return city;
	}

	public void setCity(String city) {
		this.city = city;
	}

	public Double getLatitude() {
		return latitude;
	}

	public void setLatitude(Double latitude) {
		this.latitude = latitude;
	}

	public Double getLongitude() {
		return longitude;
	}

	public void setLongitude(Double longitude) {
		this.longitude = longitude;
	}

	public String getGooglePlace() {
		return googlePlace;
	}

	public void setGooglePlace(String googlePlace) {
		this.googlePlace = googlePlace;
	}

	public Double getPlotArea() {
		return plotArea;
	}

	public void setPlotArea(Double plotArea) {
		this.plotArea = plotArea;
	}

	public Double getTotalBuiltUpArea() {
		return totalBuiltUpArea;
	}

	public void setTotalBuiltUpArea(Double totalBuiltUpArea) {
		this.totalBuiltUpArea = totalBuiltUpArea;
	}

	public Double getTotalCarpetArea() {
		return totalCarpetArea;
	}

	public void setTotalCarpetArea(Double totalCarpetArea) {
		this.totalCarpetArea = totalCarpetArea;
	}

	public LocalDateTime getProjectCreatedDateTime() {
		return projectCreatedDateTime;
	}

	public void setProjectCreatedDateTime(LocalDateTime projectCreatedDateTime) {
		this.projectCreatedDateTime = projectCreatedDateTime;
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

	public String getPriority() {
		return priority;
	}

	public void setPriority(String priority) {
		this.priority = priority;
	}

	public List<UserLiteDTO> getWorkingEmployees() {
		return workingEmployees;
	}

	public void setWorkingEmployees(List<UserLiteDTO> workingEmployees) {
		this.workingEmployees = workingEmployees;
	}

	public List<StructureDTO> getStructures() {
		return structures;
	}

	public void setStructures(List<StructureDTO> structures) {
		this.structures = structures;
	}

	public List<ProjectStageDTO> getStages() {
		return stages;
	}

	public void setStages(List<ProjectStageDTO> stages) {
		this.stages = stages;
	}

	public List<SiteVisitDTO> getSiteVisits() {
		return siteVisits;
	}

	public void setSiteVisits(List<SiteVisitDTO> siteVisits) {
		this.siteVisits = siteVisits;
	}

	public PostSalesIdDTO getPostSales() {
		return postSales;
	}

	public void setPostSales(PostSalesIdDTO postSales) {
		this.postSales = postSales;
	}

	public List<ReraProjectDTO> getReraProjects() {
		return reraProjects;
	}

	public void setReraProjects(List<ReraProjectDTO> reraProjects) {
		this.reraProjects = reraProjects;
	}

}

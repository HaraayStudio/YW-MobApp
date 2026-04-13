package com.haraay.ywarchitects.model;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Lob;
import jakarta.persistence.ManyToMany;
import jakarta.persistence.OneToMany;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "projects")
public class Project {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private long projectId;

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

	// 📐 Area (Project Level)
	private Double plotArea;
	private Double totalBuiltUpArea;
	private Double totalCarpetArea;

	@OneToMany(mappedBy = "project", cascade = CascadeType.ALL, orphanRemoval = true)
	private List<Structure> structures = new ArrayList<>();

	private LocalDateTime projectCreatedDateTime;

	private String projectStatus;
	private LocalDateTime projectStartDateTime;
	private LocalDateTime projectExpectedEndDate;
	private LocalDateTime projectEndDateTime;

	private String priority;

	@ManyToMany(mappedBy = "projects", cascade = { CascadeType.PERSIST, CascadeType.MERGE, CascadeType.MERGE })
	@JsonIgnoreProperties("projects")
	private List<User> workingemployee = new ArrayList<>();

	@OneToMany(mappedBy = "project", cascade = CascadeType.ALL, orphanRemoval = true)
	@JsonIgnoreProperties("project")
	private List<ProjectStage> stages = new ArrayList<>();

	@OneToMany(mappedBy = "project", cascade = CascadeType.ALL, orphanRemoval = true)
	@JsonIgnoreProperties("project")
	private List<SiteVisit> siteVisits = new ArrayList<>();

	// lineup ===============================
	@OneToOne(mappedBy = "project", cascade = CascadeType.ALL, fetch = FetchType.LAZY, orphanRemoval = true)
	@JsonIgnoreProperties({ "hibernateLazyInitializer", "handler", "project" })
	private ReraProject reraProject;

	@OneToOne(mappedBy = "project", fetch = FetchType.LAZY)
	@JsonIgnoreProperties("project")
	private PostSales postSales;

	public Project() {
		// TODO Auto-generated constructor stub
	}

	public String getPermanentProjectId() {
		return permanentProjectId;
	}

	public void setPermanentProjectId(String permanentProjectId) {
		this.permanentProjectId = permanentProjectId;
	}

	public long getProjectId() {
		return projectId;
	}

	public void setProjectId(long projectId) {
		this.projectId = projectId;
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

	public List<User> getWorkingemployee() {
		return workingemployee;
	}

	public void setWorkingemployee(List<User> workingemployee) {
		this.workingemployee = workingemployee;
	}

	public List<SiteVisit> getSiteVisits() {
		return siteVisits;
	}

	public void setSiteVisits(List<SiteVisit> siteVisits) {
		this.siteVisits = siteVisits;
	}

	public String getProjectCode() {
		return projectCode;
	}

	public void setProjectCode(String projectCode) {
		this.projectCode = projectCode;
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

	public List<Structure> getStructures() {
		return structures;
	}

	public void setStructures(List<Structure> structures) {
		this.structures = structures;
	}

	public LocalDateTime getProjectExpectedEndDate() {
		return projectExpectedEndDate;
	}

	public void setProjectExpectedEndDate(LocalDateTime projectExpectedEndDate) {
		this.projectExpectedEndDate = projectExpectedEndDate;
	}

	public List<ProjectStage> getStages() {
		return stages;
	}

	public void setStages(List<ProjectStage> stages) {
		this.stages = stages;
	}

	public ReraProject getReraProject() {
		return reraProject;
	}

	public void setReraProject(ReraProject reraProject) {
		this.reraProject = reraProject;
	}

	public PostSales getPostSales() {
		return postSales;
	}

	public void setPostSales(PostSales postSales) {
		this.postSales = postSales;
	}

	@Override
	public boolean equals(Object o) {
		if (this == o)
			return true;
		if (o == null || getClass() != o.getClass())
			return false;
		Project project = (Project) o;
		return projectId != 0 && projectId == project.projectId;
	}

	@Override
	public int hashCode() {
		return Objects.hash(projectId);
	}

}
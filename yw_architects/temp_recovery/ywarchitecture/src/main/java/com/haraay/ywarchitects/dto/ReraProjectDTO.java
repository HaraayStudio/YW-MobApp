package com.haraay.ywarchitects.dto;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

public class ReraProjectDTO {

	private Long id;
	private String reraNumber;
	private LocalDate registrationDate;
	private LocalDate expectedCompletionDate;
	private Boolean active;
	private LocalDateTime createdAt;
	private LocalDateTime updatedAt;

	// Project summary (avoid full project object)
	private ProjectLiteDTO project;

	// Nested lists
	private List<ReraCertificateDTO> certificates;
	private List<ReraQuarterUpdateDTO> quarterUpdates;

	// ═══════════════════════════════════════════════════
	// NESTED DTO — Project Summary (lightweight)
	// ═══════════════════════════════════════════════════
	public static class ReraProjectSummaryDTO {
		private Long projectId;
		private String projectCode;
		private String permanentProjectId;
		private String projectName;
		private String projectStatus;
		private String city;
		private String logoUrl;

		public ReraProjectSummaryDTO() {
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

		public String getCity() {
			return city;
		}

		public void setCity(String city) {
			this.city = city;
		}

		public String getLogoUrl() {
			return logoUrl;
		}

		public void setLogoUrl(String logoUrl) {
			this.logoUrl = logoUrl;
		}
	}

	// ═══════════════════════════════════════════════════
	// NESTED DTO — Certificate
	// ═══════════════════════════════════════════════════
	public static class ReraCertificateDTO {
		private Long id;
		private Double completionPercentage;
		private LocalDate certificateDate;
		private String remarks;
		private String certificateFileUrl;
		private Long certifiedBy;
		private LocalDateTime createdAt;

		// Stage summary (lightweight)
		private ReraStageSummaryDTO projectStage;

		public ReraCertificateDTO() {
		}

		public Long getId() {
			return id;
		}

		public void setId(Long id) {
			this.id = id;
		}

		public Double getCompletionPercentage() {
			return completionPercentage;
		}

		public void setCompletionPercentage(Double completionPercentage) {
			this.completionPercentage = completionPercentage;
		}

		public LocalDate getCertificateDate() {
			return certificateDate;
		}

		public void setCertificateDate(LocalDate certificateDate) {
			this.certificateDate = certificateDate;
		}

		public String getRemarks() {
			return remarks;
		}

		public void setRemarks(String remarks) {
			this.remarks = remarks;
		}

		public String getCertificateFileUrl() {
			return certificateFileUrl;
		}

		public void setCertificateFileUrl(String certificateFileUrl) {
			this.certificateFileUrl = certificateFileUrl;
		}

		public Long getCertifiedBy() {
			return certifiedBy;
		}

		public void setCertifiedBy(Long certifiedBy) {
			this.certifiedBy = certifiedBy;
		}

		public LocalDateTime getCreatedAt() {
			return createdAt;
		}

		public void setCreatedAt(LocalDateTime createdAt) {
			this.createdAt = createdAt;
		}

		public ReraStageSummaryDTO getProjectStage() {
			return projectStage;
		}

		public void setProjectStage(ReraStageSummaryDTO projectStage) {
			this.projectStage = projectStage;
		}
	}

	// ═══════════════════════════════════════════════════
	// NESTED DTO — Stage Summary (used inside Certificate)
	// ═══════════════════════════════════════════════════
	public static class ReraStageSummaryDTO {
		private Long id;
		private String stageName;
		private String stageStatus;

		public ReraStageSummaryDTO() {
		}

		public Long getId() {
			return id;
		}

		public void setId(Long id) {
			this.id = id;
		}

		public String getStageName() {
			return stageName;
		}

		public void setStageName(String stageName) {
			this.stageName = stageName;
		}

		public String getStageStatus() {
			return stageStatus;
		}

		public void setStageStatus(String stageStatus) {
			this.stageStatus = stageStatus;
		}
	}

	// ═══════════════════════════════════════════════════
	// NESTED DTO — Quarter Update
	// ═══════════════════════════════════════════════════
	public static class ReraQuarterUpdateDTO {
		private Long id;
		private String constructionStatus;
		private String salesStatus;
		private LocalDate quarterDate;
		private LocalDateTime createdAt;

		public ReraQuarterUpdateDTO() {
		}

		public Long getId() {
			return id;
		}

		public void setId(Long id) {
			this.id = id;
		}

		public String getConstructionStatus() {
			return constructionStatus;
		}

		public void setConstructionStatus(String constructionStatus) {
			this.constructionStatus = constructionStatus;
		}

		public String getSalesStatus() {
			return salesStatus;
		}

		public void setSalesStatus(String salesStatus) {
			this.salesStatus = salesStatus;
		}

		public LocalDate getQuarterDate() {
			return quarterDate;
		}

		public void setQuarterDate(LocalDate quarterDate) {
			this.quarterDate = quarterDate;
		}

		public LocalDateTime getCreatedAt() {
			return createdAt;
		}

		public void setCreatedAt(LocalDateTime createdAt) {
			this.createdAt = createdAt;
		}
	}

	// ═══════════════════════════════════════════════════
	// ReraProjectDTO Getters & Setters
	// ═══════════════════════════════════════════════════
	public ReraProjectDTO() {
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public String getReraNumber() {
		return reraNumber;
	}

	public void setReraNumber(String reraNumber) {
		this.reraNumber = reraNumber;
	}

	public LocalDate getRegistrationDate() {
		return registrationDate;
	}

	public void setRegistrationDate(LocalDate registrationDate) {
		this.registrationDate = registrationDate;
	}

	public LocalDate getExpectedCompletionDate() {
		return expectedCompletionDate;
	}

	public void setExpectedCompletionDate(LocalDate expectedCompletionDate) {
		this.expectedCompletionDate = expectedCompletionDate;
	}

	public Boolean getActive() {
		return active;
	}

	public void setActive(Boolean active) {
		this.active = active;
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

	public ProjectLiteDTO getProject() {
		return project;
	}

	public void setProject(ProjectLiteDTO project) {
		this.project = project;
	}

	public List<ReraCertificateDTO> getCertificates() {
		return certificates;
	}

	public void setCertificates(List<ReraCertificateDTO> certificates) {
		this.certificates = certificates;
	}

	public List<ReraQuarterUpdateDTO> getQuarterUpdates() {
		return quarterUpdates;
	}

	public void setQuarterUpdates(List<ReraQuarterUpdateDTO> quarterUpdates) {
		this.quarterUpdates = quarterUpdates;
	}
}
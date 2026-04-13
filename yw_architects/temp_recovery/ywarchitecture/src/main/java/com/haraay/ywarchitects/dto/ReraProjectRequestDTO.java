package com.haraay.ywarchitects.dto;

import java.time.LocalDate;
import java.util.List;

public class ReraProjectRequestDTO {

	// ── RERA Project fields ───────────────────────────────────────
	private Long projectId; // link to existing Project
	private String reraNumber;
	private LocalDate registrationDate;
	private LocalDate expectedCompletionDate;
	private Boolean active = true;

	// ── N Certificates ────────────────────────────────────────────
	private List<CertificateRequestDTO> certificates;

	// ── N Quarter Updates ─────────────────────────────────────────
	private List<QuarterUpdateRequestDTO> quarterUpdates;

	// ═══════════════════════════════════════════════
	// NESTED — Certificate Request
	// ═══════════════════════════════════════════════
	public static class CertificateRequestDTO {
		private Double completionPercentage;
		private LocalDate certificateDate;
		private String remarks;
		private Long certifiedBy;
		private Long stageId; // link to existing ProjectStage (optional)
		// Note: certificateFile uploaded separately via multipart

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

		public Long getCertifiedBy() {
			return certifiedBy;
		}

		public void setCertifiedBy(Long certifiedBy) {
			this.certifiedBy = certifiedBy;
		}

		public Long getStageId() {
			return stageId;
		}

		public void setStageId(Long stageId) {
			this.stageId = stageId;
		}
	}

	// ═══════════════════════════════════════════════
	// NESTED — Quarter Update Request
	// ═══════════════════════════════════════════════
	public static class QuarterUpdateRequestDTO {
		private String constructionStatus;
		private String salesStatus;
		private LocalDate quarterDate;

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
	}

	// ═══════════════════════════════════════════════
	// ReraProjectRequestDTO Getters & Setters
	// ═══════════════════════════════════════════════
	public Long getProjectId() {
		return projectId;
	}

	public void setProjectId(Long projectId) {
		this.projectId = projectId;
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

	public List<CertificateRequestDTO> getCertificates() {
		return certificates;
	}

	public void setCertificates(List<CertificateRequestDTO> certificates) {
		this.certificates = certificates;
	}

	public List<QuarterUpdateRequestDTO> getQuarterUpdates() {
		return quarterUpdates;
	}

	public void setQuarterUpdates(List<QuarterUpdateRequestDTO> quarterUpdates) {
		this.quarterUpdates = quarterUpdates;
	}
}  
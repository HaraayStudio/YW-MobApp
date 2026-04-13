package com.haraay.ywarchitects.model;

import java.time.LocalDate;
import java.time.LocalDateTime;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;

@Entity
@Table(name = "rera_certificates")
public class ReraCertificate {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	// 🔗 Parent RERA project
	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "rera_project_id", nullable = false)
	@JsonIgnoreProperties({ "certificates", "quarterUpdates", "project" })
	private ReraProject reraProject;

	private Double completionPercentage;
	private LocalDate certificateDate;

	@Column(length = 1000)
	private String remarks;

	private String certificateFileUrl;

	private Long certifiedBy;

	private LocalDateTime createdAt;

	@PrePersist
	public void prePersist() {
		createdAt = LocalDateTime.now();
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public ReraProject getReraProject() {
		return reraProject;
	}

	public void setReraProject(ReraProject reraProject) {
		this.reraProject = reraProject;
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
	// getter
	public Double getCompletionPercentage() { return completionPercentage; }

	// setter
	public void setCompletionPercentage(Double completionPercentage) {
	    this.completionPercentage = completionPercentage;
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
	

}
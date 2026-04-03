package com.haraay.ywarchitects.model;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;

@Entity
@Table(name = "rera_projects")
public class ReraProject {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "project_id", nullable = false)   // ← removed unique = true
	@JsonIgnoreProperties({ "hibernateLazyInitializer", "handler", "reraProjects", "stages", "structures", "siteVisits", "postSales" })
	private Project project;

	// 🔢 RERA details
	@Column(nullable = false, unique = true)
	private String reraNumber;

	private LocalDate registrationDate;

	private LocalDate expectedCompletionDate;

	private Boolean active = true;

	private LocalDateTime createdAt;

	private LocalDateTime updatedAt;

	// 🔗 Certificates issued under this RERA
	@OneToMany(mappedBy = "reraProject", cascade = CascadeType.ALL, orphanRemoval = true)
	@JsonIgnoreProperties("reraProject")
	private List<ReraCertificate> certificates = new ArrayList<>();  // ← add = new ArrayList<>()

	@OneToMany(mappedBy = "reraProject", cascade = CascadeType.ALL, orphanRemoval = true)
	@JsonIgnoreProperties("reraProject")
	private List<ReraQuarterUpdate> quarterUpdates = new ArrayList<>();  // ← ad
	// ================= LIFECYCLE =================

	@PrePersist
	public void prePersist() {
		createdAt = LocalDateTime.now();
		updatedAt = LocalDateTime.now();
	}

	@PreUpdate
	public void preUpdate() {
		updatedAt = LocalDateTime.now();
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public Project getProject() {
		return project;
	}

	public void setProject(Project project) {
		this.project = project;
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

	public List<ReraCertificate> getCertificates() {
		return certificates;
	}

	public void setCertificates(List<ReraCertificate> certificates) {
		this.certificates = certificates;
	}

	public List<ReraQuarterUpdate> getQuarterUpdates() {
		return quarterUpdates;
	}

	public void setQuarterUpdates(List<ReraQuarterUpdate> quarterUpdates) {
		this.quarterUpdates = quarterUpdates;
	}

}
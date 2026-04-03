package com.haraay.ywarchitects.model;

import java.time.LocalDate;
import java.time.LocalDateTime;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;

@Entity
@Table(name = "rera_quarter_updates")
public class ReraQuarterUpdate {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "rera_project_id", nullable = false)
	@JsonIgnoreProperties({ "certificates", "quarterUpdates", "project" })
	private ReraProject reraProject;

	@Column(length = 1000)
	private String constructionStatus;

	@Column(length = 1000)
	private String salesStatus;

	private LocalDate quarterDate;

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
package com.haraay.ywarchitects.website.dto;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * Full project DTO — used for: GET /api/projects/{slug} (project detail page)
 * POST /api/admin/projects (admin create) PUT /api/admin/projects/{id} (admin
 * update)
 */
public class WebProjectDTO {

	// ─── Identity ─────────────────────────────────────────────────────────────

	private Long id;
	private Long srNo;
	private String slug;

	// ─── Hero ─────────────────────────────────────────────────────────────────

	private String title;
	private String category;
	private String hero;
	private String full;
	private String left;
	private String right;
	private List<GalleryImageDTO> gallery = new ArrayList<>();

	// ─── Stats ────────────────────────────────────────────────────────────────

	private String status;
	private String projectType;
	private String location;
	private String scopeOfWork;
	private String client;
	private ProjectSizeDTO size;

	// ─── Content ──────────────────────────────────────────────────────────────

	private List<String> description = new ArrayList<>();
	private List<String> servicesProvided = new ArrayList<>();

	// ─── Timestamps ───────────────────────────────────────────────────────────

	private LocalDateTime createdAt;
	private LocalDateTime updatedAt;

	// ─── Constructors ─────────────────────────────────────────────────────────

	public WebProjectDTO() {
	}

	// ─── Getters & Setters ────────────────────────────────────────────────────

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public Long getSrNo() {
		return srNo;
	}

	public void setSrNo(Long srNo) {
		this.srNo = srNo;
	}

	public String getSlug() {
		return slug;
	}

	public void setSlug(String slug) {
		this.slug = slug;
	}

	public String getTitle() {
		return title;
	}

	public void setTitle(String title) {
		this.title = title;
	}

	public String getCategory() {
		return category;
	}

	public void setCategory(String category) {
		this.category = category;
	}

	public String getHero() {
		return hero;
	}

	public void setHero(String hero) {
		this.hero = hero;
	}

	public String getFull() {
		return full;
	}

	public void setFull(String full) {
		this.full = full;
	}

	public String getLeft() {
		return left;
	}

	public void setLeft(String left) {
		this.left = left;
	}

	public String getRight() {
		return right;
	}

	public void setRight(String right) {
		this.right = right;
	}

	public List<GalleryImageDTO> getGallery() {
		return gallery;
	}

	public void setGallery(List<GalleryImageDTO> gallery) {
		this.gallery = gallery;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public String getProjectType() {
		return projectType;
	}

	public void setProjectType(String projectType) {
		this.projectType = projectType;
	}

	public String getLocation() {
		return location;
	}

	public void setLocation(String location) {
		this.location = location;
	}

	public String getScopeOfWork() {
		return scopeOfWork;
	}

	public void setScopeOfWork(String scopeOfWork) {
		this.scopeOfWork = scopeOfWork;
	}

	public String getClient() {
		return client;
	}

	public void setClient(String client) {
		this.client = client;
	}

	public ProjectSizeDTO getSize() {
		return size;
	}

	public void setSize(ProjectSizeDTO size) {
		this.size = size;
	}

	public List<String> getDescription() {
		return description;
	}

	public void setDescription(List<String> description) {
		this.description = description;
	}

	public List<String> getServicesProvided() {
		return servicesProvided;
	}

	public void setServicesProvided(List<String> servicesProvided) {
		this.servicesProvided = servicesProvided;
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
}
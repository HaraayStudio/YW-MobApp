package com.haraay.ywarchitects.model;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import jakarta.persistence.*;

@Entity
public class SiteVisit {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	private String title; // "Foundation Inspection", "Slab Check"

	@Column(length = 2000)
	private String description;

	private LocalDateTime visitDateTime;

	private String locationNote; // Optional: "Basement Level", "Terrace"

	// ================= RELATIONS =================

	// 🔹 Many visits belong to one project
	@ManyToOne
	@JoinColumn(name = "project_id")
	@JsonIgnoreProperties("siteVisits")
	private Project project;

	// 🔹 Employee who created this visit
	@ManyToOne
	@JoinColumn(name = "created_by")
	@JsonIgnoreProperties({ "projects", "siteVisits" })
	private User createdBy;

	// 🔹 Photos
	@OneToMany(mappedBy = "siteVisit", cascade = CascadeType.ALL, orphanRemoval = true)
	@JsonIgnoreProperties("siteVisit")
	private List<SiteVisitPhoto> photos = new ArrayList<>();

	// 🔹 Documents
	@OneToMany(mappedBy = "siteVisit", cascade = CascadeType.ALL, orphanRemoval = true)
	@JsonIgnoreProperties("siteVisit")
	private List<SiteVisitDocument> documents = new ArrayList<>();

	// ================= HELPERS =================

	public void addPhoto(SiteVisitPhoto photo) {
		photos.add(photo);
		photo.setSiteVisit(this);
	}

	public void addDocument(SiteVisitDocument doc) {
		documents.add(doc);
		doc.setSiteVisit(this);
	}

	public SiteVisit() {
		// TODO Auto-generated constructor stub
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public String getTitle() {
		return title;
	}

	public void setTitle(String title) {
		this.title = title;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public LocalDateTime getVisitDateTime() {
		return visitDateTime;
	}

	public void setVisitDateTime(LocalDateTime visitDateTime) {
		this.visitDateTime = visitDateTime;
	}

	public String getLocationNote() {
		return locationNote;
	}

	public void setLocationNote(String locationNote) {
		this.locationNote = locationNote;
	}

	public Project getProject() {
		return project;
	}

	public void setProject(Project project) {
		this.project = project;
	}

	public User getCreatedBy() {
		return createdBy;
	}

	public void setCreatedBy(User createdBy) {
		this.createdBy = createdBy;
	}

	public List<SiteVisitPhoto> getPhotos() {
		return photos;
	}

	public void setPhotos(List<SiteVisitPhoto> photos) {
		this.photos = photos;
	}

	public List<SiteVisitDocument> getDocuments() {
		return documents;
	}

	public void setDocuments(List<SiteVisitDocument> documents) {
		this.documents = documents;
	}

}
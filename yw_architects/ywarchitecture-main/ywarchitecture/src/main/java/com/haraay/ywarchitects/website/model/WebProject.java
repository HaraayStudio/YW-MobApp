package com.haraay.ywarchitects.website.model;

import jakarta.persistence.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "websiteprojects")
public class WebProject {

    // ─── Primary Key ──────────────────────────────────────────────────────────

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /** Manual display order on the listing page. e.g. 1, 2, 3 ... */
    @Column(name = "sr_no")
    private Long srNo;

    /**
     * URL-friendly unique identifier.
     * e.g. "adhya-radha-krishna" → /projects/adhya-radha-krishna
     */
    @Column(nullable = false, unique = true, length = 150)
    private String slug;

    // ─── Hero Section ─────────────────────────────────────────────────────────

    @Column(nullable = false, length = 200)
    private String title;

    @Column(length = 100)
    private String category;

    @Column(name = "img_hero", length = 500)
    private String hero;

    @Column(name = "img_full", length = 500)
    private String full;

    @Column(name = "img_left", length = 500)
    private String left;

    @Column(name = "img_right", length = 500)
    private String right;

    // ─── Gallery ──────────────────────────────────────────────────────────────

    @OneToMany(mappedBy = "project", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.LAZY)
    @OrderBy("srNo ASC")
    private List<GalleryImage> gallery = new ArrayList<>();

    // ─── Stats ────────────────────────────────────────────────────────────────

    @Column(length = 50)
    private String status;

    @Column(length = 100)
    private String projectType;

    @Column(length = 200)
    private String location;

    @Column(length = 300)
    private String scopeOfWork;

    @Column(length = 150)
    private String client;

    // ─── Size (Embedded) ─────────────────────────────────────────────────────

    @Embedded
    private ProjectSize size;

    // ─── Description Paragraphs ───────────────────────────────────────────────

    @ElementCollection
    @CollectionTable(name = "project_description_lines", joinColumns = @JoinColumn(name = "project_id"))
    @Column(name = "line", columnDefinition = "TEXT")
    @OrderColumn(name = "line_order")
    private List<String> description = new ArrayList<>();

    // ─── Services Provided ────────────────────────────────────────────────────

    @ElementCollection
    @CollectionTable(name = "project_services", joinColumns = @JoinColumn(name = "project_id"))
    @Column(name = "service", length = 200)
    @OrderColumn(name = "service_order")
    private List<String> servicesProvided = new ArrayList<>();

    // ─── Timestamps ───────────────────────────────────────────────────────────

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    // =========================================================================
    // Embeddable: ProjectSize
    // =========================================================================

    @Embeddable
    public static class ProjectSize {

        @Column(name = "size_plot_area", length = 100)
        private String plotArea;

        @Column(name = "size_built_up_area", length = 100)
        private String builtUpArea;

        @Column(name = "size_tower_floors", length = 50)
        private String towerFloors;

        @Column(name = "size_commercial_floors", length = 50)
        private String commercialFloors;

        public ProjectSize() {}

        public ProjectSize(String plotArea, String builtUpArea,
                           String towerFloors, String commercialFloors) {
            this.plotArea         = plotArea;
            this.builtUpArea      = builtUpArea;
            this.towerFloors      = towerFloors;
            this.commercialFloors = commercialFloors;
        }

        public String getPlotArea() { return plotArea; }
        public void setPlotArea(String plotArea) { this.plotArea = plotArea; }

        public String getBuiltUpArea() { return builtUpArea; }
        public void setBuiltUpArea(String builtUpArea) { this.builtUpArea = builtUpArea; }

        public String getTowerFloors() { return towerFloors; }
        public void setTowerFloors(String towerFloors) { this.towerFloors = towerFloors; }

        public String getCommercialFloors() { return commercialFloors; }
        public void setCommercialFloors(String commercialFloors) { this.commercialFloors = commercialFloors; }
    }

    // ─── Constructors ─────────────────────────────────────────────────────────

    public WebProject() {}

    // ─── Gallery Helpers ──────────────────────────────────────────────────────

    public void addGalleryImage(GalleryImage image) {
        image.setProject(this);
        this.gallery.add(image);
    }

    public void removeGalleryImage(GalleryImage image) {
        image.setProject(null);
        this.gallery.remove(image);
    }

    // ─── Getters & Setters ────────────────────────────────────────────────────

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getSrNo() { return srNo; }
    public void setSrNo(Long srNo) { this.srNo = srNo; }

    public String getSlug() { return slug; }
    public void setSlug(String slug) { this.slug = slug; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public String getHero() { return hero; }
    public void setHero(String hero) { this.hero = hero; }

    public String getFull() { return full; }
    public void setFull(String full) { this.full = full; }

    public String getLeft() { return left; }
    public void setLeft(String left) { this.left = left; }

    public String getRight() { return right; }
    public void setRight(String right) { this.right = right; }

    public List<GalleryImage> getGallery() { return gallery; }
    public void setGallery(List<GalleryImage> gallery) { this.gallery = gallery; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getProjectType() { return projectType; }
    public void setProjectType(String projectType) { this.projectType = projectType; }

    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }

    public String getScopeOfWork() { return scopeOfWork; }
    public void setScopeOfWork(String scopeOfWork) { this.scopeOfWork = scopeOfWork; }

    public String getClient() { return client; }
    public void setClient(String client) { this.client = client; }

    public ProjectSize getSize() { return size; }
    public void setSize(ProjectSize size) { this.size = size; }

    public List<String> getDescription() { return description; }
    public void setDescription(List<String> description) { this.description = description; }

    public List<String> getServicesProvided() { return servicesProvided; }
    public void setServicesProvided(List<String> servicesProvided) { this.servicesProvided = servicesProvided; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}
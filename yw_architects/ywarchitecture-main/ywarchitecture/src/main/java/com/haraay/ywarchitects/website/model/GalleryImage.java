package com.haraay.ywarchitects.website.model;

import jakarta.persistence.*;

@Entity
@Table(name = "galleryimages")
public class GalleryImage {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /** Display / sort order in the gallery popup. e.g. 1, 2, 3 ... */
    @Column(name = "sr_no", nullable = false)
    private Long srNo;

    /** Relative or absolute URL. e.g. "/uploads/projects/adhya/gallery-1.jpg" */
    @Column(name = "image_url", nullable = false, length = 500)
    private String imageUrl;

    /** Owning project — the FK column lives on this (child) side. */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "project_id", nullable = false)
    private WebProject project;

    // ─── Constructors ─────────────────────────────────────────────────────────

    public GalleryImage() {}

    public GalleryImage(Long srNo, String imageUrl, WebProject project) {
        this.srNo     = srNo;
        this.imageUrl = imageUrl;
        this.project  = project;
    }

    // ─── Getters & Setters ────────────────────────────────────────────────────

    public Long getId() { return id; }

    public Long getSrNo() { return srNo; }
    public void setSrNo(Long srNo) { this.srNo = srNo; }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }

    public WebProject getProject() { return project; }
    public void setProject(WebProject project) { this.project = project; }

    @Override
    public String toString() {
        return "GalleryImage{id=" + id + ", srNo=" + srNo + ", imageUrl='" + imageUrl + "'}";
    }
}
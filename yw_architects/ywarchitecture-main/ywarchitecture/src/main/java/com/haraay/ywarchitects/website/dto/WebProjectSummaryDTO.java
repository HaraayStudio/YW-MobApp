package com.haraay.ywarchitects.website.dto;

/**
 * Lightweight DTO for the Projects listing page.
 * Used for: GET /api/projects  (returns a list — no heavy fields loaded)
 */
public class WebProjectSummaryDTO {

    private Long id;
    private Long srNo;
    private String slug;
    private String title;
    private String category;
    private String status;
    private String location;
    private String hero;   // thumbnail shown on the listing card

    public WebProjectSummaryDTO() {}

    public WebProjectSummaryDTO(Long id, Long srNo, String slug, String title,
                                String category, String status,
                                String location, String hero) {
        this.id       = id;
        this.srNo     = srNo;
        this.slug     = slug;
        this.title    = title;
        this.category = category;
        this.status   = status;
        this.location = location;
        this.hero     = hero;
    }

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

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }

    public String getHero() { return hero; }
    public void setHero(String hero) { this.hero = hero; }
}
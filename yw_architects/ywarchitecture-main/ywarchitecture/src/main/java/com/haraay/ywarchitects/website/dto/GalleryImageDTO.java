package com.haraay.ywarchitects.website.dto;

public class GalleryImageDTO {

    private Long id;
    private Long srNo;
    private String imageUrl;

    public GalleryImageDTO() {}

    public GalleryImageDTO(Long id, Long srNo, String imageUrl) {
        this.id       = id;
        this.srNo     = srNo;
        this.imageUrl = imageUrl;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getSrNo() { return srNo; }
    public void setSrNo(Long srNo) { this.srNo = srNo; }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }
}
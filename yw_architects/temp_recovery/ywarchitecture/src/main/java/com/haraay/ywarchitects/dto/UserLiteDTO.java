package com.haraay.ywarchitects.dto;

public class UserLiteDTO {

    private Long id;
    private String fullName;
    private String profileImage;

    public UserLiteDTO() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getProfileImage() { return profileImage; }
    public void setProfileImage(String profileImage) { this.profileImage = profileImage; }
}

package com.haraay.ywarchitects.dto;

public class LevelDTO {

	private Long id;
	private Integer levelNumber;
	private String levelLabel;
	private String levelType;
	private String usageType;
	private Double builtUpArea;
	private Double carpetArea;
	private Double floorHeight;
	private Integer sequenceOrder;
	private String constructionStatus;
	private Integer progressPercentage;

	public LevelDTO() {
	}

	// Getters & Setters
	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public Integer getLevelNumber() {
		return levelNumber;
	}

	public void setLevelNumber(Integer levelNumber) {
		this.levelNumber = levelNumber;
	}

	public String getLevelLabel() {
		return levelLabel;
	}

	public void setLevelLabel(String levelLabel) {
		this.levelLabel = levelLabel;
	}

	public String getLevelType() {
		return levelType;
	}

	public void setLevelType(String levelType) {
		this.levelType = levelType;
	}

	public String getUsageType() {
		return usageType;
	}

	public void setUsageType(String usageType) {
		this.usageType = usageType;
	}

	public Double getBuiltUpArea() {
		return builtUpArea;
	}

	public void setBuiltUpArea(Double builtUpArea) {
		this.builtUpArea = builtUpArea;
	}

	public Double getCarpetArea() {
		return carpetArea;
	}

	public void setCarpetArea(Double carpetArea) {
		this.carpetArea = carpetArea;
	}

	public Double getFloorHeight() {
		return floorHeight;
	}

	public void setFloorHeight(Double floorHeight) {
		this.floorHeight = floorHeight;
	}

	public Integer getSequenceOrder() {
		return sequenceOrder;
	}

	public void setSequenceOrder(Integer sequenceOrder) {
		this.sequenceOrder = sequenceOrder;
	}

	public String getConstructionStatus() {
		return constructionStatus;
	}

	public void setConstructionStatus(String constructionStatus) {
		this.constructionStatus = constructionStatus;
	}

	public Integer getProgressPercentage() {
		return progressPercentage;
	}

	public void setProgressPercentage(Integer progressPercentage) {
		this.progressPercentage = progressPercentage;
	}
}

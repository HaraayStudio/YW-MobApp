package com.haraay.ywarchitects.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.CascadeType;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;

import jakarta.persistence.Table;

@Entity
@Table(name = "levels")
public class Level {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	// -2, -1, 0, 1, 2 ...
	private Integer levelNumber;

	// B1, Podium 2, 5th Floor
	private String levelLabel;

	@Enumerated(EnumType.STRING)
	private LevelType levelType;

	@Enumerated(EnumType.STRING)
	private UsageType usageType;

	private Double builtUpArea;
	private Double carpetArea;
	private Double floorHeight;

	private Integer sequenceOrder; // for sorting in UI

	private String constructionStatus;
	private Integer progressPercentage;

	@ManyToOne
	@JoinColumn(name = "structure_id")
	@JsonIgnoreProperties("levels")
	private Structure structure;

	public Level() {
		// TODO Auto-generated constructor stub
	}

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

	public LevelType getLevelType() {
		return levelType;
	}

	public void setLevelType(LevelType levelType) {
		this.levelType = levelType;
	}

	public UsageType getUsageType() {
		return usageType;
	}

	public void setUsageType(UsageType usageType) {
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

	public Structure getStructure() {
		return structure;
	}

	public void setStructure(Structure structure) {
		this.structure = structure;
	}

}
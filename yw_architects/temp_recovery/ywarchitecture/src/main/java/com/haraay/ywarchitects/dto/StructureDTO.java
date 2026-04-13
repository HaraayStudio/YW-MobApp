package com.haraay.ywarchitects.dto;

import java.util.ArrayList;
import java.util.List;

public class StructureDTO {

	private Long id;
	private String structureName;
	private String structureType;
	private String usageType;
	private Integer totalFloors;
	private Integer totalBasements;
	private Double builtUpArea;

	private List<LevelDTO> levels = new ArrayList<>();

	public StructureDTO() {
	}

	// Getters & Setters
	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public String getStructureName() {
		return structureName;
	}

	public void setStructureName(String structureName) {
		this.structureName = structureName;
	}

	public String getStructureType() {
		return structureType;
	}

	public void setStructureType(String structureType) {
		this.structureType = structureType;
	}

	public String getUsageType() {
		return usageType;
	}

	public void setUsageType(String usageType) {
		this.usageType = usageType;
	}

	public Integer getTotalFloors() {
		return totalFloors;
	}

	public void setTotalFloors(Integer totalFloors) {
		this.totalFloors = totalFloors;
	}

	public Integer getTotalBasements() {
		return totalBasements;
	}

	public void setTotalBasements(Integer totalBasements) {
		this.totalBasements = totalBasements;
	}

	public Double getBuiltUpArea() {
		return builtUpArea;
	}

	public void setBuiltUpArea(Double builtUpArea) {
		this.builtUpArea = builtUpArea;
	}

	public List<LevelDTO> getLevels() {
		return levels;
	}

	public void setLevels(List<LevelDTO> levels) {
		this.levels = levels;
	}
}

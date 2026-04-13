package com.haraay.ywarchitects.model;

import java.util.ArrayList;
import java.util.List;

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
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;

@Entity
@Table(name = "structures")
public class Structure {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	private String structureName; // Wing A, Tower 1, Villa 3

	@Enumerated(EnumType.STRING)
	private StructureType structureType;

	@Enumerated(EnumType.STRING)
	private UsageType usageType; // RESIDENTIAL / COMMERCIAL / MIXED

	private Integer totalFloors;
	private Integer totalBasements;

	private Double builtUpArea;

	@ManyToOne
	@JoinColumn(name = "project_id")
	@JsonIgnoreProperties({"structures", "stages", "siteVisits", "reraProject", "postSales"})
	private Project project;

	@OneToMany(mappedBy = "structure", cascade = CascadeType.ALL, orphanRemoval = true)
	@JsonIgnoreProperties("structure")
	private List<Level> levels = new ArrayList<>();

	public Structure() {
		// TODO Auto-generated constructor stub
	}

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

	public StructureType getStructureType() {
		return structureType;
	}

	public void setStructureType(StructureType structureType) {
		this.structureType = structureType;
	}

	public UsageType getUsageType() {
		return usageType;
	}

	public void setUsageType(UsageType usageType) {
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

	public Project getProject() {
		return project;
	}

	public void setProject(Project project) {
		this.project = project;
	}

	public List<Level> getLevels() {
		return levels;
	}

	public void setLevels(List<Level> levels) {
		this.levels = levels;
	}

}
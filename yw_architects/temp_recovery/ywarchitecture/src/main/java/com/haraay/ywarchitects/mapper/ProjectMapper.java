package com.haraay.ywarchitects.mapper;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Component;

import com.haraay.ywarchitects.dto.PostSalesIdDTO;
import com.haraay.ywarchitects.dto.ProjectDTO;
import com.haraay.ywarchitects.dto.ProjectLiteDTO;
import com.haraay.ywarchitects.model.Project;

@Component
public class ProjectMapper {

	private final UserMapper userMapper;
	private final StructureMapper structureMapper;
	private final ProjectStageMapper stageMapper;
	private final SiteVisitMapper siteVisitMapper;

	private final ReraMapper reraMapper;

	public ProjectMapper(UserMapper userMapper, StructureMapper structureMapper, ProjectStageMapper stageMapper,
			SiteVisitMapper siteVisitMapper, ReraMapper reraMapper) {

		this.userMapper = userMapper;
		this.structureMapper = structureMapper;
		this.stageMapper = stageMapper;
		this.siteVisitMapper = siteVisitMapper;
		this.reraMapper = reraMapper;
	}

	public ProjectDTO toDTO(Project project) {
		if (project == null)
			return null;

		ProjectDTO dto = new ProjectDTO();

		dto.setProjectId(project.getProjectId());

		if (project.getPostSales() != null && project.getPostSales().getId() != null)
			dto.setPostSales(new PostSalesIdDTO(project.getPostSales().getId()));

		dto.setProjectCode(project.getProjectCode());
		dto.setPermanentProjectId(project.getPermanentProjectId());
		dto.setLogoUrl(project.getLogoUrl());
		dto.setProjectName(project.getProjectName());
		dto.setProjectDetails(project.getProjectDetails());

		dto.setAddress(project.getAddress());
		dto.setCity(project.getCity());
		dto.setLatitude(project.getLatitude());
		dto.setLongitude(project.getLongitude());
		dto.setGooglePlace(project.getGooglePlace());

		dto.setPlotArea(project.getPlotArea());
		dto.setTotalBuiltUpArea(project.getTotalBuiltUpArea());
		dto.setTotalCarpetArea(project.getTotalCarpetArea());

		dto.setProjectCreatedDateTime(project.getProjectCreatedDateTime());
		dto.setProjectStatus(project.getProjectStatus());
		dto.setProjectStartDateTime(project.getProjectStartDateTime());
		dto.setProjectExpectedEndDate(project.getProjectExpectedEndDate());
		dto.setProjectEndDateTime(project.getProjectEndDateTime());
		dto.setPriority(project.getPriority());

		// Employees
		dto.setWorkingEmployees(
				project.getWorkingemployee().stream().map(userMapper::toLiteDTO).collect(Collectors.toList()));

		// Structures
		dto.setStructures(project.getStructures().stream().map(structureMapper::toDTO).collect(Collectors.toList()));

		// Stages
		dto.setStages(project.getStages().stream().map(stageMapper::toDTO).collect(Collectors.toList()));

		// Site Visits
		dto.setSiteVisits(project.getSiteVisits().stream().map(siteVisitMapper::toDTO).collect(Collectors.toList()));

		if (project.getReraProject() != null) {

			dto.setReraProject(reraMapper.toDTO(project.getReraProject()));
		}

		return dto;
	}

	public List<ProjectDTO> toDTOList(List<Project> projects) {
		if (projects == null || projects.isEmpty())
			return null;

		return projects.stream().map(this::toDTO).collect(Collectors.toList());
	}

	public ProjectLiteDTO toProjectLiteDTO(Project project) {
		if (project == null)
			return null;

		ProjectLiteDTO dto = new ProjectLiteDTO();

		dto.setProjectId(project.getProjectId());
		dto.setProjectCode(project.getProjectCode());
		dto.setPermanentProjectId(project.getPermanentProjectId());
		dto.setLogoUrl(project.getLogoUrl());
		dto.setProjectName(project.getProjectName());

		dto.setProjectStatus(project.getProjectStatus());
		dto.setProjectStartDateTime(project.getProjectStartDateTime());
		dto.setProjectExpectedEndDate(project.getProjectExpectedEndDate());
		dto.setProjectEndDateTime(project.getProjectEndDateTime());

		return dto;
	}

	public List<ProjectLiteDTO> toLiteDTOList(List<Project> projects) {
		if (projects == null || projects.isEmpty()) {
			return null; // ✅ better than null
		}

		return projects.stream().map(this::toProjectLiteDTO).collect(Collectors.toList());
	}

}

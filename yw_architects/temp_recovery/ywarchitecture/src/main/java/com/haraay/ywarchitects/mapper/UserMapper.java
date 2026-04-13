package com.haraay.ywarchitects.mapper;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Component;

import com.haraay.ywarchitects.dto.ProjectLiteDTO;
import com.haraay.ywarchitects.dto.UserDTO;
import com.haraay.ywarchitects.dto.UserLiteDTO;
import com.haraay.ywarchitects.model.Project;
import com.haraay.ywarchitects.model.User;

@Component
public class UserMapper {

	public UserLiteDTO toLiteDTO(User user) {
		if (user == null)
			return null;

		UserLiteDTO dto = new UserLiteDTO();
		dto.setId(user.getId());
		dto.setProfileImage(user.getProfileImage());
		dto.setFullName(user.getFirstName() + " " + user.getLastName());

		return dto;
	}

	public UserDTO toDTO(User user) {
		if (user == null)
			return null;

		UserDTO dto = new UserDTO();

		dto.setId(user.getId());
		dto.setProfileImage(user.getProfileImage());
		dto.setFirstName(user.getFirstName());
		dto.setSecondName(user.getSecondName());
		dto.setLastName(user.getLastName());
		dto.setEmail(user.getEmail());
		dto.setPhone(user.getPhone());
		dto.setStatus(user.getStatus());
		dto.setRole(user.getRole());
		dto.setBirthDate(user.getBirthDate());
		dto.setGender(user.getGender());
		dto.setBloodGroup(user.getBloodGroup());
		dto.setJoinDate(user.getJoinDate());
		dto.setLeaveDate(user.getLeaveDate());
		dto.setAdharNumber(user.getAdharNumber());
		dto.setPanNumber(user.getPanNumber());

		if (user.getProjects() != null) {
			List<ProjectLiteDTO> projectDTOs = new ArrayList<>();
			for (Project project : user.getProjects()) {
				projectDTOs.add(toProjectLiteDTO(project));
			}
			dto.setProjects(projectDTOs);
		}

		return dto;
	}

	// ─── DTO → Entity ────────────────────────────────────────────────────────────

	public User toEntity(UserDTO dto) {
		if (dto == null)
			return null;

		User user = new User();

		user.setId(dto.getId());
		user.setProfileImage(dto.getProfileImage());
		user.setFirstName(dto.getFirstName());
		user.setSecondName(dto.getSecondName());
		user.setLastName(dto.getLastName());
		user.setEmail(dto.getEmail());
		user.setPhone(dto.getPhone());
		user.setStatus(dto.getStatus());
		user.setRole(dto.getRole());
		user.setBirthDate(dto.getBirthDate());
		user.setGender(dto.getGender());
		user.setBloodGroup(dto.getBloodGroup());
		user.setJoinDate(dto.getJoinDate());
		user.setLeaveDate(dto.getLeaveDate());
		user.setAdharNumber(dto.getAdharNumber());
		user.setPanNumber(dto.getPanNumber());

		// Note: projects are not mapped back to avoid unintended cascade operations.
		// Manage project associations explicitly via the service layer.

		return user;
	}

	// ─── List mappers
	// ─────────────────────────────────────────────────────────────

	public List<UserDTO> toDTOList(List<User> users) {
		if (users == null)
			return new ArrayList<>();
		List<UserDTO> dtos = new ArrayList<>();
		for (User user : users) {
			dtos.add(this.toDTO(user));
		}
		return dtos;
	}

	public List<User> toEntityList(List<UserDTO> dtos) {
		if (dtos == null)
			return new ArrayList<>();
		List<User> users = new ArrayList<>();
		for (UserDTO dto : dtos) {
			users.add(this.toEntity(dto));
		}
		return users;
	}

	// ─── Project → ProjectLiteDTO
	// ─────────────────────────────────────────────────

	private ProjectLiteDTO toProjectLiteDTO(Project project) {
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

	public List<UserDTO> toUserDTOList(List<User> users) {

		if (users == null || users.isEmpty()) {
			return null;
		}

		return users.stream().map(this::toDTO).collect(Collectors.toList());

	}
}

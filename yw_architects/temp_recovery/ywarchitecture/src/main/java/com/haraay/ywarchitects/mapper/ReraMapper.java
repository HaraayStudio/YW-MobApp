package com.haraay.ywarchitects.mapper;

import com.haraay.ywarchitects.dto.ProjectLiteDTO;
import com.haraay.ywarchitects.dto.ReraProjectDTO;
import com.haraay.ywarchitects.dto.ReraProjectDTO.*;
import com.haraay.ywarchitects.model.*;
import org.springframework.stereotype.Component;

import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

@Component
public class ReraMapper {

    // ── ReraProject → ReraProjectDTO ─────────────────────────────
    public ReraProjectDTO toDTO(ReraProject reraProject) {
        if (reraProject == null) return null;

        ReraProjectDTO dto = new ReraProjectDTO();
        dto.setId(reraProject.getId());
        dto.setReraNumber(reraProject.getReraNumber());
        dto.setRegistrationDate(reraProject.getRegistrationDate());
        dto.setExpectedCompletionDate(reraProject.getExpectedCompletionDate());
        dto.setActive(reraProject.getActive());
        dto.setCreatedAt(reraProject.getCreatedAt());
        dto.setUpdatedAt(reraProject.getUpdatedAt());

        // Map project summary
        if (reraProject.getProject() != null) {
            dto.setProject(toProjectLiteDTO(reraProject.getProject()));
        }

        // Map certificates
        if (reraProject.getCertificates() != null) {
            dto.setCertificates(reraProject.getCertificates()
                    .stream()
                    .map(this::toCertificateDTO)
                    .collect(Collectors.toList()));
        } else {
            dto.setCertificates(Collections.emptyList());
        }

        // Map quarter updates
        if (reraProject.getQuarterUpdates() != null) {
            dto.setQuarterUpdates(reraProject.getQuarterUpdates()
                    .stream()
                    .map(this::toQuarterUpdateDTO)
                    .collect(Collectors.toList()));
        } else {
            dto.setQuarterUpdates(Collections.emptyList());
        }

        return dto;
    }

    // ── Project → ReraProjectLiteDTO ──────────────────────────
    public ProjectLiteDTO toProjectLiteDTO(Project project) {
	    if (project == null) return null;

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

    // ── ReraCertificate → ReraCertificateDTO ─────────────────────
    public ReraCertificateDTO toCertificateDTO(ReraCertificate certificate) {
        if (certificate == null) return null;

        ReraCertificateDTO dto = new ReraCertificateDTO();
        dto.setId(certificate.getId());
      
        dto.setCertificateDate(certificate.getCertificateDate());
        dto.setRemarks(certificate.getRemarks());
        dto.setCertificateFileUrl(certificate.getCertificateFileUrl());
        dto.setCertifiedBy(certificate.getCertifiedBy());
        dto.setCreatedAt(certificate.getCreatedAt());

       
        return dto;
    }

   

    // ── ReraQuarterUpdate → ReraQuarterUpdateDTO ─────────────────
    public ReraQuarterUpdateDTO toQuarterUpdateDTO(ReraQuarterUpdate update) {
        if (update == null) return null;

        ReraQuarterUpdateDTO dto = new ReraQuarterUpdateDTO();
        dto.setId(update.getId());
        dto.setConstructionStatus(update.getConstructionStatus());
        dto.setSalesStatus(update.getSalesStatus());
        dto.setQuarterDate(update.getQuarterDate());
        dto.setCreatedAt(update.getCreatedAt());
        return dto;
    }

    // ── List mapper ───────────────────────────────────────────────
    public List<ReraProjectDTO> toDTOList(List<ReraProject> reraProjects) {
        if (reraProjects == null) return Collections.emptyList();
        return reraProjects.stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }
}
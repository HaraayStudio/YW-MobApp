package com.haraay.ywarchitects.website.mapper;

import com.haraay.ywarchitects.website.dto.GalleryImageDTO;
import com.haraay.ywarchitects.website.dto.ProjectSizeDTO;
import com.haraay.ywarchitects.website.dto.WebProjectDTO;
import com.haraay.ywarchitects.website.dto.WebProjectSummaryDTO;
import com.haraay.ywarchitects.website.model.GalleryImage;
import com.haraay.ywarchitects.website.model.WebProject;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Component
public class WebProjectMapper {

    // =========================================================================
    // DTO  →  Entity
    // =========================================================================

    /**
     * Maps a {@link WebProjectDTO} onto an existing (or new) {@link WebProject} entity.
     * Image URL fields (hero, full, left, right) and gallery are intentionally
     * NOT mapped here — those come from S3 uploads and are set by the controller.
     *
     * @param dto    source DTO
     * @param entity target entity (pass {@code new WebProject()} for create,
     *               or the fetched entity for update)
     */
    public void toEntity(WebProjectDTO dto, WebProject entity) {

        entity.setSrNo(dto.getSrNo());
        entity.setSlug(dto.getSlug());
        entity.setTitle(dto.getTitle());
        entity.setCategory(dto.getCategory());
        entity.setStatus(dto.getStatus());
        entity.setProjectType(dto.getProjectType());
        entity.setLocation(dto.getLocation());
        entity.setScopeOfWork(dto.getScopeOfWork());
        entity.setClient(dto.getClient());

        entity.setDescription(
                dto.getDescription() != null ? dto.getDescription() : new ArrayList<>());
        entity.setServicesProvided(
                dto.getServicesProvided() != null ? dto.getServicesProvided() : new ArrayList<>());

        // Size
        if (dto.getSize() != null) {
            WebProject.ProjectSize size = new WebProject.ProjectSize(
                    dto.getSize().getPlotArea(),
                    dto.getSize().getBuiltUpArea(),
                    dto.getSize().getTowerFloors(),
                    dto.getSize().getCommercialFloors()
            );
            entity.setSize(size);
        }
    }

    // =========================================================================
    // Entity  →  Full DTO
    // =========================================================================

    /**
     * Converts a {@link WebProject} entity to a full {@link WebProjectDTO}.
     * Used for create / update responses and the admin edit form.
     *
     * @param entity source entity
     * @return fully populated DTO
     */
    public WebProjectDTO toDTO(WebProject entity) {
        WebProjectDTO dto = new WebProjectDTO();

        dto.setId(entity.getId());
        dto.setSrNo(entity.getSrNo());
        dto.setSlug(entity.getSlug());
        dto.setTitle(entity.getTitle());
        dto.setCategory(entity.getCategory());

        // Images
        dto.setHero(entity.getHero());
        dto.setFull(entity.getFull());
        dto.setLeft(entity.getLeft());
        dto.setRight(entity.getRight());

        // Stats
        dto.setStatus(entity.getStatus());
        dto.setProjectType(entity.getProjectType());
        dto.setLocation(entity.getLocation());
        dto.setScopeOfWork(entity.getScopeOfWork());
        dto.setClient(entity.getClient());

        // Size
        if (entity.getSize() != null) {
            dto.setSize(new ProjectSizeDTO(
                    entity.getSize().getPlotArea(),
                    entity.getSize().getBuiltUpArea(),
                    entity.getSize().getTowerFloors(),
                    entity.getSize().getCommercialFloors()
            ));
        }

        // Content
        dto.setDescription(entity.getDescription());
        dto.setServicesProvided(entity.getServicesProvided());

        // Gallery
        if (entity.getGallery() != null) {
            List<GalleryImageDTO> galleryDTOs = entity.getGallery().stream()
                    .map(img -> new GalleryImageDTO(img.getId(), img.getSrNo(), img.getImageUrl()))
                    .collect(Collectors.toList());
            dto.setGallery(galleryDTOs);
        }

        // Timestamps
        dto.setCreatedAt(entity.getCreatedAt());
        dto.setUpdatedAt(entity.getUpdatedAt());

        return dto;
    }

    // =========================================================================
    // Entity  →  Summary DTO  (listing page — no heavy fields)
    // =========================================================================

    /**
     * Converts a {@link WebProject} to a lightweight {@link WebProjectSummaryDTO}.
     * Used for GET /api/projects — only loads what the listing card needs.
     *
     * @param entity source entity
     * @return summary DTO
     */
    public WebProjectSummaryDTO toSummaryDTO(WebProject entity) {
        return new WebProjectSummaryDTO(
                entity.getId(),
                entity.getSrNo(),
                entity.getSlug(),
                entity.getTitle(),
                entity.getCategory(),
                entity.getStatus(),
                entity.getLocation(),
                entity.getHero()
        );
    }

    // =========================================================================
    // Convenience: map a list of entities → list of summary DTOs
    // =========================================================================

    public List<WebProjectSummaryDTO> toSummaryDTOList(List<WebProject> entities) {
        return entities.stream()
                .map(this::toSummaryDTO)
                .collect(Collectors.toList());
    }
}
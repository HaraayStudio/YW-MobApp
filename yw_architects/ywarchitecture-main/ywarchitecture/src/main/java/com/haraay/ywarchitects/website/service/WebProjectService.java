package com.haraay.ywarchitects.website.service;

import com.haraay.ywarchitects.service.S3Service;
import com.haraay.ywarchitects.website.dto.GalleryImageDTO;
import com.haraay.ywarchitects.website.dto.ProjectSizeDTO;
import com.haraay.ywarchitects.website.dto.WebProjectDTO;
import com.haraay.ywarchitects.website.dto.WebProjectSummaryDTO;
import com.haraay.ywarchitects.website.model.GalleryImage;
import com.haraay.ywarchitects.website.model.WebProject;
import com.haraay.ywarchitects.website.repository.WebProjectRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@Transactional
public class WebProjectService {

    private final WebProjectRepository webProjectRepository;
    private final S3Service            s3Service;

    public WebProjectService(WebProjectRepository webProjectRepository, S3Service s3Service) {
        this.webProjectRepository = webProjectRepository;
        this.s3Service            = s3Service;
    }

    // =========================================================================
    // PUBLIC — Website
    // =========================================================================

    @Transactional(readOnly = true)
    public List<WebProjectSummaryDTO> getAllProjects() {
        return webProjectRepository.findAllByOrderBySrNoAsc()
                .stream()
                .map(this::toSummaryDTO)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public WebProjectDTO getProjectBySlug(String slug) {
        WebProject project = webProjectRepository.findBySlug(slug)
                .orElseThrow(() -> new RuntimeException("Project not found with slug: " + slug));
        return toDTO(project);
    }

    // =========================================================================
    // ADMIN — Read
    // =========================================================================

    @Transactional(readOnly = true)
    public WebProjectDTO getProjectById(Long id) {
        return toDTO(findById(id));
    }

    // =========================================================================
    // ADMIN — Create
    // =========================================================================

    /**
     * Creates a new project.
     * All 4 named images are required. Gallery images are optional.
     */
    public WebProjectDTO createProject(
            WebProjectDTO dto,
            MultipartFile heroImage,
            MultipartFile fullImage,
            MultipartFile leftImage,
            MultipartFile rightImage,
            List<MultipartFile> galleryImages
    ) {
        // Slug uniqueness check
        if (webProjectRepository.existsBySlug(dto.getSlug())) {
            throw new RuntimeException("Slug already exists: " + dto.getSlug());
        }

        WebProject project = new WebProject();

        // Map all scalar + size fields from DTO
        mapDtoToEntity(dto, project);

        // Upload named images → set URLs
        // ✅ 4. Upload Images (S3)
        if (heroImage != null && !heroImage.isEmpty()) {
            String heroUrl = s3Service.uploadWebsiteImage(heroImage);
            project.setHero(heroUrl);
        }
        if (fullImage != null && !fullImage.isEmpty()) {
            String fullUrl = s3Service.uploadWebsiteImage(fullImage);
            project.setFull(fullUrl);
        }

        if (leftImage != null && !leftImage.isEmpty()) {
            String leftUrl = s3Service.uploadWebsiteImage(leftImage);
            project.setLeft(leftUrl);
        }

        if (rightImage != null && !rightImage.isEmpty()) {
            String rightUrl = s3Service.uploadWebsiteImage(rightImage);
            project.setRight(rightUrl);
        }

        // Upload gallery images
        if (galleryImages != null && !galleryImages.isEmpty()) {
            long srNo = 1;
            for (MultipartFile file : galleryImages) {
                if (file != null && !file.isEmpty()) {
                    GalleryImage image = new GalleryImage();
                    image.setSrNo(srNo++);
                    image.setImageUrl(s3Service.uploadWebsiteImage(file));
                    project.addGalleryImage(image);
                }
            }
        }

        return toDTO(webProjectRepository.save(project));
    }

    // =========================================================================
    // ADMIN — Granular Update methods
    // Each method is surgical — touches ONLY its own field(s).
    // =========================================================================

    // ─────────────────────────────────────────────────────────────────────────
    // 1. Update text + stats fields only  (zero S3 calls)
    //    Touches: slug, title, category, status, projectType, location,
    //             scopeOfWork, client, size, description, servicesProvided, srNo
    // ─────────────────────────────────────────────────────────────────────────
    public WebProjectDTO updateDetails(Long id, WebProjectDTO dto) {
        WebProject project = findById(id);

        if (webProjectRepository.existsBySlugAndIdNot(dto.getSlug(), id)) {
            throw new RuntimeException("Slug already in use: " + dto.getSlug());
        }

        mapDtoToEntity(dto, project);   // images are NOT mapped inside — safe
        return toDTO(webProjectRepository.save(project));
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 2. Update Hero image only
    //    Deletes old S3 object → uploads new → saves new URL
    //    Returns: { "hero": "<new url>" }
    // ─────────────────────────────────────────────────────────────────────────
    public Map<String, String> updateHeroImage(Long id, MultipartFile heroImage) {
        WebProject project = findById(id);

        if (project.getHero() != null && !project.getHero().isEmpty()) s3Service.deleteFileByUrl(project.getHero());
        String newUrl = s3Service.uploadWebsiteImage(heroImage);
        project.setHero(newUrl);

        webProjectRepository.save(project);
        return Map.of("hero", newUrl);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 3. Update Full-width image only
    // ─────────────────────────────────────────────────────────────────────────
    public Map<String, String> updateFullImage(Long id, MultipartFile fullImage) {
        WebProject project = findById(id);

        if (project.getFull() != null && !project.getFull().isEmpty()) s3Service.deleteFileByUrl(project.getFull());
        String newUrl = s3Service.uploadWebsiteImage(fullImage);
        project.setFull(newUrl);

        webProjectRepository.save(project);
        return Map.of("full", newUrl);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 4. Update Left panel image only
    // ─────────────────────────────────────────────────────────────────────────
    public Map<String, String> updateLeftImage(Long id, MultipartFile leftImage) {
        WebProject project = findById(id);

        if (project.getLeft() != null && !project.getLeft().isEmpty()) s3Service.deleteFileByUrl(project.getLeft());
        String newUrl = s3Service.uploadWebsiteImage(leftImage);
        project.setLeft(newUrl);

        webProjectRepository.save(project);
        return Map.of("left", newUrl);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 5. Update Right panel image only
    // ─────────────────────────────────────────────────────────────────────────
    public Map<String, String> updateRightImage(Long id, MultipartFile rightImage) {
        WebProject project = findById(id);

        if (project.getRight() != null && !project.getRight().isEmpty()) s3Service.deleteFileByUrl(project.getRight());
        String newUrl = s3Service.uploadWebsiteImage(rightImage);
        project.setRight(newUrl);

        webProjectRepository.save(project);
        return Map.of("right", newUrl);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 6. Add images to gallery  (appends — existing images are untouched)
    //    srNo continues from current max so order stays consistent
    // ─────────────────────────────────────────────────────────────────────────
    public WebProjectDTO addGalleryImages(Long id, List<MultipartFile> galleryImages) {
        WebProject project = findById(id);

        long nextSrNo = project.getGallery().stream()
                .mapToLong(GalleryImage::getSrNo)
                .max()
                .orElse(0L) + 1;

        for (MultipartFile file : galleryImages) {
            if (file != null && !file.isEmpty()) {
                GalleryImage image = new GalleryImage();
                image.setSrNo(nextSrNo++);
                image.setImageUrl(s3Service.uploadWebsiteImage(file));
                project.addGalleryImage(image);
            }
        }

        return toDTO(webProjectRepository.save(project));
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 7. Delete a single gallery image by its own id
    //    Deletes S3 object + removes entity (orphanRemoval handles DB row)
    // ─────────────────────────────────────────────────────────────────────────
    public void deleteGalleryImage(Long projectId, Long imageId) {
        WebProject project = findById(projectId);

        GalleryImage target = project.getGallery().stream()
                .filter(img -> img.getId().equals(imageId))
                .findFirst()
                .orElseThrow(() -> new RuntimeException("Gallery image not found: " + imageId));

        if (target.getImageUrl() != null) s3Service.deleteFileByUrl(target.getImageUrl());

        project.removeGalleryImage(target);  // orphanRemoval removes DB row on save
        webProjectRepository.save(project);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 8. Replace entire gallery  (delete all old → upload fresh set)
    // ─────────────────────────────────────────────────────────────────────────
    public WebProjectDTO replaceGallery(Long id, List<MultipartFile> galleryImages) {
        WebProject project = findById(id);

        // Delete all old S3 objects
        for (GalleryImage old : project.getGallery()) {
            if (old.getImageUrl() != null) s3Service.deleteFileByUrl(old.getImageUrl());
        }
        project.getGallery().clear();  // orphanRemoval removes DB rows on save

        // Upload and rebuild
        long srNo = 1;
        for (MultipartFile file : galleryImages) {
            if (file != null && !file.isEmpty()) {
                GalleryImage image = new GalleryImage();
                image.setSrNo(srNo++);
                image.setImageUrl(s3Service.uploadWebsiteImage(file));
                project.addGalleryImage(image);
            }
        }

        return toDTO(webProjectRepository.save(project));
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 9. Reorder gallery images  (zero S3 calls — only srNo values updated)
    //    Body: [ { "id": 3, "srNo": 1 }, { "id": 7, "srNo": 2 }, ... ]
    // ─────────────────────────────────────────────────────────────────────────
    public WebProjectDTO reorderGallery(Long id, List<Map<String, Long>> order) {
        WebProject project = findById(id);

        for (Map<String, Long> entry : order) {
            Long imageId = entry.get("id");
            Long newSrNo = entry.get("srNo");
            project.getGallery().stream()
                    .filter(img -> img.getId().equals(imageId))
                    .findFirst()
                    .ifPresent(img -> img.setSrNo(newSrNo));
        }

        return toDTO(webProjectRepository.save(project));
    }

    // =========================================================================
    // ADMIN — Delete entire project
    // =========================================================================

    /**
     * Deletes the project record AND all associated S3 objects.
     */
    public void deleteProject(Long id) {
        WebProject project = findById(id);

        // Delete named images from S3
        if (project.getHero()  != null) s3Service.deleteFileByUrl(project.getHero());
        if (project.getFull()  != null) s3Service.deleteFileByUrl(project.getFull());
        if (project.getLeft()  != null) s3Service.deleteFileByUrl(project.getLeft());
        if (project.getRight() != null) s3Service.deleteFileByUrl(project.getRight());

        // Delete gallery images from S3
        for (GalleryImage img : project.getGallery()) {
            if (img.getImageUrl() != null) s3Service.deleteFileByUrl(img.getImageUrl());
        }

        // CascadeType.ALL + orphanRemoval handles all child DB rows automatically
        webProjectRepository.delete(project);
    }

    // =========================================================================
    // Private Helpers
    // =========================================================================

    private WebProject findById(Long id) {
        return webProjectRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Project not found with id: " + id));
    }

    /**
     * Maps scalar + size fields from DTO → Entity.
     * Image fields (hero, full, left, right, gallery) are intentionally excluded
     * because those come from S3 uploads and are set separately.
     */
    private void mapDtoToEntity(WebProjectDTO dto, WebProject entity) {
        entity.setSrNo(dto.getSrNo());
        entity.setSlug(dto.getSlug());
        entity.setTitle(dto.getTitle());
        entity.setCategory(dto.getCategory());
        entity.setStatus(dto.getStatus());
        entity.setProjectType(dto.getProjectType());
        entity.setLocation(dto.getLocation());
        entity.setScopeOfWork(dto.getScopeOfWork());
        entity.setClient(dto.getClient());
        entity.setDescription(dto.getDescription()      != null ? dto.getDescription()      : new ArrayList<>());
        entity.setServicesProvided(dto.getServicesProvided() != null ? dto.getServicesProvided() : new ArrayList<>());

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

    /** Full DTO — used for detail page, admin form, and all mutation responses. */
    private WebProjectDTO toDTO(WebProject entity) {
        WebProjectDTO dto = new WebProjectDTO();
        dto.setId(entity.getId());
        dto.setSrNo(entity.getSrNo());
        dto.setSlug(entity.getSlug());
        dto.setTitle(entity.getTitle());
        dto.setCategory(entity.getCategory());
        dto.setHero(entity.getHero());
        dto.setFull(entity.getFull());
        dto.setLeft(entity.getLeft());
        dto.setRight(entity.getRight());
        dto.setStatus(entity.getStatus());
        dto.setProjectType(entity.getProjectType());
        dto.setLocation(entity.getLocation());
        dto.setScopeOfWork(entity.getScopeOfWork());
        dto.setClient(entity.getClient());
        dto.setDescription(entity.getDescription());
        dto.setServicesProvided(entity.getServicesProvided());
        dto.setCreatedAt(entity.getCreatedAt());
        dto.setUpdatedAt(entity.getUpdatedAt());

        if (entity.getSize() != null) {
            dto.setSize(new ProjectSizeDTO(
                    entity.getSize().getPlotArea(),
                    entity.getSize().getBuiltUpArea(),
                    entity.getSize().getTowerFloors(),
                    entity.getSize().getCommercialFloors()
            ));
        }

        if (entity.getGallery() != null) {
            List<GalleryImageDTO> galleryDTOs = entity.getGallery().stream()
                    .map(img -> new GalleryImageDTO(img.getId(), img.getSrNo(), img.getImageUrl()))
                    .collect(Collectors.toList());
            dto.setGallery(galleryDTOs);
        }

        return dto;
    }

    /** Lightweight summary DTO — used for the public listing page. */
    private WebProjectSummaryDTO toSummaryDTO(WebProject entity) {
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
}
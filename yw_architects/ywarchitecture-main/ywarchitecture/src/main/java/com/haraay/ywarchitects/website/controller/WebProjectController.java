package com.haraay.ywarchitects.website.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.haraay.ywarchitects.website.dto.WebProjectDTO;
import com.haraay.ywarchitects.website.dto.WebProjectSummaryDTO;
import com.haraay.ywarchitects.website.service.WebProjectService;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/website")
public class WebProjectController {

	private final WebProjectService webProjectService;
	private final ObjectMapper objectMapper;

	public WebProjectController(WebProjectService webProjectService, ObjectMapper objectMapper) {
		this.webProjectService = webProjectService;
		this.objectMapper = objectMapper;
	}

	// =========================================================================
	// PUBLIC — Website
	// =========================================================================

	@GetMapping("/projects")
	public ResponseEntity<List<WebProjectSummaryDTO>> getAllProjects() {
		return ResponseEntity.ok(webProjectService.getAllProjects());
	}

	@GetMapping("/projects/{slug}")
	public ResponseEntity<WebProjectDTO> getProjectBySlug(@PathVariable String slug) {
		return ResponseEntity.ok(webProjectService.getProjectBySlug(slug));
	}

	// =========================================================================
	// ADMIN — Read
	// =========================================================================

	@GetMapping("/getprojectbyid/{id}")
	public ResponseEntity<WebProjectDTO> getProjectById(@PathVariable Long id) {
		return ResponseEntity.ok(webProjectService.getProjectById(id));
	}

	// =========================================================================
	// ADMIN — Create
	// =========================================================================

	@PostMapping(value = "/webprojects/createproject", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
	public ResponseEntity<WebProjectDTO> createProject(@RequestPart("projectData") String projectDataJson,
			@RequestPart(value = "heroImage", required = false) MultipartFile heroImage,
			@RequestPart(value = "fullImage", required = false) MultipartFile fullImage,
			@RequestPart(value = "leftImage", required = false) MultipartFile leftImage,
			@RequestPart(value = "rightImage", required = false) MultipartFile rightImage,
			@RequestPart(value = "galleryImages", required = false) List<MultipartFile> galleryImages)
			throws Exception {
		WebProjectDTO dto = objectMapper.readValue(projectDataJson, WebProjectDTO.class);
		WebProjectDTO created = webProjectService.createProject(dto, heroImage, fullImage, leftImage, rightImage,
				galleryImages);
		return ResponseEntity.status(HttpStatus.CREATED).body(created);
	}

	// =========================================================================
	// ADMIN — Granular Updates
	// =========================================================================

	@PatchMapping(value = "/webprojects/{id}/details", consumes = MediaType.APPLICATION_JSON_VALUE)
	public ResponseEntity<WebProjectDTO> updateDetails(@PathVariable Long id, @RequestBody WebProjectDTO dto) {
		return ResponseEntity.ok(webProjectService.updateDetails(id, dto));
	}

	@PatchMapping(value = "/webprojects/{id}/hero", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
	public ResponseEntity<Map<String, String>> updateHeroImage(@PathVariable Long id,
			@RequestPart("heroImage") MultipartFile heroImage) {
		return ResponseEntity.ok(webProjectService.updateHeroImage(id, heroImage));
	}

	@PatchMapping(value = "/webprojects/{id}/full", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
	public ResponseEntity<Map<String, String>> updateFullImage(@PathVariable Long id,
			@RequestPart("fullImage") MultipartFile fullImage) {
		return ResponseEntity.ok(webProjectService.updateFullImage(id, fullImage));
	}

	@PatchMapping(value = "/webprojects/{id}/left", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
	public ResponseEntity<Map<String, String>> updateLeftImage(@PathVariable Long id,
			@RequestPart("leftImage") MultipartFile leftImage) {
		return ResponseEntity.ok(webProjectService.updateLeftImage(id, leftImage));
	}

	@PatchMapping(value = "/webprojects/{id}/right", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
	public ResponseEntity<Map<String, String>> updateRightImage(@PathVariable Long id,
			@RequestPart("rightImage") MultipartFile rightImage) {
		return ResponseEntity.ok(webProjectService.updateRightImage(id, rightImage));
	}

	@PatchMapping(value = "/webprojects/{id}/gallery/add", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
	public ResponseEntity<WebProjectDTO> addGalleryImages(@PathVariable Long id,
			@RequestPart("galleryImages") List<MultipartFile> galleryImages) {
		return ResponseEntity.ok(webProjectService.addGalleryImages(id, galleryImages));
	}

	@DeleteMapping("/webprojects/{id}/gallery/{imageId}")
	public ResponseEntity<Void> deleteGalleryImage(@PathVariable Long id, @PathVariable Long imageId) {
		webProjectService.deleteGalleryImage(id, imageId);
		return ResponseEntity.noContent().build();
	}

	@PatchMapping(value = "/webprojects/{id}/gallery/replace", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
	public ResponseEntity<WebProjectDTO> replaceGallery(@PathVariable Long id,
			@RequestPart("galleryImages") List<MultipartFile> galleryImages) {
		return ResponseEntity.ok(webProjectService.replaceGallery(id, galleryImages));
	}

	@PatchMapping(value = "/webprojects/{id}/gallery/reorder", consumes = MediaType.APPLICATION_JSON_VALUE)
	public ResponseEntity<WebProjectDTO> reorderGallery(@PathVariable Long id,
			@RequestBody List<Map<String, Long>> order) {
		return ResponseEntity.ok(webProjectService.reorderGallery(id, order));
	}

	// =========================================================================
	// ADMIN — Delete
	// =========================================================================

	@DeleteMapping("/webprojects/deleteproject/{id}")
	public ResponseEntity<Void> deleteProject(@PathVariable Long id) {
		webProjectService.deleteProject(id);
		return ResponseEntity.noContent().build();
	}
}
// SiteVisitController.java
package com.haraay.ywarchitects.controller;

import com.haraay.ywarchitects.service.SiteVisitService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@RestController
@RequestMapping("/api/site-visits")
public class SiteVisitController {

	@Autowired
	private SiteVisitService siteVisitService;

	// ─────────────────────────────────────────────
	// CREATE
	// ─────────────────────────────────────────────
	@PostMapping(consumes = "multipart/form-data")
	public ResponseEntity<?> createSiteVisit(@RequestParam Long projectId, @RequestParam String title,
			@RequestParam(required = false) String description, @RequestParam(required = false) String locationNote,
			@RequestParam(required = false) String visitDateTime,
			@RequestParam(required = false) List<MultipartFile> photos,
			@RequestParam(required = false) List<String> photoCaptions,
			@RequestParam(required = false) List<MultipartFile> documents,
			@RequestParam(required = false) List<String> documentNames,
			@AuthenticationPrincipal UserDetails userDetails) {
		try {
			return siteVisitService.createSiteVisit(projectId, title, description, locationNote, visitDateTime, photos,
					photoCaptions, documents, documentNames, userDetails.getUsername());

		} catch (IllegalArgumentException e) {
			return ResponseEntity.badRequest().body(e.getMessage());
		} catch (Exception e) {
			return ResponseEntity.internalServerError().body("Something went wrong: " + e.getMessage());
		}
	}

	// ─────────────────────────────────────────────
	// GET ALL BY PROJECT
	// ─────────────────────────────────────────────
	@GetMapping("/project/{projectId}")
	public ResponseEntity<?> getVisitsByProject(@PathVariable Long projectId) {
		try {
			return siteVisitService.getVisitsByProject(projectId);
		} catch (IllegalArgumentException e) {
			return ResponseEntity.badRequest().body(e.getMessage());
		}
	}

	// ─────────────────────────────────────────────
	// GET BY ID
	// ─────────────────────────────────────────────
	@GetMapping("/{id}")
	public ResponseEntity<?> getVisitById(@PathVariable Long id) {
		try {
			return ResponseEntity.ok(siteVisitService.getVisitById(id));
		} catch (IllegalArgumentException e) {
			return ResponseEntity.notFound().build();
		}
	}

	// ─────────────────────────────────────────────
	// DELETE
	// ─────────────────────────────────────────────
	@DeleteMapping("/{id}")
	public ResponseEntity<?> deleteVisit(@PathVariable Long id) {
		try {
			return siteVisitService.deleteVisit(id);

		} catch (IllegalArgumentException e) {
			return ResponseEntity.notFound().build();
		} catch (Exception e) {
			return ResponseEntity.internalServerError().body("Failed to delete: " + e.getMessage());
		}
	}

	// ─────────────────────────────────────────────
	// UPDATE (title, description, visitDateTime, locationNote only)
	// ─────────────────────────────────────────────
	@PutMapping("/{id}")
	public ResponseEntity<?> updateSiteVisit(@PathVariable Long id, @RequestParam(required = false) String title,
			@RequestParam(required = false) String description, @RequestParam(required = false) String visitDateTime,
			@RequestParam(required = false) String locationNote) {
		try {
			return siteVisitService.updateSiteVisit(id, title, description, visitDateTime, locationNote);
		} catch (IllegalArgumentException e) {
			return ResponseEntity.badRequest().body(e.getMessage());
		} catch (Exception e) {
			return ResponseEntity.internalServerError().body("Something went wrong: " + e.getMessage());
		}
	}

	// ─────────────────────────────────────────────
	// ADD PHOTOS to existing site visit
	// ─────────────────────────────────────────────
	@PostMapping(value = "/{id}/photos", consumes = "multipart/form-data")
	public ResponseEntity<?> addPhotos(@PathVariable Long id, @RequestParam List<MultipartFile> photos,
			@RequestParam(required = false) List<String> photoCaptions) {
		try {
			return siteVisitService.addPhotos(id, photos, photoCaptions);
		} catch (IllegalArgumentException e) {
			return ResponseEntity.badRequest().body(e.getMessage());
		} catch (Exception e) {
			return ResponseEntity.internalServerError().body("Failed to upload photos: " + e.getMessage());
		}
	}

	// ─────────────────────────────────────────────
	// ADD DOCUMENTS to existing site visit
	// ─────────────────────────────────────────────
	@PostMapping(value = "/{id}/documents", consumes = "multipart/form-data")
	public ResponseEntity<?> addDocuments(@PathVariable Long id, @RequestParam List<MultipartFile> documents,
			@RequestParam(required = false) List<String> documentNames) {
		try {
			return siteVisitService.addDocuments(id, documents, documentNames);
		} catch (IllegalArgumentException e) {
			return ResponseEntity.badRequest().body(e.getMessage());
		} catch (Exception e) {
			return ResponseEntity.internalServerError().body("Failed to upload documents: " + e.getMessage());
		}
	}

	// DELETE a single photo by photoId
	@DeleteMapping("/{visitId}/photos/{photoId}")
	public ResponseEntity<?> deletePhoto(@PathVariable Long visitId, @PathVariable Long photoId) {
		try {
			return siteVisitService.deletePhoto(visitId, photoId);
		} catch (IllegalArgumentException e) {
			return ResponseEntity.badRequest().body(e.getMessage());
		} catch (Exception e) {
			return ResponseEntity.internalServerError().body("Failed to delete photo: " + e.getMessage());
		}
	}

	// DELETE a single document by documentId
	@DeleteMapping("/{visitId}/documents/{documentId}")
	public ResponseEntity<?> deleteDocument(@PathVariable Long visitId, @PathVariable Long documentId) {
		try {
			return siteVisitService.deleteDocument(visitId, documentId);
		} catch (IllegalArgumentException e) {
			return ResponseEntity.badRequest().body(e.getMessage());
		} catch (Exception e) {
			return ResponseEntity.internalServerError().body("Failed to delete document: " + e.getMessage());
		}
	}

}
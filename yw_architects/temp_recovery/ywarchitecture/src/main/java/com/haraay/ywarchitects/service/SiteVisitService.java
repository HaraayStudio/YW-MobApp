// SiteVisitService.java
package com.haraay.ywarchitects.service;

import com.haraay.ywarchitects.dto.SiteVisitDTO;
import com.haraay.ywarchitects.dto.SuccessDTO;
import com.haraay.ywarchitects.mapper.SiteVisitMapper;
import com.haraay.ywarchitects.model.*;
import com.haraay.ywarchitects.repository.*;
import com.haraay.ywarchitects.util.ResponseStructure;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class SiteVisitService {

	@Autowired
	private SiteVisitRepository siteVisitRepository;

	@Autowired
	private ProjectRepository projectRepository;

	@Autowired
	private UserRepository userRepository;
	
	@Autowired
	private SiteVisitPhotoRepository siteVisitPhotoRepository;

	@Autowired
	private SiteVisitDocumentRepository siteVisitDocumentRepository;

	@Autowired
	private SiteVisitMapper siteVisitMapper;

	@Autowired
	private S3Service s3Service;

	@Autowired
	private ResponseStructure<SiteVisitDTO> siteVisitDTOStructure;

	@Autowired
	private ResponseStructure<List<SiteVisitDTO>> siteVisitDTOListStructure;

	@Autowired
	private ResponseStructure<SuccessDTO> successDTOStructure;

	// ─────────────────────────────────────────────
	// CREATE
	// ─────────────────────────────────────────────
	@Transactional
	public ResponseEntity<ResponseStructure<SiteVisitDTO>> createSiteVisit(Long projectId, String title,
			String description, String locationNote, String visitDateTime, List<MultipartFile> photos,
			List<String> photoCaptions, List<MultipartFile> documents, List<String> documentNames, String userEmail) {
		// 1. Validate project ID
		if (projectId == null) {
			throw new IllegalArgumentException("Project ID is required.");
		}

		// 2. Check project exists
		Project project = projectRepository.findById(projectId)
				.orElseThrow(() -> new IllegalArgumentException("Project not found with ID: " + projectId));

		// 3. Resolve authenticated user
		User createdBy = userRepository.findByEmail(userEmail)
				.orElseThrow(() -> new IllegalArgumentException("User not found with email: " + userEmail));

		// 4. Build SiteVisit
		SiteVisit siteVisit = new SiteVisit();
		siteVisit.setTitle(title);
		siteVisit.setDescription(description);
		siteVisit.setLocationNote(locationNote);
		siteVisit.setProject(project);
		siteVisit.setCreatedBy(createdBy);
		siteVisit.setVisitDateTime(visitDateTime != null ? LocalDateTime.parse(visitDateTime) : LocalDateTime.now());

		// 5. Handle Photos
		if (photos != null && !photos.isEmpty()) {
			for (int i = 0; i < photos.size(); i++) {
				MultipartFile photoFile = photos.get(i);
				if (photoFile != null && !photoFile.isEmpty()) {
					String url = s3Service.uploadFile(photoFile);

					SiteVisitPhoto photo = new SiteVisitPhoto();
					photo.setImageUrl(url);
					photo.setUploadedAt(LocalDateTime.now());

					if (photoCaptions != null && i < photoCaptions.size()) {
						photo.setCaption(photoCaptions.get(i));
					}

					siteVisit.addPhoto(photo);
				}
			}
		}

		// 6. Handle Documents
		if (documents != null && !documents.isEmpty()) {
			for (int i = 0; i < documents.size(); i++) {
				MultipartFile docFile = documents.get(i);
				if (docFile != null && !docFile.isEmpty()) {
					String url = s3Service.uploadFile(docFile);

					SiteVisitDocument doc = new SiteVisitDocument();
					doc.setDocumentUrl(url);
					doc.setUploadedAt(LocalDateTime.now());
					doc.setDocumentName((documentNames != null && i < documentNames.size()) ? documentNames.get(i)
							: docFile.getOriginalFilename());

					siteVisit.addDocument(doc);
				}
			}
		}

		SiteVisit savedSiteVisit = siteVisitRepository.save(siteVisit);

		siteVisitDTOStructure.setMessage("saved");
		siteVisitDTOStructure.setStatus(HttpStatus.CREATED.value());
		siteVisitDTOStructure.setData(siteVisitMapper.toDTO(savedSiteVisit));

		return new ResponseEntity<ResponseStructure<SiteVisitDTO>>(siteVisitDTOStructure, HttpStatus.CREATED);
	}

	// ─────────────────────────────────────────────
	// GET ALL BY PROJECT
	// ─────────────────────────────────────────────
	public ResponseEntity<ResponseStructure<List<SiteVisitDTO>>> getVisitsByProject(Long projectId) {
		Project project = projectRepository.findById(projectId)
				.orElseThrow(() -> new IllegalArgumentException("Project not found with ID: " + projectId));
		List<SiteVisit> siteVisits = siteVisitRepository.findByProject(project);

		siteVisitDTOListStructure.setMessage("FOUND");
		siteVisitDTOListStructure.setStatus(HttpStatus.FOUND.value());
		siteVisitDTOListStructure.setData(siteVisitMapper.toDTOList(siteVisits));

		return new ResponseEntity<ResponseStructure<List<SiteVisitDTO>>>(siteVisitDTOListStructure, HttpStatus.FOUND);

	}

	// ─────────────────────────────────────────────
	// GET BY ID
	// ─────────────────────────────────────────────
	public SiteVisit getVisitById(Long id) {
		return siteVisitRepository.findById(id)
				.orElseThrow(() -> new IllegalArgumentException("Site visit not found with ID: " + id));
	}

	// ─────────────────────────────────────────────
	// DELETE
	// ─────────────────────────────────────────────
	@Transactional
	public ResponseEntity<ResponseStructure<SuccessDTO>> deleteVisit(Long id) {
		SiteVisit visit = siteVisitRepository.findById(id)
				.orElseThrow(() -> new IllegalArgumentException("Site visit not found with ID: " + id));

		// Clean up S3 photos
		for (SiteVisitPhoto photo : visit.getPhotos()) {
			try {
				s3Service.deleteFileByUrl(photo.getImageUrl());
			} catch (Exception e) {
				System.err.println("Failed to delete photo from S3: " + photo.getImageUrl());
			}
		}

		// Clean up S3 documents
		for (SiteVisitDocument doc : visit.getDocuments()) {
			try {
				s3Service.deleteFileByUrl(doc.getDocumentUrl());
			} catch (Exception e) {
				System.err.println("Failed to delete document from S3: " + doc.getDocumentUrl());
			}
		}

		siteVisitRepository.delete(visit);

		successDTOStructure.setMessage("Site visit deleted successfully. ");
		successDTOStructure.setStatus(HttpStatus.OK.value());
		successDTOStructure.setData(new SuccessDTO("DELETED SITEVISIT WITH ID = " + id));

		return new ResponseEntity<ResponseStructure<SuccessDTO>>(successDTOStructure, HttpStatus.OK);

	}

	// Add these 3 methods to your existing SiteVisitService.java

	// ─────────────────────────────────────────────
	// UPDATE - title, description, visitDateTime, locationNote
	// ─────────────────────────────────────────────
	public ResponseEntity<?> updateSiteVisit(Long id, String title, String description, String visitDateTime,
			String locationNote) {

		// Check site visit exists
		SiteVisit siteVisit = siteVisitRepository.findById(id)
				.orElseThrow(() -> new IllegalArgumentException("Site visit not found with id: " + id));

		// Only update fields that are provided (not null)
		if (title != null && !title.isBlank()) {
			siteVisit.setTitle(title);
		}
		if (description != null && !description.isBlank()) {
			siteVisit.setDescription(description);
		}
		if (visitDateTime != null && !visitDateTime.isBlank()) {
			siteVisit.setVisitDateTime(LocalDateTime.parse(visitDateTime)); // format: "2026-03-09T10:30:00"
		}
		if (locationNote != null && !locationNote.isBlank()) {
			siteVisit.setLocationNote(locationNote);
		}

		SiteVisit updated = siteVisitRepository.save(siteVisit);

		ResponseStructure<SiteVisitDTO> response = new ResponseStructure<>();
		response.setStatus(HttpStatus.OK.value());
		response.setMessage("Site visit updated successfully");
		response.setData(siteVisitMapper.toDTO(updated));

		return ResponseEntity.ok(response);
	}

	// ─────────────────────────────────────────────
	// ADD PHOTOS to existing site visit
	// ─────────────────────────────────────────────
	public ResponseEntity<?> addPhotos(Long id, List<MultipartFile> photos, List<String> photoCaptions)
			throws Exception {

		// Check site visit exists
		SiteVisit siteVisit = siteVisitRepository.findById(id)
				.orElseThrow(() -> new IllegalArgumentException("Site visit not found with id: " + id));

		if (photos == null || photos.isEmpty()) {
			throw new IllegalArgumentException("No photos provided");
		}

		for (int i = 0; i < photos.size(); i++) {
			MultipartFile file = photos.get(i);
			String caption = (photoCaptions != null && i < photoCaptions.size()) ? photoCaptions.get(i) : null;

			// Upload to S3 (or your storage) and get URL
			String photoUrl = s3Service.uploadFile(file); // replace with your upload method

			SiteVisitPhoto photo = new SiteVisitPhoto();
			photo.setImageUrl(photoUrl);
			photo.setCaption(caption);
			photo.setUploadedAt(LocalDateTime.now());

			siteVisit.addPhoto(photo); // uses your helper method
		}

		SiteVisit updated = siteVisitRepository.save(siteVisit);

		ResponseStructure<SiteVisitDTO> response = new ResponseStructure<>();
		response.setStatus(HttpStatus.OK.value());
		response.setMessage(photos.size() + " photo(s) added successfully");
		response.setData(siteVisitMapper.toDTO(updated));

		return ResponseEntity.ok(response);
	}

	// ─────────────────────────────────────────────
	// ADD DOCUMENTS to existing site visit
	// ─────────────────────────────────────────────
	public ResponseEntity<?> addDocuments(Long id, List<MultipartFile> documents, List<String> documentNames)
			throws Exception {

		// Check site visit exists
		SiteVisit siteVisit = siteVisitRepository.findById(id)
				.orElseThrow(() -> new IllegalArgumentException("Site visit not found with id: " + id));

		if (documents == null || documents.isEmpty()) {
			throw new IllegalArgumentException("No documents provided");
		}

		for (int i = 0; i < documents.size(); i++) {
			MultipartFile file = documents.get(i);
			String docName = (documentNames != null && i < documentNames.size()) ? documentNames.get(i)
					: file.getOriginalFilename(); // fallback to original filename

			// Upload to S3 (or your storage) and get URL
			String docUrl = s3Service.uploadFile(file); // replace with your upload method

			SiteVisitDocument doc = new SiteVisitDocument();
			doc.setDocumentUrl(docUrl);
			doc.setDocumentName(docName);
			doc.setUploadedAt(LocalDateTime.now());

			siteVisit.addDocument(doc); // uses your helper method
		}

		SiteVisit updated = siteVisitRepository.save(siteVisit);

		ResponseStructure<SiteVisitDTO> response = new ResponseStructure<>();
		response.setStatus(HttpStatus.OK.value());
		response.setMessage(documents.size() + " document(s) added successfully");
		response.setData(siteVisitMapper.toDTO(updated));

		return ResponseEntity.ok(response);
	}

	// DELETE PHOTO
	public ResponseEntity<?> deletePhoto(Long visitId, Long photoId) {

		// Check site visit exists
		SiteVisit siteVisit = siteVisitRepository.findById(visitId)
				.orElseThrow(() -> new IllegalArgumentException("Site visit not found with id: " + visitId));

		// Check photo exists and belongs to this visit
		SiteVisitPhoto photo = siteVisitPhotoRepository.findById(photoId)
				.orElseThrow(() -> new IllegalArgumentException("Photo not found with id: " + photoId));

		if (!photo.getSiteVisit().getId().equals(visitId)) {
			throw new IllegalArgumentException("Photo does not belong to this site visit");
		}

		// Delete from S3 (or your storage)
		s3Service.deleteFileByUrl(photo.getImageUrl()); // replace with your delete method

		// Remove from visit and delete
		siteVisit.getPhotos().remove(photo);
		siteVisitPhotoRepository.delete(photo);

		ResponseStructure<String> response = new ResponseStructure<>();
		response.setStatus(HttpStatus.OK.value());
		response.setMessage("Photo deleted successfully");
		response.setData("Photo with id " + photoId + " deleted");

		return ResponseEntity.ok(response);
	}

	// DELETE DOCUMENT
	public ResponseEntity<?> deleteDocument(Long visitId, Long documentId) {

		// Check site visit exists
		SiteVisit siteVisit = siteVisitRepository.findById(visitId)
				.orElseThrow(() -> new IllegalArgumentException("Site visit not found with id: " + visitId));

		// Check document exists and belongs to this visit
		SiteVisitDocument document = siteVisitDocumentRepository.findById(documentId)
				.orElseThrow(() -> new IllegalArgumentException("Document not found with id: " + documentId));

		if (!document.getSiteVisit().getId().equals(visitId)) {
			throw new IllegalArgumentException("Document does not belong to this site visit");
		}

		// Delete from S3 (or your storage)
		s3Service.deleteFileByUrl(document.getDocumentUrl()); // replace with your delete method

		// Remove from visit and delete
		siteVisit.getDocuments().remove(document);
		siteVisitDocumentRepository.delete(document);

		ResponseStructure<String> response = new ResponseStructure<>();
		response.setStatus(HttpStatus.OK.value());
		response.setMessage("Document deleted successfully");
		response.setData("Document with id " + documentId + " deleted");

		return ResponseEntity.ok(response);
	}

}
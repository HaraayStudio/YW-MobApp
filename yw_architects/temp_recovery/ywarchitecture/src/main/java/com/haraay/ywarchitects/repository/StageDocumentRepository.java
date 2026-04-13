package com.haraay.ywarchitects.repository;

import com.haraay.ywarchitects.model.StageDocument;
import com.haraay.ywarchitects.model.DocumentType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface StageDocumentRepository extends JpaRepository<StageDocument, Long> {

	// Get all documents for a stage
	List<StageDocument> findByProjectStageId(Long stageId);

	// Get documents by type
	List<StageDocument> findByProjectStageIdAndDocumentType(Long stageId, DocumentType documentType);

	// Get approved / pending documents
	List<StageDocument> findByProjectStageIdAndIsApproved(Long stageId, Boolean isApproved);

	// Get documents by category (using description as category OR add separate
	// field if needed)
	@Query("SELECT d FROM StageDocument d WHERE d.projectStage.id = :stageId AND d.description = :category")
	List<StageDocument> findByStageAndCategory(@Param("stageId") Long stageId, @Param("category") String category);

	// Get latest documents (based on upload time)
	@Query("SELECT d FROM StageDocument d WHERE d.projectStage.id = :stageId ORDER BY d.uploadedAt DESC")
	List<StageDocument> findLatestDocumentsByStage(@Param("stageId") Long stageId);

	// Get documents uploaded by a specific user
	@Query("SELECT d FROM StageDocument d WHERE d.projectStage.id = :stageId AND d.uploadedBy = :userId")
	List<StageDocument> findByProjectStageIdAndUploadedBy(@Param("stageId") Long stageId, @Param("userId") Long userId);

	// Documents waiting for approval (not approved yet)
	@Query("SELECT d FROM StageDocument d WHERE d.projectStage.id = :stageId AND d.isApproved = false")
	List<StageDocument> findPendingApprovalDocuments(@Param("stageId") Long stageId);

	// Count total documents in stage
	Long countByProjectStageId(Long stageId);

	// Count approved documents
	Long countByProjectStageIdAndIsApproved(Long stageId, Boolean isApproved);

	@Query("SELECT sd FROM StageDocument sd WHERE sd.filePath = :documentFilePath")
	StageDocument findByFilePath(@Param("documentFilePath") String documentFilePath);
}

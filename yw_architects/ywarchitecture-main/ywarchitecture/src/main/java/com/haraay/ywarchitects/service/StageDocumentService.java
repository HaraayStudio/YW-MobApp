package com.haraay.ywarchitects.service;


import com.haraay.ywarchitects.model.StageDocument;
import com.haraay.ywarchitects.dto.StageDocumentDTO;
import com.haraay.ywarchitects.dto.SuccessDTO;
import com.haraay.ywarchitects.mapper.StageDocumentMapper;
import com.haraay.ywarchitects.model.DocumentType;
import com.haraay.ywarchitects.model.Project;
import com.haraay.ywarchitects.model.ProjectStage;
import com.haraay.ywarchitects.repository.ProjectStageRepository;
import com.haraay.ywarchitects.repository.StageDocumentRepository;
import com.haraay.ywarchitects.util.ResponseStructure;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
public class StageDocumentService {
    
    @Autowired
    private StageDocumentRepository documentRepository;
    
    @Autowired
    private ProjectStageRepository projectStageRepository;
    
    @Autowired
    private StageDocumentMapper stageDocumentMapper;
    
    @Autowired
    private S3Service s3Service;
    
    @Autowired
    private ResponseStructure<SuccessDTO> successDTOStructure;
   
    @Autowired
	private ResponseStructure<StageDocumentDTO> stageDocumentDTOStructure;
    
    
    // ═══════════════════════════════════════════════════════════════
    // READ OPERATIONS
    // ═══════════════════════════════════════════════════════════════
    
    /**
     * Get all documents for a stage
     */
    @Transactional(readOnly = true)
    public List<StageDocument> getDocumentsByStage(Long stageId) {
        return documentRepository.findByProjectStageId(stageId);
    }
    
    /**
     * Get document by ID
     */
    @Transactional(readOnly = true)
    public Optional<StageDocument> getDocumentById(Long documentId) {
        return documentRepository.findById(documentId);
    }
    
    /**
     * Get documents by type
     */
    @Transactional(readOnly = true)
    public List<StageDocument> getDocumentsByType(Long stageId, DocumentType documentType) {
        return documentRepository.findByProjectStageIdAndDocumentType(stageId, documentType);
    }
    
    /**
     * Get approved documents
     */
    @Transactional(readOnly = true)
    public List<StageDocument> getApprovedDocuments(Long stageId) {
        return documentRepository.findByProjectStageIdAndIsApproved(stageId, true);
    }
    
    /**
     * Get pending documents
     */
    @Transactional(readOnly = true)
    public List<StageDocument> getPendingDocuments(Long stageId) {
        return documentRepository.findByProjectStageIdAndIsApproved(stageId, false);
    }
    
    /**
     * Get documents by category
     */
    @Transactional(readOnly = true)
    public List<StageDocument> getDocumentsByCategory(Long stageId, String category) {
        return documentRepository.findByStageAndCategory(stageId, category);
    }
    
    /**
     * Get latest documents
     */
    @Transactional(readOnly = true)
    public List<StageDocument> getLatestDocuments(Long stageId) {
        return documentRepository.findLatestDocumentsByStage(stageId);
    }
    
    /**
     * Get documents uploaded by user
     */
    @Transactional(readOnly = true)
    public List<StageDocument> getDocumentsByUser(Long stageId, Long userId) {
        return documentRepository.findByProjectStageIdAndUploadedBy(stageId, userId);
    }
    
    /**
     * Get pending approval documents
     */
    @Transactional(readOnly = true)
    public List<StageDocument> getPendingApprovalDocuments(Long stageId) {
        return documentRepository.findPendingApprovalDocuments(stageId);
    }
    
    
    // ═══════════════════════════════════════════════════════════════
    // UPDATE OPERATIONS
    // ═══════════════════════════════════════════════════════════════
    
    /**
     * Approve document
     */
    @Transactional
    public StageDocument approveDocument(Long documentId, Long approvedBy, String approvalRemarks) {
        StageDocument document = documentRepository.findById(documentId)
            .orElseThrow(() -> new RuntimeException("Document not found with id: " + documentId));
        
        document.setIsApproved(true);
        document.setApprovedAt(LocalDateTime.now());
        document.setApprovedBy(approvedBy);
        document.setApprovalRemarks(approvalRemarks);
        
        return documentRepository.save(document);
    }
    
    /**
     * Reject document
     */
    @Transactional
    public StageDocument rejectDocument(Long documentId, Long rejectedBy, String rejectionRemarks) {
        StageDocument document = documentRepository.findById(documentId)
            .orElseThrow(() -> new RuntimeException("Document not found with id: " + documentId));
        
        document.setIsApproved(false);
        document.setApprovedAt(null);
        document.setApprovedBy(null);
        document.setApprovalRemarks(rejectionRemarks);
        
        return documentRepository.save(document);
    }
    
    /**
     * Update document
     * @param documentId 
     */
    @Transactional
    public ResponseEntity<ResponseStructure<StageDocumentDTO>> updateDocument(
            Long documentId,
            MultipartFile document) {

        ResponseStructure<StageDocumentDTO> response = new ResponseStructure<>();

        StageDocument existing = documentRepository.findById(documentId)
                .orElseThrow(() ->
                        new RuntimeException("Document not found with id: " + documentId));

        String oldUrl = existing.getFilePath();
        String newUrl = null;

        // ✅ upload FIRST
        if (document != null && !document.isEmpty()) {
            newUrl = s3Service.uploadFile(document);
            existing.setFilePath(newUrl);
        }

        StageDocument saved = documentRepository.save(existing);

        // ✅ delete OLD only after success
        if (newUrl != null && oldUrl != null) {
            try {
                s3Service.deleteFileByUrl(oldUrl);
            } catch (Exception ex) {
                // 🔥 senior move: don't break main flow
                // just log
                System.err.println("Failed to delete old S3 file: " + oldUrl);
            }
        }

        response.setData(stageDocumentMapper.toDTO(saved));
        response.setMessage("Document updated successfully");
        response.setStatus(HttpStatus.OK.value());

        return ResponseEntity.ok(response);
    }
    
    
    // ═══════════════════════════════════════════════════════════════
    // DELETE OPERATIONS
    // ═══════════════════════════════════════════════════════════════
    
    /**
     * Delete document
     */
    @Transactional
    public ResponseEntity<ResponseStructure<SuccessDTO>> deleteDocument(String documentFilePath) {
		StageDocument stageDocument = documentRepository.findByFilePath(documentFilePath);
        s3Service.deleteFileByUrl(documentFilePath);
        
        stageDocument.setFilePath(null);
        if( documentRepository.save(stageDocument)==null) {
        	successDTOStructure.setData(null);
        	successDTOStructure.setMessage("FAILED TO DELETE DOCUMENT");
        	successDTOStructure.setStatus(HttpStatus.INTERNAL_SERVER_ERROR.value());
        	
        	return new ResponseEntity<ResponseStructure<SuccessDTO>>(successDTOStructure,HttpStatus.INTERNAL_SERVER_ERROR);
        }
        
        successDTOStructure.setData(new SuccessDTO("DOCUMENT DELETED !"));
    	successDTOStructure.setMessage(documentFilePath);
    	successDTOStructure.setStatus(HttpStatus.OK.value());
    	
    	return new ResponseEntity<ResponseStructure<SuccessDTO>>(successDTOStructure,HttpStatus.OK);
 
        
    }

	public ResponseEntity<ResponseStructure<StageDocumentDTO>> addDocument(Long stageId, String documentName,String documentType,
			MultipartFile document) {
		
		
		 ResponseStructure<StageDocumentDTO> response = new ResponseStructure<>();

	        ProjectStage projectStage = projectStageRepository.findById(stageId)
	                .orElseThrow(() ->
	                        new RuntimeException("projectStage not found with id: " + stageId));

	       
	        String newUrl = null;

	        // ✅ upload FIRST
	        if (document != null && !document.isEmpty()) {
	            newUrl = s3Service.uploadFile(document);
	            
	        }
	        
	        StageDocument stageDocument= new StageDocument();
	        stageDocument.setFileName(documentName);
	        stageDocument.setFilePath(newUrl);
	        stageDocument.setUploadedAt(LocalDateTime.now());
	        
	        stageDocument.setDocumentType(DocumentType.valueOf(documentType));

	        stageDocument.setUploadedBy(1L);        // required column
	        stageDocument.setIsApproved(false);     // default
	        stageDocument.setVersion(1);            // default
	        
	        stageDocument.setProjectStage(projectStage);
	        
	        projectStage.getDocuments().add(stageDocument);

	        ProjectStage saved = projectStageRepository.save(projectStage);

	       
	        response.setData(stageDocumentMapper.toDTO(stageDocument));
	        response.setMessage("Document updated successfully");
	        response.setStatus(HttpStatus.OK.value());

	        return ResponseEntity.ok(response);
	}
    
    
}
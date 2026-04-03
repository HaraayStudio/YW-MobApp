package com.haraay.ywarchitects.controller;



import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import com.haraay.ywarchitects.dto.StageDocumentDTO;
import com.haraay.ywarchitects.dto.SuccessDTO;
import com.haraay.ywarchitects.model.DocumentType;
import com.haraay.ywarchitects.model.StageDocument;
import com.haraay.ywarchitects.service.StageDocumentService;
import com.haraay.ywarchitects.util.ResponseStructure;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/stages/{stageId}/documents")
@CrossOrigin(origins = "*")
public class StageDocumentController {
    
    @Autowired
    private StageDocumentService documentService;
    
    
    // ═══════════════════════════════════════════════════════════════
    // GET OPERATIONS
    // ═══════════════════════════════════════════════════════════════
    
    /**
     * Get all documents for a stage
     * 
     * GET /api/stages/6/documents
     */
    @GetMapping
    public ResponseEntity<List<StageDocument>> getAllDocuments(@PathVariable Long stageId) {
        List<StageDocument> documents = documentService.getDocumentsByStage(stageId);
        return ResponseEntity.ok(documents);
    }
    
    /**
     * Get document by ID
     * 
     * GET /api/stages/6/documents/50
     */
    @GetMapping("/{documentId}")
    public ResponseEntity<StageDocument> getDocumentById(
            @PathVariable Long stageId,
            @PathVariable Long documentId) {
        
        return documentService.getDocumentById(documentId)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }
    
    /**
     * Get documents by type
     * 
     * GET /api/stages/6/documents/type/APPLICATION
     */
    @GetMapping("/type/{documentType}")
    public ResponseEntity<List<StageDocument>> getDocumentsByType(
            @PathVariable Long stageId,
            @PathVariable String documentType) {
        
        DocumentType type = DocumentType.valueOf(documentType);
        List<StageDocument> documents = documentService.getDocumentsByType(stageId, type);
        return ResponseEntity.ok(documents);
    }
    
    /**
     * Get approved documents
     * 
     * GET /api/stages/6/documents/approved
     */
    @GetMapping("/approved")
    public ResponseEntity<List<StageDocument>> getApprovedDocuments(@PathVariable Long stageId) {
        List<StageDocument> documents = documentService.getApprovedDocuments(stageId);
        return ResponseEntity.ok(documents);
    }
    
    /**
     * Get pending documents
     * 
     * GET /api/stages/6/documents/pending
     */
    @GetMapping("/pending")
    public ResponseEntity<List<StageDocument>> getPendingDocuments(@PathVariable Long stageId) {
        List<StageDocument> documents = documentService.getPendingDocuments(stageId);
        return ResponseEntity.ok(documents);
    }
    
    /**
     * Get pending approval documents
     * 
     * GET /api/stages/6/documents/pending-approval
     */
    @GetMapping("/pending-approval")
    public ResponseEntity<List<StageDocument>> getPendingApprovalDocuments(@PathVariable Long stageId) {
        List<StageDocument> documents = documentService.getPendingApprovalDocuments(stageId);
        return ResponseEntity.ok(documents);
    }
    
    /**
     * Get documents by category
     * 
     * GET /api/stages/6/documents/category/7/12%20Extract
     */
    @GetMapping("/category/{category}")
    public ResponseEntity<List<StageDocument>> getDocumentsByCategory(
            @PathVariable Long stageId,
            @PathVariable String category) {
        
        List<StageDocument> documents = documentService.getDocumentsByCategory(stageId, category);
        return ResponseEntity.ok(documents);
    }
    
    /**
     * Get latest documents
     * 
     * GET /api/stages/6/documents/latest
     */
    @GetMapping("/latest")
    public ResponseEntity<List<StageDocument>> getLatestDocuments(@PathVariable Long stageId) {
        List<StageDocument> documents = documentService.getLatestDocuments(stageId);
        return ResponseEntity.ok(documents);
    }
    
    /**
     * Get documents by user
     * 
     * GET /api/stages/6/documents/user/123
     */
    @GetMapping("/user/{userId}")
    public ResponseEntity<List<StageDocument>> getDocumentsByUser(
            @PathVariable Long stageId,
            @PathVariable Long userId) {
        
        List<StageDocument> documents = documentService.getDocumentsByUser(stageId, userId);
        return ResponseEntity.ok(documents);
    }
    
    
    // ═══════════════════════════════════════════════════════════════
    // UPDATE OPERATIONS
    // ═══════════════════════════════════════════════════════════════
    
    /**
     * Approve a document
     * 
     * PUT /api/stages/6/documents/50/approve
     * Body: {
     *   "approvedBy": 125,
     *   "approvalRemarks": "All sections verified"
     * }
     */
    @PutMapping("/{documentId}/approve")
    public ResponseEntity<StageDocument> approveDocument(
            @PathVariable Long stageId,
            @PathVariable Long documentId,
            @RequestBody Map<String, Object> request) {
        
        Long approvedBy = ((Number) request.get("approvedBy")).longValue();
        String approvalRemarks = (String) request.get("approvalRemarks");
        
        StageDocument approved = documentService.approveDocument(documentId, approvedBy, approvalRemarks);
        return ResponseEntity.ok(approved);
    }
    
    /**
     * Reject a document
     * 
     * PUT /api/stages/6/documents/50/reject
     * Body: {
     *   "rejectedBy": 125,
     *   "rejectionRemarks": "Missing signatures"
     * }
     */
    @PutMapping("/{documentId}/reject")
    public ResponseEntity<StageDocument> rejectDocument(
            @PathVariable Long stageId,
            @PathVariable Long documentId,
            @RequestBody Map<String, Object> request) {
        
        Long rejectedBy = ((Number) request.get("rejectedBy")).longValue();
        String rejectionRemarks = (String) request.get("rejectionRemarks");
        
        StageDocument rejected = documentService.rejectDocument(documentId, rejectedBy, rejectionRemarks);
        return ResponseEntity.ok(rejected);
    }
    
    
    @PostMapping(value="/addDocument/{documentName}/{documentType}", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ResponseStructure<StageDocumentDTO>> addDocument(            
            @PathVariable Long stageId,
            @PathVariable String documentName,
            @PathVariable String documentType,
            @RequestPart(value = "document",required = true) MultipartFile document) {
        
        
       return  documentService.addDocument(stageId,documentName,documentType,document);
       
    }
    
    /**
     * Update document
     * 
     * PUT /api/stages/6/documents/50
     */
    @PutMapping(value = "/updateDocument/{documentId}",consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ResponseStructure<StageDocumentDTO>> updateDocument(            
            @PathVariable Long documentId,
            @RequestPart(value = "document",required = true) MultipartFile document) {
        
        
       return  documentService.updateDocument(documentId,document);
       
    }
    
    
    // ═══════════════════════════════════════════════════════════════
    // DELETE OPERATIONS
    // ═══════════════════════════════════════════════════════════════
    
    /**
     * Delete document
     * 
     * DELETE /api/stages/6/documents/50
     */
    @DeleteMapping("/deletedocument/{documentId}")
    public ResponseEntity<ResponseStructure<SuccessDTO>> deleteDocument(
           @PathVariable String documentFilePath) {
        
    	return  documentService.deleteDocument(documentFilePath);
         
    }
    
}

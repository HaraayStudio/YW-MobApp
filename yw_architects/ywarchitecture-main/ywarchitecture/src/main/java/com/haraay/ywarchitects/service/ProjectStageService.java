package com.haraay.ywarchitects.service;


import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.haraay.ywarchitects.dto.SuccessDTO;
import com.haraay.ywarchitects.model.*;
import com.haraay.ywarchitects.repository.*;
import com.haraay.ywarchitects.util.ResponseStructure;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
public class ProjectStageService {
    
    @Autowired
    private ProjectStageRepository stageRepository;
    
    @Autowired
    private StageDocumentRepository documentRepository;
    
    @Autowired
    private StageMediaRepository mediaRepository;
    
    @Autowired
    private StageTaskRepository taskRepository;
    
    @Autowired
    private ProjectRepository projectRepository;
    
    @Autowired
	private ResponseStructure<SuccessDTO> successDTOStructure;
    
    
    // ═══════════════════════════════════════════════════════════════
    // PARENT STAGE OPERATIONS
    // ═══════════════════════════════════════════════════════════════
    
    /**
     * Get all parent stages for a project (children come nested automatically)
     */
    @Transactional(readOnly = true)
    public List<ProjectStage> getParentStages(Long projectId) {
        return stageRepository.findParentStagesByProjectId(projectId);
    }
    
    /**
     * Create a new parent stage
     */
    @Transactional
    public ProjectStage createParentStage(Long projectId, StageName stageName, 
                                         String customStageName, Integer displayOrder,
                                         Long createdBy) {
        Project project = projectRepository.findById(projectId)
            .orElseThrow(() -> new RuntimeException("Project not found with id: " + projectId));
        
        ProjectStage stage = new ProjectStage();
        stage.setProject(project);
        stage.setStageName(stageName);
        stage.setCustomStageName(customStageName);
        stage.setStatus(StageStatus.NOT_STARTED);
        stage.setProgressPercentage(0);
        stage.setDisplayOrder(displayOrder);
        stage.setParentStage(null); // This is a parent
        stage.setCreatedBy(createdBy);
        
        return stageRepository.save(stage);
    }
    
    /**
     * Get a specific stage by ID with all relationships
     */
    @Transactional(readOnly = true)
    public Optional<ProjectStage> getStageById(Long stageId) {
        return stageRepository.findById(stageId);
    }
    

    
    
    // ═══════════════════════════════════════════════════════════════
    // CHILD STAGE OPERATIONS
    // ═══════════════════════════════════════════════════════════════
    
    /**
     * Create a child stage under a parent
     */
    @Transactional
    public ProjectStage createChildStage(Long parentStageId, String customStageName, 
                                        Integer displayOrder, Long createdBy) {
        ProjectStage parentStage = stageRepository.findById(parentStageId)
            .orElseThrow(() -> new RuntimeException("Parent stage not found with id: " + parentStageId));
        
        ProjectStage childStage = new ProjectStage();
        childStage.setProject(parentStage.getProject());
        childStage.setStageName(parentStage.getStageName()); // Same as parent
        childStage.setCustomStageName(customStageName); // e.g., "Water NOC"
        childStage.setStatus(StageStatus.NOT_STARTED);
        childStage.setProgressPercentage(0);
        childStage.setDisplayOrder(displayOrder);
        childStage.setParentStage(parentStage);
        childStage.setCreatedBy(createdBy);
        
        return stageRepository.save(childStage);
    }
    
    /**
     * Get all child stages of a parent
     */
    
    
    
    // ═══════════════════════════════════════════════════════════════
    // BUILDING PERMISSION SPECIFIC - BULK CHILD CREATION
    // ═══════════════════════════════════════════════════════════════
    
    /**
     * Create all Building Permission NOC child stages at once
     */
    @Transactional
    public List<ProjectStage> createBuildingPermissionNOCs(Long buildingPermissionStageId, Long createdBy) {
        String[] nocNames = {
            "Water NOC",
            "Drainage NOC",
            "Garden NOC",
            "Fire NOC",
            "Elevation / Height NOC",
            "C & D Waste Management"
        };
        
        List<ProjectStage> childStages = new java.util.ArrayList<>();
        
        for (int i = 0; i < nocNames.length; i++) {
            ProjectStage child = createChildStage(
                buildingPermissionStageId,
                nocNames[i],
                i + 1,
                createdBy
            );
            childStages.add(child);
        }
        
        return childStages;
    }
    
    
    // ═══════════════════════════════════════════════════════════════
    // STAGE UPDATE OPERATIONS
    // ═══════════════════════════════════════════════════════════════
    
    /**
     * Update stage status
     */
    @Transactional
    public ProjectStage updateStageStatus(Long stageId, StageStatus status, Long updatedBy) {
        ProjectStage stage = stageRepository.findById(stageId)
            .orElseThrow(() -> new RuntimeException("Stage not found with id: " + stageId));
        
        stage.setStatus(status);
        stage.setUpdatedBy(updatedBy);
        
        if (status == StageStatus.IN_PROGRESS && stage.getStartedAt() == null) {
            stage.setStartedAt(LocalDateTime.now());
        }
        
        if (status == StageStatus.COMPLETED) {
            stage.setActualCompletionDate(LocalDateTime.now());
            stage.setProgressPercentage(100);
        }
        
        ProjectStage updated = stageRepository.save(stage);
        
        // If this is a child stage, update parent progress
        if (stage.getParentStage() != null) {
            updateParentProgress(stage.getParentStage().getId());
        }
        
        return updated;
    }
    
    /**
     * Update stage progress percentage
     */
    @Transactional
    public ProjectStage updateStageProgress(Long stageId, Integer progressPercentage, Long updatedBy) {
        ProjectStage stage = stageRepository.findById(stageId)
            .orElseThrow(() -> new RuntimeException("Stage not found with id: " + stageId));
        
        stage.setProgressPercentage(progressPercentage);
        stage.setUpdatedBy(updatedBy);
        
        // Auto-update status based on progress
        if (progressPercentage == 0 && stage.getStatus() == StageStatus.NOT_STARTED) {
            // Keep as NOT_STARTED
        } else if (progressPercentage > 0 && progressPercentage < 100) {
            stage.setStatus(StageStatus.IN_PROGRESS);
            if (stage.getStartedAt() == null) {
                stage.setStartedAt(LocalDateTime.now());
            }
        } else if (progressPercentage == 100) {
            stage.setStatus(StageStatus.COMPLETED);
            stage.setActualCompletionDate(LocalDateTime.now());
        }
        
        ProjectStage updated = stageRepository.save(stage);
        
        // If this is a child stage, update parent progress
        if (stage.getParentStage() != null) {
            updateParentProgress(stage.getParentStage().getId());
        }
        
        return updated;
    }
    
    /**
     * Update stage remarks
     */
    @Transactional
    public ProjectStage updateStageRemarks(Long stageId, String remarks, Long updatedBy) {
        ProjectStage stage = stageRepository.findById(stageId)
            .orElseThrow(() -> new RuntimeException("Stage not found with id: " + stageId));
        
        stage.setRemarks(remarks);
        stage.setUpdatedBy(updatedBy);
        
        return stageRepository.save(stage);
    }
    
    
    // ═══════════════════════════════════════════════════════════════
    // PROGRESS CALCULATION
    // ═══════════════════════════════════════════════════════════════
    
    /**
     * Update parent stage progress based on children
     */
    @Transactional
    public void updateParentProgress(Long parentStageId) {
        ProjectStage parentStage = stageRepository.findById(parentStageId)
            .orElseThrow(() -> new RuntimeException("Parent stage not found with id: " + parentStageId));
        
        Integer calculatedProgress = parentStage.calculateOverallProgress();
        parentStage.setProgressPercentage(calculatedProgress);
        
        // Auto-update status based on progress
        if (calculatedProgress == 0) {
            parentStage.setStatus(StageStatus.NOT_STARTED);
        } else if (calculatedProgress == 100) {
            parentStage.setStatus(StageStatus.COMPLETED);
            if (parentStage.getActualCompletionDate() == null) {
                parentStage.setActualCompletionDate(LocalDateTime.now());
            }
        } else {
            parentStage.setStatus(StageStatus.IN_PROGRESS);
            if (parentStage.getStartedAt() == null) {
                parentStage.setStartedAt(LocalDateTime.now());
            }
        }
        
        stageRepository.save(parentStage);
    }
    
    /**
     * Calculate stage progress from completed tasks
     */
   
    
    
    // ═══════════════════════════════════════════════════════════════
    // DOCUMENT OPERATIONS
    // ═══════════════════════════════════════════════════════════════
    
    /**
     * Add document to a stage
     */
    @Transactional
    public StageDocument addDocument(Long stageId, String fileName, String filePath,
                                    DocumentType documentType,
                                    Long uploadedBy) {
        ProjectStage stage = stageRepository.findById(stageId)
            .orElseThrow(() -> new RuntimeException("Stage not found with id: " + stageId));
        
        StageDocument document = new StageDocument();
        document.setProjectStage(stage);
        document.setFileName(fileName);
        document.setFilePath(filePath);
        document.setDocumentType(documentType);
        
        document.setUploadedBy(uploadedBy);
        document.setIsApproved(false);
        
        return documentRepository.save(document);
    }
    
    /**
     * Approve a document
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
     * Get all documents for a stage
     */
    @Transactional(readOnly = true)
    public List<StageDocument> getStageDocuments(Long stageId) {
        return documentRepository.findByProjectStageId(stageId);
    }
    
    
    // ═══════════════════════════════════════════════════════════════
    // MEDIA OPERATIONS
    // ═══════════════════════════════════════════════════════════════
    
    /**
     * Add media to a stage
     */
    @Transactional
    public StageMedia addMedia(Long stageId, String fileName, String filePath,
                              MediaType mediaType, String description,
                              Long uploadedBy) {
        ProjectStage stage = stageRepository.findById(stageId)
            .orElseThrow(() -> new RuntimeException("Stage not found with id: " + stageId));
        
        StageMedia media = new StageMedia();
        media.setProjectStage(stage);
        media.setFileName(fileName);
        media.setFilePath(filePath);
        media.setMediaType(mediaType);
        media.setDescription(description);
        media.setUploadedBy(uploadedBy);
        media.setCapturedAt(LocalDateTime.now());
        
        return mediaRepository.save(media);
    }
    
    
    // ═══════════════════════════════════════════════════════════════
    // TASK OPERATIONS
    // ═══════════════════════════════════════════════════════════════
    
    /**
     * Add task to a stage
     */
    @Transactional
    public StageTask addTask(Long stageId, String taskName, String description,
                            Boolean isMandatory, Integer displayOrder) {
        ProjectStage stage = stageRepository.findById(stageId)
            .orElseThrow(() -> new RuntimeException("Stage not found with id: " + stageId));
        
        StageTask task = new StageTask();
        task.setProjectStage(stage);
        task.setTaskName(taskName);
        task.setDescription(description);
        task.setIsMandatory(isMandatory);
        task.setDisplayOrder(displayOrder);
        task.setIsCompleted(false);
        
        return taskRepository.save(task);
    }
    
    /**
     * Complete a task
     */
    @Transactional
    public StageTask completeTask(Long taskId, Long completedBy, String notes) {
        StageTask task = taskRepository.findById(taskId)
            .orElseThrow(() -> new RuntimeException("Task not found with id: " + taskId));
        
        task.setIsCompleted(true);
        task.setCompletedAt(LocalDateTime.now());
        task.setCompletedBy(completedBy);
        if (notes != null) {
            task.setNotes(notes);
        }
        
        StageTask updated = taskRepository.save(task);
        
        // Update stage progress based on task completion
//        updateStageProgressFromTasks(task.getProjectStage().getId());
        
        return updated;
    }
    
    /**
     * Get all tasks for a stage
     */
    
    
    
    // ═══════════════════════════════════════════════════════════════
    // DELETE OPERATIONS
    // ═══════════════════════════════════════════════════════════════
    
    /**
     * Delete a stage (and all its children if parent)
     */
    @Transactional
    public void deleteStage(Long stageId) {
        ProjectStage stage = stageRepository.findById(stageId)
            .orElseThrow(() -> new RuntimeException("Stage not found with id: " + stageId));
        
        // If this is a child, update parent progress after deletion
        ProjectStage parent = stage.getParentStage();
        
        stageRepository.delete(stage);
        
        if (parent != null) {
            updateParentProgress(parent.getId());
        }
    }
    
    /**
     * Delete a document
     */
    @Transactional
    public void deleteDocument(Long documentId) {
        documentRepository.deleteById(documentId);
    }
    
    /**
     * Delete a media file
     */
    @Transactional
    public void deleteMedia(Long mediaId) {
        mediaRepository.deleteById(mediaId);
    }
    
    /**
     * Delete a task
     */
    @Transactional
    public ResponseEntity<ResponseStructure<SuccessDTO>> deleteTask(Long taskId) {
        Optional<StageTask> optional = taskRepository.findById(taskId);
            if(optional.isEmpty()) {
            	successDTOStructure.setData(new SuccessDTO("StageTask NOT FOund"));
        		successDTOStructure.setMessage("task Not FOund with taskId - " + taskId);
        		successDTOStructure.setStatus(HttpStatus.NOT_FOUND.value());
        		return new ResponseEntity<ResponseStructure<SuccessDTO>>(successDTOStructure, HttpStatus.NOT_FOUND);

            }
        
       
        taskRepository.delete(optional.get());
        
        successDTOStructure.setData(new SuccessDTO("Task deleted"));
		successDTOStructure.setMessage("task deleted with srNumber - " + taskId);
		successDTOStructure.setStatus(HttpStatus.OK.value());
		return new ResponseEntity<ResponseStructure<SuccessDTO>>(successDTOStructure, HttpStatus.OK);

        
       
    }
}

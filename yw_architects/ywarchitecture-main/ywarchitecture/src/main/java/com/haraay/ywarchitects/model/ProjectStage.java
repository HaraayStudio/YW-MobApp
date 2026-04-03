package com.haraay.ywarchitects.model;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;

@Entity
@Table(name = "project_stages")
public class ProjectStage {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "project_id", nullable = false)
    @JsonIgnoreProperties({"stages", "structures", "siteVisits", "reraProject", "postSales"})
    private Project project;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private StageName stageName;
    
    // For child stages - custom names like "Water NOC", "Fire NOC"
    @Column(length = 200)
    private String customStageName;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private StageStatus status = StageStatus.NOT_STARTED;
    
    // Parent-Child Relationship
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "parent_stage_id")
    private ProjectStage parentStage;
    
    @OneToMany(mappedBy = "parentStage", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<ProjectStage> childStages = new ArrayList<>();
    
    // Progress tracking
    @Column(nullable = false)
    private Integer progressPercentage = 0;
    
    // Dates
    @Column
    private LocalDateTime startedAt;
    
    @Column
    private LocalDateTime targetCompletionDate;
    
    @Column
    private LocalDateTime actualCompletionDate;
    
    // Remarks & Notes
    @Column(columnDefinition = "TEXT")
    private String remarks;
    
    @Column(columnDefinition = "TEXT")
    private String internalNotes;
    
    // Stage Order (for sequencing)
    @Column
    private Integer displayOrder;
    
    // Is this stage mandatory?
    @Column(nullable = false)
    private Boolean isMandatory = true;
    
    // Documents and Media
    @OneToMany(mappedBy = "projectStage", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<StageDocument> documents = new ArrayList<>();
    
    @OneToMany(mappedBy = "projectStage", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<StageMedia> mediaFiles = new ArrayList<>();
    
    // Tasks/Checklists
    @OneToMany(mappedBy = "projectStage", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<StageTask> tasks = new ArrayList<>();
    
    // Audit fields
    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;
    
    @Column(nullable = false)
    private LocalDateTime updatedAt;
    
    @Column
    private Long createdBy;
    
    @Column
    private Long updatedBy;
    
    // ============================================
    // Constructors
    // ============================================
    public ProjectStage() {
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }
    
    // ============================================
    // Helper Methods
    // ============================================
    
    /**
     * Check if this is a parent stage
     */
    public boolean isParentStage() {
        return this.parentStage == null;
    }
    
    /**
     * Check if this is a child stage
     */
    public boolean isChildStage() {
        return this.parentStage != null;
    }
    
    /**
     * Get display name (custom name if available, otherwise enum name)
     */
    public String getDisplayName() {
        return customStageName != null ? customStageName : stageName.name();
    }
    
    /**
     * Calculate overall progress for parent stages based on child stages
     */
    public Integer calculateOverallProgress() {
        if (childStages.isEmpty()) {
            return progressPercentage;
        }
        
        int totalProgress = 0;
        for (ProjectStage child : childStages) {
            totalProgress += child.getProgressPercentage();
        }
        return childStages.isEmpty() ? 0 : totalProgress / childStages.size();
    }
    
    /**
     * Add a child stage
     */
    public void addChildStage(ProjectStage childStage) {
        childStages.add(childStage);
        childStage.setParentStage(this);
    }
    
    /**
     * Remove a child stage
     */
    public void removeChildStage(ProjectStage childStage) {
        childStages.remove(childStage);
        childStage.setParentStage(null);
    }
    
    /**
     * Add a document
     */
    public void addDocument(StageDocument document) {
        documents.add(document);
        document.setProjectStage(this);
    }
    
    /**
     * Add media
     */
    public void addMedia(StageMedia media) {
        mediaFiles.add(media);
        media.setProjectStage(this);
    }
    
    /**
     * Add task
     */
    public void addTask(StageTask task) {
        tasks.add(task);
        task.setProjectStage(this);
    }
    
    @PreUpdate
    protected void onUpdate() {
        this.updatedAt = LocalDateTime.now();
    }
    
    // ============================================
    // Getters and Setters
    // ============================================
    
    public Long getId() {
        return id;
    }
    
    public void setId(Long id) {
        this.id = id;
    }
    
    public Project getProject() {
        return project;
    }
    
    public void setProject(Project project) {
        this.project = project;
    }
    
    public StageName getStageName() {
        return stageName;
    }
    
    public void setStageName(StageName stageName) {
        this.stageName = stageName;
    }
    
    public String getCustomStageName() {
        return customStageName;
    }
    
    public void setCustomStageName(String customStageName) {
        this.customStageName = customStageName;
    }
    
    public StageStatus getStatus() {
        return status;
    }
    
    public void setStatus(StageStatus status) {
        this.status = status;
    }
    
    public ProjectStage getParentStage() {
        return parentStage;
    }
    
    public void setParentStage(ProjectStage parentStage) {
        this.parentStage = parentStage;
    }
    
    public List<ProjectStage> getChildStages() {
        return childStages;
    }
    
    public void setChildStages(List<ProjectStage> childStages) {
        this.childStages = childStages;
    }
    
    public Integer getProgressPercentage() {
        return progressPercentage;
    }
    
    public void setProgressPercentage(Integer progressPercentage) {
        this.progressPercentage = progressPercentage;
    }
    
    public LocalDateTime getStartedAt() {
        return startedAt;
    }
    
    public void setStartedAt(LocalDateTime startedAt) {
        this.startedAt = startedAt;
    }
    
    public LocalDateTime getTargetCompletionDate() {
        return targetCompletionDate;
    }
    
    public void setTargetCompletionDate(LocalDateTime targetCompletionDate) {
        this.targetCompletionDate = targetCompletionDate;
    }
    
    public LocalDateTime getActualCompletionDate() {
        return actualCompletionDate;
    }
    
    public void setActualCompletionDate(LocalDateTime actualCompletionDate) {
        this.actualCompletionDate = actualCompletionDate;
    }
    
    public String getRemarks() {
        return remarks;
    }
    
    public void setRemarks(String remarks) {
        this.remarks = remarks;
    }
    
    public String getInternalNotes() {
        return internalNotes;
    }
    
    public void setInternalNotes(String internalNotes) {
        this.internalNotes = internalNotes;
    }
    
    public Integer getDisplayOrder() {
        return displayOrder;
    }
    
    public void setDisplayOrder(Integer displayOrder) {
        this.displayOrder = displayOrder;
    }
    
    public Boolean getIsMandatory() {
        return isMandatory;
    }
    
    public void setIsMandatory(Boolean isMandatory) {
        this.isMandatory = isMandatory;
    }
    
    public List<StageDocument> getDocuments() {
        return documents;
    }
    
    public void setDocuments(List<StageDocument> documents) {
        this.documents = documents;
    }
    
    public List<StageMedia> getMediaFiles() {
        return mediaFiles;
    }
    
    public void setMediaFiles(List<StageMedia> mediaFiles) {
        this.mediaFiles = mediaFiles;
    }
    
    public List<StageTask> getTasks() {
        return tasks;
    }
    
    public void setTasks(List<StageTask> tasks) {
        this.tasks = tasks;
    }
    
    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
    
    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }
    
    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }
    
    public Long getCreatedBy() {
        return createdBy;
    }
    
    public void setCreatedBy(Long createdBy) {
        this.createdBy = createdBy;
    }
    
    public Long getUpdatedBy() {
        return updatedBy;
    }
    
    public void setUpdatedBy(Long updatedBy) {
        this.updatedBy = updatedBy;
    }
}
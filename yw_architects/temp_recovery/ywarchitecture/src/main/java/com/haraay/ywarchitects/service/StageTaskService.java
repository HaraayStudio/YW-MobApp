package com.haraay.ywarchitects.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.haraay.ywarchitects.model.StageTask;
import com.haraay.ywarchitects.repository.StageTaskRepository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
public class StageTaskService {
    
    @Autowired
    private StageTaskRepository taskRepository;
    
    
    // ═══════════════════════════════════════════════════════════════
    // READ OPERATIONS
    // ═══════════════════════════════════════════════════════════════
    
    /**
     * Get all tasks for a stage
     */
   
    
    /**
     * Get task by ID
     */
    @Transactional(readOnly = true)
    public Optional<StageTask> getTaskById(Long taskId) {
        return taskRepository.findById(taskId);
    }
    
    /**
     * Get completed tasks
     */
   
    
    /**
     * Get incomplete tasks
     */
   
    /**
     * Get mandatory tasks
     */
    
    
    /**
     * Get incomplete mandatory tasks (blocking tasks)
     */
    
    
    /**
     * Get tasks completed by user
     */
    
    
    
    // ═══════════════════════════════════════════════════════════════
    // UPDATE OPERATIONS
    // ═══════════════════════════════════════════════════════════════
    
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
        
        return taskRepository.save(task);
    }
    
    /**
     * Uncomplete a task (mark as incomplete)
     */
    @Transactional
    public StageTask uncompleteTask(Long taskId) {
        StageTask task = taskRepository.findById(taskId)
            .orElseThrow(() -> new RuntimeException("Task not found with id: " + taskId));
        
        task.setIsCompleted(false);
        task.setCompletedAt(null);
        task.setCompletedBy(null);
        
        return taskRepository.save(task);
    }
    
    /**
     * Update task
     */
    @Transactional
    public StageTask updateTask(StageTask task) {
        return taskRepository.save(task);
    }
    
    
    // ═══════════════════════════════════════════════════════════════
    // DELETE OPERATIONS
    // ═══════════════════════════════════════════════════════════════
    
    /**
     * Delete task
     */
    @Transactional
    public void deleteTask(Long taskId) {
        taskRepository.deleteById(taskId);
    }
    
    
    // ═══════════════════════════════════════════════════════════════
    // STATISTICS
    // ═══════════════════════════════════════════════════════════════
    
    /**
     * Count total tasks
     */
    
    /**
     * Calculate task completion percentage
     */
//    @Transactional(readOnly = true)
//    public Integer calculateCompletionPercentage(Long stageId) {
//        Integer percentage = taskRepository.calculateTaskCompletionPercentage(stageId);
//        return percentage != null ? percentage : 0;
//    }
}

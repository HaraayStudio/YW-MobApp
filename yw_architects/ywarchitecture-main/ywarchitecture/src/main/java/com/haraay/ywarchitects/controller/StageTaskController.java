//package com.haraay.ywarchitects.controller;
//
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.http.HttpStatus;
//import org.springframework.http.ResponseEntity;
//import org.springframework.web.bind.annotation.*;
//
//import com.haraay.ywarchitects.model.StageTask;
//import com.haraay.ywarchitects.service.StageTaskService;
//
//import java.util.HashMap;
//import java.util.List;
//import java.util.Map;
//
//@RestController
//@RequestMapping("/api/stages/{stageId}/tasks")
//@CrossOrigin(origins = "*")
//public class StageTaskController {
//    
//    @Autowired
//    private StageTaskService taskService;
//    
//    
//    // ═══════════════════════════════════════════════════════════════
//    // GET OPERATIONS
//    // ═══════════════════════════════════════════════════════════════
//    
//    /**
//     * Get all tasks for a stage
//     * 
//     * GET /api/stages/6/tasks
//     */
//    @GetMapping
//    public ResponseEntity<List<StageTask>> getAllTasks(@PathVariable Long stageId) {
//        List<StageTask> tasks = taskService.getTasksByStage(stageId);
//        return ResponseEntity.ok(tasks);
//    }
//    
//    /**
//     * Get task by ID
//     * 
//     * GET /api/stages/6/tasks/70
//     */
//    @GetMapping("/{taskId}")
//    public ResponseEntity<StageTask> getTaskById(
//            @PathVariable Long stageId,
//            @PathVariable Long taskId) {
//        
//        return taskService.getTaskById(taskId)
//            .map(ResponseEntity::ok)
//            .orElse(ResponseEntity.notFound().build());
//    }
//    
//    /**
//     * Get completed tasks
//     * 
//     * GET /api/stages/6/tasks/completed
//     */
//    @GetMapping("/completed")
//    public ResponseEntity<List<StageTask>> getCompletedTasks(@PathVariable Long stageId) {
//        List<StageTask> tasks = taskService.getCompletedTasks(stageId);
//        return ResponseEntity.ok(tasks);
//    }
//    
//    /**
//     * Get incomplete tasks
//     * 
//     * GET /api/stages/6/tasks/incomplete
//     */
//    @GetMapping("/incomplete")
//    public ResponseEntity<List<StageTask>> getIncompleteTasks(@PathVariable Long stageId) {
//        List<StageTask> tasks = taskService.getIncompleteTasks(stageId);
//        return ResponseEntity.ok(tasks);
//    }
//    
//    /**
//     * Get mandatory tasks
//     * 
//     * GET /api/stages/6/tasks/mandatory
//     */
//    @GetMapping("/mandatory")
//    public ResponseEntity<List<StageTask>> getMandatoryTasks(@PathVariable Long stageId) {
//        List<StageTask> tasks = taskService.getMandatoryTasks(stageId);
//        return ResponseEntity.ok(tasks);
//    }
//    
//    /**
//     * Get incomplete mandatory tasks (blocking tasks)
//     * 
//     * GET /api/stages/6/tasks/blocking
//     */
//    @GetMapping("/blocking")
//    public ResponseEntity<List<StageTask>> getBlockingTasks(@PathVariable Long stageId) {
//        List<StageTask> tasks = taskService.getIncompleteMandatoryTasks(stageId);
//        return ResponseEntity.ok(tasks);
//    }
//    
//    /**
//     * Get tasks by user
//     * 
//     * GET /api/stages/6/tasks/user/123
//     */
//    @GetMapping("/user/{userId}")
//    public ResponseEntity<List<StageTask>> getTasksByUser(
//            @PathVariable Long stageId,
//            @PathVariable Long userId) {
//        
//        List<StageTask> tasks = taskService.getTasksByUser(stageId, userId);
//        return ResponseEntity.ok(tasks);
//    }
//    
//    
//    // ═══════════════════════════════════════════════════════════════
//    // UPDATE OPERATIONS
//    // ═══════════════════════════════════════════════════════════════
//    
//    /**
//     * Complete a task
//     * 
//     * PUT /api/stages/6/tasks/70/complete
//     * Body: {
//     *   "completedBy": 123,
//     *   "notes": "Completed without issues"
//     * }
//     */
//    @PutMapping("/{taskId}/complete")
//    public ResponseEntity<StageTask> completeTask(
//            @PathVariable Long stageId,
//            @PathVariable Long taskId,
//            @RequestBody Map<String, Object> request) {
//        
//        Long completedBy = ((Number) request.get("completedBy")).longValue();
//        String notes = (String) request.get("notes");
//        
//        StageTask completed = taskService.completeTask(taskId, completedBy, notes);
//        return ResponseEntity.ok(completed);
//    }
//    
//    /**
//     * Uncomplete a task (mark as incomplete)
//     * 
//     * PUT /api/stages/6/tasks/70/uncomplete
//     */
//    @PutMapping("/{taskId}/uncomplete")
//    public ResponseEntity<StageTask> uncompleteTask(
//            @PathVariable Long stageId,
//            @PathVariable Long taskId) {
//        
//        StageTask uncompleted = taskService.uncompleteTask(taskId);
//        return ResponseEntity.ok(uncompleted);
//    }
//    
//    /**
//     * Update task
//     * 
//     * PUT /api/stages/6/tasks/70
//     */
//    @PutMapping("/{taskId}")
//    public ResponseEntity<StageTask> updateTask(
//            @PathVariable Long stageId,
//            @PathVariable Long taskId,
//            @RequestBody StageTask task) {
//        
//        task.setId(taskId);
//        StageTask updated = taskService.updateTask(task);
//        return ResponseEntity.ok(updated);
//    }
//    
//    
//    // ═══════════════════════════════════════════════════════════════
//    // DELETE OPERATIONS
//    // ═══════════════════════════════════════════════════════════════
//    
//    /**
//     * Delete task
//     * 
//     * DELETE /api/stages/6/tasks/70
//     */
//    @DeleteMapping("/{taskId}")
//    public ResponseEntity<Void> deleteTask(
//            @PathVariable Long stageId,
//            @PathVariable Long taskId) {
//        
//        taskService.deleteTask(taskId);
//        return ResponseEntity.noContent().build();
//    }
//    
//    
//    // ═══════════════════════════════════════════════════════════════
//    // STATISTICS
//    // ═══════════════════════════════════════════════════════════════
//    
//    /**
//     * Get task statistics
//     * 
//     * GET /api/stages/6/tasks/statistics
//     */
//    @GetMapping("/statistics")
//    public ResponseEntity<Map<String, Object>> getTaskStatistics(@PathVariable Long stageId) {
//        Map<String, Object> stats = new HashMap<>();
//        
//        stats.put("totalTasks", taskService.countTotalTasks(stageId));
//        stats.put("completedTasks", taskService.countCompletedTasks(stageId));
//        stats.put("pendingMandatoryTasks", taskService.countPendingMandatoryTasks(stageId));
//        stats.put("completionPercentage", taskService.calculateCompletionPercentage(stageId));
//        
//        return ResponseEntity.ok(stats);
//    }
//}

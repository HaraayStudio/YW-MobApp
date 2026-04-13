package com.haraay.ywarchitects.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import com.haraay.ywarchitects.dto.ProjectDTO;
import com.haraay.ywarchitects.dto.ProjectLiteDTO;
import com.haraay.ywarchitects.dto.SuccessDTO;
import com.haraay.ywarchitects.model.Project;
import com.haraay.ywarchitects.service.ProjectService;
import com.haraay.ywarchitects.util.ResponseStructure;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.http.MediaType;

@RestController
@RequestMapping("/api/projects")
@CrossOrigin(origins = "*")
public class ProjectController {
    
    @Autowired
    private ProjectService projectService;
    
    
    // ═══════════════════════════════════════════════════════════════
    // CREATE OPERATIONS
    // ═══════════════════════════════════════════════════════════════
    
    /**
     * Create a new project
     * 
     * POST /api/projects
     * Body: {
     *   "projectName": "ABC Heights Residential Complex",
     *   "projectCode": "ABC-2026-001",
     *   "address": "Survey No. 42/3, Baner",
     *   "city": "Pune",
     *   "projectDetails": "Luxury residential complex",
     *   "priority": "HIGH",
     *   "plotArea": 5000.0,
     *   "totalBuiltUpArea": 12000.0
     * }
     */
    @PostMapping("/createproject")
    public ResponseEntity<ResponseStructure<ProjectDTO>> createProject(@RequestBody Project project) {
    	return projectService.createProject(project);
         
    }
//    @PostMapping("/createquickproject")
//    public ResponseEntity<ResponseStructure<ProjectDTO>> createQuickProject(
//            @RequestBody Project project) {
//        return projectService.createQuickProject(project);
//    }

    
    /**
     * Create project with basic details
     * 
     * POST /api/projects/quick
     * Body: {
     *   "projectName": "ABC Heights",
     *   "projectCode": "ABC-2026-001",
     *   "address": "Survey No. 42/3, Baner",
     *   "city": "Pune"
     * }
     */
       
    // ═══════════════════════════════════════════════════════════════
    // READ OPERATIONS
    // ═══════════════════════════════════════════════════════════════
    
    /**
     * Get all projects
     * 
     * GET /api/projects
     */
    @GetMapping("getallprojects")
    public ResponseEntity<ResponseStructure<List<ProjectLiteDTO>>> getAllProjects(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {

        return projectService.getAllProjects(page, size);
    }

    
    /**
     * Get project by ID
     * 
     * GET /api/projects/100
     */
    @GetMapping("/{projectId}")
    public ResponseEntity<ResponseStructure<ProjectDTO>> getProjectById(@PathVariable Long projectId) {
        return projectService.getProjectById(projectId);
            
    }
    
    /**
     * Get project with all stages (children nested)
     * 
     * GET /api/projects/100/with-stages
     */
    @GetMapping("/{projectId}/with-stages")
    public ResponseEntity<Project> getProjectWithStages(@PathVariable Long projectId) {
        return projectService.getProjectWithStages(projectId)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }
    
    /**
     * Get project with all relationships
     * 
     * GET /api/projects/100/complete
     */
    @GetMapping("/{projectId}/complete")
    public ResponseEntity<Project> getProjectComplete(@PathVariable Long projectId) {
        return projectService.getProjectWithAllRelations(projectId)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }
    
    /**
     * Get project by code
     * 
     * GET /api/projects/by-code/ABC-2026-001
     */
    @GetMapping("/by-code/{projectCode}")
    public ResponseEntity<Project> getProjectByCode(@PathVariable String projectCode) {
        return projectService.getProjectByCode(projectCode)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }
    
    /**
     * Get projects by status
     * 
     * GET /api/projects/status/IN_PROGRESS
     */
    @GetMapping("/status/{status}")
    public ResponseEntity<List<Project>> getProjectsByStatus(@PathVariable String status) {
        List<Project> projects = projectService.getProjectsByStatus(status);
        return ResponseEntity.ok(projects);
    }
    
    /**
     * Get projects by priority
     * 
     * GET /api/projects/priority/HIGH
     */
    @GetMapping("/priority/{priority}")
    public ResponseEntity<List<Project>> getProjectsByPriority(@PathVariable String priority) {
        List<Project> projects = projectService.getProjectsByPriority(priority);
        return ResponseEntity.ok(projects);
    }
    
    /**
     * Get projects by city
     * 
     * GET /api/projects/city/Pune
     */
    @GetMapping("/city/{city}")
    public ResponseEntity<List<Project>> getProjectsByCity(@PathVariable String city) {
        List<Project> projects = projectService.getProjectsByCity(city);
        return ResponseEntity.ok(projects);
    }
    
    /**
     * Search projects by name
     * 
     * GET /api/projects/search?name=ABC
     */
    @GetMapping("/search")
    public ResponseEntity<List<Project>> searchProjects(@RequestParam String name) {
        List<Project> projects = projectService.searchProjectsByName(name);
        return ResponseEntity.ok(projects);
    }
    
    /**
     * Get projects assigned to a user
     * 
     * GET /api/projects/user/123
     */
    @GetMapping("/user/{userId}")
    public ResponseEntity<List<Project>> getProjectsByUser(@PathVariable Long userId) {
        List<Project> projects = projectService.getProjectsByUserId(userId);
        return ResponseEntity.ok(projects);
    }
    
    /**
     * Get active projects
     * 
     * GET /api/projects/active
     */
    @GetMapping("/active")
    public ResponseEntity<List<Project>> getActiveProjects() {
        List<Project> projects = projectService.getActiveProjects();
        return ResponseEntity.ok(projects);
    }
    
    /**
     * Get recent projects
     * 
     * GET /api/projects/recent
     */
    @GetMapping("/recent")
    public ResponseEntity<List<Project>> getRecentProjects() {
        List<Project> projects = projectService.getRecentProjects();
        return ResponseEntity.ok(projects);
    }
    
    
    // ═══════════════════════════════════════════════════════════════
    // UPDATE OPERATIONS
    // ═══════════════════════════════════════════════════════════════
    
    /**
     * Update project
     * 
     * PUT /api/projects/100
     * Body: {
     *   "projectName": "ABC Heights Updated",
     *   "projectDetails": "Updated details",
     *   ...
     * }
     */
    @PutMapping(value = "/{projectId}", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ResponseStructure<ProjectDTO>> updateProject(
            @PathVariable Long projectId,
            @RequestPart("project") Project project,
            @RequestPart(value = "logo", required = false) MultipartFile logoFile) {

        return projectService.updateProject(projectId, project, logoFile);
    }
    
    /**
     * Update project status
     * 
     * PUT /api/projects/100/status
     * Body: {
     *   "status": "IN_PROGRESS"
     * }
     */
    @PutMapping("/{projectId}/status")
    public ResponseEntity<Project> updateProjectStatus(
            @PathVariable Long projectId,
            @RequestBody Map<String, String> request) {
        
        String status = request.get("status");
        Project updated = projectService.updateProjectStatus(projectId, status);
        return ResponseEntity.ok(updated);
    }
    
    /**
     * Update project priority
     * 
     * PUT /api/projects/100/priority
     * Body: {
     *   "priority": "HIGH"
     * }
     */
    @PutMapping("/{projectId}/priority")
    public ResponseEntity<Project> updateProjectPriority(
            @PathVariable Long projectId,
            @RequestBody Map<String, String> request) {
        
        String priority = request.get("priority");
        Project updated = projectService.updateProjectPriority(projectId, priority);
        return ResponseEntity.ok(updated);
    }
    
    /**
     * Update project details
     * 
     * PUT /api/projects/100/details
     * Body: {
     *   "projectName": "ABC Heights",
     *   "projectDetails": "Luxury residential",
     *   "address": "Survey No. 42/3",
     *   "city": "Pune"
     * }
     */
    @PutMapping("/{projectId}/details")
    public ResponseEntity<Project> updateProjectDetails(
            @PathVariable Long projectId,
            @RequestBody Map<String, String> request) {
        
        String projectName = request.get("projectName");
        String projectDetails = request.get("projectDetails");
        String address = request.get("address");
        String city = request.get("city");
        
        Project updated = projectService.updateProjectDetails(
            projectId, projectName, projectDetails, address, city
        );
        return ResponseEntity.ok(updated);
    }
    
    /**
     * Update project location
     * 
     * PUT /api/projects/100/location
     * Body: {
     *   "address": "Survey No. 42/3, Baner",
     *   "city": "Pune",
     *   "latitude": 18.5629,
     *   "longitude": 73.7799
     * }
     */
    @PutMapping("/{projectId}/location")
    public ResponseEntity<Project> updateProjectLocation(
            @PathVariable Long projectId,
            @RequestBody Map<String, Object> request) {
        
        String address = (String) request.get("address");
        String city = (String) request.get("city");
        Double latitude = request.get("latitude") != null 
            ? ((Number) request.get("latitude")).doubleValue() : null;
        Double longitude = request.get("longitude") != null 
            ? ((Number) request.get("longitude")).doubleValue() : null;
        
        Project updated = projectService.updateProjectLocation(
            projectId, address, city, latitude, longitude
        );
        return ResponseEntity.ok(updated);
    }
    
    /**
     * Update project area
     * 
     * PUT /api/projects/100/area
     * Body: {
     *   "plotArea": 5000.0,
     *   "totalBuiltUpArea": 12000.0,
     *   "totalCarpetArea": 9600.0
     * }
     */
    @PutMapping("/{projectId}/area")
    public ResponseEntity<Project> updateProjectArea(
            @PathVariable Long projectId,
            @RequestBody Map<String, Double> request) {
        
        Double plotArea = request.get("plotArea");
        Double totalBuiltUpArea = request.get("totalBuiltUpArea");
        Double totalCarpetArea = request.get("totalCarpetArea");
        
        Project updated = projectService.updateProjectArea(
            projectId, plotArea, totalBuiltUpArea, totalCarpetArea
        );
        return ResponseEntity.ok(updated);
    }
    
    /**
     * Set project dates
     * 
     * PUT /api/projects/100/dates
     * Body: {
     *   "startDate": "2026-01-01T00:00:00",
     *   "expectedEndDate": "2027-12-31T23:59:59"
     * }
     */
    @PutMapping("/{projectId}/dates")
    public ResponseEntity<Project> setProjectDates(
            @PathVariable Long projectId,
            @RequestBody Map<String, String> request) {
        
        LocalDateTime startDate = request.get("startDate") != null 
            ? LocalDateTime.parse(request.get("startDate")) : null;
        LocalDateTime expectedEndDate = request.get("expectedEndDate") != null 
            ? LocalDateTime.parse(request.get("expectedEndDate")) : null;
        
        Project updated = projectService.setProjectDates(projectId, startDate, expectedEndDate);
        return ResponseEntity.ok(updated);
    }
    
    
    // ═══════════════════════════════════════════════════════════════
    // DELETE OPERATIONS
    // ═══════════════════════════════════════════════════════════════
    
    /**
     * Delete project
     * 
     * DELETE /api/projects/100
     */
    @DeleteMapping("/{projectId}")
    public ResponseEntity<Void> deleteProject(@PathVariable Long projectId) {
        projectService.deleteProject(projectId);
        return ResponseEntity.noContent().build();
    }
    
    
    // ═══════════════════════════════════════════════════════════════
    // STATISTICS & ANALYTICS
    // ═══════════════════════════════════════════════════════════════
    
    /**
     * Get project statistics
     * 
     * GET /api/projects/statistics
     */
    @GetMapping("/statistics")
    public ResponseEntity<Map<String, Object>> getProjectStatistics() {
        Map<String, Object> stats = new HashMap<>();
        
        stats.put("totalProjects", projectService.getTotalProjectCount());
        stats.put("planningProjects", projectService.getProjectCountByStatus("PLANNING"));
        stats.put("inProgressProjects", projectService.getProjectCountByStatus("IN_PROGRESS"));
        stats.put("completedProjects", projectService.getProjectCountByStatus("COMPLETED"));
        stats.put("onHoldProjects", projectService.getProjectCountByStatus("ON_HOLD"));
        
        return ResponseEntity.ok(stats);
    }
    
    /**
     * Get project progress
     * 
     * GET /api/projects/100/progress
     */
    @GetMapping("/{projectId}/progress")
    public ResponseEntity<Map<String, Object>> getProjectProgress(@PathVariable Long projectId) {
        Integer progress = projectService.calculateProjectProgress(projectId);
        
        Map<String, Object> response = new HashMap<>();
        response.put("projectId", projectId);
        response.put("overallProgress", progress);
        
        return ResponseEntity.ok(response);
    }
    
        @PutMapping("/addusers/{projectId}")
    public ResponseEntity<ResponseStructure<String>> addMultipleUsers(
            @PathVariable Long projectId,
            @RequestBody List<Long> userIds) {

        projectService.addMultipleUsers(projectId, userIds);

        ResponseStructure<String> response = new ResponseStructure<>();
        response.setStatus(HttpStatus.OK.value());
        response.setMessage("Users successfully added to project");
        response.setData(userIds.size() + " user(s) added to project " + projectId);

        return ResponseEntity.ok(response);
    }
}

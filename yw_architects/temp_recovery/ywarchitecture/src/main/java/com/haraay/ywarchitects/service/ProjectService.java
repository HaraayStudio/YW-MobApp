package com.haraay.ywarchitects.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import com.haraay.ywarchitects.dto.ProjectDTO;
import com.haraay.ywarchitects.dto.ProjectLiteDTO;
import com.haraay.ywarchitects.exception.AlreadyExistsException;
import com.haraay.ywarchitects.exception.ResourceNotFoundException;
import com.haraay.ywarchitects.mapper.ProjectMapper;
import com.haraay.ywarchitects.model.DocumentType;
import com.haraay.ywarchitects.model.PostSales;
import com.haraay.ywarchitects.model.Project;
import com.haraay.ywarchitects.model.ProjectStage;
import com.haraay.ywarchitects.model.StageDocument;
import com.haraay.ywarchitects.model.StageName;
import com.haraay.ywarchitects.model.StageStatus;
import com.haraay.ywarchitects.model.User;
import com.haraay.ywarchitects.repository.PostSalesRepository;
import com.haraay.ywarchitects.repository.ProjectRepository;
import com.haraay.ywarchitects.repository.ProjectStageRepository;
import com.haraay.ywarchitects.repository.UserRepository;
import com.haraay.ywarchitects.util.ResponseStructure;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
public class ProjectService {

	private final ProjectRepository projectRepository;
	private final UserRepository userRepository;
	private final PostSalesRepository postSalesRepository;
	private final ProjectStageRepository stageRepository;

	private final ProjectMapper projectMapper;

	@Autowired
	private S3Service s3Service;

	@Autowired
	private ResponseStructure<ProjectDTO> projectDTOStructure;

	@Autowired
	private ResponseStructure<List<ProjectLiteDTO>> projectLiteDTOListStructure;

	@Autowired
	private ResponseStructure<List<ProjectDTO>> projectDTOListStructure;

	public ProjectService(ProjectRepository projectRepository, PostSalesRepository postSalesRepository,
			ProjectStageRepository stageRepository, ProjectMapper projectMapper, UserRepository userRepository) {
		this.projectRepository = projectRepository;
		this.postSalesRepository = postSalesRepository;
		this.stageRepository = stageRepository;
		this.projectMapper = projectMapper;
		this.userRepository = userRepository;

	}

	// ═══════════════════════════════════════════════════════════════
	// CREATE OPERATIONS
	// ═══════════════════════════════════════════════════════════════

	/**
	 * Create a new project { "projectName": "ABC Heights Residential Complex",
	 * "projectCode": "ABC-2026-001", "address": "Survey No. 42/3, Baner", "city":
	 * "Pune", "projectDetails": "Luxury residential complex", "priority": "HIGH",
	 * "plotArea": 5000.0, "totalBuiltUpArea": 12000.0 }
	 */
	@Transactional
	public ResponseEntity<ResponseStructure<ProjectDTO>> createProject(Project project) {

		project.setProjectCreatedDateTime(LocalDateTime.now());

		if (project.getProjectStatus() == null) {
			project.setProjectStatus("PLANNING");
		}

		// 🔥 STEP 1 — validate postsales input
		if (project.getPostSales() == null || project.getPostSales().getId() == null) {

			projectDTOStructure.setData(null);
			projectDTOStructure.setMessage("PostSales ID is required to create project!");
			projectDTOStructure.setStatus(HttpStatus.BAD_REQUEST.value());

			return new ResponseEntity<>(projectDTOStructure, HttpStatus.BAD_REQUEST);
		}

		Long postSalesId = project.getPostSales().getId();

		// 🔥 STEP 2 — fetch existing postsales
		Optional<PostSales> optPostSales = postSalesRepository.findById(postSalesId);

		if (optPostSales == null || optPostSales.isEmpty()) {
			projectDTOStructure.setData(null);
			projectDTOStructure.setMessage("PostSales Is Empty!");
			projectDTOStructure.setStatus(HttpStatus.NOT_FOUND.value());

			return new ResponseEntity<>(projectDTOStructure, HttpStatus.NOT_FOUND);

		}
		PostSales postSales = optPostSales.get();

		// 🔥 STEP 3 — prevent duplicate project mapping
		if (postSales.getProject() != null) {

			projectDTOStructure.setData(null);
			projectDTOStructure.setMessage("Project already exists for this PostSales");
			projectDTOStructure.setStatus(HttpStatus.CONFLICT.value());

			return new ResponseEntity<>(projectDTOStructure, HttpStatus.CONFLICT);
		}

		// 🔥 STEP 4 — link both sides
		project.setPostSales(postSales); // inverse side
		postSales.setProject(project); // owning side

		// 🔥 STEP 5 — save (save owning side OR project with cascade)
		Project savedProject = projectRepository.save(project);

		// 🔥 response
		projectDTOStructure.setData(projectMapper.toDTO(savedProject));
		projectDTOStructure.setMessage("CREATED");
		projectDTOStructure.setStatus(HttpStatus.CREATED.value());

		return new ResponseEntity<ResponseStructure<ProjectDTO>>(projectDTOStructure, HttpStatus.CREATED);
	}

	// ═══════════════════════════════════════════════════════════════
	// READ OPERATIONS
	// ═══════════════════════════════════════════════════════════════

	/**
	 * Get all projects
	 */
	@Transactional(readOnly = true)
	public ResponseEntity<ResponseStructure<List<ProjectLiteDTO>>> getAllProjects(int page, int size) {

		Pageable pageable = PageRequest.of(page, size);

		Page<Project> projectPage = projectRepository.findAll(pageable);

		List<ProjectLiteDTO> dtoProjects = projectMapper.toLiteDTOList(projectPage.getContent());

		ResponseStructure<List<ProjectLiteDTO>> structure = new ResponseStructure<>();
		structure.setData(dtoProjects);
		structure.setMessage("Projects fetched successfully");
		structure.setStatus(HttpStatus.OK.value());

		return new ResponseEntity<>(structure, HttpStatus.OK);
	}

	/**
	 * Get project by ID
	 */
	@Transactional(readOnly = true)
	public ResponseEntity<ResponseStructure<ProjectDTO>> getProjectById(Long projectId) {
		Optional<Project> optional = projectRepository.findById(projectId);

		if (optional.isEmpty()) {

			projectDTOStructure.setData(null);
			projectDTOStructure.setMessage("NOT FOUND !");
			projectDTOStructure.setStatus(HttpStatus.NOT_FOUND.value());

			return new ResponseEntity<ResponseStructure<ProjectDTO>>(projectDTOStructure, HttpStatus.NOT_FOUND);

		}
		projectDTOStructure.setData(projectMapper.toDTO(optional.get()));
		projectDTOStructure.setMessage("FOUND");
		projectDTOStructure.setStatus(HttpStatus.FOUND.value());

		return new ResponseEntity<ResponseStructure<ProjectDTO>>(projectDTOStructure, HttpStatus.FOUND);

	}

	/**
	 * Get project with all stages
	 */
	@Transactional(readOnly = true)
	public Optional<Project> getProjectWithStages(Long projectId) {
		return projectRepository.findByIdWithStages(projectId);
	}

	/**
	 * Get project with all relationships (stages, users, site visits, structures)
	 */
	@Transactional(readOnly = true)
	public Optional<Project> getProjectWithAllRelations(Long projectId) {
		return projectRepository.findByIdWithAllRelations(projectId);
	}

	/**
	 * Get project by project code
	 */
	@Transactional(readOnly = true)
	public Optional<Project> getProjectByCode(String projectCode) {
		return projectRepository.findByProjectCode(projectCode);
	}

	/**
	 * Get projects by status
	 */
	@Transactional(readOnly = true)
	public List<Project> getProjectsByStatus(String status) {
		return projectRepository.findByProjectStatus(status);
	}

	/**
	 * Get projects by priority
	 */
	@Transactional(readOnly = true)
	public List<Project> getProjectsByPriority(String priority) {
		return projectRepository.findByPriority(priority);
	}

	/**
	 * Get projects by city
	 */
	@Transactional(readOnly = true)
	public List<Project> getProjectsByCity(String city) {
		return projectRepository.findByCity(city);
	}

	/**
	 * Search projects by name
	 */
	@Transactional(readOnly = true)
	public List<Project> searchProjectsByName(String name) {
		return projectRepository.searchByName(name);
	}

	/**
	 * Get projects assigned to a user
	 */
	@Transactional(readOnly = true)
	public List<Project> getProjectsByUserId(Long userId) {
		return projectRepository.findProjectsByUserId(userId);
	}

	/**
	 * Get active projects
	 */
	@Transactional(readOnly = true)
	public List<Project> getActiveProjects() {
		return projectRepository.findActiveProjects();
	}

	/**
	 * Get recent projects
	 */
	@Transactional(readOnly = true)
	public List<Project> getRecentProjects() {
		return projectRepository.findRecentProjects();
	}

	// ═══════════════════════════════════════════════════════════════
	// UPDATE OPERATIONS
	// ═══════════════════════════════════════════════════════════════

	/**
	 * Update project
	 */

	@Transactional
	public ResponseEntity<ResponseStructure<ProjectDTO>> updateProject(Long projectId, Project newProject,
			MultipartFile logoFile) {

		Optional<Project> optionalProject = projectRepository.findById(projectId);

		if (optionalProject.isEmpty()) {
			projectDTOStructure.setData(null);
			projectDTOStructure.setMessage("Project is Not exists with id - " + projectId);
			projectDTOStructure.setStatus(HttpStatus.NOT_FOUND.value());

			return new ResponseEntity<>(projectDTOStructure, HttpStatus.NOT_FOUND);
		}

		Project existingProject = optionalProject.get();

		if (logoFile != null && !logoFile.isEmpty()) {
			String logoUrl = s3Service.uploadFile(logoFile); // your S3/local logic
			existingProject.setLogoUrl(logoUrl);
		}

		// 🔥 transfer simple fields
		existingProject.setProjectCode(newProject.getProjectCode());
		existingProject.setPermanentProjectId(newProject.getPermanentProjectId());

		existingProject.setProjectName(newProject.getProjectName());
		existingProject.setProjectDetails(newProject.getProjectDetails());

		existingProject.setAddress(newProject.getAddress());
		existingProject.setCity(newProject.getCity());
		existingProject.setLatitude(newProject.getLatitude());
		existingProject.setLongitude(newProject.getLongitude());
		existingProject.setGooglePlace(newProject.getGooglePlace());

		existingProject.setPlotArea(newProject.getPlotArea());
		existingProject.setTotalBuiltUpArea(newProject.getTotalBuiltUpArea());
		existingProject.setTotalCarpetArea(newProject.getTotalCarpetArea());

		existingProject.setProjectStatus(newProject.getProjectStatus());
		existingProject.setProjectStartDateTime(newProject.getProjectStartDateTime());
		existingProject.setProjectExpectedEndDate(newProject.getProjectExpectedEndDate());
		existingProject.setProjectEndDateTime(newProject.getProjectEndDateTime());
		existingProject.setPriority(newProject.getPriority());

		// 🔥 save managed entity
		Project savedProject = projectRepository.save(existingProject);

		if (savedProject == null) {
			projectDTOStructure.setData(null);
			projectDTOStructure.setMessage("Failed to save Project");
			projectDTOStructure.setStatus(HttpStatus.INTERNAL_SERVER_ERROR.value());

			return new ResponseEntity<>(projectDTOStructure, HttpStatus.INTERNAL_SERVER_ERROR);
		}

		// 🔥 convert to DTO (assuming mapper exists)
		ProjectDTO dto = projectMapper.toDTO(savedProject);

		projectDTOStructure.setData(dto);
		projectDTOStructure.setMessage("Project Updated Successfully");
		projectDTOStructure.setStatus(HttpStatus.OK.value());

		return new ResponseEntity<>(projectDTOStructure, HttpStatus.OK);
	}

	/**
	 * Update project status
	 */
	@Transactional
	public Project updateProjectStatus(Long projectId, String status) {
		Project project = projectRepository.findById(projectId)
				.orElseThrow(() -> new RuntimeException("Project not found with id: " + projectId));

		project.setProjectStatus(status);

		if ("IN_PROGRESS".equals(status) && project.getProjectStartDateTime() == null) {
			project.setProjectStartDateTime(LocalDateTime.now());
		}

		if ("COMPLETED".equals(status)) {
			project.setProjectEndDateTime(LocalDateTime.now());
		}

		return projectRepository.save(project);
	}

	/**
	 * Update project priority
	 */
	@Transactional
	public Project updateProjectPriority(Long projectId, String priority) {
		Project project = projectRepository.findById(projectId)
				.orElseThrow(() -> new RuntimeException("Project not found with id: " + projectId));

		project.setPriority(priority);
		return projectRepository.save(project);
	}

	/**
	 * Update project details
	 */
	@Transactional
	public Project updateProjectDetails(Long projectId, String projectName, String projectDetails, String address,
			String city) {
		Project project = projectRepository.findById(projectId)
				.orElseThrow(() -> new RuntimeException("Project not found with id: " + projectId));

		if (projectName != null)
			project.setProjectName(projectName);
		if (projectDetails != null)
			project.setProjectDetails(projectDetails);
		if (address != null)
			project.setAddress(address);
		if (city != null)
			project.setCity(city);

		return projectRepository.save(project);
	}

	/**
	 * Update project location
	 */
	@Transactional
	public Project updateProjectLocation(Long projectId, String address, String city, Double latitude,
			Double longitude) {
		Project project = projectRepository.findById(projectId)
				.orElseThrow(() -> new RuntimeException("Project not found with id: " + projectId));

		project.setAddress(address);
		project.setCity(city);
		project.setLatitude(latitude);
		project.setLongitude(longitude);

		return projectRepository.save(project);
	}

	/**
	 * Update project area details
	 */
	@Transactional
	public Project updateProjectArea(Long projectId, Double plotArea, Double totalBuiltUpArea, Double totalCarpetArea) {
		Project project = projectRepository.findById(projectId)
				.orElseThrow(() -> new RuntimeException("Project not found with id: " + projectId));

		if (plotArea != null)
			project.setPlotArea(plotArea);
		if (totalBuiltUpArea != null)
			project.setTotalBuiltUpArea(totalBuiltUpArea);
		if (totalCarpetArea != null)
			project.setTotalCarpetArea(totalCarpetArea);

		return projectRepository.save(project);
	}

	/**
	 * Set project dates
	 */
	@Transactional
	public Project setProjectDates(Long projectId, LocalDateTime startDate, LocalDateTime expectedEndDate) {
		Project project = projectRepository.findById(projectId)
				.orElseThrow(() -> new RuntimeException("Project not found with id: " + projectId));

		if (startDate != null)
			project.setProjectStartDateTime(startDate);
		if (expectedEndDate != null)
			project.setProjectExpectedEndDate(expectedEndDate);

		return projectRepository.save(project);
	}

	// ═══════════════════════════════════════════════════════════════
	// DELETE OPERATIONS
	// ═══════════════════════════════════════════════════════════════

	/**
	 * Delete project
	 */
	@Transactional
	public void deleteProject(Long projectId) {
		projectRepository.deleteById(projectId);
	}

	// ═══════════════════════════════════════════════════════════════
	// STATISTICS & ANALYTICS
	// ═══════════════════════════════════════════════════════════════

	/**
	 * Get project count by status
	 */
	@Transactional(readOnly = true)
	public Long getProjectCountByStatus(String status) {
		return projectRepository.countByProjectStatus(status);
	}

	/**
	 * Get total project count
	 */
	@Transactional(readOnly = true)
	public Long getTotalProjectCount() {
		return projectRepository.count();
	}

	/**
	 * Calculate overall project progress based on stages
	 */
	@Transactional(readOnly = true)
	public Integer calculateProjectProgress(Long projectId) {

		List<ProjectStage> parentStages = stageRepository.findParentStagesByProjectId(projectId);

		if (parentStages == null || parentStages.isEmpty()) {
			return 0;
		}

		int totalProgress = parentStages.stream().filter(stage -> stage.getProgressPercentage() != null)
				.mapToInt(ProjectStage::getProgressPercentage).sum();

		return totalProgress / parentStages.size();
	}

	@Transactional
	public Project createQuickProject() {

		Project project = new Project();

		project.setProjectCreatedDateTime(LocalDateTime.now());

		if (project.getProjectStatus() == null) {
			project.setProjectStatus("PLANNING");
		}

		// ✅ auto create stage hierarchy
		buildDefaultProjectStages(project);

		return project;

	}

	private ProjectStage createParentStage(Project project, StageName stageName, int order) {

		ProjectStage stage = new ProjectStage();
		stage.setProject(project);
		stage.setStageName(stageName);
		stage.setDisplayOrder(order);
		stage.setProgressPercentage(0);
		stage.setStatus(StageStatus.NOT_STARTED);

		project.getStages().add(stage);
		return stage;
//		return stageRepository.save(stage);
	}

	private ProjectStage createChildStage(Project project, ProjectStage parent, StageName stageName, String customName,
			int order) {

		ProjectStage stage = new ProjectStage();
		stage.setProject(project);
		stage.setStageName(stageName);
		stage.setCustomStageName(customName);
		stage.setParentStage(parent);
		stage.setDisplayOrder(order);
		stage.setProgressPercentage(0);
		stage.setStatus(StageStatus.NOT_STARTED);

		project.getStages().add(stage);

		return stage;
//		return stageRepository.save(stage);
	}

	private void buildDefaultProjectStages(Project project) {

		// =========================================================
		// 1️⃣ CONCEPT DESIGN
		// =========================================================
		ProjectStage concept = createParentStage(project, StageName.CONCEPT_DESIGN, 1);

		createChildStage(project, concept, StageName.CONCEPT_DESIGN, "Concept Drawings", 1);
		createChildStage(project, concept, StageName.CONCEPT_DESIGN, "Massing Study", 2);
		createChildStage(project, concept, StageName.CONCEPT_DESIGN, "Basic Floor Plans", 3);
		createChildStage(project, concept, StageName.CONCEPT_DESIGN, "Client Approval on Concept", 4);

		// create documents

//		concept.getDocuments().add(new StageDocument("Concept Drawings",DocumentType.OTHER));
//		concept.getDocuments().add(new StageDocument("Massing Study",DocumentType.OTHER));
//		concept.getDocuments().add(new StageDocument("Basic Floor Plans",DocumentType.OTHER));
//		concept.getDocuments().add(new StageDocument("Client Approval on Concept",DocumentType.OTHER));

		// =========================================================
		// 2️⃣ DETAILED DESIGN
		// =========================================================
		ProjectStage detailed = createParentStage(project, StageName.FINAL_DRAWINGS, 2);

		createChildStage(project, detailed, StageName.FINAL_DRAWINGS, "Architectural Layouts", 1);
		createChildStage(project, detailed, StageName.FINAL_DRAWINGS, "Sections & Elevations", 2);
		createChildStage(project, detailed, StageName.FINAL_DRAWINGS, "Parking Layout", 3);
		createChildStage(project, detailed, StageName.FINAL_DRAWINGS, "Area Statement", 4);
		createChildStage(project, detailed, StageName.FINAL_DRAWINGS, "3D Views", 5);

		// =========================================================
		// 3️⃣ DOCUMENTATION STAGE
		// =========================================================
		ProjectStage documentation = createParentStage(project, StageName.DOCUMENTATION_STAGE, 3);

		createChildStage(project, documentation, StageName.DOCUMENTATION_STAGE, "Final Architectural Drawings", 1);
		createChildStage(project, documentation, StageName.DOCUMENTATION_STAGE, "7/12 Extract / Property Card", 2);
		createChildStage(project, documentation, StageName.DOCUMENTATION_STAGE, "Latest Demarcation Copy", 3);
		createChildStage(project, documentation, StageName.DOCUMENTATION_STAGE, "Power of Attorney", 4);
		createChildStage(project, documentation, StageName.DOCUMENTATION_STAGE, "DP Opinion", 5);

		// =========================================================
		// 4️⃣ BUILDING PERMISSION STAGE
		// =========================================================
		ProjectStage buildingPermission = createParentStage(project, StageName.BUILDING_PERMISSION, 4);

		// 💧 Water NOC
		ProjectStage waterNoc = createChildStage(project, buildingPermission, StageName.NOC_PREPARATION, "Water NOC",
				1);
		createChildStage(project, waterNoc, StageName.NOC_PREPARATION, "Application", 1);
		createChildStage(project, waterNoc, StageName.NOC_PREPARATION, "Water Line Layout", 2);
		createChildStage(project, waterNoc, StageName.NOC_PREPARATION, "Tank Capacity Calculation", 3);
		createChildStage(project, waterNoc, StageName.NOC_PREPARATION, "Fire Water Requirement", 4);

		// 🚰 Drainage NOC
		ProjectStage drainageNoc = createChildStage(project, buildingPermission, StageName.NOC_PREPARATION,
				"Drainage NOC", 2);
		createChildStage(project, drainageNoc, StageName.NOC_PREPARATION, "Application", 1);
		createChildStage(project, drainageNoc, StageName.NOC_PREPARATION, "Architectural Drawing", 2);
		createChildStage(project, drainageNoc, StageName.NOC_PREPARATION, "Drainage Layout", 3);
		createChildStage(project, drainageNoc, StageName.NOC_PREPARATION, "Hamipatr", 4);
		createChildStage(project, drainageNoc, StageName.NOC_PREPARATION, "STP Calculation", 5);
		createChildStage(project, drainageNoc, StageName.NOC_PREPARATION, "Google Location Map", 6);

		// 🌳 Garden NOC
		ProjectStage gardenNoc = createChildStage(project, buildingPermission, StageName.NOC_PREPARATION, "Garden NOC",
				3);
		createChildStage(project, gardenNoc, StageName.NOC_PREPARATION, "Tree Marking Plan", 1);
		createChildStage(project, gardenNoc, StageName.NOC_PREPARATION, "Site Images", 2);
		createChildStage(project, gardenNoc, StageName.NOC_PREPARATION, "Plot Area as per 7/12", 3);

		// 🔥 Fire NOC
		ProjectStage fireNoc = createChildStage(project, buildingPermission, StageName.NOC_PREPARATION, "Fire NOC", 4);
		createChildStage(project, fireNoc, StageName.NOC_PREPARATION, "Fire Layout Plan", 1);
		createChildStage(project, fireNoc, StageName.NOC_PREPARATION, "Driveway Width Marking", 2);
		createChildStage(project, fireNoc, StageName.NOC_PREPARATION, "Entry/Exit Gate Width", 3);
		createChildStage(project, fireNoc, StageName.NOC_PREPARATION, "Ramp Details", 4);
		createChildStage(project, fireNoc, StageName.NOC_PREPARATION, "Fire Water Calculations", 5);

		// 🏢 Elevation / Height NOC
		ProjectStage elevationNoc = createChildStage(project, buildingPermission, StageName.NOC_PREPARATION,
				"Elevation / Height NOC", 5);
		createChildStage(project, elevationNoc, StageName.NOC_PREPARATION, "Elevation Drawing", 1);
		createChildStage(project, elevationNoc, StageName.NOC_PREPARATION, "Section with Building Height", 2);
		createChildStage(project, elevationNoc, StageName.NOC_PREPARATION, "Crane Height Marking", 3);
		createChildStage(project, elevationNoc, StageName.NOC_PREPARATION, "Monarch Report", 4);

		// ♻ C & D Waste NOC
		ProjectStage cdWaste = createChildStage(project, buildingPermission, StageName.NOC_PREPARATION,
				"C & D Waste NOC", 6);
		createChildStage(project, cdWaste, StageName.NOC_PREPARATION, "C&D Waste Calculation", 1);
		createChildStage(project, cdWaste, StageName.NOC_PREPARATION, "Disposal Plan", 2);

		// =========================================================
		// 5️⃣ SURVEY & LAND RECORDS
		// =========================================================
		ProjectStage survey = createParentStage(project, StageName.SURVEY_LAND_RECORDS, 5);

		createChildStage(project, survey, StageName.SURVEY_LAND_RECORDS, "Demarcation Nakal", 1);
		createChildStage(project, survey, StageName.SURVEY_LAND_RECORDS, "Demarcation K-Prat", 2);
		createChildStage(project, survey, StageName.SURVEY_LAND_RECORDS, "Tree Survey", 3);
		createChildStage(project, survey, StageName.SURVEY_LAND_RECORDS, "DP Abhipray", 4);

		// =========================================================
		// 6️⃣ BUILDING PERMISSION SCRUTINY
		// =========================================================
		ProjectStage scrutiny = createParentStage(project, StageName.BUILDING_PERMISSION_SCRUTINY, 6);

		createChildStage(project, scrutiny, StageName.BUILDING_PERMISSION_SCRUTINY, "Inward Submission at CFC", 1);
		createChildStage(project, scrutiny, StageName.BUILDING_PERMISSION_SCRUTINY, "Online Inward Entry", 2);
		createChildStage(project, scrutiny, StageName.BUILDING_PERMISSION_SCRUTINY, "Site Visits (JE / DE / EE)", 3);
		createChildStage(project, scrutiny, StageName.BUILDING_PERMISSION_SCRUTINY, "Pre-DCR Drawing Run", 4);
		createChildStage(project, scrutiny, StageName.BUILDING_PERMISSION_SCRUTINY, "Drawing Scrutiny", 5);
		createChildStage(project, scrutiny, StageName.BUILDING_PERMISSION_SCRUTINY, "Challan Calculation & Payment", 6);
		createChildStage(project, scrutiny, StageName.BUILDING_PERMISSION_SCRUTINY, "Demand Sheet Entry", 7);
		createChildStage(project, scrutiny, StageName.BUILDING_PERMISSION_SCRUTINY, "Sanction Number Generation", 8);
		createChildStage(project, scrutiny, StageName.BUILDING_PERMISSION_SCRUTINY, "Sanction Copy Collection", 9);

		// =========================================================
		// 7️⃣ SETBACK APPROVAL
		// =========================================================
		ProjectStage setback = createParentStage(project, StageName.SETBACK_APPROVAL, 7);

		createChildStage(project, setback, StageName.SETBACK_APPROVAL, "Application", 1);
		createChildStage(project, setback, StageName.SETBACK_APPROVAL, "Sanctioned Plan Copy", 2);
		createChildStage(project, setback, StageName.SETBACK_APPROVAL, "Commencement Certificate", 3);
		createChildStage(project, setback, StageName.SETBACK_APPROVAL, "Total Station Survey", 4);

		// =========================================================
		// 8️⃣ PLINTH CHECKING
		// =========================================================
		ProjectStage plinth = createParentStage(project, StageName.PLINTH_CHECKING, 8);

		createChildStage(project, plinth, StageName.PLINTH_CHECKING, "Application", 1);
		createChildStage(project, plinth, StageName.PLINTH_CHECKING, "Structural Stability Certificate", 2);
		createChildStage(project, plinth, StageName.PLINTH_CHECKING, "NA Order", 3);
		createChildStage(project, plinth, StageName.PLINTH_CHECKING, "Water & Drainage NOCs", 4);
		createChildStage(project, plinth, StageName.PLINTH_CHECKING, "Condition Compliance", 5);

		// =========================================================
		// 9️⃣ TDR / FSI STAGE
		// =========================================================
		ProjectStage tdrParent = createParentStage(project, StageName.TDR_FSI_STAGE, 9);

		// 🔹 TDR Generation
		ProjectStage tdrGeneration = createChildStage(project, tdrParent, StageName.TDR_FSI_STAGE, "TDR Generation", 1);

		createChildStage(project, tdrGeneration, StageName.TDR_FSI_STAGE, "Search & Title Report", 1);
		createChildStage(project, tdrGeneration, StageName.TDR_FSI_STAGE, "Ownership Documents", 2);
		createChildStage(project, tdrGeneration, StageName.TDR_FSI_STAGE, "Prapatra A & B", 3);

		// 🔹 TDR Utilization
		ProjectStage tdrUtilization = createChildStage(project, tdrParent, StageName.TDR_FSI_STAGE, "TDR Utilization",
				2);

		createChildStage(project, tdrUtilization, StageName.TDR_FSI_STAGE, "TDR Undertaking", 1);
		createChildStage(project, tdrUtilization, StageName.TDR_FSI_STAGE, "Development Agreement", 2);
		createChildStage(project, tdrUtilization, StageName.TDR_FSI_STAGE, "Sanctioned Plan", 3);

		// =========================================================
		// 🔟 CONSTRUCTION STAGE
		// =========================================================
		ProjectStage construction = createParentStage(project, StageName.CONSTRUCTION_EXECUTION, 10);

		createChildStage(project, construction, StageName.CONSTRUCTION_EXECUTION, "Excavation", 1);
		createChildStage(project, construction, StageName.CONSTRUCTION_EXECUTION, "Foundation Work", 2);
		createChildStage(project, construction, StageName.CONSTRUCTION_EXECUTION, "Superstructure", 3);
		createChildStage(project, construction, StageName.CONSTRUCTION_EXECUTION, "Services Installation", 4);
		createChildStage(project, construction, StageName.CONSTRUCTION_EXECUTION, "Finishing Work", 5);

		// =========================================================
		// 1️⃣1️⃣ COMPLETION PROCESS
		// =========================================================
		ProjectStage completion = createParentStage(project, StageName.COMPLETION_PROCESS, 11);

		createChildStage(project, completion, StageName.COMPLETION_PROCESS, "Application for Completion", 1);
		createChildStage(project, completion, StageName.COMPLETION_PROCESS, "Site Inspections (JE / DE / EE)", 2);
		createChildStage(project, completion, StageName.COMPLETION_PROCESS, "Structural Stability Certificate", 3);
		createChildStage(project, completion, StageName.COMPLETION_PROCESS, "Final NOCs", 4);
		createChildStage(project, completion, StageName.COMPLETION_PROCESS, "Solar Certificate", 5);
		createChildStage(project, completion, StageName.COMPLETION_PROCESS, "Rainwater Harvesting Certificate", 6);
		createChildStage(project, completion, StageName.COMPLETION_PROCESS, "Lift NOC", 7);
		createChildStage(project, completion, StageName.COMPLETION_PROCESS, "STP Certificate", 8);
		createChildStage(project, completion, StageName.COMPLETION_PROCESS, "Consent to Operate / Establish", 9);
		createChildStage(project, completion, StageName.COMPLETION_PROCESS, "Completion Certificate Approval", 10);
		createChildStage(project, completion, StageName.COMPLETION_PROCESS, "Final Outward & Certificate Collection",
				11);
	}

	

	// Service
	public Project addMultipleUsers(Long projectId, List<Long> userIds) {

		// Check project exists
		Project project = projectRepository.findById(projectId)
				.orElseThrow(() -> new ResourceNotFoundException("Project not found with id: " + projectId));

		// Check if userIds list is empty
		if (userIds == null || userIds.isEmpty()) {
			throw new IllegalArgumentException("User id list cannot be empty");
		}

		for (Long userId : userIds) {
			// Check each user exists
			User user = userRepository.findById(userId)
					.orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + userId));

			// Skip if user already in project
			if (project.getWorkingemployee().contains(user)) {
				continue; // skip silently, or throw if you want strict behavior
			}

			// Add both sides of ManyToMany
			project.getWorkingemployee().add(user);
			user.getProjects().add(project);
			userRepository.save(user);
		}

		return projectRepository.save(project);
	}

}

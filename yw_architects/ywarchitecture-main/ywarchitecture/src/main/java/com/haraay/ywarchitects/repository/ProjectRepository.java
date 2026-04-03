package com.haraay.ywarchitects.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.haraay.ywarchitects.model.Project;

import java.util.List;
import java.util.Optional;

@Repository
public interface ProjectRepository extends JpaRepository<Project, Long> {
    
    /**
     * Find project by project code
     */
    Optional<Project> findByProjectCode(String projectCode);
    
    /**
     * Find projects by status
     */
    List<Project> findByProjectStatus(String status);
    
    /**
     * Find projects by priority
     */
    List<Project> findByPriority(String priority);
    
    /**
     * Find projects by city
     */
    List<Project> findByCity(String city);
    
    /**
     * Find project with all stages loaded
     */
    @Query("SELECT p FROM Project p LEFT JOIN FETCH p.stages WHERE p.projectId = :projectId")
    Optional<Project> findByIdWithStages(@Param("projectId") Long projectId);
    
    /**
     * Find project with all relationships loaded
     */
    @Query("SELECT DISTINCT p FROM Project p " +
           "LEFT JOIN FETCH p.stages " +
           "LEFT JOIN FETCH p.workingemployee " +
           "LEFT JOIN FETCH p.siteVisits " +
           "LEFT JOIN FETCH p.structures " +
           "WHERE p.projectId = :projectId")
    Optional<Project> findByIdWithAllRelations(@Param("projectId") Long projectId);
    
    /**
     * Search projects by name
     */
    @Query("SELECT p FROM Project p WHERE LOWER(p.projectName) LIKE LOWER(CONCAT('%', :name, '%'))")
    List<Project> searchByName(@Param("name") String name);
    
    /**
     * Find projects assigned to a specific user
     */
    @Query("SELECT p FROM Project p JOIN p.workingemployee u WHERE u.id = :userId")
    List<Project> findProjectsByUserId(@Param("userId") Long userId);
    
    /**
     * Count projects by status
     */
    Long countByProjectStatus(String status);
    
    /**
     * Find active projects (not completed or cancelled)
     */
    @Query("SELECT p FROM Project p WHERE p.projectStatus NOT IN ('COMPLETED', 'CANCELLED') ORDER BY p.projectCreatedDateTime DESC")
    List<Project> findActiveProjects();
    
    /**
     * Find recently created projects
     */
    @Query("SELECT p FROM Project p ORDER BY p.projectCreatedDateTime DESC")
    List<Project> findRecentProjects();
}
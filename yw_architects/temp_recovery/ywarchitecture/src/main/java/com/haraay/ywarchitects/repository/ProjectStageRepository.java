package com.haraay.ywarchitects.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import com.haraay.ywarchitects.model.ProjectStage;

public interface ProjectStageRepository extends JpaRepository<ProjectStage, Long>{

	@Query("""
		    SELECT ps
		    FROM ProjectStage ps
		    WHERE ps.project.projectId = :projectId
		    AND ps.parentStage IS NULL
		""")
		List<ProjectStage> findParentStagesByProjectId(Long projectId);


}

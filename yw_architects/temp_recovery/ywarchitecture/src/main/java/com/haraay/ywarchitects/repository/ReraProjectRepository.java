package com.haraay.ywarchitects.repository;

import com.haraay.ywarchitects.model.ReraProject;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface ReraProjectRepository extends JpaRepository<ReraProject, Long> {
	Optional<ReraProject> findByProject_ProjectId(long projectId);

	boolean existsByReraNumber(String reraNumber);
}
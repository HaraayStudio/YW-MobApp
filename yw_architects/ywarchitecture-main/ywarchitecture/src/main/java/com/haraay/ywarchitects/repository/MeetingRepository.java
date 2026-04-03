package com.haraay.ywarchitects.repository;

import com.haraay.ywarchitects.model.Meeting;
import com.haraay.ywarchitects.model.MeetingMessage;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.util.List;

public interface MeetingRepository extends JpaRepository<Meeting, Long> {

	List<Meeting> findByProjectProjectIdOrderByScheduledAtDesc(long projectId);

	@Query("SELECT m FROM Meeting m WHERE m.project.projectId = :projectId AND m.status = :status")
	List<Meeting> findByProjectAndStatus(@Param("projectId") long projectId, @Param("status") String status);
}
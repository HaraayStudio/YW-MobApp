package com.haraay.ywarchitects.repository;

import com.haraay.ywarchitects.model.Attendance;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface AttendanceRepository extends JpaRepository<Attendance, Long> {

	// Monthly fetch for one user
	List<Attendance> findByUserIdAndAttendanceDateBetween(Long userId, LocalDate start, LocalDate end);

	// Monthly fetch for all users (HR view)
	List<Attendance> findByAttendanceDateBetween(LocalDate start, LocalDate end);

	// Prevent duplicate entry on bulk re-save
	Optional<Attendance> findByUserIdAndAttendanceDate(Long userId, LocalDate date);

	List<Attendance> findByAttendanceDate(LocalDate date);
}
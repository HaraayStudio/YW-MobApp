package com.haraay.ywarchitects.service;

import com.haraay.ywarchitects.dto.AttendanceDTO;
import com.haraay.ywarchitects.dto.BulkAttendanceRequest;
import com.haraay.ywarchitects.dto.UserDTO;
import com.haraay.ywarchitects.exception.ResourceNotFoundException;
import com.haraay.ywarchitects.mapper.AttendanceMapper;
import com.haraay.ywarchitects.model.Attendance;
import com.haraay.ywarchitects.model.AttendanceStatus;
import com.haraay.ywarchitects.model.User;
import com.haraay.ywarchitects.repository.AttendanceRepository;
import com.haraay.ywarchitects.repository.UserRepository;
import com.haraay.ywarchitects.util.JwtUtil;
import com.haraay.ywarchitects.util.ResponseStructure;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
public class AttendanceService {

	@Autowired
	private JwtUtil jwtUtil;

	@Autowired
	private AttendanceRepository attendanceRepository;

	@Autowired
	private UserRepository userRepository;

	@Autowired
	private AttendanceMapper attendanceMapper;

	// ── HR: bulk mark attendance for a date ──────────────────────────────────
	@Transactional
	public ResponseEntity<ResponseStructure<List<AttendanceDTO>>> markBulkAttendance(LocalDate date,
			List<BulkAttendanceRequest> requests) {

		List<Attendance> saved = new ArrayList<>();

		for (BulkAttendanceRequest req : requests) {

			User user = userRepository.findById(req.getUserId())
					.orElseThrow(() -> new ResourceNotFoundException("User not found: " + req.getUserId()));

			// If attendance already exists for this user+date, update it
			Attendance attendance = attendanceRepository.findByUserIdAndAttendanceDate(req.getUserId(), date)
					.orElse(new Attendance()); // create new if not exists

			attendance.setUser(user);
			attendance.setAttendanceDate(date);
			attendance.setStatus(req.getStatus());
			attendance.setCheckIn(req.getCheckIn());
			attendance.setCheckOut(req.getCheckOut());
			attendance.setRemarks(req.getRemarks());

			saved.add(attendanceRepository.save(attendance));
		}

		ResponseStructure<List<AttendanceDTO>> response = new ResponseStructure<>();
		response.setStatus(HttpStatus.OK.value());
		response.setMessage("Attendance marked for " + saved.size() + " employees on " + date);
		response.setData(attendanceMapper.toDTOList(saved));

		return ResponseEntity.ok(response);
	}

	// ── User/HR: fetch monthly attendance for one user ───────────────────────
	public ResponseEntity<ResponseStructure<List<AttendanceDTO>>> getMonthlyAttendance(Long userId, int month,
			int year) {

		LocalDate start = LocalDate.of(year, month, 1);
		LocalDate end = start.withDayOfMonth(start.lengthOfMonth());

		List<Attendance> records = attendanceRepository.findByUserIdAndAttendanceDateBetween(userId, start, end);

		ResponseStructure<List<AttendanceDTO>> response = new ResponseStructure<>();
		response.setStatus(HttpStatus.OK.value());
		response.setMessage("Attendance for month " + month + "/" + year);
		response.setData(attendanceMapper.toDTOList(records));

		return ResponseEntity.ok(response);
	}

	// ── HR: fetch all employees attendance for a month ───────────────────────
	public ResponseEntity<ResponseStructure<List<AttendanceDTO>>> getAllEmployeesMonthlyAttendance(int month,
			int year) {

		LocalDate start = LocalDate.of(year, month, 1);
		LocalDate end = start.withDayOfMonth(start.lengthOfMonth());

		List<Attendance> records = attendanceRepository.findByAttendanceDateBetween(start, end);

		ResponseStructure<List<AttendanceDTO>> response = new ResponseStructure<>();
		response.setStatus(HttpStatus.OK.value());
		response.setMessage("All employees attendance for " + month + "/" + year);
		response.setData(attendanceMapper.toDTOList(records));

		return ResponseEntity.ok(response);
	}

	public ResponseEntity<ResponseStructure<List<AttendanceDTO>>> getMyMonthlyAttendance(String token, int month,
			int year) {
		String jwtToken = token.replace("Bearer ", "");
		String email = jwtUtil.getEmailFromToken(jwtToken);
		Optional<User> optionalUser = userRepository.findByEmail(email);

		ResponseStructure<List<AttendanceDTO>> response = new ResponseStructure<>();
		if (optionalUser.isEmpty()) {

			response.setStatus(HttpStatus.NOT_FOUND.value());
			response.setMessage("USER NOT FOUND ");
			response.setData(null);

			return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);

		}

		User user = optionalUser.get();
		LocalDate start = LocalDate.of(year, month, 1);
		LocalDate end = start.withDayOfMonth(start.lengthOfMonth());

		List<Attendance> records = attendanceRepository.findByUserIdAndAttendanceDateBetween(user.getId(), start, end);

		response.setStatus(HttpStatus.OK.value());
		response.setMessage("My Attendance for month " + month + "/" + year);
		response.setData(attendanceMapper.toDTOList(records));

		return ResponseEntity.ok(response);
	}

	// ── HR: mark single user attendance ─────────────────────────────────────
	@Transactional
	public ResponseEntity<ResponseStructure<AttendanceDTO>> markSingleAttendance(LocalDate date,
			BulkAttendanceRequest req) {

		User user = userRepository.findById(req.getUserId())
				.orElseThrow(() -> new ResourceNotFoundException("User not found: " + req.getUserId()));

		Attendance attendance = attendanceRepository.findByUserIdAndAttendanceDate(req.getUserId(), date)
				.orElse(new Attendance());

		attendance.setUser(user);
		attendance.setAttendanceDate(date);
		attendance.setStatus(req.getStatus());
		attendance.setCheckIn(req.getCheckIn());
		attendance.setCheckOut(req.getCheckOut());
		attendance.setRemarks(req.getRemarks());

		Attendance saved = attendanceRepository.save(attendance);

		ResponseStructure<AttendanceDTO> response = new ResponseStructure<>();
		response.setStatus(HttpStatus.OK.value());
		response.setMessage("Attendance marked for user " + req.getUserId() + " on " + date);
		response.setData(attendanceMapper.toDTO(saved));

		return ResponseEntity.ok(response);
	}

	// ── HR: record check-in time ─────────────────────────────────────────────
	@Transactional
	public ResponseEntity<ResponseStructure<AttendanceDTO>> recordCheckIn(Long userId, LocalDate date, LocalTime time) {

		User user = userRepository.findById(userId)
				.orElseThrow(() -> new ResourceNotFoundException("User not found: " + userId));

		Attendance attendance = attendanceRepository.findByUserIdAndAttendanceDate(userId, date)
				.orElse(new Attendance()); // create if not exists

		// Guard: already checked in
		if (attendance.getCheckIn() != null) {
			throw new IllegalStateException("Check-in already recorded for user " + userId + " on " + date);
		}

		// Set missing fields when creating new record
		attendance.setUser(user);
		attendance.setAttendanceDate(date);
		attendance.setStatus(AttendanceStatus.PRESENT); // auto PRESENT when HR adds check-in

		attendance.setCheckIn(time);
		Attendance saved = attendanceRepository.save(attendance);

		ResponseStructure<AttendanceDTO> response = new ResponseStructure<>();
		response.setStatus(HttpStatus.OK.value());
		response.setMessage("Check-in time recorded: " + time);
		response.setData(attendanceMapper.toDTO(saved));

		return ResponseEntity.ok(response);
	}

	// ── HR: record check-out time ────────────────────────────────────────────
	@Transactional
	public ResponseEntity<ResponseStructure<AttendanceDTO>> recordCheckOut(Long userId, LocalDate date,
			LocalTime time,String attendanceStatus) {

		Attendance attendance = attendanceRepository.findByUserIdAndAttendanceDate(userId, date)
				.orElseThrow(() -> new ResourceNotFoundException("No attendance record found for user " + userId
						+ " on " + date + ". Mark attendance first before adding check-out time."));

		if (attendance.getCheckIn() != null && time.isBefore(attendance.getCheckIn())) {
			throw new IllegalArgumentException("Check-out time cannot be before check-in time");
		}

		attendance.setCheckOut(time);
		attendance.setStatus(AttendanceStatus.valueOf(attendanceStatus.toUpperCase()));

		Attendance saved = attendanceRepository.save(attendance);

		ResponseStructure<AttendanceDTO> response = new ResponseStructure<>();
		response.setStatus(HttpStatus.OK.value());
		response.setMessage("Check-out time recorded: " + time);
		response.setData(attendanceMapper.toDTO(saved));

		return ResponseEntity.ok(response);
	}

	public ResponseEntity<ResponseStructure<AttendanceDTO>> recordMyCheckIn(String token, LocalDate date,
			LocalTime time) {

		String jwtToken = token.replace("Bearer ", "");
		String email = jwtUtil.getEmailFromToken(jwtToken);

		User user = userRepository.findByEmail(email)
				.orElseThrow(() -> new ResourceNotFoundException("User not found"));

		Attendance attendance = attendanceRepository.findByUserIdAndAttendanceDate(user.getId(), date)
				.orElse(new Attendance()); // create if HR hasn't marked yet

		// Guard: already checked in
		if (attendance.getCheckIn() != null) {
			throw new IllegalStateException("Check-in already recorded for " + date);
		}

		// Fix: set missing fields when creating new record
		attendance.setUser(user);
		attendance.setAttendanceDate(date); // ← was missing
		attendance.setStatus(AttendanceStatus.PRESENT); // ← was missing, auto-mark PRESENT on self check-in

		attendance.setCheckIn(time);
		Attendance saved = attendanceRepository.save(attendance);

		ResponseStructure<AttendanceDTO> response = new ResponseStructure<>();
		response.setStatus(HttpStatus.OK.value());
		response.setMessage("Check-in recorded: " + time);
		response.setData(attendanceMapper.toDTO(saved));

		return ResponseEntity.ok(response);
	}
	public ResponseEntity<ResponseStructure<List<AttendanceDTO>>> getTodayAttendance() {

	    LocalDate today = LocalDate.now();

	    List<Attendance> records = attendanceRepository.findByAttendanceDate(today);

	    ResponseStructure<List<AttendanceDTO>> response = new ResponseStructure<>();
	    response.setStatus(HttpStatus.OK.value());
	    response.setMessage("Attendance for today: " + today);
	    response.setData(attendanceMapper.toDTOList(records));

	    return ResponseEntity.ok(response);
	}

	public ResponseEntity<ResponseStructure<AttendanceDTO>> recordMyCheckOut(String token, LocalDate date,
			LocalTime time, String attendanceStatus) {
		
		String jwtToken = token.replace("Bearer ", "");
		String email = jwtUtil.getEmailFromToken(jwtToken);

		User user = userRepository.findByEmail(email)
				.orElseThrow(() -> new ResourceNotFoundException("User not found"));

		Attendance attendance = attendanceRepository.findByUserIdAndAttendanceDate(user.getId(), date)
				.orElseThrow(() -> new ResourceNotFoundException("No attendance record found for user " + user.getId()
						+ " on " + date + ". Mark attendance first before adding check-out time."));

		if (attendance.getCheckIn() != null && time.isBefore(attendance.getCheckIn())) {
			throw new IllegalArgumentException("Check-out time cannot be before check-in time");
		}

		attendance.setCheckOut(time);
		attendance.setStatus(AttendanceStatus.valueOf(attendanceStatus.toUpperCase()));

		Attendance saved = attendanceRepository.save(attendance);

		ResponseStructure<AttendanceDTO> response = new ResponseStructure<>();
		response.setStatus(HttpStatus.OK.value());
		response.setMessage("Check-out time recorded: " + time);
		response.setData(attendanceMapper.toDTO(saved));

		return ResponseEntity.ok(response);
	}
}
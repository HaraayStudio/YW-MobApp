package com.haraay.ywarchitects.controller;

import com.haraay.ywarchitects.dto.AttendanceDTO;
import com.haraay.ywarchitects.dto.BulkAttendanceRequest;
import com.haraay.ywarchitects.service.AttendanceService;
import com.haraay.ywarchitects.util.ResponseStructure;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

@RestController
@RequestMapping("/api/attendance")
public class AttendanceController {

	@Autowired
	private AttendanceService attendanceService;

	// USer records check-in time
	// PATCH /api/recordmycheckIn?date=2026-03-20&time=09:30
	@PatchMapping("/recordmycheckIn")
	public ResponseEntity<ResponseStructure<AttendanceDTO>> recordMyCheckIn(
			@RequestHeader("Authorization") String token,
			@RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date,
			@RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.TIME) LocalTime time) {

		return attendanceService.recordMyCheckIn(token, date, time);
	}
	
	@PatchMapping("/recordmycheckout")
	public ResponseEntity<ResponseStructure<AttendanceDTO>> recordMyCheckOut(
			@RequestHeader("Authorization") String token,
			@RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date,
			@RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.TIME) LocalTime time,
			@RequestParam String attendanceStatus) {

		return attendanceService.recordMyCheckOut(token, date, time,attendanceStatus);
	}

	// HR records check-in time
	// PATCH /api/attendance/{userId}/checkin?date=2026-03-20&time=09:30
	@PatchMapping("/{userId}/checkin")
	public ResponseEntity<ResponseStructure<AttendanceDTO>> recordCheckIn(@PathVariable Long userId,
			@RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date,
			@RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.TIME) LocalTime time) {

		return attendanceService.recordCheckIn(userId, date, time);
	}

	// HR records check-out time
	// PATCH /api/attendance/{userId}/checkout?date=2026-03-20&time=18:30
	@PatchMapping("/{userId}/checkout")
	public ResponseEntity<ResponseStructure<AttendanceDTO>> recordCheckOut(@PathVariable Long userId,
			@RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date,
			@RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.TIME) LocalTime time,
			@RequestParam String attendanceStatus) {

		return attendanceService.recordCheckOut(userId, date, time,attendanceStatus);
	}

	// HR marks attendance for a single user
	// POST /api/attendance/single?date=2026-03-20
	@PostMapping("/single")
	public ResponseEntity<ResponseStructure<AttendanceDTO>> markSingleAttendance(
			@RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date,
			@RequestBody BulkAttendanceRequest request) {

		return attendanceService.markSingleAttendance(date, request);
	}

	// HR marks attendance for all employees on a given date
	// POST /api/attendance/bulk?date=2026-03-20
	@PostMapping("/bulk")
	public ResponseEntity<ResponseStructure<List<AttendanceDTO>>> markBulkAttendance(
			@RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date,
			@RequestBody List<BulkAttendanceRequest> requests) {

		return attendanceService.markBulkAttendance(date, requests);
	}

	// HR can see monthly attendance of an user
	// GET /api/attendance/{userId}?month=3&year=2026
	@GetMapping("/{userId}")
	public ResponseEntity<ResponseStructure<List<AttendanceDTO>>> getMonthlyAttendance(@PathVariable Long userId,
			@RequestParam int month, @RequestParam int year) {

		return attendanceService.getMonthlyAttendance(userId, month, year);
	}

	// HR sees all employees attendance for a month
	// GET /api/attendance/all?month=3&year=2026
	@GetMapping("/all")
	public ResponseEntity<ResponseStructure<List<AttendanceDTO>>> getAllEmployeesMonthlyAttendance(
			@RequestParam int month, @RequestParam int year) {

		return attendanceService.getAllEmployeesMonthlyAttendance(month, year);
	}

	// User sees their own monthly attendance
	// GET /api/getmyattendance?month=3&year=2026
	@GetMapping("/getmymonthlyattendance")
	public ResponseEntity<ResponseStructure<List<AttendanceDTO>>> getMyMonthlyAttendance(
			@RequestHeader("Authorization") String token, @RequestParam int month, @RequestParam int year) {

		return attendanceService.getMyMonthlyAttendance(token, month, year);
	}
	
	// GET /api/attendance/today
	@GetMapping("/today")
	public ResponseEntity<ResponseStructure<List<AttendanceDTO>>> getTodayAttendance() {
	    return attendanceService.getTodayAttendance();
	}

}
package com.haraay.ywarchitects.dto;

import com.haraay.ywarchitects.model.AttendanceStatus;
import java.time.LocalDate;
import java.time.LocalTime;

public class AttendanceDTO {

	private Long id;
	private LocalDate attendanceDate;
	private AttendanceStatus status;
	private LocalTime checkIn;
	private LocalTime checkOut;
	private String remarks;
	private UserLiteDTO user; // just id + fullName + profileImage

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public LocalDate getAttendanceDate() {
		return attendanceDate;
	}

	public void setAttendanceDate(LocalDate attendanceDate) {
		this.attendanceDate = attendanceDate;
	}

	public AttendanceStatus getStatus() {
		return status;
	}

	public void setStatus(AttendanceStatus status) {
		this.status = status;
	}

	public LocalTime getCheckIn() {
		return checkIn;
	}

	public void setCheckIn(LocalTime checkIn) {
		this.checkIn = checkIn;
	}

	public LocalTime getCheckOut() {
		return checkOut;
	}

	public void setCheckOut(LocalTime checkOut) {
		this.checkOut = checkOut;
	}

	public String getRemarks() {
		return remarks;
	}

	public void setRemarks(String remarks) {
		this.remarks = remarks;
	}

	public UserLiteDTO getUser() {
		return user;
	}

	public void setUser(UserLiteDTO user) {
		this.user = user;
	}
}

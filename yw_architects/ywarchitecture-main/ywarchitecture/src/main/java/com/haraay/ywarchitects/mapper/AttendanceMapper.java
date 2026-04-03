package com.haraay.ywarchitects.mapper;

import com.haraay.ywarchitects.dto.AttendanceDTO;
import com.haraay.ywarchitects.model.Attendance;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;

@Component
public class AttendanceMapper {

    @Autowired
    private UserMapper userMapper;

    public AttendanceDTO toDTO(Attendance attendance) {
        if (attendance == null) return null;

        AttendanceDTO dto = new AttendanceDTO();
        dto.setId(attendance.getId());
        dto.setAttendanceDate(attendance.getAttendanceDate());
        dto.setStatus(attendance.getStatus());
        dto.setCheckIn(attendance.getCheckIn());
        dto.setCheckOut(attendance.getCheckOut());
        dto.setRemarks(attendance.getRemarks());
        dto.setUser(userMapper.toLiteDTO(attendance.getUser())); // reuse your existing mapper

        return dto;
    }

    public List<AttendanceDTO> toDTOList(List<Attendance> attendances) {
        if (attendances == null) return new ArrayList<>();
        List<AttendanceDTO> dtos = new ArrayList<>();
        for (Attendance a : attendances) {
            dtos.add(toDTO(a));
        }
        return dtos;
    }
}
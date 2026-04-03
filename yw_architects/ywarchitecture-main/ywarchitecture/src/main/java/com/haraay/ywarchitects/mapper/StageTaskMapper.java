package com.haraay.ywarchitects.mapper;

import org.springframework.stereotype.Component;

import com.haraay.ywarchitects.dto.StageTaskDTO;
import com.haraay.ywarchitects.model.StageTask;

@Component
public class StageTaskMapper {

    private final UserMapper userMapper;

    public StageTaskMapper(UserMapper userMapper) {
        this.userMapper = userMapper;
    }

    public StageTaskDTO toDTO(StageTask task) {
        if (task == null) return null;

        StageTaskDTO dto = new StageTaskDTO();
        dto.setId(task.getId());
        dto.setTaskName(task.getTaskName());
        dto.setDescription(task.getDescription());
        dto.setIsCompleted(task.getIsCompleted());
        dto.setCompletedAt(task.getCompletedAt());
        dto.setDisplayOrder(task.getDisplayOrder());
        dto.setIsMandatory(task.getIsMandatory());
        dto.setNotes(task.getNotes());
        dto.setCreatedAt(task.getCreatedAt());

        return dto;
    }
}


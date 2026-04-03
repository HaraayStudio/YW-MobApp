package com.haraay.ywarchitects.mapper;

import org.springframework.stereotype.Component;

import com.haraay.ywarchitects.dto.LevelDTO;
import com.haraay.ywarchitects.model.Level;

@Component
public class LevelMapper {

    public LevelDTO toDTO(Level level) {
        if (level == null) return null;

        LevelDTO dto = new LevelDTO();

        dto.setId(level.getId());
        dto.setLevelNumber(level.getLevelNumber());
        dto.setLevelLabel(level.getLevelLabel());

        dto.setLevelType(
                level.getLevelType() != null 
                ? level.getLevelType().name() 
                : null
        );

        dto.setUsageType(
                level.getUsageType() != null 
                ? level.getUsageType().name() 
                : null
        );

        dto.setBuiltUpArea(level.getBuiltUpArea());
        dto.setCarpetArea(level.getCarpetArea());
        dto.setFloorHeight(level.getFloorHeight());
        dto.setSequenceOrder(level.getSequenceOrder());
        dto.setConstructionStatus(level.getConstructionStatus());
        dto.setProgressPercentage(level.getProgressPercentage());

        return dto;
    }
}

package com.haraay.ywarchitects.mapper;

import java.util.stream.Collectors;

import org.springframework.stereotype.Component;

import com.haraay.ywarchitects.dto.StructureDTO;
import com.haraay.ywarchitects.model.Structure;

@Component
public class StructureMapper {

    private final LevelMapper levelMapper;

    public StructureMapper(LevelMapper levelMapper) {
        this.levelMapper = levelMapper;
    }

    public StructureDTO toDTO(Structure structure) {
        if (structure == null) return null;

        StructureDTO dto = new StructureDTO();

        dto.setId(structure.getId());
        dto.setStructureName(structure.getStructureName());

        dto.setStructureType(
                structure.getStructureType() != null
                ? structure.getStructureType().name()
                : null
        );

        dto.setUsageType(
                structure.getUsageType() != null
                ? structure.getUsageType().name()
                : null
        );

        dto.setTotalFloors(structure.getTotalFloors());
        dto.setTotalBasements(structure.getTotalBasements());
        dto.setBuiltUpArea(structure.getBuiltUpArea());

        // Map Levels
        if (structure.getLevels() != null) {
            dto.setLevels(
                    structure.getLevels()
                             .stream()
                             .map(levelMapper::toDTO)
                             .collect(Collectors.toList())
            );
        }

        return dto;
    }
}

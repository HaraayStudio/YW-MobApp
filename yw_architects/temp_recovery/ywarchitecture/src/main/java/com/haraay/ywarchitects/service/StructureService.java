package com.haraay.ywarchitects.service;

import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

import com.haraay.ywarchitects.dto.ProjectDTO;
import com.haraay.ywarchitects.dto.StructureDTO;
import com.haraay.ywarchitects.mapper.StructureMapper;
import com.haraay.ywarchitects.model.Project;
import com.haraay.ywarchitects.model.Structure;
import com.haraay.ywarchitects.repository.ProjectRepository;
import com.haraay.ywarchitects.repository.StructureRepository;
import com.haraay.ywarchitects.util.ResponseStructure;

import jakarta.transaction.Transactional;

@Service
public class StructureService {

    private final ProjectRepository projectRepository;
    private final StructureRepository structureRepository;
    private final StructureMapper structureMapper;

    public StructureService(ProjectRepository projectRepository,
                            StructureRepository structureRepository,
                            StructureMapper structureMapper) {
        this.projectRepository = projectRepository;
        this.structureRepository = structureRepository;
        this.structureMapper = structureMapper;
    }

    @Transactional
    public ResponseEntity<ResponseStructure<StructureDTO>> createStructure(
            Long projectId,
            Structure structure) {

        ResponseStructure<StructureDTO> response = new ResponseStructure<>();

        Project project = projectRepository.findById(projectId)
                .orElseThrow(() -> new RuntimeException("Project not found with id: " + projectId));

        // ✅ safe bidirectional linking
        project.getStructures().add(structure);
        structure.setProject(project);

        // ✅ fix child hierarchy
        configureLevels(structure);

        Structure saved = structureRepository.save(structure);

        response.setData(structureMapper.toDTO(saved));
        response.setMessage("Structure created successfully");
        response.setStatus(HttpStatus.CREATED.value());

        return new ResponseEntity<>(response, HttpStatus.CREATED);
    }

    // ✅ clean hierarchy fixer
    private void configureLevels(Structure structure) {

        if (structure.getLevels() == null || structure.getLevels().isEmpty()) {
            return;
        }

        structure.getLevels().forEach(level ->
                level.setStructure(structure)
        );
    }
}
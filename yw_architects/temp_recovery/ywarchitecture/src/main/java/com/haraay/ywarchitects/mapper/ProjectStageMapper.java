package com.haraay.ywarchitects.mapper;

import org.springframework.stereotype.Component;

import com.haraay.ywarchitects.dto.ProjectStageDTO;
import com.haraay.ywarchitects.model.ProjectStage;

@Component
public class ProjectStageMapper {

    private final StageDocumentMapper documentMapper;
    private final StageMediaMapper mediaMapper;
    private final StageTaskMapper taskMapper;
    private final UserMapper userMapper;

    public ProjectStageMapper(StageDocumentMapper documentMapper,
                              StageMediaMapper mediaMapper,
                              StageTaskMapper taskMapper,
                              UserMapper userMapper) {
        this.documentMapper = documentMapper;
        this.mediaMapper = mediaMapper;
        this.taskMapper = taskMapper;
        this.userMapper = userMapper;
    }

    public ProjectStageDTO toDTO(ProjectStage stage) {
        if (stage == null) return null;

        ProjectStageDTO dto = new ProjectStageDTO();

        dto.setId(stage.getId());
        dto.setProjectId(stage.getProject().getProjectId());
        dto.setStageName(stage.getStageName());
        dto.setCustomStageName(stage.getCustomStageName());
        dto.setStatus(stage.getStatus());
        dto.setParentStageId(stage.getParentStage() != null ? stage.getParentStage().getId() : null);

        dto.setProgressPercentage(stage.getProgressPercentage());
        dto.setStartedAt(stage.getStartedAt());
        dto.setTargetCompletionDate(stage.getTargetCompletionDate());
        dto.setActualCompletionDate(stage.getActualCompletionDate());

        dto.setRemarks(stage.getRemarks());
        dto.setInternalNotes(stage.getInternalNotes());
        dto.setDisplayOrder(stage.getDisplayOrder());
        dto.setIsMandatory(stage.getIsMandatory());

        if (stage.getDocuments() != null)
            dto.setDocuments(stage.getDocuments().stream()
                    .map(documentMapper::toDTO)
                    .toList());

        if (stage.getMediaFiles() != null)
            dto.setMediaFiles(stage.getMediaFiles().stream()
                    .map(mediaMapper::toDTO)
                    .toList());

        if (stage.getTasks() != null)
            dto.setTasks(stage.getTasks().stream()
                    .map(taskMapper::toDTO)
                    .toList());

        if (stage.getChildStages() != null)
            dto.setChildStages(stage.getChildStages().stream()
                    .map(this::toDTO)
                    .toList());

        return dto;
    }
}


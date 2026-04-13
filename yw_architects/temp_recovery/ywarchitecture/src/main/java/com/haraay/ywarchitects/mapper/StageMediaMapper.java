package com.haraay.ywarchitects.mapper;

import org.springframework.stereotype.Component;

import com.haraay.ywarchitects.dto.StageMediaDTO;
import com.haraay.ywarchitects.model.StageMedia;

@Component
public class StageMediaMapper {

    private final UserMapper userMapper;

    public StageMediaMapper(UserMapper userMapper) {
        this.userMapper = userMapper;
    }

    public StageMediaDTO toDTO(StageMedia media) {
        if (media == null) return null;

        StageMediaDTO dto = new StageMediaDTO();
        dto.setId(media.getId());
        dto.setFileName(media.getFileName());
        dto.setFilePath(media.getFilePath());
        dto.setMediaType(media.getMediaType());
        dto.setDescription(media.getDescription());
        dto.setFileSize(media.getFileSize());
        dto.setMimeType(media.getMimeType());
        dto.setThumbnailPath(media.getThumbnailPath());
        dto.setDurationSeconds(media.getDurationSeconds());
        dto.setCapturedAt(media.getCapturedAt());
        dto.setLocation(media.getLocation());
        dto.setUploadedAt(media.getUploadedAt());

        return dto;
    }
}


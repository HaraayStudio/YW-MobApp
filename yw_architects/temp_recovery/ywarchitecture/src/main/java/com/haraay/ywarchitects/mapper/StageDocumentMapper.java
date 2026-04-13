package com.haraay.ywarchitects.mapper;

import org.springframework.stereotype.Component;

import com.haraay.ywarchitects.dto.StageDocumentDTO;
import com.haraay.ywarchitects.model.StageDocument;

@Component
public class StageDocumentMapper {

    private final UserMapper userMapper;

    public StageDocumentMapper(UserMapper userMapper) {
        this.userMapper = userMapper;
    }

    public StageDocumentDTO toDTO(StageDocument doc) {
        if (doc == null) return null;

        StageDocumentDTO dto = new StageDocumentDTO();
        dto.setId(doc.getId());
        dto.setFileName(doc.getFileName());
        dto.setFilePath(doc.getFilePath());
        dto.setDocumentType(doc.getDocumentType());
        dto.setDescription(doc.getDescription());
       
        dto.setIsApproved(doc.getIsApproved());
        dto.setApprovedAt(doc.getApprovedAt());
        dto.setApprovalRemarks(doc.getApprovalRemarks());
        dto.setVersion(doc.getVersion());
        dto.setUploadedAt(doc.getUploadedAt());

        return dto;
    }
}


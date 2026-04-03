package com.haraay.ywarchitects.mapper;

import org.springframework.stereotype.Component;
import com.haraay.ywarchitects.dto.SiteVisitDocumentDTO;
import com.haraay.ywarchitects.model.SiteVisitDocument;

@Component
public class SiteVisitDocumentMapper {

    public SiteVisitDocumentDTO toDTO(SiteVisitDocument document) {
        if (document == null) return null;

        SiteVisitDocumentDTO dto = new SiteVisitDocumentDTO();
        dto.setId(document.getId());
        dto.setDocumentUrl(document.getDocumentUrl());
        dto.setDocumentName(document.getDocumentName());
        dto.setUploadedAt(document.getUploadedAt());

        return dto;
    }
}

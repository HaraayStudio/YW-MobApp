package com.haraay.ywarchitects.mapper;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Component;

import com.haraay.ywarchitects.dto.SiteVisitDTO;
import com.haraay.ywarchitects.model.SiteVisit;

@Component
public class SiteVisitMapper {

    private final SiteVisitPhotoMapper photoMapper;
    private final SiteVisitDocumentMapper documentMapper;
    private final UserMapper userMapper;

    public SiteVisitMapper(
            SiteVisitPhotoMapper photoMapper,
            SiteVisitDocumentMapper documentMapper,
            UserMapper userMapper) {
        this.photoMapper = photoMapper;
        this.documentMapper = documentMapper;
        this.userMapper = userMapper;
    }

    public SiteVisitDTO toDTO(SiteVisit visit) {
        if (visit == null) return null;

        SiteVisitDTO dto = new SiteVisitDTO();

        dto.setId(visit.getId());
        dto.setTitle(visit.getTitle());
        dto.setDescription(visit.getDescription());
        dto.setVisitDateTime(visit.getVisitDateTime());
        dto.setLocationNote(visit.getLocationNote());

        dto.setProjectId(
            visit.getProject() != null ? visit.getProject().getProjectId() : null
        );

        dto.setCreatedBy(
            userMapper.toLiteDTO(visit.getCreatedBy())
        );

        dto.setPhotos(
            visit.getPhotos()
                 .stream()
                 .map(photoMapper::toDTO)
                 .collect(Collectors.toList())
        );

        dto.setDocuments(
            visit.getDocuments()
                 .stream()
                 .map(documentMapper::toDTO)
                 .collect(Collectors.toList())
        );

        return dto;
    }

	public List<SiteVisitDTO> toDTOList(List<SiteVisit> siteVisits) {
		if(siteVisits==null || siteVisits.isEmpty())
			return null;
		
		return siteVisits.stream().map(this::toDTO).collect(Collectors.toList());
	}
}

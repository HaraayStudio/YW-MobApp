package com.haraay.ywarchitects.mapper;

import org.springframework.stereotype.Component;
import com.haraay.ywarchitects.dto.SiteVisitPhotoDTO;
import com.haraay.ywarchitects.model.SiteVisitPhoto;

@Component
public class SiteVisitPhotoMapper {

	public SiteVisitPhotoDTO toDTO(SiteVisitPhoto photo) {
		if (photo == null)
			return null;

		SiteVisitPhotoDTO dto = new SiteVisitPhotoDTO();
		dto.setId(photo.getId());
		dto.setImageUrl(photo.getImageUrl());
		dto.setCaption(photo.getCaption());
		dto.setUploadedAt(photo.getUploadedAt());

		return dto;
	}
}

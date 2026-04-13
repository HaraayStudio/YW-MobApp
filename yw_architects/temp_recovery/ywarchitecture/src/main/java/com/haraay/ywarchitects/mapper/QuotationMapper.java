package com.haraay.ywarchitects.mapper;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Component;

import com.haraay.ywarchitects.dto.QuotationDTO;
import com.haraay.ywarchitects.model.Quotation;

@Component
public class QuotationMapper {

    // 🔹 Entity → DTO
    public QuotationDTO toDTO(Quotation quotation) {

        if (quotation == null) return null;

        QuotationDTO dto = new QuotationDTO();
        dto.setId(quotation.getId());
        dto.setQuotationNumber(quotation.getQuotationNumber());
        dto.setDateTimeIssued(quotation.getDateTimeIssued());
        dto.setQuotationDetails(quotation.getQuotationDetails());
        dto.setSended(quotation.getSended());
        dto.setAccepted(quotation.getAccepted());

        return dto;
    }

   

    // 🔹 List<Entity> → List<DTO>
    public List<QuotationDTO> toDTOList(List<Quotation> quotations) {
        return quotations.stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

   
}

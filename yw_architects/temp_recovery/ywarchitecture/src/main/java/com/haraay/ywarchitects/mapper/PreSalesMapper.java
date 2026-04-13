package com.haraay.ywarchitects.mapper;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Component;

import com.haraay.ywarchitects.dto.*;
import com.haraay.ywarchitects.model.*;

@Component
public class PreSalesMapper {
	
	private final QuotationMapper quotationMapper;
	
	

    public PreSalesMapper(QuotationMapper quotationMapper) {
		super();
		this.quotationMapper = quotationMapper;
	}

	public PreSalesDTO toDTO(PreSales preSales) {

        PreSalesDTO dto = new PreSalesDTO();

        dto.setSrNumber(preSales.getSrNumber());
        dto.setDateTime(preSales.getDateTime());

        ClientBasicDTO clientDTO = new ClientBasicDTO();
        clientDTO.setId(preSales.getClient().getId());
        clientDTO.setName(preSales.getClient().getName());
        clientDTO.setEmail(preSales.getClient().getEmail());
        clientDTO.setPhone(preSales.getClient().getPhone());

        dto.setClient(clientDTO);

        dto.setPersonName(preSales.getPersonName());
        dto.setApproachedVia(preSales.getApproachedVia());

        if (preSales.getQuotations() != null) {
        	
        	 List<QuotationDTO> list= quotationMapper.toDTOList(preSales.getQuotations());
            dto.setQuotations(list);
        }

        dto.setStatus(preSales.getStatus());
        dto.setConclusion(preSales.getConclusion());

        return dto;
    }

    public List<PreSalesDTO> toDTOList(List<PreSales> list) {
        return list.stream().map(this::toDTO).collect(Collectors.toList());
    }
}

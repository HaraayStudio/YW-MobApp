package com.haraay.ywarchitects.mapper;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Component;

import com.haraay.ywarchitects.dto.ClientBasicDTO;
import com.haraay.ywarchitects.dto.PostSalesDTO;
import com.haraay.ywarchitects.model.Client;
import com.haraay.ywarchitects.model.PostSales;

@Component
public class PostSalesMapper {

	private final ProjectMapper projectMapper;
	private final ProformaInvoiceMapper proformaMapper;
	private final TaxInvoiceMapper taxMapper;

	public PostSalesMapper(

			ProjectMapper projectMapper, ProformaInvoiceMapper proformaMapper, TaxInvoiceMapper taxMapper) {

		this.projectMapper = projectMapper;
		this.proformaMapper = proformaMapper;
		this.taxMapper = taxMapper;
	}

	public PostSalesDTO toDTO(PostSales entity) {
		if (entity == null)
			return null;

		PostSalesDTO dto = new PostSalesDTO();

		dto.setId(entity.getId());
		dto.setPostSalesdateTime(entity.getPostSalesdateTime());
		dto.setRemark(entity.getRemark());
		dto.setNotified(entity.isNotified());
		dto.setPostSalesStatus(entity.getPostSalesStatus());

		// client
		if (entity.getClient() != null) {

			Client client = entity.getClient();
			ClientBasicDTO clientBasicDTO = new ClientBasicDTO();
			clientBasicDTO.setId(client.getId());
			clientBasicDTO.setName(client.getName());
			clientBasicDTO.setEmail(client.getEmail());
			clientBasicDTO.setPhone(client.getPhone());

			dto.setClient(clientBasicDTO);

		}

		// project
		if (entity.getProject() != null) {
			dto.setProject(projectMapper.toProjectLiteDTO(entity.getProject()));
		}

		// proforma invoices
		if (entity.getProformaInvoices() != null) {
			dto.setProformaInvoices(
					entity.getProformaInvoices().stream().map(proformaMapper::toDTO).collect(Collectors.toList()));
		}

		// tax invoices
		if (entity.getTaxInvoices() != null) {
			dto.setTaxInvoices(entity.getTaxInvoices().stream().map(taxMapper::toTaxInvoiceDTO).collect(Collectors.toList()));
		}

		return dto;
	}

	public List<PostSalesDTO> toDTOList(List<PostSales> list) {
		if (list == null || list.isEmpty())
			return null;

		return list.stream().map(this::toDTO).collect(Collectors.toList());
	}
}

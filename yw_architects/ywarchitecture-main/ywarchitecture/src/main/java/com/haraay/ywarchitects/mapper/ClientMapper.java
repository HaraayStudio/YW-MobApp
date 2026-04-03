package com.haraay.ywarchitects.mapper;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.haraay.ywarchitects.dto.ClientBasicDTO;
import com.haraay.ywarchitects.dto.ClientDTO;
import com.haraay.ywarchitects.dto.ClientINEPAGPDTO;
import com.haraay.ywarchitects.model.Client;


@Component
public class ClientMapper {
	
	@Autowired
	private PreSalesMapper preSalesMapper;
	
	@Autowired
	private PostSalesMapper postSalesMapper;

	// ===============================
	// ✅ ENTITY → BASIC DTO (MOST USED)
	// ===============================
	public ClientBasicDTO toBasicDTO(Client entity) {
		if (entity == null)
			return null;

		ClientBasicDTO dto = new ClientBasicDTO();
		dto.setId(entity.getId());
		dto.setName(entity.getName());
		dto.setEmail(entity.getEmail());
		dto.setPhone(entity.getPhone());

		return dto;
	}

	// ===============================
	// ✅ DTO → ENTITY (light update use)
	// ===============================
	public Client toEntity(ClientBasicDTO dto) {
		if (dto == null)
			return null;

		Client entity = new Client();
		entity.setId(dto.getId());
		entity.setName(dto.getName());
		entity.setEmail(dto.getEmail());
		entity.setPhone(dto.getPhone());

		return entity;
	}

	// ===============================
	// ✅ UPDATE EXISTING ENTITY (BEST PRACTICE)
	// ===============================
	public void updateEntity(Client entity, ClientBasicDTO dto) {
		if (entity == null || dto == null)
			return;

		if (dto.getName() != null) {
			entity.setName(dto.getName());
		}

		if (dto.getEmail() != null) {
			entity.setEmail(dto.getEmail());
		}

		if (dto.getPhone() != null) {
			entity.setPhone(dto.getPhone());
		}
	}

	public List<ClientBasicDTO> clientListToCLientDTOList(List<Client> clients) {
		if (clients == null || clients.isEmpty())
			return null;

		return clients.stream().map(this::toBasicDTO).collect(Collectors.toList());
	}

	public com.haraay.ywarchitects.dto.ClientDTO toClientDTO(Client entity) {
		if (entity == null)
			return null;

		ClientDTO dto = new ClientDTO();

		dto.setId(entity.getId());
		dto.setName(entity.getName());
		dto.setEmail(entity.getEmail());
		dto.setPhone(entity.getPhone());
		dto.setAddress(entity.getAddress());
		dto.setGSTCertificate(entity.getGSTCertificate());
		dto.setPAN(entity.getPAN());

		// 🔥 map presales
		if (entity.getPreSales() != null) {
			dto.setPreSales(entity.getPreSales().stream().map(preSalesMapper::toDTO).collect(Collectors.toList()));
		}

		// 🔥 map postsales
		if (entity.getPostSales() != null) {
			dto.setPostSales(entity.getPostSales().stream().map(postSalesMapper::toDTO).collect(Collectors.toList()));
		}

		return dto;
	}
	// ── helper: Client → ClientINEPAGPDTO ────────────────────────────────────
		public ClientINEPAGPDTO toClientINEPAGPDTO(Client client) {
		    ClientINEPAGPDTO dto = new ClientINEPAGPDTO();
		    dto.setId(client.getId());
		    dto.setName(client.getName());
		    dto.setEmail(client.getEmail());
		    dto.setPhone(client.getPhone());
		    dto.setAddress(client.getAddress());
		    dto.setGSTCertificate(client.getGSTCertificate());
		    dto.setPAN(client.getPAN());
		    return dto;
		}
}
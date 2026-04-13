package com.haraay.ywarchitects.service;



import com.haraay.ywarchitects.dto.ClientBasicDTO;
import com.haraay.ywarchitects.dto.ClientDTO;
import com.haraay.ywarchitects.dto.ClientINEPAGPDTO;
import com.haraay.ywarchitects.dto.SuccessDTO;
import com.haraay.ywarchitects.mapper.ClientMapper;
import com.haraay.ywarchitects.model.Client;

import com.haraay.ywarchitects.repository.ClientRepository;

import com.haraay.ywarchitects.util.ResponseStructure;


import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class ClientService {

	@Autowired
	private ClientRepository clientRepository;

	@Autowired
	private ResponseStructure<ClientBasicDTO> ClientBasicDTOStructure;
	
	@Autowired
	private ResponseStructure<ClientDTO> clientDTOStructure;

	@Autowired
	private ResponseStructure<List<ClientBasicDTO>> ClientBasicDTOListStructure;

	@Autowired
	private ResponseStructure<SuccessDTO> successStructure;

	
	private final ClientMapper clientMapper;
	
	

	public ClientService(ClientRepository clientRepository, ClientMapper clientMapper) {
		super();
		this.clientRepository = clientRepository;
		this.clientMapper = clientMapper;
	}

	public ResponseEntity<ResponseStructure<ClientBasicDTO>> createClient(Client client) {
		Client saved = clientRepository.save(client);
		ClientBasicDTO dto = clientMapper.toBasicDTO(saved);
		ClientBasicDTOStructure.setStatus(HttpStatus.CREATED.value());
		ClientBasicDTOStructure.setMessage("Client created successfully.");
		ClientBasicDTOStructure.setData(dto);
		return new ResponseEntity<ResponseStructure<ClientBasicDTO>>(ClientBasicDTOStructure, HttpStatus.CREATED);

	}

	public ResponseEntity<ResponseStructure<ClientDTO>> getClientById(Long id) {
		Optional<Client> optionalClient = clientRepository.findById(id);

		if (optionalClient.isEmpty()) {
			clientDTOStructure.setStatus(HttpStatus.NOT_FOUND.value());
			clientDTOStructure.setMessage("Client Not Found with ID = " + id);
			clientDTOStructure.setData(null);
			return new ResponseEntity<ResponseStructure<ClientDTO>>(clientDTOStructure, HttpStatus.NOT_FOUND);

		}
		ClientDTO dto = clientMapper.toClientDTO(optionalClient.get());
		clientDTOStructure.setStatus(HttpStatus.FOUND.value());
		clientDTOStructure.setMessage("Client Found");
		clientDTOStructure.setData(dto);
		return new ResponseEntity<ResponseStructure<ClientDTO>>(clientDTOStructure, HttpStatus.OK);
	}

	public ResponseEntity<ResponseStructure<List<ClientBasicDTO>>> getAllClients() {
		List<Client> clients = clientRepository.findAllDesc();
		List<ClientBasicDTO> dtos = clientMapper.clientListToCLientDTOList(clients);

		ClientBasicDTOListStructure.setStatus(HttpStatus.FOUND.value());
		ClientBasicDTOListStructure.setMessage("Clients Found");
		ClientBasicDTOListStructure.setData(dtos);
		return new ResponseEntity<ResponseStructure<List<ClientBasicDTO>>>(ClientBasicDTOListStructure, HttpStatus.OK);

	}

	public ResponseEntity<ResponseStructure<ClientDTO>> updateClient(Long id, ClientINEPAGPDTO clientNEPAGPDTO) {
		Optional<Client> optionalClient = clientRepository.findById(id);

		if (optionalClient.isEmpty()) {
			clientDTOStructure.setStatus(HttpStatus.NOT_FOUND.value());
			clientDTOStructure.setMessage("Client Not Found with ID = " + id);
			clientDTOStructure.setData(null);
			return new ResponseEntity<ResponseStructure<ClientDTO>>(clientDTOStructure, HttpStatus.NOT_FOUND);

		}

		Client client = optionalClient.get();
		client.setName(clientNEPAGPDTO.getName());
		client.setEmail(clientNEPAGPDTO.getEmail());
		client.setPhone(clientNEPAGPDTO.getPhone());
		client.setAddress(clientNEPAGPDTO.getAddress());
		client.setGSTCertificate(clientNEPAGPDTO.getGSTCertificate());
		client.setPAN(clientNEPAGPDTO.getPAN());

		Client updatedClient = clientRepository.save(client);

		if (updatedClient == null) {
			clientDTOStructure.setStatus(HttpStatus.INTERNAL_SERVER_ERROR.value());
			clientDTOStructure.setMessage("FAILED TO UPDATE Client.");
			clientDTOStructure.setData(null);
			return new ResponseEntity<ResponseStructure<ClientDTO>>(clientDTOStructure,
					HttpStatus.INTERNAL_SERVER_ERROR);

		}
		ClientDTO dto = clientMapper.toClientDTO(updatedClient);
		clientDTOStructure.setStatus(HttpStatus.CREATED.value());
		clientDTOStructure.setMessage("Client created successfully.");
		clientDTOStructure.setData(dto);
		return new ResponseEntity<ResponseStructure<ClientDTO>>(clientDTOStructure, HttpStatus.CREATED);

	}

}

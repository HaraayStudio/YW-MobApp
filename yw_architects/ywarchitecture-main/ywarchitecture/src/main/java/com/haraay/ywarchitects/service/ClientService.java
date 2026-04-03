package com.haraay.ywarchitects.service;

import com.haraay.ywarchitects.dto.ClientBasicDTO;
import com.haraay.ywarchitects.dto.ClientDTO;
import com.haraay.ywarchitects.dto.ClientINEPAGPDTO;
import com.haraay.ywarchitects.dto.SuccessDTO;
import com.haraay.ywarchitects.dto.UserDTO;
import com.haraay.ywarchitects.exception.ResourceNotFoundException;
import com.haraay.ywarchitects.mapper.ClientMapper;
import com.haraay.ywarchitects.model.Client;
import com.haraay.ywarchitects.model.User;
import com.haraay.ywarchitects.repository.ClientRepository;
import com.haraay.ywarchitects.util.JwtUtil;
import com.haraay.ywarchitects.util.ResponseStructure;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class ClientService {

	@Autowired
	private JwtUtil jwtUtil;

	@Autowired
	private PasswordEncoder passwordEncoder;

	@Autowired
	private ClientRepository clientRepository;

	@Autowired
	private ResponseStructure<ClientBasicDTO> ClientBasicDTOStructure;

	@Autowired
	private ResponseStructure<ClientINEPAGPDTO> ClientINEPAGPDTOStructure;

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
		// encode pass

		client.setPassword(passwordEncoder.encode(client.getPassword()));
		client.setRole("CLIENT");

		System.out.println(client.getPassword());

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

	public ResponseEntity<ResponseStructure<ClientDTO>> getclient(String token) {
		String jwtToken = token.replace("Bearer ", "");
		String email = jwtUtil.getEmailFromToken(jwtToken);
		Optional<Client> optionalUser = clientRepository.findByEmail(email);

		if (optionalUser.isEmpty()) {

			clientDTOStructure.setMessage(" CLIENT ID NOT FOUND");
			clientDTOStructure.setStatus(HttpStatus.NOT_FOUND.value());
			clientDTOStructure.setData(null);

			return new ResponseEntity<ResponseStructure<ClientDTO>>(clientDTOStructure, HttpStatus.NOT_FOUND);
		}

		Client databaseClient = optionalUser.get();

		clientDTOStructure.setMessage("CLIENT FOUND");
		clientDTOStructure.setStatus(HttpStatus.FOUND.value());
		clientDTOStructure.setData(clientMapper.toClientDTO(databaseClient));

		return new ResponseEntity<ResponseStructure<ClientDTO>>(clientDTOStructure, HttpStatus.FOUND);
	}

	public ResponseEntity<ResponseStructure<ClientINEPAGPDTO>> updateMyProfile(String token,
			ClientINEPAGPDTO clientDTO) {
		String jwtToken = token.replace("Bearer ", "");
		String email = jwtUtil.getEmailFromToken(jwtToken);

		Client client = clientRepository.findByEmail(email)
				.orElseThrow(() -> new ResourceNotFoundException("Client not found"));

		// Update only allowed fields
		client.setName(clientDTO.getName());
		client.setEmail(clientDTO.getEmail());
		client.setPhone(clientDTO.getPhone());
		client.setAddress(clientDTO.getAddress());
		client.setGSTCertificate(clientDTO.getGSTCertificate());
		client.setPAN(clientDTO.getPAN());

		Client saved = clientRepository.save(client);

		ResponseStructure<ClientINEPAGPDTO> response = new ResponseStructure<>();
		response.setStatus(HttpStatus.OK.value());
		response.setMessage("Profile updated successfully");
		response.setData(clientMapper.toClientINEPAGPDTO(saved));

		return ResponseEntity.ok(response);
	}

	public ResponseEntity<ResponseStructure<SuccessDTO>> updateMyPassword(String token, String oldPassword,
			String newPassword) {

		String jwtToken = token.replace("Bearer ", "");
		String email = jwtUtil.getEmailFromToken(jwtToken);

		Client client = clientRepository.findByEmail(email)
				.orElseThrow(() -> new ResourceNotFoundException("Client not found"));

		// 1. Verify old password
		if (!passwordEncoder.matches(oldPassword, client.getPassword())) {
			throw new IllegalArgumentException("Old password is incorrect");
		}
		// 2. Validate new password
		if (newPassword == null || newPassword.isBlank()) {
			throw new IllegalArgumentException("New password cannot be empty");
		}

		// 3. Guard: new password must not be same as old
		if (newPassword != null && !newPassword.isBlank() && newPassword.isEmpty()
				&& passwordEncoder.matches(newPassword, client.getPassword())) {
			throw new IllegalArgumentException("New password must be different from old password");
		}

		// 3. Update password
		client.setPassword(passwordEncoder.encode(newPassword));
		clientRepository.save(client);

		ResponseStructure<SuccessDTO> response = new ResponseStructure<>();
		response.setStatus(HttpStatus.OK.value());
		response.setMessage("Password updated successfully");
		response.setData(null);

		return ResponseEntity.ok(response);
	}

}

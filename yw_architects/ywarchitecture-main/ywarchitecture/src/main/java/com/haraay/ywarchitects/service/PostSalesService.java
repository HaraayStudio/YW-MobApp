package com.haraay.ywarchitects.service;

import com.haraay.ywarchitects.dto.PostSalesDTO;
import com.haraay.ywarchitects.dto.SuccessDTO;
import com.haraay.ywarchitects.mapper.PostSalesMapper;
import com.haraay.ywarchitects.model.Client;
import com.haraay.ywarchitects.model.PostSales;
import com.haraay.ywarchitects.model.PostSalesStatus;
import com.haraay.ywarchitects.model.PreSales;
import com.haraay.ywarchitects.model.Project;
import com.haraay.ywarchitects.model.Quotation;
import com.haraay.ywarchitects.repository.ClientRepository;
import com.haraay.ywarchitects.repository.PostSalesRepository;
import com.haraay.ywarchitects.repository.PreSalesRepository;
import com.haraay.ywarchitects.repository.ProjectRepository;
import com.haraay.ywarchitects.repository.QuotationRepository;
import com.haraay.ywarchitects.util.ResponseStructure;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Comparator;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class PostSalesService {

	private final PostSalesRepository postSalesRepository;
	private final PreSalesRepository preSalesRepository;
	private final QuotationRepository quotationRepository;
	private final ProjectRepository projectRepository;
	private final PostSalesMapper postSalesMapper;
	private final ProjectService projectService;
	private final ClientRepository clientRepository;
	
	@Autowired
	private PasswordEncoder passwordEncoder;

	@Autowired
	private ResponseStructure<PostSalesDTO> postSalesDTOResponseStructure;

	@Autowired
	private ResponseStructure<SuccessDTO> successStructure;

	@Autowired
	private ResponseStructure<List<PostSalesDTO>> postSalesDTOListResponseStructure;

	public PostSalesService(PostSalesRepository postSalesRepository, PostSalesMapper postSalesMapper,
			ProjectService projectService, ClientRepository clientRepository, PreSalesRepository preSalesRepository,
			QuotationRepository quotationRepository, ProjectRepository projectRepository) {
		this.postSalesRepository = postSalesRepository;
		this.postSalesMapper = postSalesMapper;
		this.projectService = projectService;
		this.clientRepository = clientRepository;
		this.preSalesRepository = preSalesRepository;
		this.quotationRepository = quotationRepository;
		this.projectRepository = projectRepository;
	}

	@Transactional
	public ResponseEntity<ResponseStructure<PostSalesDTO>> createPostSales(PostSales postSales, boolean isOldClient) {

		Client client;

		if (!isOldClient) {
			// Create a new client from the postSales client data
			Client newClient = postSales.getClient();
			if (newClient == null) {
				postSalesDTOResponseStructure.setData(null);
				postSalesDTOResponseStructure.setMessage("Client details are required to create a new client!");
				postSalesDTOResponseStructure.setStatus(HttpStatus.BAD_REQUEST.value());
				return new ResponseEntity<>(postSalesDTOResponseStructure, HttpStatus.BAD_REQUEST);
			}
			
			newClient.setPassword(passwordEncoder.encode(newClient.getPassword()));
			newClient.setRole("CLIENT");
			
			client = clientRepository.save(newClient);
			if (client == null) {
				postSalesDTOResponseStructure.setData(null);
				postSalesDTOResponseStructure.setMessage("Failed to create new Client!");
				postSalesDTOResponseStructure.setStatus(HttpStatus.INTERNAL_SERVER_ERROR.value());
				return new ResponseEntity<>(postSalesDTOResponseStructure, HttpStatus.INTERNAL_SERVER_ERROR);
			}

		} else {
			// Old client — find by existing ID
			if (postSales.getClient() == null || postSales.getClient().getId() == null) {
				postSalesDTOResponseStructure.setData(null);
				postSalesDTOResponseStructure.setMessage("Client ID is required for existing client!");
				postSalesDTOResponseStructure.setStatus(HttpStatus.BAD_REQUEST.value());
				return new ResponseEntity<>(postSalesDTOResponseStructure, HttpStatus.BAD_REQUEST);
			}
			Long clientId = postSales.getClient().getId();
			Optional<Client> optClient = clientRepository.findById(clientId);
			if (optClient == null || optClient.isEmpty()) {
				postSalesDTOResponseStructure.setData(null);
				postSalesDTOResponseStructure.setMessage("Client not found with given ID!");
				postSalesDTOResponseStructure.setStatus(HttpStatus.NOT_FOUND.value());
				return new ResponseEntity<>(postSalesDTOResponseStructure, HttpStatus.NOT_FOUND);
			}
			client = optClient.get();
		}

		// Common logic for both old and new client
		client.getPostSales().add(postSales);
		postSales.setClient(client);
		postSales.setPostSalesdateTime(LocalDateTime.now());

		Project project = projectService.createQuickProject();
		if (project == null) {
			postSalesDTOResponseStructure.setData(null);
			postSalesDTOResponseStructure.setMessage("Failed to create Project!");
			postSalesDTOResponseStructure.setStatus(HttpStatus.INTERNAL_SERVER_ERROR.value());
			return new ResponseEntity<>(postSalesDTOResponseStructure, HttpStatus.INTERNAL_SERVER_ERROR);
		}

		postSales.setProject(project);
		project.setPostSales(postSales);

		PostSales savedPS = postSalesRepository.save(postSales);
		if (savedPS == null) {
			postSalesDTOResponseStructure.setData(null);
			postSalesDTOResponseStructure.setMessage("Failed to save PostSales!");
			postSalesDTOResponseStructure.setStatus(HttpStatus.INTERNAL_SERVER_ERROR.value());
			return new ResponseEntity<>(postSalesDTOResponseStructure, HttpStatus.INTERNAL_SERVER_ERROR);
		}

		postSalesDTOResponseStructure.setData(postSalesMapper.toDTO(savedPS));
		postSalesDTOResponseStructure.setMessage("PostSales saved successfully!");
		postSalesDTOResponseStructure.setStatus(HttpStatus.CREATED.value());
		return new ResponseEntity<>(postSalesDTOResponseStructure, HttpStatus.CREATED);
	}

	@Transactional(readOnly = true)
	public ResponseEntity<ResponseStructure<List<PostSalesDTO>>> getAllPostSales(int page, int size) {
		Pageable pageable = PageRequest.of(page, size);
		Page<PostSales> pages = postSalesRepository.findAll(pageable);

		if (pages.isEmpty()) {
			postSalesDTOListResponseStructure.setData(null);
			postSalesDTOListResponseStructure.setMessage("List Is Empty");
			postSalesDTOListResponseStructure.setStatus(HttpStatus.OK.value());
			return new ResponseEntity<>(postSalesDTOListResponseStructure, HttpStatus.OK);
		}

		List<PostSalesDTO> dtos = postSalesMapper.toDTOList(pages.getContent());
		postSalesDTOListResponseStructure.setData(dtos);
		postSalesDTOListResponseStructure.setMessage("Success");
		postSalesDTOListResponseStructure.setStatus(HttpStatus.OK.value());
		return new ResponseEntity<>(postSalesDTOListResponseStructure, HttpStatus.OK);
	}

	// ✅ Internal use only — raw entity for service-to-service calls
	@Transactional(readOnly = true)
	public PostSales getPostSalesById(Long id) {
		return postSalesRepository.findById(id)
				.orElseThrow(() -> new RuntimeException("PostSales not found with id: " + id));
	}

	// ✅ For the controller — returns DTO wrapped in ResponseStructure
	@Transactional(readOnly = true)
	public ResponseEntity<ResponseStructure<PostSalesDTO>> getPostSalesDTOById(Long id) {
		PostSales entity = postSalesRepository.findById(id).orElse(null);

		if (entity == null) {
			postSalesDTOResponseStructure.setData(null);
			postSalesDTOResponseStructure.setMessage("PostSales not found with id: " + id);
			postSalesDTOResponseStructure.setStatus(HttpStatus.NOT_FOUND.value());
			return new ResponseEntity<>(postSalesDTOResponseStructure, HttpStatus.NOT_FOUND);
		}

		postSalesDTOResponseStructure.setData(postSalesMapper.toDTO(entity));
		postSalesDTOResponseStructure.setMessage("Success");
		postSalesDTOResponseStructure.setStatus(HttpStatus.OK.value());
		return new ResponseEntity<>(postSalesDTOResponseStructure, HttpStatus.OK);
	}

	@Transactional(readOnly = true)
	public ResponseEntity<ResponseStructure<List<PostSalesDTO>>> getPostSalesByClient(Long clientId,
			Pageable pageable) {
		Page<PostSales> page = postSalesRepository.findByClientId(clientId, pageable);
		List<PostSalesDTO> dtos = page.getContent().stream().map(postSalesMapper::toDTO).collect(Collectors.toList());

		postSalesDTOListResponseStructure.setData(dtos);
		postSalesDTOListResponseStructure.setMessage("Success");
		postSalesDTOListResponseStructure.setStatus(HttpStatus.OK.value());
		return new ResponseEntity<>(postSalesDTOListResponseStructure, HttpStatus.OK);
	}

	@Transactional(readOnly = true)
	public ResponseEntity<ResponseStructure<List<PostSalesDTO>>> getPostSalesByProject(Long projectId,
			Pageable pageable) {
		Page<PostSales> page = postSalesRepository.findByProject_ProjectId(projectId, pageable);
		List<PostSalesDTO> dtos = page.getContent().stream().map(postSalesMapper::toDTO).collect(Collectors.toList());

		postSalesDTOListResponseStructure.setData(dtos);
		postSalesDTOListResponseStructure.setMessage("Success");
		postSalesDTOListResponseStructure.setStatus(HttpStatus.OK.value());
		return new ResponseEntity<>(postSalesDTOListResponseStructure, HttpStatus.OK);
	}

	@Transactional(readOnly = true)
	public ResponseEntity<ResponseStructure<List<PostSalesDTO>>> getByStatus(PostSalesStatus status,
			Pageable pageable) {
		Page<PostSales> page = postSalesRepository.findByPostSalesStatus(status, pageable);
		List<PostSalesDTO> dtos = page.getContent().stream().map(postSalesMapper::toDTO).collect(Collectors.toList());

		postSalesDTOListResponseStructure.setData(dtos);
		postSalesDTOListResponseStructure.setMessage("Success");
		postSalesDTOListResponseStructure.setStatus(HttpStatus.OK.value());
		return new ResponseEntity<>(postSalesDTOListResponseStructure, HttpStatus.OK);
	}

	@Transactional(readOnly = true)
	public ResponseEntity<ResponseStructure<List<PostSalesDTO>>> getByNotified(Boolean notified, Pageable pageable) {
		Page<PostSales> page = postSalesRepository.findByNotified(notified, pageable);
		List<PostSalesDTO> dtos = page.getContent().stream().map(postSalesMapper::toDTO).collect(Collectors.toList());

		postSalesDTOListResponseStructure.setData(dtos);
		postSalesDTOListResponseStructure.setMessage("Success");
		postSalesDTOListResponseStructure.setStatus(HttpStatus.OK.value());
		return new ResponseEntity<>(postSalesDTOListResponseStructure, HttpStatus.OK);
	}

	@Transactional
	public ResponseEntity<ResponseStructure<PostSalesDTO>> updateStatus(Long id, PostSalesStatus status) {
		PostSales postSales = getPostSalesById(id);
		postSales.setPostSalesStatus(status);
		PostSales saved = postSalesRepository.save(postSales);

		postSalesDTOResponseStructure.setData(postSalesMapper.toDTO(saved));
		postSalesDTOResponseStructure.setMessage("Status updated");
		postSalesDTOResponseStructure.setStatus(HttpStatus.OK.value());
		return new ResponseEntity<>(postSalesDTOResponseStructure, HttpStatus.OK);
	}

	@Transactional
	public ResponseEntity<ResponseStructure<PostSalesDTO>> markAsNotified(Long id) {
		PostSales postSales = getPostSalesById(id);
		postSales.setNotified(true);
		PostSales saved = postSalesRepository.save(postSales);

		postSalesDTOResponseStructure.setData(postSalesMapper.toDTO(saved));
		postSalesDTOResponseStructure.setMessage("Marked as notified");
		postSalesDTOResponseStructure.setStatus(HttpStatus.OK.value());
		return new ResponseEntity<>(postSalesDTOResponseStructure, HttpStatus.OK);
	}

	@Transactional
	public ResponseEntity<ResponseStructure<PostSalesDTO>> updateRemark(Long id, String remark) {
		PostSales postSales = getPostSalesById(id);
		postSales.setRemark(remark);
		PostSales saved = postSalesRepository.save(postSales);

		postSalesDTOResponseStructure.setData(postSalesMapper.toDTO(saved));
		postSalesDTOResponseStructure.setMessage("Remark updated");
		postSalesDTOResponseStructure.setStatus(HttpStatus.OK.value());
		return new ResponseEntity<>(postSalesDTOResponseStructure, HttpStatus.OK);
	}

	@Transactional
	public void deletePostSales(Long id) {
		postSalesRepository.deleteById(id);
	}

	@Transactional
	public ResponseEntity<ResponseStructure<SuccessDTO>> convertToPostSales(Long preSalesId,
			boolean isQuotationAvailable) {

		Optional<PreSales> optPreSales = preSalesRepository.findById(preSalesId);
		if (optPreSales.isEmpty()) {
			successStructure.setData(null);
			successStructure.setMessage("PreSales Not Found");
			successStructure.setStatus(HttpStatus.NOT_FOUND.value());
			return new ResponseEntity<>(successStructure, HttpStatus.NOT_FOUND);
		}

		PreSales preSales = optPreSales.get();
		PostSales postSales = new PostSales();

		if (postSalesRepository.existsByPreSales(preSales)) {
			successStructure.setData(null);
			successStructure.setMessage("PreSales already converted to Postsales");
			successStructure.setStatus(HttpStatus.ALREADY_REPORTED.value());
			return new ResponseEntity<>(successStructure, HttpStatus.ALREADY_REPORTED);
		}

		if (isQuotationAvailable) {
			Quotation lastAcceptedQuotation = preSales.getQuotations().stream()
					.filter(q -> Boolean.TRUE.equals(q.getAccepted()))
					.max(Comparator.comparing(Quotation::getDateTimeIssued)).orElse(null);
			postSales.setAcceptedQuotation(lastAcceptedQuotation);
		}
		postSales.setPreSales(preSales);
		Client client = preSales.getClient();
		postSales.setClient(client);
		client.getPostSales().add(postSales);
		postSales.setPostSalesdateTime(LocalDateTime.now());
		postSales.setPostSalesStatus(PostSalesStatus.CREATED);

		Project project = projectService.createQuickProject();
		postSales.setProject(project);
		project.setPostSales(postSales);

		PostSales saved = postSalesRepository.save(postSales);
		if (saved == null) {
			successStructure.setData(null);
			successStructure.setMessage("FAILED TO SAVE POSTSALES");
			successStructure.setStatus(HttpStatus.INTERNAL_SERVER_ERROR.value());
			return new ResponseEntity<>(successStructure, HttpStatus.INTERNAL_SERVER_ERROR);
		}

		successStructure.setData(null);
		successStructure.setMessage("CONVERTED.");
		successStructure.setStatus(HttpStatus.OK.value());
		return new ResponseEntity<>(successStructure, HttpStatus.OK);
	}

	public ResponseEntity<ResponseStructure<PostSalesDTO>> updatePostSales(Long postSalesId, PostSales postSales) {
		// TODO Auto-generated method stub
		return null;
	}
}
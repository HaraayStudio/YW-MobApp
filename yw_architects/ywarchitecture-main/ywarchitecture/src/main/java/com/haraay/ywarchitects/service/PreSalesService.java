package com.haraay.ywarchitects.service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.haraay.ywarchitects.dto.*;
import com.haraay.ywarchitects.mapper.PreSalesMapper;
import com.haraay.ywarchitects.model.*;
import com.haraay.ywarchitects.repository.*;
import com.haraay.ywarchitects.service.PreSalesService;
import com.haraay.ywarchitects.util.ResponseStructure;

@Service
public class PreSalesService {

	private final PreSalesRepository preSalesRepository;
	private final ClientRepository clientRepository;
	private final PreSalesMapper preSalesMapper;
	
	@Autowired
	private PasswordEncoder passwordEncoder;

	@Autowired
	private ResponseStructure<PreSalesDTO> preSalesDTOStructure;
	@Autowired
	private ResponseStructure<List<PreSalesDTO>> preSalesDTOListStructure;

	@Autowired
	private ResponseStructure<SuccessDTO> successDTOStructure;

	public PreSalesService(PreSalesRepository preSalesRepository, ClientRepository clientRepository,
			PreSalesMapper preSalesMapper) {
		this.preSalesRepository = preSalesRepository;
		this.clientRepository = clientRepository;
		this.preSalesMapper = preSalesMapper;
	}

	public ResponseEntity<ResponseStructure<PreSalesDTO>> createPreSales(PreSales preSales, boolean existingClient) {

		if (!existingClient) {
			Client newClient=preSales.getClient();
			
			newClient.setPassword(passwordEncoder.encode(newClient.getPassword()));
			newClient.setRole("CLIENT");
			
			Client savedClient = clientRepository.save(newClient);
			preSales.setClient(savedClient);
		}

		preSales.setDateTime(LocalDateTime.now());
		PreSales saved = preSalesRepository.save(preSales);

		if (saved == null) {
			preSalesDTOStructure.setData(null);
			preSalesDTOStructure.setMessage("FAILED TO SAVE PRESALES");
			preSalesDTOStructure.setStatus(HttpStatus.INTERNAL_SERVER_ERROR.value());
			return new ResponseEntity<ResponseStructure<PreSalesDTO>>(preSalesDTOStructure,
					HttpStatus.INTERNAL_SERVER_ERROR);
		}

		PreSalesDTO dto = preSalesMapper.toDTO(saved);
		preSalesDTOStructure.setData(dto);
		preSalesDTOStructure.setMessage("PRESALES SAVEd !");
		preSalesDTOStructure.setStatus(HttpStatus.OK.value());
		return new ResponseEntity<ResponseStructure<PreSalesDTO>>(preSalesDTOStructure, HttpStatus.OK);
	}

	public ResponseEntity<ResponseStructure<List<PreSalesDTO>>> getAllPreSales(int page, int size) {
		
		Pageable pageable = PageRequest.of(page, size);


		Page<PreSales> list = preSalesRepository.findAll(pageable);

		if (list.isEmpty() || list == null) {
			preSalesDTOListStructure.setData(null);
			preSalesDTOListStructure.setMessage("EMPTY LIST !");
			preSalesDTOListStructure.setStatus(HttpStatus.FOUND.value());
			return new ResponseEntity<ResponseStructure<List<PreSalesDTO>>>(preSalesDTOListStructure, HttpStatus.FOUND);

		}

		List<PreSalesDTO> dtoList = preSalesMapper.toDTOList(list.getContent() );
		preSalesDTOListStructure.setData(dtoList);
		preSalesDTOListStructure.setMessage("FETCHED !");
		preSalesDTOListStructure.setStatus(HttpStatus.OK.value());
		return new ResponseEntity<ResponseStructure<List<PreSalesDTO>>>(preSalesDTOListStructure, HttpStatus.OK);

	}

	public ResponseEntity<ResponseStructure<PreSalesDTO>> updatePreSales(PreSales preSales) {

		Optional<PreSales> optional = preSalesRepository.findById(preSales.getSrNumber());
		if (optional.isEmpty()) {
			preSalesDTOStructure.setData(null);
			preSalesDTOStructure.setMessage("PRESALES NOT PRESENT !");
			preSalesDTOStructure.setStatus(HttpStatus.NOT_FOUND.value());
			return new ResponseEntity<ResponseStructure<PreSalesDTO>>(preSalesDTOStructure, HttpStatus.NOT_FOUND);

		}

		PreSales existing = optional.get();

		existing.setPersonName(preSales.getPersonName());
		existing.setApproachedVia(preSales.getApproachedVia());

		existing.setStatus(preSales.getStatus());
		existing.setConclusion(preSales.getConclusion());

		PreSales updated = preSalesRepository.save(existing);

		if (updated == null) {
			preSalesDTOStructure.setData(null);
			preSalesDTOStructure.setMessage("FAILED TO UPDATE PRESALES !");
			preSalesDTOStructure.setStatus(HttpStatus.INTERNAL_SERVER_ERROR.value());
			return new ResponseEntity<ResponseStructure<PreSalesDTO>>(preSalesDTOStructure,
					HttpStatus.INTERNAL_SERVER_ERROR);

		}
		preSalesDTOStructure.setData(preSalesMapper.toDTO(updated));
		preSalesDTOStructure.setMessage("PRESALES UPDATED  !");
		preSalesDTOStructure.setStatus(HttpStatus.OK.value());
		return new ResponseEntity<ResponseStructure<PreSalesDTO>>(preSalesDTOStructure, HttpStatus.OK);

	}

	public ResponseEntity<ResponseStructure<SuccessDTO>> deletePreSales(Long srNumber) {

		preSalesRepository.deleteById(srNumber);

		successDTOStructure.setData(new SuccessDTO("PreSales deleted"));
		successDTOStructure.setMessage("PreSales deleted with srNumber - " + srNumber);
		successDTOStructure.setStatus(HttpStatus.OK.value());
		return new ResponseEntity<ResponseStructure<SuccessDTO>>(successDTOStructure, HttpStatus.OK);
	}

	public ResponseEntity<ResponseStructure<SuccessDTO>> updatePreSalesStatus(Long srNumber, String status) {

		Optional<PreSales> optional = preSalesRepository.findById(srNumber);
		if (optional.isEmpty()) {
			successDTOStructure.setData(null);
			successDTOStructure.setMessage("PRESALES NOT PRESENT !");
			successDTOStructure.setStatus(HttpStatus.NOT_FOUND.value());
			return new ResponseEntity<ResponseStructure<SuccessDTO>>(successDTOStructure, HttpStatus.NOT_FOUND);

		}

		PreSales existing = optional.get();

		

		existing.setStatus(status);
		

		PreSales updated = preSalesRepository.save(existing);

		if (updated == null) {
			successDTOStructure.setData(null);
			successDTOStructure.setMessage("FAILED TO UPDATE PRESALES STATUS!");
			successDTOStructure.setStatus(HttpStatus.INTERNAL_SERVER_ERROR.value());
			return new ResponseEntity<ResponseStructure<SuccessDTO>>(successDTOStructure,
					HttpStatus.INTERNAL_SERVER_ERROR);

		}
		successDTOStructure.setData(new SuccessDTO("PRESALES STATUS UPDATED"));
		successDTOStructure.setMessage("PRESALES STATUS UPDATED  !");
		successDTOStructure.setStatus(HttpStatus.OK.value());
		return new ResponseEntity<ResponseStructure<SuccessDTO>>(successDTOStructure, HttpStatus.OK);
}
}

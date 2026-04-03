package com.haraay.ywarchitects.service;

import com.haraay.ywarchitects.dto.QuotationDTO;
import com.haraay.ywarchitects.mapper.QuotationMapper;
import com.haraay.ywarchitects.model.PreSales;
import com.haraay.ywarchitects.model.Quotation;
import com.haraay.ywarchitects.repository.PreSalesRepository;
import com.haraay.ywarchitects.repository.QuotationRepository;
import com.haraay.ywarchitects.util.ResponseStructure;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Service
public class QuotationService {

	@Autowired
	private QuotationRepository quotationRepository;

	@Autowired
	private PreSalesRepository preSalesRepository;

	@Autowired
	private QuotationMapper quotationMapper;

	// ═══════════════════════════════════════════════════════
	// CREATE
	// ═══════════════════════════════════════════════════════
	public ResponseEntity<ResponseStructure<QuotationDTO>> createQuotation(Long preSalesId, Quotation quotation) {

		// Check PreSales exists
		PreSales preSales = preSalesRepository.findById(preSalesId)
				.orElseThrow(() -> new IllegalArgumentException("PreSales not found with id: " + preSalesId));

		String quotationNumber = generateQuotationNumber();
		quotation.setQuotationNumber(quotationNumber);

		// Set defaults
		quotation.setPreSales(preSales);
		quotation.setDateTimeIssued(LocalDateTime.now());

		if (quotation.getSended() == null)
			quotation.setSended(false);
		if (quotation.getAccepted() == null)
			quotation.setAccepted(false);

		Quotation saved = quotationRepository.save(quotation);

		ResponseStructure<QuotationDTO> response = new ResponseStructure<>();
		response.setStatus(HttpStatus.CREATED.value());
		response.setMessage("Quotation created successfully");
		response.setData(quotationMapper.toDTO(saved));
		return ResponseEntity.status(HttpStatus.CREATED).body(response);
	}

	// ═══════════════════════════════════════════════════════
	// GET BY ID
	// ═══════════════════════════════════════════════════════
	public ResponseEntity<ResponseStructure<QuotationDTO>> getQuotationById(Long id) {

		Quotation quotation = quotationRepository.findById(id)
				.orElseThrow(() -> new IllegalArgumentException("Quotation not found with id: " + id));

		ResponseStructure<QuotationDTO> response = new ResponseStructure<>();
		response.setStatus(HttpStatus.OK.value());
		response.setMessage("Quotation fetched successfully");
		response.setData(quotationMapper.toDTO(quotation));
		return ResponseEntity.ok(response);
	}

	// ═══════════════════════════════════════════════════════
	// GET ALL BY PRESALES ID
	// ═══════════════════════════════════════════════════════
	public ResponseEntity<ResponseStructure<List<QuotationDTO>>> getQuotationsByPreSalesId(Long preSalesId) {

		// Verify PreSales exists
		preSalesRepository.findById(preSalesId)
				.orElseThrow(() -> new IllegalArgumentException("PreSales not found with id: " + preSalesId));

		List<Quotation> quotations = quotationRepository.findByPreSales_SrNumberOrderByDateTimeIssuedDesc(preSalesId);

		ResponseStructure<List<QuotationDTO>> response = new ResponseStructure<>();
		response.setStatus(HttpStatus.OK.value());
		response.setMessage("Quotations fetched successfully");
		response.setData(quotationMapper.toDTOList(quotations));
		return ResponseEntity.ok(response);
	}

	// ═══════════════════════════════════════════════════════
	// GET ALL
	// ═══════════════════════════════════════════════════════
	public ResponseEntity<ResponseStructure<List<QuotationDTO>>> getAllQuotations() {

		List<Quotation> quotations = quotationRepository.findAll();

		ResponseStructure<List<QuotationDTO>> response = new ResponseStructure<>();
		response.setStatus(HttpStatus.OK.value());
		response.setMessage("All quotations fetched successfully");
		response.setData(quotationMapper.toDTOList(quotations));
		return ResponseEntity.ok(response);
	}

	// ═══════════════════════════════════════════════════════
	// UPDATE
	// ═══════════════════════════════════════════════════════
	public ResponseEntity<ResponseStructure<QuotationDTO>> updateQuotation(Long id, Quotation updates) {

		Quotation existing = quotationRepository.findById(id)
				.orElseThrow(() -> new IllegalArgumentException("Quotation not found with id: " + id));

		if (updates.getQuotationDetails() != null && !updates.getQuotationDetails().isBlank())
			existing.setQuotationDetails(updates.getQuotationDetails());

		if (updates.getQuotationNumber() != null && !updates.getQuotationNumber().isBlank())
			existing.setQuotationNumber(updates.getQuotationNumber());

		if (updates.getDateTimeIssued() != null)
			existing.setDateTimeIssued(updates.getDateTimeIssued());

		if (updates.getSended() != null)
			existing.setSended(updates.getSended());

		if (updates.getAccepted() != null)
			existing.setAccepted(updates.getAccepted());

		Quotation saved = quotationRepository.save(existing);

		ResponseStructure<QuotationDTO> response = new ResponseStructure<>();
		response.setStatus(HttpStatus.OK.value());
		response.setMessage("Quotation updated successfully");
		response.setData(quotationMapper.toDTO(saved));
		return ResponseEntity.ok(response);
	}

	// ═══════════════════════════════════════════════════════
	// MARK AS SENT
	// ═══════════════════════════════════════════════════════
	public ResponseEntity<ResponseStructure<QuotationDTO>> markAsSent(Long id) {

		Quotation quotation = quotationRepository.findById(id)
				.orElseThrow(() -> new IllegalArgumentException("Quotation not found with id: " + id));

		quotation.setSended(true);
		Quotation saved = quotationRepository.save(quotation);

		ResponseStructure<QuotationDTO> response = new ResponseStructure<>();
		response.setStatus(HttpStatus.OK.value());
		response.setMessage("Quotation marked as sent");
		response.setData(quotationMapper.toDTO(saved));
		return ResponseEntity.ok(response);
	}

	// ═══════════════════════════════════════════════════════
	// MARK AS ACCEPTED
	// ═══════════════════════════════════════════════════════
	public ResponseEntity<ResponseStructure<QuotationDTO>> markAsAccepted(Long id) {

		Quotation quotation = quotationRepository.findById(id)
				.orElseThrow(() -> new IllegalArgumentException("Quotation not found with id: " + id));

		quotation.setAccepted(true);
		Quotation saved = quotationRepository.save(quotation);

		ResponseStructure<QuotationDTO> response = new ResponseStructure<>();
		response.setStatus(HttpStatus.OK.value());
		response.setMessage("Quotation marked as accepted");
		response.setData(quotationMapper.toDTO(saved));
		return ResponseEntity.ok(response);
	}

	// ═══════════════════════════════════════════════════════
	// DELETE
	// ═══════════════════════════════════════════════════════
	public ResponseEntity<ResponseStructure<String>> deleteQuotation(Long id) {

		Quotation quotation = quotationRepository.findById(id)
				.orElseThrow(() -> new IllegalArgumentException("Quotation not found with id: " + id));

		quotationRepository.delete(quotation);

		ResponseStructure<String> response = new ResponseStructure<>();
		response.setStatus(HttpStatus.OK.value());
		response.setMessage("Quotation deleted successfully");
		response.setData("Quotation with id " + id + " deleted");
		return ResponseEntity.ok(response);
	}

	// ═══════════════════════════════════════════════════════
	// HELPER — Auto-generate quotation number
	// ═══════════════════════════════════════════════════════

	private String generateQuotationNumber() {
		LocalDate now = LocalDate.now();

		// Calculate financial year (April to March)
		int startYear, endYear;
		if (now.getMonthValue() >= 4) { // April onwards
			startYear = now.getYear();
			endYear = now.getYear() + 1;
		} else { // January to March
			startYear = now.getYear() - 1;
			endYear = now.getYear();
		}

		// Format last 2 digits of years
		String startYearShort = String.format("%02d", startYear % 100);
		String endYearShort = String.format("%02d", endYear % 100);

		// Find last quotation number for this financial year
		String lastQuotationNumber = quotationRepository.findLastQuotationNumberOfFinancialYear(startYearShort,
				endYearShort);

		int nextSequence = 1;

		if (lastQuotationNumber != null && !lastQuotationNumber.trim().isEmpty()) {
			try {
				// Parse format: "QUOTE-25-25-0001"
				String[] parts = lastQuotationNumber.split("-");
				if (parts.length == 4 && parts[0].equals("QUOTE") && parts[1].equals(startYearShort)
						&& parts[2].equals(endYearShort)) {
					nextSequence = Integer.parseInt(parts[3]) + 1;
				}
			} catch (NumberFormatException e) {
				System.err.println("Error parsing financial year quotation: " + lastQuotationNumber);
				nextSequence = 1; // fallback to 0001
			}
		}

		// Generate final quotation number: QUOTE-YY-YY-NNNN
		return String.format("QUOTE-%s-%s-%04d", startYearShort, endYearShort, nextSequence);
	}

}
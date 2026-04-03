package com.haraay.ywarchitects.service;

import com.haraay.ywarchitects.dto.ProformaInvoiceDTO;
import com.haraay.ywarchitects.dto.SuccessDTO;
import com.haraay.ywarchitects.dto.TaxInvoiceDTO;
import com.haraay.ywarchitects.exception.ResourceNotFoundException;
import com.haraay.ywarchitects.mapper.TaxInvoiceMapper;
import com.haraay.ywarchitects.model.*;
import com.haraay.ywarchitects.repository.*;
import com.haraay.ywarchitects.util.ResponseStructure;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Service
public class InvoiceService {

	@Autowired
	private ProformaInvoiceRepository proformaRepository;
	@Autowired
	private TaxInvoiceRepository taxInvoiceRepository;

	@Autowired
	private PaymentRepositoty paymentRepositoty;
	@Autowired
	private PostSalesRepository postSalesRepository;
	@Autowired
	private TaxInvoiceMapper invoiceMapper;

	// ═══════════════════════════════════════════════════════
	// PROFORMA INVOICE
	// ═══════════════════════════════════════════════════════

	// CREATE Proforma
	@Transactional
	public ResponseEntity<ResponseStructure<ProformaInvoiceDTO>> createProformaInvoice(Long postSalesId,
			ProformaInvoice proforma) {

		PostSales postSales = postSalesRepository.findById(postSalesId)
				.orElseThrow(() -> new IllegalArgumentException("PostSales not found: " + postSalesId));

		// Auto-generate invoice number if not provided

		proforma.setInvoiceNumber(generateProformaNumber());

		proforma.setPostSales(postSales);
		proforma.setIssueDate(LocalDate.now());
		proforma.setPaid(false);
		proforma.setStatus("DRAFT");

		ProformaInvoice saved = proformaRepository.save(proforma);

		ResponseStructure<ProformaInvoiceDTO> response = new ResponseStructure<>();
		response.setStatus(HttpStatus.CREATED.value());
		response.setMessage("Proforma invoice created successfully");
		response.setData(invoiceMapper.toProformaDTO(saved));
		return ResponseEntity.status(HttpStatus.CREATED).body(response);
	}

	// GET Proforma by ID
	public ResponseEntity<ResponseStructure<ProformaInvoiceDTO>> getProformaById(Long id) {

		ProformaInvoice proforma = proformaRepository.findById(id)
				.orElseThrow(() -> new IllegalArgumentException("Proforma invoice not found: " + id));

		ResponseStructure<ProformaInvoiceDTO> response = new ResponseStructure<>();
		response.setStatus(HttpStatus.OK.value());
		response.setMessage("Proforma invoice fetched");
		response.setData(invoiceMapper.toProformaDTO(proforma));
		return ResponseEntity.ok(response);
	}

	// GET all Proforma invoices by PostSalesId
	public ResponseEntity<ResponseStructure<List<ProformaInvoiceDTO>>> getProformasByPostSalesId(Long postSalesId) {

		postSalesRepository.findById(postSalesId)
				.orElseThrow(() -> new IllegalArgumentException("PostSales not found: " + postSalesId));

		List<ProformaInvoice> list = proformaRepository.findByPostSales_IdOrderByIssueDateDesc(postSalesId);

		ResponseStructure<List<ProformaInvoiceDTO>> response = new ResponseStructure<>();
		response.setStatus(HttpStatus.OK.value());
		response.setMessage("Proforma invoices fetched");
		response.setData(invoiceMapper.toProformaDTOList(list));
		return ResponseEntity.ok(response);
	}

	// UPDATE Proforma
	@Transactional
	public ResponseEntity<ResponseStructure<ProformaInvoiceDTO>> updateProformaInvoice(Long id,
			ProformaInvoice updates) {

		ProformaInvoice existing = proformaRepository.findById(id)
				.orElseThrow(() -> new IllegalArgumentException("Proforma invoice not found: " + id));

		// Block update if already converted to tax invoice
		if (existing.getTaxInvoice() != null) {
			throw new IllegalStateException("Cannot update proforma — already converted to tax invoice");
		}

		if (updates.getClientName() != null)
			existing.setClientName(updates.getClientName());
		if (updates.getClientEmail() != null)
			existing.setClientEmail(updates.getClientEmail());
		if (updates.getClientPhone() != null)
			existing.setClientPhone(updates.getClientPhone());
		if (updates.getClientAddress() != null)
			existing.setClientAddress(updates.getClientAddress());
		if (updates.getClientGstin() != null)
			existing.setClientGstin(updates.getClientGstin());
		if (updates.getNetAmount() != null)
			existing.setNetAmount(updates.getNetAmount());
		if (updates.getCgstAmount() != null)
			existing.setCgstAmount(updates.getCgstAmount());
		if (updates.getSgstAmount() != null)
			existing.setSgstAmount(updates.getSgstAmount());
		if (updates.getGrossAmount() != null)
			existing.setGrossAmount(updates.getGrossAmount());
		if (updates.getAmountInWords() != null)
			existing.setAmountInWords(updates.getAmountInWords());
		if (updates.getValidTill() != null)
			existing.setValidTill(updates.getValidTill());

		ProformaInvoice saved = proformaRepository.save(existing);

		ResponseStructure<ProformaInvoiceDTO> response = new ResponseStructure<>();
		response.setStatus(HttpStatus.OK.value());
		response.setMessage("Proforma invoice updated");
		response.setData(invoiceMapper.toProformaDTO(saved));
		return ResponseEntity.ok(response);
	}

	// MARK Proforma as SENT
	@Transactional
	public ResponseEntity<ResponseStructure<ProformaInvoiceDTO>> markProformaAsSent(Long id) {

		ProformaInvoice proforma = proformaRepository.findById(id)
				.orElseThrow(() -> new IllegalArgumentException("Proforma invoice not found: " + id));

		proforma.setStatus("SENT");
		proforma.setNotified(true);
		ProformaInvoice saved = proformaRepository.save(proforma);

		ResponseStructure<ProformaInvoiceDTO> response = new ResponseStructure<>();
		response.setStatus(HttpStatus.OK.value());
		response.setMessage("Proforma invoice marked as sent");
		response.setData(invoiceMapper.toProformaDTO(saved));
		return ResponseEntity.ok(response);
	}

	// MARK Proforma as PAID (client paid the proforma)
	@Transactional
	public ResponseEntity<ResponseStructure<ProformaInvoiceDTO>> markProformaAsPaid(Long id) {

		ProformaInvoice proforma = proformaRepository.findById(id)
				.orElseThrow(() -> new IllegalArgumentException("Proforma invoice not found: " + id));

		proforma.setPaid(true);
		proforma.setStatus("PAID");
		ProformaInvoice saved = proformaRepository.save(proforma);

		ResponseStructure<ProformaInvoiceDTO> response = new ResponseStructure<>();
		response.setStatus(HttpStatus.OK.value());
		response.setMessage("Proforma invoice marked as paid — ready to convert to tax invoice");
		response.setData(invoiceMapper.toProformaDTO(saved));
		return ResponseEntity.ok(response);
	}

	// DELETE Proforma
	@Transactional
	public ResponseEntity<ResponseStructure<String>> deleteProformaInvoice(Long id) {

		ProformaInvoice proforma = proformaRepository.findById(id)
				.orElseThrow(() -> new IllegalArgumentException("Proforma invoice not found: " + id));

		if (proforma.getTaxInvoice() != null) {
			throw new IllegalStateException("Cannot delete proforma — already converted to tax invoice");
		}

		proformaRepository.delete(proforma);

		ResponseStructure<String> response = new ResponseStructure<>();
		response.setStatus(HttpStatus.OK.value());
		response.setMessage("Proforma invoice deleted");
		response.setData("Proforma with id " + id + " deleted");
		return ResponseEntity.ok(response);
	}

	// ═══════════════════════════════════════════════════════
	// CONVERT PROFORMA → TAX INVOICE (core business flow)
	// Only allowed when proforma is PAID
	// ═══════════════════════════════════════════════════════
	@Transactional
	public ResponseEntity<ResponseStructure<TaxInvoiceDTO>> convertProformaToTaxInvoice(Long proformaId) {

		ProformaInvoice proforma = proformaRepository.findById(proformaId)
				.orElseThrow(() -> new IllegalArgumentException("Proforma invoice not found: " + proformaId));

		// Must be paid before converting
		if (!proforma.isPaid()) {
			throw new IllegalStateException("Proforma must be marked as PAID before converting to tax invoice");
		}

		// Already converted check
		if (taxInvoiceRepository.existsByConvertedFrom_Id(proformaId)) {
			throw new IllegalStateException("Proforma already converted to tax invoice");
		}

		// Copy all data from proforma to new tax invoice
		TaxInvoice taxInvoice = new TaxInvoice();
		taxInvoice.setPostSales(proforma.getPostSales());
		taxInvoice.setConvertedFrom(proforma);
		taxInvoice.setInvoiceNumber(generateTaxInvoiceNumber());
		taxInvoice.setIssueDate(LocalDate.now());
		taxInvoice.setValidTill(proforma.getValidTill());

		// Copy client details
		taxInvoice.setClientName(proforma.getClientName());
		taxInvoice.setClientEmail(proforma.getClientEmail());
		taxInvoice.setClientPhone(proforma.getClientPhone());
		taxInvoice.setClientAddress(proforma.getClientAddress());
		taxInvoice.setClientGstin(proforma.getClientGstin());

		// Copy amounts
		taxInvoice.setNetAmount(proforma.getNetAmount());
		taxInvoice.setCgstAmount(proforma.getCgstAmount());
		taxInvoice.setSgstAmount(proforma.getSgstAmount());
		taxInvoice.setGrossAmount(proforma.getGrossAmount());
		taxInvoice.setAmountInWords(proforma.getAmountInWords());

		taxInvoice.setPaid(false);
		taxInvoice.setStatus("DRAFT");

		TaxInvoice saved = taxInvoiceRepository.save(taxInvoice);

		// Update proforma status to CONVERTED
		proforma.setStatus("CONVERTED");
		proformaRepository.save(proforma);

		ResponseStructure<TaxInvoiceDTO> response = new ResponseStructure<>();
		response.setStatus(HttpStatus.CREATED.value());
		response.setMessage("Tax invoice created from proforma #" + proforma.getInvoiceNumber());
		response.setData(invoiceMapper.toTaxInvoiceDTO(saved));
		return ResponseEntity.status(HttpStatus.CREATED).body(response);
	}

	// ═══════════════════════════════════════════════════════
	// TAX INVOICE
	// ═══════════════════════════════════════════════════════

	// CREATE Tax Invoice directly (without proforma)
	@Transactional
	public ResponseEntity<ResponseStructure<TaxInvoiceDTO>> createTaxInvoice(Long postSalesId, TaxInvoice taxInvoice) {

		PostSales postSales = postSalesRepository.findById(postSalesId)
				.orElseThrow(() -> new IllegalArgumentException("PostSales not found: " + postSalesId));

		if (taxInvoice.getInvoiceNumber() == null || taxInvoice.getInvoiceNumber().isBlank()) {
			taxInvoice.setInvoiceNumber(generateTaxInvoiceNumber());
		} else if (taxInvoiceRepository.existsByInvoiceNumber(taxInvoice.getInvoiceNumber())) {
			throw new IllegalArgumentException("Tax invoice number already exists: " + taxInvoice.getInvoiceNumber());
		}

		taxInvoice.setPostSales(postSales);
		taxInvoice.setIssueDate(LocalDate.now());
		taxInvoice.setPaid(false);
		taxInvoice.setStatus("DRAFT");

		TaxInvoice saved = taxInvoiceRepository.save(taxInvoice);

		ResponseStructure<TaxInvoiceDTO> response = new ResponseStructure<>();
		response.setStatus(HttpStatus.CREATED.value());
		response.setMessage("Tax invoice created successfully");
		response.setData(invoiceMapper.toTaxInvoiceDTO(saved));
		return ResponseEntity.status(HttpStatus.CREATED).body(response);
	}

	// GET Tax Invoice by ID
	public ResponseEntity<ResponseStructure<TaxInvoiceDTO>> getTaxInvoiceById(Long id) {

		TaxInvoice taxInvoice = taxInvoiceRepository.findById(id)
				.orElseThrow(() -> new IllegalArgumentException("Tax invoice not found: " + id));

		ResponseStructure<TaxInvoiceDTO> response = new ResponseStructure<>();
		response.setStatus(HttpStatus.OK.value());
		response.setMessage("Tax invoice fetched");
		response.setData(invoiceMapper.toTaxInvoiceDTO(taxInvoice));
		return ResponseEntity.ok(response);
	}

	// GET all Tax Invoices by PostSalesId
	public ResponseEntity<ResponseStructure<List<TaxInvoiceDTO>>> getTaxInvoicesByPostSalesId(Long postSalesId) {

		postSalesRepository.findById(postSalesId)
				.orElseThrow(() -> new IllegalArgumentException("PostSales not found: " + postSalesId));

		List<TaxInvoice> list = taxInvoiceRepository.findByPostSales_IdOrderByIssueDateDesc(postSalesId);

		ResponseStructure<List<TaxInvoiceDTO>> response = new ResponseStructure<>();
		response.setStatus(HttpStatus.OK.value());
		response.setMessage("Tax invoices fetched");
		response.setData(invoiceMapper.toTaxInvoiceDTOList(list));
		return ResponseEntity.ok(response);
	}

	// MARK Tax Invoice as SENT
	@Transactional
	public ResponseEntity<ResponseStructure<TaxInvoiceDTO>> markTaxInvoiceAsSent(Long id) {

		TaxInvoice taxInvoice = taxInvoiceRepository.findById(id)
				.orElseThrow(() -> new IllegalArgumentException("Tax invoice not found: " + id));

		taxInvoice.setStatus("SENT");
		taxInvoice.setNotified(true);
		TaxInvoice saved = taxInvoiceRepository.save(taxInvoice);

		ResponseStructure<TaxInvoiceDTO> response = new ResponseStructure<>();
		response.setStatus(HttpStatus.OK.value());
		response.setMessage("Tax invoice marked as sent");
		response.setData(invoiceMapper.toTaxInvoiceDTO(saved));
		return ResponseEntity.ok(response);
	}

	// MARK Tax Invoice as PAID
	@Transactional
	public ResponseEntity<ResponseStructure<TaxInvoiceDTO>> markTaxInvoiceAsPaid(Long id) {

		TaxInvoice taxInvoice = taxInvoiceRepository.findById(id)
				.orElseThrow(() -> new IllegalArgumentException("Tax invoice not found: " + id));

		taxInvoice.setPaid(true);
		taxInvoice.setStatus("PAID");
		TaxInvoice saved = taxInvoiceRepository.save(taxInvoice);

		ResponseStructure<TaxInvoiceDTO> response = new ResponseStructure<>();
		response.setStatus(HttpStatus.OK.value());
		response.setMessage("Tax invoice marked as paid");
		response.setData(invoiceMapper.toTaxInvoiceDTO(saved));
		return ResponseEntity.ok(response);
	}

	// DELETE Tax Invoice
	@Transactional
	public ResponseEntity<ResponseStructure<String>> deleteTaxInvoice(Long id) {

		TaxInvoice taxInvoice = taxInvoiceRepository.findById(id)
				.orElseThrow(() -> new IllegalArgumentException("Tax invoice not found: " + id));

		taxInvoiceRepository.delete(taxInvoice);

		ResponseStructure<String> response = new ResponseStructure<>();
		response.setStatus(HttpStatus.OK.value());
		response.setMessage("Tax invoice deleted");
		response.setData("Tax invoice with id " + id + " deleted");
		return ResponseEntity.ok(response);
	}

	// ═══════════════════════════════════════════════════════
	// HELPERS — Auto-generate invoice numbers
	// ═══════════════════════════════════════════════════════
	// ═══════════════════════════════════════════════════════
	// HELPERS — Auto-generate invoice numbers
	// ═══════════════════════════════════════════════════════

	private String generateProformaNumber() {
		String prefix = "PI";
		String financialYearSuffix = getFinancialYearSuffix(); // e.g. "25-26"
		String financialYearPrefix = prefix + "-" + financialYearSuffix; // e.g. "PI-25-26"

		String lastNumber = proformaRepository.findLastProformaInvoiceNumberOfFinancialYear(financialYearPrefix);
		int nextSequence = parseNextSequence(lastNumber, financialYearPrefix);

		return String.format("%s-%04d", financialYearPrefix, nextSequence); // PI-25-26-0001
	}

	private String generateTaxInvoiceNumber() {
		String prefix = "TI";
		String financialYearSuffix = getFinancialYearSuffix(); // e.g. "25-26"
		String financialYearPrefix = prefix + "-" + financialYearSuffix; // e.g. "TI-25-26"

		String lastNumber = taxInvoiceRepository.findLastInvoiceNumberOfFinancialYear(financialYearPrefix);
		int nextSequence = parseNextSequence(lastNumber, financialYearPrefix);

		return String.format("%s-%04d", financialYearPrefix, nextSequence); // TI-25-26-0001
	}

	// ───────────────────────────────────────────────────────
	// Shared utility: returns "25-26" style suffix
	// ───────────────────────────────────────────────────────
	private String getFinancialYearSuffix() {
		LocalDate now = LocalDate.now();
		int startYear, endYear;

		if (now.getMonthValue() >= 4) { // April onwards → new FY
			startYear = now.getYear();
			endYear = now.getYear() + 1;
		} else { // Jan–Mar → still previous FY
			startYear = now.getYear() - 1;
			endYear = now.getYear();
		}

		// "2025" → "25", "2026" → "26"
		return String.format("%02d-%02d", startYear % 100, endYear % 100);
	}

	// ───────────────────────────────────────────────────────
	// Shared utility: parses last invoice and returns next seq
	// ───────────────────────────────────────────────────────
	private int parseNextSequence(String lastInvoiceNumber, String expectedPrefix) {
		if (lastInvoiceNumber == null || lastInvoiceNumber.trim().isEmpty()) {
			return 1;
		}
		try {
			// Expected format: "PI-25-26-0001" → prefix="PI-25-26", seq="0001"
			if (lastInvoiceNumber.startsWith(expectedPrefix + "-")) {
				String sequencePart = lastInvoiceNumber.substring(expectedPrefix.length() + 1);
				return Integer.parseInt(sequencePart) + 1;
			}
		} catch (NumberFormatException e) {
			System.err.println("Error parsing invoice number: " + lastInvoiceNumber);
		}
		return 1; // fallback
	}

	@Transactional
	public ResponseEntity<ResponseStructure<TaxInvoiceDTO>> makeInvoicePaid(String invoiceNumber, Payment payment) {

		// 1. Fetch invoice
		TaxInvoice taxInvoice = taxInvoiceRepository.findByInvoiceNumber(invoiceNumber)
				.orElseThrow(() -> new ResourceNotFoundException("Tax invoice not found: " + invoiceNumber));

		// 2. Guard — already paid
		if ("PAID".equals(taxInvoice.getStatus())) {
			throw new IllegalStateException("Invoice " + invoiceNumber + " is already marked as PAID");
		}

		// 3. Validate payment fields
		if (payment.getAmountPaid() == null || payment.getAmountPaid().compareTo(BigDecimal.ZERO) <= 0) {
			throw new IllegalArgumentException("Payment amount must be greater than zero");
		}
		if (payment.getPaymentDate() == null) {
			payment.setPaymentDate(LocalDate.now()); // default to today
		}
		if (payment.getPaymentMode() == null) {
			throw new IllegalArgumentException("Payment mode is required");
		}

		// 4. Link payment to invoice

		payment.setTaxInvoice(taxInvoice);
		paymentRepositoty.save(payment);

		taxInvoice.getPayments().add(payment);

		// 5. Calculate total paid so far (including this payment)
		BigDecimal totalPaid = taxInvoice.getPayments().stream().map(Payment::getAmountPaid).reduce(BigDecimal.ZERO,
				BigDecimal::add);

		// 6. Mark PAID only if fully paid, else PARTIAL
		if (taxInvoice.getGrossAmount() != null && totalPaid.compareTo(taxInvoice.getGrossAmount()) >= 0) {
			taxInvoice.setPaid(true);
			taxInvoice.setStatus("PAID");
		} else {
			taxInvoice.setStatus("PARTIAL");
		}

		TaxInvoice saved = taxInvoiceRepository.save(taxInvoice);

		ResponseStructure<TaxInvoiceDTO> response = new ResponseStructure<>();
		response.setStatus(HttpStatus.OK.value());
		response.setMessage("Payment recorded. Invoice status: " + saved.getStatus());
		response.setData(invoiceMapper.toTaxInvoiceDTO(saved));

		return ResponseEntity.ok(response);
	}

}
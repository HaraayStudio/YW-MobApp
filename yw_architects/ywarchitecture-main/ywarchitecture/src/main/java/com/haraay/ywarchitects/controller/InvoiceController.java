package com.haraay.ywarchitects.controller;

import com.haraay.ywarchitects.dto.SuccessDTO;
import com.haraay.ywarchitects.dto.ProformaInvoiceDTO;
import com.haraay.ywarchitects.dto.TaxInvoiceDTO;
import com.haraay.ywarchitects.model.Payment;
import com.haraay.ywarchitects.model.ProformaInvoice;
import com.haraay.ywarchitects.model.TaxInvoice;
import com.haraay.ywarchitects.service.InvoiceService;
import com.haraay.ywarchitects.util.ResponseStructure;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/invoices")
public class InvoiceController {

	@Autowired
	private InvoiceService invoiceService;

	// ═══════════════════════════════════════════════════════
	// PROFORMA INVOICE ENDPOINTS
	// ═══════════════════════════════════════════════════════

	// POST /api/invoices/proforma/postsales/{postSalesId}
	@PostMapping("/proforma/postsales/{postSalesId}")
	public ResponseEntity<ResponseStructure<ProformaInvoiceDTO>> createProforma(@PathVariable Long postSalesId,
			@RequestBody ProformaInvoice proforma) {
		try {
			return invoiceService.createProformaInvoice(postSalesId, proforma);
		} catch (IllegalArgumentException e) {
			return ResponseEntity.badRequest().build();
		} catch (Exception e) {
			return ResponseEntity.internalServerError().build();
		}
	}

	// GET /api/invoices/proforma/{id}
	@GetMapping("/proforma/{id}")
	public ResponseEntity<ResponseStructure<ProformaInvoiceDTO>> getProformaById(@PathVariable Long id) {
		try {
			return invoiceService.getProformaById(id);
		} catch (IllegalArgumentException e) {
			return ResponseEntity.notFound().build();
		}
	}

	// GET /api/invoices/proforma/postsales/{postSalesId}
	@GetMapping("/proforma/postsales/{postSalesId}")
	public ResponseEntity<ResponseStructure<List<ProformaInvoiceDTO>>> getProformasByPostSales(
			@PathVariable Long postSalesId) {
		try {
			return invoiceService.getProformasByPostSalesId(postSalesId);
		} catch (IllegalArgumentException e) {
			return ResponseEntity.notFound().build();
		}
	}

	// PUT /api/invoices/proforma/{id}
	@PutMapping("/proforma/{id}")
	public ResponseEntity<ResponseStructure<ProformaInvoiceDTO>> updateProforma(@PathVariable Long id,
			@RequestBody ProformaInvoice proforma) {
		try {
			return invoiceService.updateProformaInvoice(id, proforma);
		} catch (IllegalArgumentException | IllegalStateException e) {
			return ResponseEntity.badRequest().build();
		}
	}

	// PATCH /api/invoices/proforma/{id}/send
	@PatchMapping("/proforma/{id}/send")
	public ResponseEntity<ResponseStructure<ProformaInvoiceDTO>> markProformaAsSent(@PathVariable Long id) {
		try {
			return invoiceService.markProformaAsSent(id);
		} catch (IllegalArgumentException e) {
			return ResponseEntity.notFound().build();
		}
	}

	// PATCH /api/invoices/proforma/{id}/paid
	@PatchMapping("/proforma/{id}/paid")
	public ResponseEntity<ResponseStructure<ProformaInvoiceDTO>> markProformaAsPaid(@PathVariable Long id) {
		try {
			return invoiceService.markProformaAsPaid(id);
		} catch (IllegalArgumentException e) {
			return ResponseEntity.notFound().build();
		}
	}

	// POST /api/invoices/proforma/{proformaId}/convert
	// ⭐ KEY ENDPOINT — Convert paid proforma to tax invoice
	@PostMapping("/proforma/{proformaId}/convert")
	public ResponseEntity<ResponseStructure<TaxInvoiceDTO>> convertToTaxInvoice(@PathVariable Long proformaId) {
		try {
			return invoiceService.convertProformaToTaxInvoice(proformaId);
		} catch (IllegalArgumentException e) {
			return ResponseEntity.badRequest().build();
		} catch (IllegalStateException e) {
			return ResponseEntity.badRequest().build();
		}
	}

	// DELETE /api/invoices/proforma/{id}
	@DeleteMapping("/proforma/{id}")
	public ResponseEntity<ResponseStructure<String>> deleteProforma(@PathVariable Long id) {
		try {
			return invoiceService.deleteProformaInvoice(id);
		} catch (IllegalArgumentException | IllegalStateException e) {
			return ResponseEntity.badRequest().build();
		}
	}

	// ═══════════════════════════════════════════════════════
	// TAX INVOICE ENDPOINTS
	// ═══════════════════════════════════════════════════════

	// POST /api/invoices/tax/postsales/{postSalesId}
	@PostMapping("/tax/postsales/{postSalesId}")
	public ResponseEntity<ResponseStructure<TaxInvoiceDTO>> createTaxInvoice(@PathVariable Long postSalesId,
			@RequestBody TaxInvoice taxInvoice) {
		try {
			return invoiceService.createTaxInvoice(postSalesId, taxInvoice);
		} catch (IllegalArgumentException e) {
			return ResponseEntity.badRequest().build();
		}
	}

	// GET /api/invoices/tax/{id}
	@GetMapping("/tax/{id}")
	public ResponseEntity<ResponseStructure<TaxInvoiceDTO>> getTaxInvoiceById(@PathVariable Long id) {
		try {
			return invoiceService.getTaxInvoiceById(id);
		} catch (IllegalArgumentException e) {
			return ResponseEntity.notFound().build();
		}
	}

	// GET /api/invoices/tax/postsales/{postSalesId}
	@GetMapping("/tax/postsales/{postSalesId}")
	public ResponseEntity<ResponseStructure<List<TaxInvoiceDTO>>> getTaxInvoicesByPostSales(
			@PathVariable Long postSalesId) {
		try {
			return invoiceService.getTaxInvoicesByPostSalesId(postSalesId);
		} catch (IllegalArgumentException e) {
			return ResponseEntity.notFound().build();
		}
	}

	// PATCH /api/invoices/tax/{id}/send
	@PatchMapping("/tax/{id}/send")
	public ResponseEntity<ResponseStructure<TaxInvoiceDTO>> markTaxInvoiceAsSent(@PathVariable Long id) {
		try {
			return invoiceService.markTaxInvoiceAsSent(id);
		} catch (IllegalArgumentException e) {
			return ResponseEntity.notFound().build();
		}
	}

	// PATCH /api/invoices/tax/{id}/paid
	@PatchMapping("/tax/{id}/paid")
	public ResponseEntity<ResponseStructure<TaxInvoiceDTO>> markTaxInvoiceAsPaid(@PathVariable Long id) {
		try {
			return invoiceService.markTaxInvoiceAsPaid(id);
		} catch (IllegalArgumentException e) {
			return ResponseEntity.notFound().build();
		}
	}

	// DELETE /api/invoices/tax/{id}
	@DeleteMapping("/tax/{id}")
	public ResponseEntity<ResponseStructure<String>> deleteTaxInvoice(@PathVariable Long id) {
		try {
			return invoiceService.deleteTaxInvoice(id);
		} catch (IllegalArgumentException e) {
			return ResponseEntity.notFound().build();
		}
	}

	@PostMapping("/makeinvoicepaid")
	public ResponseEntity<ResponseStructure<TaxInvoiceDTO>> makeInvoicePaid(@RequestParam String invoiceNumber,
			@RequestBody Payment payment) {

		return invoiceService.makeInvoicePaid(invoiceNumber, payment);

	}
}
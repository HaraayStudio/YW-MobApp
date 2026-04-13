package com.haraay.ywarchitects.mapper;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Component;

import com.haraay.ywarchitects.dto.ProformaInvoiceDTO;
import com.haraay.ywarchitects.dto.TaxInvoiceDTO;
import com.haraay.ywarchitects.model.ProformaInvoice;
import com.haraay.ywarchitects.model.TaxInvoice;

@Component
public class TaxInvoiceMapper {

	private final PaymentMapper paymentMapper;

	public TaxInvoiceMapper(PaymentMapper paymentMapper) {
		this.paymentMapper = paymentMapper;
	}

	public List<TaxInvoiceDTO> toTaxInvoiceDTOList(List<TaxInvoice> taxInvoices) {
		if (taxInvoices == null)
			return null;
		return taxInvoices.stream().map(this::toTaxInvoiceDTO).collect(Collectors.toList());
	}

	public TaxInvoiceDTO toTaxInvoiceDTO(TaxInvoice entity) {
		if (entity == null)
			return null;

		TaxInvoiceDTO dto = new TaxInvoiceDTO();

		// Base fields
		dto.setId(entity.getId());
		dto.setInvoiceNumber(entity.getInvoiceNumber());
		dto.setIssueDate(entity.getIssueDate());
		dto.setValidTill(entity.getValidTill());
		dto.setClientName(entity.getClientName());
		dto.setClientEmail(entity.getClientEmail());
		dto.setClientPhone(entity.getClientPhone());
		dto.setClientAddress(entity.getClientAddress());
		dto.setClientGstin(entity.getClientGstin());
		dto.setNetAmount(entity.getNetAmount());
		dto.setCgstAmount(entity.getCgstAmount());
		dto.setSgstAmount(entity.getSgstAmount());
		dto.setGrossAmount(entity.getGrossAmount());
		dto.setAmountInWords(entity.getAmountInWords());
		dto.setNotified(entity.isNotified());

		dto.setPaid(entity.isPaid());

		if (entity.getPostSales() != null) {
			dto.setPostSalesId(entity.getPostSales().getId());
		}

		if (entity.getConvertedFrom() != null) {
			dto.setConvertedFromProformaId(entity.getConvertedFrom().getId());
		}

		// payments mapping
		if (entity.getPayments() != null) {
			dto.setPayments(entity.getPayments().stream().map(paymentMapper::toDTO).collect(Collectors.toList()));
		}

		return dto;
	}

	public TaxInvoice toEntity(TaxInvoiceDTO dto) {
		if (dto == null)
			return null;

		TaxInvoice entity = new TaxInvoice();

		entity.setId(dto.getId());
		entity.setInvoiceNumber(dto.getInvoiceNumber());
		entity.setIssueDate(dto.getIssueDate());
		entity.setValidTill(dto.getValidTill());
		entity.setClientName(dto.getClientName());
		entity.setClientEmail(dto.getClientEmail());
		entity.setClientPhone(dto.getClientPhone());
		entity.setClientAddress(dto.getClientAddress());
		entity.setClientGstin(dto.getClientGstin());
		entity.setNetAmount(dto.getNetAmount());
		entity.setCgstAmount(dto.getCgstAmount());
		entity.setSgstAmount(dto.getSgstAmount());
		entity.setGrossAmount(dto.getGrossAmount());
		entity.setAmountInWords(dto.getAmountInWords());
		entity.setNotified(dto.isNotified());

		entity.setPaid(dto.isPaid());

		return entity;
	}

	// ── ProformaInvoice → ProformaInvoiceDTO ─────────────────────
	public ProformaInvoiceDTO toProformaDTO(ProformaInvoice proforma) {
		if (proforma == null)
			return null;

		ProformaInvoiceDTO dto = new ProformaInvoiceDTO();

		dto.setId(proforma.getId());
		dto.setInvoiceNumber(proforma.getInvoiceNumber());
		dto.setIssueDate(proforma.getIssueDate());
		dto.setValidTill(proforma.getValidTill());

		// Client details
		dto.setClientName(proforma.getClientName());
		dto.setClientEmail(proforma.getClientEmail());
		dto.setClientPhone(proforma.getClientPhone());
		dto.setClientAddress(proforma.getClientAddress());
		dto.setClientGstin(proforma.getClientGstin());

		// Amounts
		dto.setNetAmount(proforma.getNetAmount());
		dto.setCgstAmount(proforma.getCgstAmount());
		dto.setSgstAmount(proforma.getSgstAmount());
		dto.setGrossAmount(proforma.getGrossAmount());
		dto.setAmountInWords(proforma.getAmountInWords());

		// Status flags
		dto.setPaid(proforma.isPaid());
		dto.setNotified(proforma.isNotified());
		dto.setStatus(proforma.getStatus());

		// PostSales ID (just the ID to avoid circular refs)
		if (proforma.getPostSales() != null) {
			dto.setPostSalesId(proforma.getPostSales().getId());
		}

		// Check if converted to tax invoice
		boolean converted = proforma.getTaxInvoice() != null;
		dto.setConvertedToTaxInvoice(converted);
		if (converted) {
			dto.setTaxInvoiceId(proforma.getTaxInvoice().getId());
		}

		return dto;
	}

	// ── List mapper ───────────────────────────────────────────────
	public List<ProformaInvoiceDTO> toProformaDTOList(List<ProformaInvoice> proformas) {
		if (proformas == null)
			return null;
		return proformas.stream().map(this::toProformaDTO).collect(Collectors.toList());
	}
}

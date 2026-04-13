package com.haraay.ywarchitects.dto;

import java.time.LocalDateTime;

public class QuotationDTO {

	private Long id;
	private String quotationNumber;
	private LocalDateTime dateTimeIssued;
	private String quotationDetails;
	private Boolean sended;
	private Boolean accepted;

	// ═══════════════════════════════════════════════
	// QuotationDTO Getters & Setters
	// ═══════════════════════════════════════════════
	public QuotationDTO() {
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public String getQuotationNumber() {
		return quotationNumber;
	}

	public void setQuotationNumber(String quotationNumber) {
		this.quotationNumber = quotationNumber;
	}

	public LocalDateTime getDateTimeIssued() {
		return dateTimeIssued;
	}

	public void setDateTimeIssued(LocalDateTime dateTimeIssued) {
		this.dateTimeIssued = dateTimeIssued;
	}

	public String getQuotationDetails() {
		return quotationDetails;
	}

	public void setQuotationDetails(String quotationDetails) {
		this.quotationDetails = quotationDetails;
	}

	public Boolean getSended() {
		return sended;
	}

	public void setSended(Boolean sended) {
		this.sended = sended;
	}

	public Boolean getAccepted() {
		return accepted;
	}

	public void setAccepted(Boolean accepted) {
		this.accepted = accepted;
	}

	
}
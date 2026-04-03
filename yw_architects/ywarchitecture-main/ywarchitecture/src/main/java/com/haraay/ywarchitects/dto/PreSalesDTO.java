package com.haraay.ywarchitects.dto;

import java.time.LocalDateTime;
import java.util.List;

public class PreSalesDTO {

	private Long srNumber;
	private LocalDateTime dateTime;

	private ClientBasicDTO client;

	private String personName;
	private String approachedVia;

	private List<QuotationDTO> quotations;

	private String status;
	private String conclusion;

	public PreSalesDTO() {
		// TODO Auto-generated constructor stub
	}

	public Long getSrNumber() {
		return srNumber;
	}

	public void setSrNumber(Long srNumber) {
		this.srNumber = srNumber;
	}

	public LocalDateTime getDateTime() {
		return dateTime;
	}

	public void setDateTime(LocalDateTime dateTime) {
		this.dateTime = dateTime;
	}

	public ClientBasicDTO getClient() {
		return client;
	}

	public void setClient(ClientBasicDTO client) {
		this.client = client;
	}

	public String getPersonName() {
		return personName;
	}

	public void setPersonName(String personName) {
		this.personName = personName;
	}

	public String getApproachedVia() {
		return approachedVia;
	}

	public void setApproachedVia(String approachedVia) {
		this.approachedVia = approachedVia;
	}

	public List<QuotationDTO> getQuotations() {
		return quotations;
	}

	public void setQuotations(List<QuotationDTO> quotations) {
		this.quotations = quotations;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public String getConclusion() {
		return conclusion;
	}

	public void setConclusion(String conclusion) {
		this.conclusion = conclusion;
	}

}

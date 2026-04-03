package com.haraay.ywarchitects.model;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.OneToOne;

@Entity
public class PreSales {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long srNumber;
	private LocalDateTime dateTime;

	@ManyToOne
	@JoinColumn(name = "client_id")
	@JsonIgnoreProperties("preSales")
	private Client client;

	

	private String personName;
	private String approachedVia;

	
	@OneToMany(mappedBy = "preSales", cascade = CascadeType.ALL, orphanRemoval = true)
	@JsonIgnoreProperties("preSales")
	private List<Quotation> quotations = new ArrayList<>();

	private String status;// Onboarded / Not onboarded
	private String conclusion;// Onboarded / Not onboarded reason
	
	@OneToOne(mappedBy = "preSales", cascade = CascadeType.ALL)
	@JsonIgnoreProperties("preSales")
	private PostSales postSales;

	private Boolean converted = false;


	public PreSales() {
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

	public Client getClient() {
		return client;
	}

	public void setClient(Client client) {
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

	public List<Quotation> getQuotations() {
		return quotations;
	}

	public void setQuotations(List<Quotation> quotations) {
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
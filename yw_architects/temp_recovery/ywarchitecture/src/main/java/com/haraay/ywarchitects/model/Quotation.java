package com.haraay.ywarchitects.model;

import jakarta.persistence.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

@Entity
@Table(name = "quotation")
public class Quotation {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	@ManyToOne
	@JoinColumn(name = "pre_sales_id")
	@JsonIgnoreProperties("quotation")
	private PreSales preSales;

	@Column(name = "quotation_number")
	private String quotationNumber;

	@Column(name = "date_time_issued")
	private LocalDateTime dateTimeIssued;
	
	private String quotationDetails;

	@Column(name = "sended")
	private Boolean sended;

	@Column(name = "accepted")
	private Boolean accepted;

	// Default Constructor
	public Quotation() {
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public PreSales getPreSales() {
		return preSales;
	}

	public void setPreSales(PreSales preSales) {
		this.preSales = preSales;
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

	public String getQuotationDetails() {
		return quotationDetails;
	}

	public void setQuotationDetails(String quotationDetails) {
		this.quotationDetails = quotationDetails;
	}

	

}

package com.haraay.ywarchitects.model;

import java.time.LocalDateTime;
import java.util.ArrayList;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.OneToOne;
import java.util.List;

@Entity
public class PostSales {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	private LocalDateTime postSalesdateTime;

	@OneToOne
	@JoinColumn(name = "pre_sales_id", unique = true)
	@JsonIgnoreProperties("postSales")
	private PreSales preSales;

	@OneToOne
	@JoinColumn(name = "accepted_quotation_id")
	private Quotation acceptedQuotation;

	@ManyToOne
	@JoinColumn(name = "client_id")
	@JsonIgnoreProperties("postSales")
	private Client client;

	@OneToOne(cascade = CascadeType.ALL, orphanRemoval = true)
	@JoinColumn(name = "project_id")
	@JsonIgnoreProperties("postSales")
	private Project project;

// do we have only one project or multiple projects

	@OneToMany(mappedBy = "postSales", cascade = CascadeType.ALL)
	private List<ProformaInvoice> proformaInvoices = new ArrayList<>();

	@OneToMany(mappedBy = "postSales", cascade = CascadeType.ALL)
	private List<TaxInvoice> taxInvoices = new ArrayList<>();

	// ===============================

	private String remark;

	private boolean notified = false;

	@Enumerated(EnumType.STRING)
	@Column(length = 20)
	private PostSalesStatus postSalesStatus;

	public PostSales() {
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public Project getProject() {
		return project;
	}

	public void setProject(Project project) {
		this.project = project;
	}

	public List<ProformaInvoice> getProformaInvoices() {
		return proformaInvoices;
	}

	public void setProformaInvoices(List<ProformaInvoice> proformaInvoices) {
		this.proformaInvoices = proformaInvoices;
	}

	public List<TaxInvoice> getTaxInvoices() {
		return taxInvoices;
	}

	public void setTaxInvoices(List<TaxInvoice> taxInvoices) {
		this.taxInvoices = taxInvoices;
	}

	public LocalDateTime getPostSalesdateTime() {
		return postSalesdateTime;
	}

	public void setPostSalesdateTime(LocalDateTime postSalesdateTime) {
		this.postSalesdateTime = postSalesdateTime;
	}

	public Client getClient() {
		return client;
	}

	public void setClient(Client client) {
		this.client = client;
	}

	public String getRemark() {
		return remark;
	}

	public void setRemark(String remark) {
		this.remark = remark;
	}

	public boolean isNotified() {
		return notified;
	}

	public void setNotified(boolean notified) {
		this.notified = notified;
	}

	public PostSalesStatus getPostSalesStatus() {
		return postSalesStatus;
	}

	public void setPostSalesStatus(PostSalesStatus postSalesStatus) {
		this.postSalesStatus = postSalesStatus;
	}

	public PreSales getPreSales() {
		return preSales;
	}

	public void setPreSales(PreSales preSales) {
		this.preSales = preSales;
	}

	public Quotation getAcceptedQuotation() {
		return acceptedQuotation;
	}

	public void setAcceptedQuotation(Quotation acceptedQuotation) {
		this.acceptedQuotation = acceptedQuotation;
	}

	// ─── Getters and Setters ───

}

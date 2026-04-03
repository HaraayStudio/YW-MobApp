package com.haraay.ywarchitects.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;

@Entity
@Table(name = "proforma_invoice")
public class ProformaInvoice extends BaseInvoice {

	private boolean paid = false;

	// Status: DRAFT → SENT → PAID → CONVERTED
	private String status = "DRAFT";

	@ManyToOne
	@JoinColumn(name = "post_sales_id")
	@JsonIgnoreProperties({ "proformaInvoices", "taxInvoices", "preSales", "client", "project", "acceptedQuotation" })
	private PostSales postSales;

	// When this proforma is converted to tax invoice, link it
	@OneToOne(mappedBy = "convertedFrom")
	@JsonIgnoreProperties("convertedFrom")
	private TaxInvoice taxInvoice;

	public ProformaInvoice() {
	}

	public boolean isPaid() {
		return paid;
	}

	public void setPaid(boolean paid) {
		this.paid = paid;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public PostSales getPostSales() {
		return postSales;
	}

	public void setPostSales(PostSales postSales) {
		this.postSales = postSales;
	}

	public TaxInvoice getTaxInvoice() {
		return taxInvoice;
	}

	public void setTaxInvoice(TaxInvoice taxInvoice) {
		this.taxInvoice = taxInvoice;
	}
}
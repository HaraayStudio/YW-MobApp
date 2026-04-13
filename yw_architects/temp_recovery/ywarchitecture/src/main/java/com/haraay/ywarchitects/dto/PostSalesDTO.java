package com.haraay.ywarchitects.dto;

import java.time.LocalDateTime;
import java.util.List;

import com.haraay.ywarchitects.model.PostSalesStatus;

public class PostSalesDTO {

	private Long id;
	private LocalDateTime postSalesdateTime;

	// 🔗 lightweight relations
	private ClientBasicDTO client;
	private ProjectLiteDTO project;

	private List<ProformaInvoiceDTO> proformaInvoices;
	private List<TaxInvoiceDTO> taxInvoices;

	private String remark;
	private boolean notified;
	private PostSalesStatus postSalesStatus;

	public PostSalesDTO() {
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public LocalDateTime getPostSalesdateTime() {
		return postSalesdateTime;
	}

	public void setPostSalesdateTime(LocalDateTime postSalesdateTime) {
		this.postSalesdateTime = postSalesdateTime;
	}

	public ClientBasicDTO getClient() {
		return client;
	}

	public void setClient(ClientBasicDTO client) {
		this.client = client;
	}

	public ProjectLiteDTO getProject() {
		return project;
	}

	public void setProject(ProjectLiteDTO project) {
		this.project = project;
	}

	public List<ProformaInvoiceDTO> getProformaInvoices() {
		return proformaInvoices;
	}

	public void setProformaInvoices(List<ProformaInvoiceDTO> proformaInvoices) {
		this.proformaInvoices = proformaInvoices;
	}

	public List<TaxInvoiceDTO> getTaxInvoices() {
		return taxInvoices;
	}

	public void setTaxInvoices(List<TaxInvoiceDTO> taxInvoices) {
		this.taxInvoices = taxInvoices;
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

	
}

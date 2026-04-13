package com.haraay.ywarchitects.dto;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

public class TaxInvoiceDTO {

	private Long id;
	private String invoiceNumber;
	private LocalDate issueDate;
	private LocalDate validTill;

	// Client
	private String clientName;
	private String clientEmail;
	private String clientPhone;
	private String clientAddress;
	private String clientGstin;

	// Amounts
	private BigDecimal netAmount;
	private BigDecimal cgstAmount;
	private BigDecimal sgstAmount;
	private BigDecimal grossAmount;
	private String amountInWords;

	// Status
	private boolean paid;
	private boolean notified;
	private String status; // DRAFT, SENT, PAID

	// PostSales summary
	private Long postSalesId;

	// Converted from proforma (if applicable)
	private Long convertedFromProformaId;
	private String convertedFromProformaNumber;

	// Payments made
	private List<PaymentDTO> payments;

	// ── Nested Payment summary ────────────────────────────────────
	
	public TaxInvoiceDTO() {
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public String getInvoiceNumber() {
		return invoiceNumber;
	}

	public void setInvoiceNumber(String invoiceNumber) {
		this.invoiceNumber = invoiceNumber;
	}

	public LocalDate getIssueDate() {
		return issueDate;
	}

	public void setIssueDate(LocalDate issueDate) {
		this.issueDate = issueDate;
	}

	public LocalDate getValidTill() {
		return validTill;
	}

	public void setValidTill(LocalDate validTill) {
		this.validTill = validTill;
	}

	public String getClientName() {
		return clientName;
	}

	public void setClientName(String clientName) {
		this.clientName = clientName;
	}

	public String getClientEmail() {
		return clientEmail;
	}

	public void setClientEmail(String clientEmail) {
		this.clientEmail = clientEmail;
	}

	public String getClientPhone() {
		return clientPhone;
	}

	public void setClientPhone(String clientPhone) {
		this.clientPhone = clientPhone;
	}

	public String getClientAddress() {
		return clientAddress;
	}

	public void setClientAddress(String clientAddress) {
		this.clientAddress = clientAddress;
	}

	public String getClientGstin() {
		return clientGstin;
	}

	public void setClientGstin(String clientGstin) {
		this.clientGstin = clientGstin;
	}

	public BigDecimal getNetAmount() {
		return netAmount;
	}

	public void setNetAmount(BigDecimal netAmount) {
		this.netAmount = netAmount;
	}

	public BigDecimal getCgstAmount() {
		return cgstAmount;
	}

	public void setCgstAmount(BigDecimal cgstAmount) {
		this.cgstAmount = cgstAmount;
	}

	public BigDecimal getSgstAmount() {
		return sgstAmount;
	}

	public void setSgstAmount(BigDecimal sgstAmount) {
		this.sgstAmount = sgstAmount;
	}

	public BigDecimal getGrossAmount() {
		return grossAmount;
	}

	public void setGrossAmount(BigDecimal grossAmount) {
		this.grossAmount = grossAmount;
	}

	public String getAmountInWords() {
		return amountInWords;
	}

	public void setAmountInWords(String amountInWords) {
		this.amountInWords = amountInWords;
	}

	public boolean isPaid() {
		return paid;
	}

	public void setPaid(boolean paid) {
		this.paid = paid;
	}

	public boolean isNotified() {
		return notified;
	}

	public void setNotified(boolean notified) {
		this.notified = notified;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public Long getPostSalesId() {
		return postSalesId;
	}

	public void setPostSalesId(Long postSalesId) {
		this.postSalesId = postSalesId;
	}

	public Long getConvertedFromProformaId() {
		return convertedFromProformaId;
	}

	public void setConvertedFromProformaId(Long convertedFromProformaId) {
		this.convertedFromProformaId = convertedFromProformaId;
	}

	public String getConvertedFromProformaNumber() {
		return convertedFromProformaNumber;
	}

	public void setConvertedFromProformaNumber(String convertedFromProformaNumber) {
		this.convertedFromProformaNumber = convertedFromProformaNumber;
	}

	public List<PaymentDTO> getPayments() {
		return payments;
	}

	public void setPayments(List<PaymentDTO> payments) {
		this.payments = payments;
	}
}
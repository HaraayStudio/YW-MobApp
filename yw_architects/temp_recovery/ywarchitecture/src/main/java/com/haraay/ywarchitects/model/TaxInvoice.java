package com.haraay.ywarchitects.model;
 
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import java.util.ArrayList;
import java.util.List;
 
@Entity
@Table(name = "tax_invoice")
public class TaxInvoice extends BaseInvoice {
 
    private boolean paid = false;
 
    // Status: DRAFT → SENT → PAID
    private String status = "DRAFT";
 
    @ManyToOne
    @JoinColumn(name = "post_sales_id")
    @JsonIgnoreProperties({"proformaInvoices", "taxInvoices", "preSales", "client", "project", "acceptedQuotation"})
    private PostSales postSales;
 
    // Payments made against this tax invoice
    @OneToMany(mappedBy = "taxInvoice", cascade = CascadeType.ALL, orphanRemoval = true)
    @JsonIgnoreProperties("taxInvoice")
    private List<Payment> payments = new ArrayList<>();
 
    // The proforma this was converted from (nullable — tax invoice can exist without proforma)
    @OneToOne
    @JoinColumn(name = "proforma_id", nullable = true)
    @JsonIgnoreProperties("taxInvoice")
    private ProformaInvoice convertedFrom;
 
    public TaxInvoice() {}
 
    public boolean isPaid() { return paid; }
    public void setPaid(boolean paid) { this.paid = paid; }
 
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
 
    public PostSales getPostSales() { return postSales; }
    public void setPostSales(PostSales postSales) { this.postSales = postSales; }
 
    public List<Payment> getPayments() { return payments; }
    public void setPayments(List<Payment> payments) { this.payments = payments; }
 
    public ProformaInvoice getConvertedFrom() { return convertedFrom; }
    public void setConvertedFrom(ProformaInvoice convertedFrom) { this.convertedFrom = convertedFrom; }
}
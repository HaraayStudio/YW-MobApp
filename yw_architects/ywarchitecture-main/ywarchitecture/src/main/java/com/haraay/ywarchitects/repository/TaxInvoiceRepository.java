package com.haraay.ywarchitects.repository;

import com.haraay.ywarchitects.model.TaxInvoice;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface TaxInvoiceRepository extends JpaRepository<TaxInvoice, Long> {

	// All tax invoices for a PostSales
	List<TaxInvoice> findByPostSales_IdOrderByIssueDateDesc(Long postSalesId);

	// All unpaid tax invoices
	List<TaxInvoice> findByPaidFalse();

	// Check if proforma already converted
	boolean existsByConvertedFrom_Id(Long proformaId);

	// Check invoice number exists
	boolean existsByInvoiceNumber(String invoiceNumber);

	@Query("SELECT t FROM TaxInvoice t WHERE t.invoiceNumber = :invoiceNumber")
	Optional<TaxInvoice> findByInvoiceNumber(@Param("invoiceNumber") String invoiceNumber);

	// Latest invoice number for auto-generation
	Optional<TaxInvoice> findTopByOrderByIdDesc();

	@Query("SELECT i.invoiceNumber FROM TaxInvoice i "
			+ "WHERE i.invoiceNumber LIKE CONCAT(:financialYearPrefix, '-%') "
			+ "ORDER BY i.invoiceNumber DESC LIMIT 1")
	String findLastInvoiceNumberOfFinancialYear(@Param("financialYearPrefix") String financialYearPrefix);
}
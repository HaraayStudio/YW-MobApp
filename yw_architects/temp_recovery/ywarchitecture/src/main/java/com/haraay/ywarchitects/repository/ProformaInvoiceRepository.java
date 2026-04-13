package com.haraay.ywarchitects.repository;

import com.haraay.ywarchitects.model.ProformaInvoice;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface ProformaInvoiceRepository extends JpaRepository<ProformaInvoice, Long> {

	// All proforma invoices for a PostSales
	List<ProformaInvoice> findByPostSales_IdOrderByIssueDateDesc(Long postSalesId);

	// All unpaid proforma invoices
	List<ProformaInvoice> findByPaidFalse();

	// All paid but not yet converted to tax invoice
	List<ProformaInvoice> findByPaidTrueAndTaxInvoiceIsNull();

	// Check invoice number exists
	boolean existsByInvoiceNumber(String invoiceNumber);

	// Latest invoice number for auto-generation
	Optional<ProformaInvoice> findTopByOrderByIdDesc();

	@Query("SELECT i.invoiceNumber FROM ProformaInvoice i "
			+ "WHERE i.invoiceNumber LIKE CONCAT(:financialYearPrefix, '-%') "
			+ "ORDER BY i.invoiceNumber DESC LIMIT 1")
	String findLastProformaInvoiceNumberOfFinancialYear(@Param("financialYearPrefix") String financialYearPrefix);
}
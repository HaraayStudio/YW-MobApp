package com.haraay.ywarchitects.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.haraay.ywarchitects.model.Quotation;

public interface QuotationRepository extends JpaRepository<Quotation, Long> {

	 // Get all quotations by preSalesId
	List<Quotation> findByPreSales_SrNumberOrderByDateTimeIssuedDesc(Long srNumber);

    // Check if quotation number already exists
    boolean existsByQuotationNumber(String quotationNumber);

    // Get all accepted quotations
    List<Quotation> findByAcceptedTrue();

    // Get all sent quotations
    List<Quotation> findBySendedTrue();

    // Get latest quotation number for auto-generation
    @Query("SELECT q.quotationNumber FROM Quotation q ORDER BY q.id DESC LIMIT 1")
    Optional<String> findLatestQuotationNumber();

	@Query("SELECT q.quotationNumber FROM Quotation q "
			+ "WHERE q.quotationNumber LIKE CONCAT('QUOTE-', :startYear, '-', :endYear, '-%') "
			+ "ORDER BY q.quotationNumber DESC LIMIT 1")
	String findLastQuotationNumberOfFinancialYear(@Param("startYear") String startYear,
			@Param("endYear") String endYear);
}

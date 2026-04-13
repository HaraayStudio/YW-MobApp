package com.haraay.ywarchitects.controller;

import com.haraay.ywarchitects.dto.QuotationDTO;
import com.haraay.ywarchitects.model.Quotation;
import com.haraay.ywarchitects.service.QuotationService;
import com.haraay.ywarchitects.util.ResponseStructure;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/quotations")
public class QuotationController {

    @Autowired
    private QuotationService quotationService;

    // ── CREATE ────────────────────────────────────────────────────
    // POST /api/quotations/presales/{preSalesId}
    @PostMapping("/presales/{preSalesId}")
    public ResponseEntity<ResponseStructure<QuotationDTO>> createQuotation(
            @PathVariable Long preSalesId,
            @RequestBody Quotation quotation) {
        try {
            return quotationService.createQuotation(preSalesId, quotation);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }

    // ── GET BY ID ─────────────────────────────────────────────────
    // GET /api/quotations/{id}
    @GetMapping("/{id}")
    public ResponseEntity<ResponseStructure<QuotationDTO>> getQuotationById(@PathVariable Long id) {
        try {
            return quotationService.getQuotationById(id);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.notFound().build();
        }
    }

    // ── GET ALL BY PRESALES ───────────────────────────────────────
    // GET /api/quotations/presales/{preSalesId}
    @GetMapping("/presales/{preSalesId}")
    public ResponseEntity<ResponseStructure<List<QuotationDTO>>> getByPreSalesId(
            @PathVariable Long preSalesId) {
        try {
            return quotationService.getQuotationsByPreSalesId(preSalesId);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.notFound().build();
        }
    }

    // ── GET ALL ───────────────────────────────────────────────────
    // GET /api/quotations/all
    @GetMapping("/all")
    public ResponseEntity<ResponseStructure<List<QuotationDTO>>> getAllQuotations() {
        return quotationService.getAllQuotations();
    }

    // ── UPDATE ────────────────────────────────────────────────────
    // PUT /api/quotations/{id}
    @PutMapping("/{id}")
    public ResponseEntity<ResponseStructure<QuotationDTO>> updateQuotation(
            @PathVariable Long id,
            @RequestBody Quotation quotation) {
        try {
            return quotationService.updateQuotation(id, quotation);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        }
    }

    // ── MARK AS SENT ──────────────────────────────────────────────
    // PATCH /api/quotations/{id}/send
    @PatchMapping("/{id}/send")
    public ResponseEntity<ResponseStructure<QuotationDTO>> markAsSent(@PathVariable Long id) {
        try {
            return quotationService.markAsSent(id);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.notFound().build();
        }
    }

    // ── MARK AS ACCEPTED ──────────────────────────────────────────
    // PATCH /api/quotations/{id}/accept
    @PatchMapping("/{id}/accept")
    public ResponseEntity<ResponseStructure<QuotationDTO>> markAsAccepted(@PathVariable Long id) {
        try {
            return quotationService.markAsAccepted(id);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.notFound().build();
        }
    }

    // ── DELETE ────────────────────────────────────────────────────
    // DELETE /api/quotations/{id}
    @DeleteMapping("/{id}")
    public ResponseEntity<ResponseStructure<String>> deleteQuotation(@PathVariable Long id) {
        try {
            return quotationService.deleteQuotation(id);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.notFound().build();
        }
    }
}
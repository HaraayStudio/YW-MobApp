package com.haraay.ywarchitects.controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.haraay.ywarchitects.dto.*;
import com.haraay.ywarchitects.model.PreSales;
import com.haraay.ywarchitects.service.PreSalesService;
import com.haraay.ywarchitects.util.ResponseStructure;

@RestController
@RequestMapping("/api/presales")
public class PreSalesController {

    private final PreSalesService preSalesService;

    public PreSalesController(PreSalesService preSalesService) {
        this.preSalesService = preSalesService;
    }

    @PostMapping("/create")
    public ResponseEntity<ResponseStructure<PreSalesDTO>> create(
            @RequestBody PreSales preSales,
            @RequestParam boolean existingClient) {

        return preSalesService.createPreSales(preSales, existingClient);
    }

    @GetMapping("/getall")
    public ResponseEntity<ResponseStructure<List<PreSalesDTO>>> getAll(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        return preSalesService.getAllPreSales(page,size);
    }

    @PutMapping("/update")
    public ResponseEntity<ResponseStructure<PreSalesDTO>> update(@RequestBody PreSales preSales) {
        return preSalesService.updatePreSales(preSales);
    }

    @DeleteMapping("/delete/{srNumber}")
    public ResponseEntity<ResponseStructure<SuccessDTO>> delete(@PathVariable Long srNumber) {
        return preSalesService.deletePreSales(srNumber);
    }

    @PutMapping("/status")
    public ResponseEntity<ResponseStructure<SuccessDTO>> updateStatus(
            @RequestParam Long srNumber,
            @RequestParam String status) {

        return preSalesService.updatePreSalesStatus(srNumber, status);
    }
}

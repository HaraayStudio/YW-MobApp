package com.haraay.ywarchitects.controller;

import com.haraay.ywarchitects.dto.PostSalesDTO;
import com.haraay.ywarchitects.dto.SuccessDTO;
import com.haraay.ywarchitects.model.PostSales;
import com.haraay.ywarchitects.model.PostSalesStatus;
import com.haraay.ywarchitects.service.PostSalesService;
import com.haraay.ywarchitects.util.ResponseStructure;

import java.util.List;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/postsales")
@CrossOrigin
public class PostSalesController {

    private final PostSalesService postSalesService;

    public PostSalesController(PostSalesService postSalesService) {
        this.postSalesService = postSalesService;
    }

    // ✅ Create
    @PostMapping("/createpostSales")
    public ResponseEntity<ResponseStructure<PostSalesDTO>> create(@RequestBody PostSales postSales) {
        return postSalesService.createPostSales(postSales);
    }

    @PostMapping("/converttopostSales")
    public ResponseEntity<ResponseStructure<SuccessDTO>> convertToPostSales(@RequestParam Long preSalesId) {
        return postSalesService.convertToPostSales(preSalesId, true);
    }

    // ✅ Get All (Paginated)
    @GetMapping("/getall")
    public ResponseEntity<ResponseStructure<List<PostSalesDTO>>> getAll(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        return postSalesService.getAllPostSales(page, size);
    }

    // ✅ Get By ID — now returns DTO wrapped in ResponseStructure
    @GetMapping("/{id}")
    public ResponseEntity<ResponseStructure<PostSalesDTO>> getById(@PathVariable Long id) {
        return postSalesService.getPostSalesDTOById(id);
    }

    // ✅ Get By Client (Paginated)
    @GetMapping("/client/{clientId}")
    public ResponseEntity<ResponseStructure<List<PostSalesDTO>>> getByClient(
            @PathVariable Long clientId, Pageable pageable) {
        return postSalesService.getPostSalesByClient(clientId, pageable);
    }

    // ✅ Get By Project (Paginated)
    @GetMapping("/project/{projectId}")
    public ResponseEntity<ResponseStructure<List<PostSalesDTO>>> getByProject(
            @PathVariable Long projectId, Pageable pageable) {
        return postSalesService.getPostSalesByProject(projectId, pageable);
    }

    // ✅ Get By Status (Paginated)
    @GetMapping("/status/{status}")
    public ResponseEntity<ResponseStructure<List<PostSalesDTO>>> getByStatus(
            @PathVariable PostSalesStatus status, Pageable pageable) {
        return postSalesService.getByStatus(status, pageable);
    }

    // ✅ Get By Notified (Paginated)
    @GetMapping("/notified/{notified}")
    public ResponseEntity<ResponseStructure<List<PostSalesDTO>>> getByNotified(
            @PathVariable Boolean notified, Pageable pageable) {
        return postSalesService.getByNotified(notified, pageable);
    }

    // ✅ Update Status
    @PutMapping("/{id}/status/{status}")
    public ResponseEntity<ResponseStructure<PostSalesDTO>> updateStatus(
            @PathVariable Long id, @PathVariable PostSalesStatus status) {
        return postSalesService.updateStatus(id, status);
    }

    // ✅ Mark as Notified
    @PutMapping("/{id}/notify")
    public ResponseEntity<ResponseStructure<PostSalesDTO>> markNotified(@PathVariable Long id) {
        return postSalesService.markAsNotified(id);
    }

    // ✅ Update Remark
    @PutMapping("/{id}/remark")
    public ResponseEntity<ResponseStructure<PostSalesDTO>> updateRemark(
            @PathVariable Long id, @RequestParam String remark) {
        return postSalesService.updateRemark(id, remark);
    }

    // ✅ Delete
    @DeleteMapping("/{id}")
    public void delete(@PathVariable Long id) {
        postSalesService.deletePostSales(id);
    }
}
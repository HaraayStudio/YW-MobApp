package com.haraay.ywarchitects.controller;



import com.haraay.ywarchitects.dto.ReraProjectDTO;
import com.haraay.ywarchitects.dto.ReraProjectRequestDTO;
import com.haraay.ywarchitects.model.*;
import com.haraay.ywarchitects.service.ReraService;
import com.haraay.ywarchitects.util.ResponseStructure;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@RestController
@RequestMapping("/api/rera")
public class ReraController {

    @Autowired
    private ReraService reraService;

    // ═══════════════════════════════════════════════════════
    // RERA PROJECT
    // ═══════════════════════════════════════════════════════

    // POST /api/rera/project/{projectId}
    @PostMapping("/project/{projectId}")
    public ResponseEntity<ResponseStructure<ReraProjectDTO>> createReraProject(
            @PathVariable Long projectId,
            @RequestBody ReraProject reraProject) {
        try {
            return reraService.createReraProject(projectId, reraProject);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        }
    }

    // GET /api/rera/project/{projectId}
    @GetMapping("/project/{projectId}")
    public ResponseEntity<ResponseStructure<ReraProject>> getReraByProjectId(@PathVariable Long projectId) {
        try {
            return reraService.getReraByProjectId(projectId);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.notFound().build();
        }
    }

    // GET /api/rera/{reraId}
    @GetMapping("/{reraId}")
    public ResponseEntity<ResponseStructure<ReraProject>> getReraById(@PathVariable Long reraId) {
        try {
            return reraService.getReraById(reraId);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.notFound().build();
        }
    }

   

    // PUT /api/rera/{reraId}
    @PutMapping("/{reraId}")
    public ResponseEntity<ResponseStructure<ReraProject>> updateReraProject(
            @PathVariable Long reraId,
            @RequestBody ReraProject reraProject) {
        try {
            return reraService.updateReraProject(reraId, reraProject);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        }
    }

    // DELETE /api/rera/{reraId}
    @DeleteMapping("/{reraId}")
    public ResponseEntity<ResponseStructure<String>> deleteReraProject(@PathVariable Long reraId) {
        try {
            return reraService.deleteReraProject(reraId);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.notFound().build();
        }
    }

    // ═══════════════════════════════════════════════════════
    // RERA CERTIFICATE
    // ═══════════════════════════════════════════════════════

    // POST /api/rera/{reraId}/certificates
    @PostMapping(value = "/{reraId}/certificates", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ResponseStructure<ReraCertificate>> addCertificate(
            @PathVariable Long reraId,
            @RequestPart("certificate") ReraCertificate certificate,
            @RequestPart(value = "file", required = false) MultipartFile certificateFile) {
        try {
            return reraService.addCertificate(reraId, certificate, certificateFile);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }

    // GET /api/rera/{reraId}/certificates
    @GetMapping("/{reraId}/certificates")
    public ResponseEntity<ResponseStructure<List<ReraCertificate>>> getCertificates(@PathVariable Long reraId) {
        try {
            return reraService.getCertificatesByReraId(reraId);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.notFound().build();
        }
    }

    // PUT /api/rera/certificates/{certificateId}
    @PutMapping(value = "/certificates/{certificateId}", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ResponseStructure<ReraCertificate>> updateCertificate(
            @PathVariable Long certificateId,
            @RequestPart("certificate") ReraCertificate certificate,
            @RequestPart(value = "file", required = false) MultipartFile certificateFile) {
        try {
            return reraService.updateCertificate(certificateId, certificate, certificateFile);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }

    // DELETE /api/rera/certificates/{certificateId}
    @DeleteMapping("/certificates/{certificateId}")
    public ResponseEntity<ResponseStructure<String>> deleteCertificate(@PathVariable Long certificateId) {
        try {
            return reraService.deleteCertificate(certificateId);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.notFound().build();
        }
    }

    // ═══════════════════════════════════════════════════════
    // RERA QUARTER UPDATES
    // ═══════════════════════════════════════════════════════

    // POST /api/rera/{reraId}/quarter-updates
    @PostMapping("/{reraId}/quarter-updates")
    public ResponseEntity<ResponseStructure<ReraQuarterUpdate>> addQuarterUpdate(
            @PathVariable Long reraId,
            @RequestBody ReraQuarterUpdate quarterUpdate) {
        try {
            return reraService.addQuarterUpdate(reraId, quarterUpdate);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        }
    }

   

    // PUT /api/rera/quarter-updates/{updateId}
    @PutMapping("/quarter-updates/{updateId}")
    public ResponseEntity<ResponseStructure<ReraQuarterUpdate>> updateQuarterUpdate(
            @PathVariable Long updateId,
            @RequestBody ReraQuarterUpdate quarterUpdate) {
        try {
            return reraService.updateQuarterUpdate(updateId, quarterUpdate);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        }
    }

    // DELETE /api/rera/quarter-updates/{updateId}
    @DeleteMapping("/quarter-updates/{updateId}")
    public ResponseEntity<ResponseStructure<String>> deleteQuarterUpdate(@PathVariable Long updateId) {
        try {
            return reraService.deleteQuarterUpdate(updateId);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.notFound().build();
        }
    }
    
 // POST /api/rera/save-full
 // Accepts: multipart — reraData (JSON) + certificate files
 @PostMapping(value = "/save-full", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
 public ResponseEntity<ResponseStructure<ReraProjectDTO>> saveFullReraProject(
         @RequestPart("reraData") ReraProjectRequestDTO requestDTO,
         @RequestPart(value = "certificateFiles", required = false) List<MultipartFile> certificateFiles) {
     try {
         return reraService.saveFullReraProject(requestDTO, certificateFiles);
     } catch (IllegalArgumentException e) {
         return ResponseEntity.badRequest().build();
     } catch (Exception e) {
         return ResponseEntity.internalServerError().build();
     }
 }
}
package com.haraay.ywarchitects.service;

import com.haraay.ywarchitects.dto.ReraProjectDTO;
import com.haraay.ywarchitects.dto.ReraProjectRequestDTO;
import com.haraay.ywarchitects.exception.AlreadyExistsException;
import com.haraay.ywarchitects.mapper.ReraMapper;
import com.haraay.ywarchitects.model.*;
import com.haraay.ywarchitects.repository.*;
import com.haraay.ywarchitects.util.ResponseStructure;

import jakarta.transaction.Transactional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@Service
public class ReraService {

    @Autowired
    private ReraProjectRepository reraProjectRepository;

    @Autowired
    private ReraCertificateRepository reraCertificateRepository;

    @Autowired
    private ReraQuarterUpdateRepository reraQuarterUpdateRepository;

    @Autowired
    private ProjectRepository projectRepository;

    @Autowired
    private S3Service s3Service; // replace with your actual S3 service
    
    @Autowired
    private ReraMapper reraMapper;

    // ═══════════════════════════════════════════════════════
    // RERA PROJECT CRUD
    // ═══════════════════════════════════════════════════════

    // CREATE ReraProject linked to a Project
    public ResponseEntity<ResponseStructure<ReraProjectDTO>> createReraProject(Long projectId, ReraProject reraProject) {

        Project project = projectRepository.findById(projectId)
                .orElseThrow(() -> new IllegalArgumentException("Project not found with id: " + projectId));

        // Check if RERA already exists for this project
        if (reraProjectRepository.findByProject_ProjectId(projectId).isPresent()) {
            throw new AlreadyExistsException("RERA project already exists for project id: " + projectId);
        }

        // Check duplicate RERA number
        if (reraProjectRepository.existsByReraNumber(reraProject.getReraNumber())) {
            throw new AlreadyExistsException("RERA number already exists: " + reraProject.getReraNumber());
        }

        reraProject.setProject(project);
        ReraProject saved = reraProjectRepository.save(reraProject);

        ResponseStructure<ReraProjectDTO> response = new ResponseStructure<>();
        response.setStatus(HttpStatus.CREATED.value());
        response.setMessage("RERA project created successfully");
        response.setData(reraMapper.toDTO(saved));
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    // GET ReraProject by projectId
    public ResponseEntity<ResponseStructure<ReraProject>> getReraByProjectId(Long projectId) {

        ReraProject reraProject = reraProjectRepository.findByProject_ProjectId(projectId)
                .orElseThrow(() -> new IllegalArgumentException("RERA project not found for project id: " + projectId));

        ResponseStructure<ReraProject> response = new ResponseStructure<>();
        response.setStatus(HttpStatus.OK.value());
        response.setMessage("RERA project fetched successfully");
        response.setData(reraProject);
        return ResponseEntity.ok(response);
    }

    // GET ReraProject by reraId
    public ResponseEntity<ResponseStructure<ReraProject>> getReraById(Long reraId) {

        ReraProject reraProject = reraProjectRepository.findById(reraId)
                .orElseThrow(() -> new IllegalArgumentException("RERA project not found with id: " + reraId));

        ResponseStructure<ReraProject> response = new ResponseStructure<>();
        response.setStatus(HttpStatus.OK.value());
        response.setMessage("RERA project fetched successfully");
        response.setData(reraProject);
        return ResponseEntity.ok(response);
    }

    // GET ALL ReraProjects
    public ResponseEntity<ResponseStructure<List<ReraProject>>> getAllReraProjects() {

        List<ReraProject> list = reraProjectRepository.findAll();

        ResponseStructure<List<ReraProject>> response = new ResponseStructure<>();
        response.setStatus(HttpStatus.OK.value());
        response.setMessage("All RERA projects fetched");
        response.setData(list);
        return ResponseEntity.ok(response);
    }

    // UPDATE ReraProject
    public ResponseEntity<ResponseStructure<ReraProject>> updateReraProject(Long reraId, ReraProject updates) {

        ReraProject existing = reraProjectRepository.findById(reraId)
                .orElseThrow(() -> new IllegalArgumentException("RERA project not found with id: " + reraId));

        if (updates.getReraNumber() != null && !updates.getReraNumber().isBlank())
            existing.setReraNumber(updates.getReraNumber());

        if (updates.getRegistrationDate() != null)
            existing.setRegistrationDate(updates.getRegistrationDate());

        if (updates.getExpectedCompletionDate() != null)
            existing.setExpectedCompletionDate(updates.getExpectedCompletionDate());

        if (updates.getActive() != null)
            existing.setActive(updates.getActive());

        ReraProject saved = reraProjectRepository.save(existing);

        ResponseStructure<ReraProject> response = new ResponseStructure<>();
        response.setStatus(HttpStatus.OK.value());
        response.setMessage("RERA project updated successfully");
        response.setData(saved);
        return ResponseEntity.ok(response);
    }

    // DELETE ReraProject
    public ResponseEntity<ResponseStructure<String>> deleteReraProject(Long reraId) {

        ReraProject reraProject = reraProjectRepository.findById(reraId)
                .orElseThrow(() -> new IllegalArgumentException("RERA project not found with id: " + reraId));

        reraProjectRepository.delete(reraProject);

        ResponseStructure<String> response = new ResponseStructure<>();
        response.setStatus(HttpStatus.OK.value());
        response.setMessage("RERA project deleted successfully");
        response.setData("RERA project with id " + reraId + " deleted");
        return ResponseEntity.ok(response);
    }

    // ═══════════════════════════════════════════════════════
    // RERA CERTIFICATE CRUD
    // ═══════════════════════════════════════════════════════

    // ADD Certificate to ReraProject
    public ResponseEntity<ResponseStructure<ReraCertificate>> addCertificate(
            Long reraId,
            ReraCertificate certificate,
            MultipartFile certificateFile) throws Exception {

        ReraProject reraProject = reraProjectRepository.findById(reraId)
                .orElseThrow(() -> new IllegalArgumentException("RERA project not found with id: " + reraId));

        // Upload certificate file to S3 if provided
        if (certificateFile != null && !certificateFile.isEmpty()) {
            String fileUrl = s3Service.uploadFile(certificateFile);
            certificate.setCertificateFileUrl(fileUrl);
        }

        certificate.setReraProject(reraProject);
        ReraCertificate saved = reraCertificateRepository.save(certificate);

        ResponseStructure<ReraCertificate> response = new ResponseStructure<>();
        response.setStatus(HttpStatus.CREATED.value());
        response.setMessage("Certificate added successfully");
        response.setData(saved);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    // GET all Certificates by reraId
    public ResponseEntity<ResponseStructure<List<ReraCertificate>>> getCertificatesByReraId(Long reraId) {

        // Verify rera exists
        reraProjectRepository.findById(reraId)
                .orElseThrow(() -> new IllegalArgumentException("RERA project not found with id: " + reraId));

        List<ReraCertificate> certificates = reraCertificateRepository.findByReraProject_Id(reraId);

        ResponseStructure<List<ReraCertificate>> response = new ResponseStructure<>();
        response.setStatus(HttpStatus.OK.value());
        response.setMessage("Certificates fetched successfully");
        response.setData(certificates);
        return ResponseEntity.ok(response);
    }

    // UPDATE Certificate
    public ResponseEntity<ResponseStructure<ReraCertificate>> updateCertificate(
            Long certificateId,
            ReraCertificate updates,
            MultipartFile certificateFile) throws Exception {

        ReraCertificate existing = reraCertificateRepository.findById(certificateId)
                .orElseThrow(() -> new IllegalArgumentException("Certificate not found with id: " + certificateId));

       
        if (updates.getCertificateDate() != null)
            existing.setCertificateDate(updates.getCertificateDate());

        if (updates.getRemarks() != null && !updates.getRemarks().isBlank())
            existing.setRemarks(updates.getRemarks());

        if (updates.getCertifiedBy() != null)
            existing.setCertifiedBy(updates.getCertifiedBy());

        // Upload new certificate file if provided
        if (certificateFile != null && !certificateFile.isEmpty()) {
            // Delete old file from S3
            if (existing.getCertificateFileUrl() != null) {
                try { s3Service.deleteFileByUrl(existing.getCertificateFileUrl()); } catch (Exception ignored) {}
            }
            String fileUrl = s3Service.uploadFile(certificateFile);
            existing.setCertificateFileUrl(fileUrl);
        }

        ReraCertificate saved = reraCertificateRepository.save(existing);

        ResponseStructure<ReraCertificate> response = new ResponseStructure<>();
        response.setStatus(HttpStatus.OK.value());
        response.setMessage("Certificate updated successfully");
        response.setData(saved);
        return ResponseEntity.ok(response);
    }

    // DELETE Certificate
    public ResponseEntity<ResponseStructure<String>> deleteCertificate(Long certificateId) {

        ReraCertificate certificate = reraCertificateRepository.findById(certificateId)
                .orElseThrow(() -> new IllegalArgumentException("Certificate not found with id: " + certificateId));

        // Delete file from S3
        if (certificate.getCertificateFileUrl() != null) {
            try { s3Service.deleteFileByUrl(certificate.getCertificateFileUrl() ); } catch (Exception ignored) {}
        }

        reraCertificateRepository.delete(certificate);

        ResponseStructure<String> response = new ResponseStructure<>();
        response.setStatus(HttpStatus.OK.value());
        response.setMessage("Certificate deleted successfully");
        response.setData("Certificate with id " + certificateId + " deleted");
        return ResponseEntity.ok(response);
    }

    // ═══════════════════════════════════════════════════════
    // RERA QUARTER UPDATE CRUD
    // ═══════════════════════════════════════════════════════

    // ADD Quarter Update
    public ResponseEntity<ResponseStructure<ReraQuarterUpdate>> addQuarterUpdate(Long reraId, ReraQuarterUpdate quarterUpdate) {

        ReraProject reraProject = reraProjectRepository.findById(reraId)
                .orElseThrow(() -> new IllegalArgumentException("RERA project not found with id: " + reraId));

        quarterUpdate.setReraProject(reraProject);
        ReraQuarterUpdate saved = reraQuarterUpdateRepository.save(quarterUpdate);

        ResponseStructure<ReraQuarterUpdate> response = new ResponseStructure<>();
        response.setStatus(HttpStatus.CREATED.value());
        response.setMessage("Quarter update added successfully");
        response.setData(saved);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

   

    // UPDATE Quarter Update
    public ResponseEntity<ResponseStructure<ReraQuarterUpdate>> updateQuarterUpdate(Long updateId, ReraQuarterUpdate updates) {

        ReraQuarterUpdate existing = reraQuarterUpdateRepository.findById(updateId)
                .orElseThrow(() -> new IllegalArgumentException("Quarter update not found with id: " + updateId));

        if (updates.getConstructionStatus() != null && !updates.getConstructionStatus().isBlank())
            existing.setConstructionStatus(updates.getConstructionStatus());

        if (updates.getSalesStatus() != null && !updates.getSalesStatus().isBlank())
            existing.setSalesStatus(updates.getSalesStatus());

        if (updates.getQuarterDate() != null)
            existing.setQuarterDate(updates.getQuarterDate());

        ReraQuarterUpdate saved = reraQuarterUpdateRepository.save(existing);

        ResponseStructure<ReraQuarterUpdate> response = new ResponseStructure<>();
        response.setStatus(HttpStatus.OK.value());
        response.setMessage("Quarter update updated successfully");
        response.setData(saved);
        return ResponseEntity.ok(response);
    }

    // DELETE Quarter Update
    public ResponseEntity<ResponseStructure<String>> deleteQuarterUpdate(Long updateId) {

        ReraQuarterUpdate update = reraQuarterUpdateRepository.findById(updateId)
                .orElseThrow(() -> new IllegalArgumentException("Quarter update not found with id: " + updateId));

        reraQuarterUpdateRepository.delete(update);

        ResponseStructure<String> response = new ResponseStructure<>();
        response.setStatus(HttpStatus.OK.value());
        response.setMessage("Quarter update deleted successfully");
        response.setData("Quarter update with id " + updateId + " deleted");
        return ResponseEntity.ok(response);
    }
    
    @Transactional
    public ResponseEntity<ResponseStructure<ReraProjectDTO>> saveFullReraProject(
            ReraProjectRequestDTO requestDTO,
            List<MultipartFile> certificateFiles) throws Exception {

        // ── 1. Validate project exists ────────────────────────────────
        Project project = projectRepository.findById(requestDTO.getProjectId())
                .orElseThrow(() -> new IllegalArgumentException(
                        "Project not found with id: " + requestDTO.getProjectId()));

        // ── 2. Check RERA not already linked to this project ──────────
        if (reraProjectRepository.findByProject_ProjectId(requestDTO.getProjectId()).isPresent()) {
            throw new IllegalArgumentException(
                    "RERA project already exists for project id: " + requestDTO.getProjectId());
        }

        // ── 3. Check duplicate RERA number ────────────────────────────
        if (reraProjectRepository.existsByReraNumber(requestDTO.getReraNumber())) {
            throw new IllegalArgumentException(
                    "RERA number already registered: " + requestDTO.getReraNumber());
        }

        // ── 4. Build ReraProject ──────────────────────────────────────
        ReraProject reraProject = new ReraProject();
        reraProject.setProject(project);
        reraProject.setReraNumber(requestDTO.getReraNumber());
        reraProject.setRegistrationDate(requestDTO.getRegistrationDate());
        reraProject.setExpectedCompletionDate(requestDTO.getExpectedCompletionDate());
        reraProject.setActive(requestDTO.getActive() != null ? requestDTO.getActive() : true);

        // ── 5. Build N Certificates ───────────────────────────────────
        if (requestDTO.getCertificates() != null && !requestDTO.getCertificates().isEmpty()) {

            for (int i = 0; i < requestDTO.getCertificates().size(); i++) {
                ReraProjectRequestDTO.CertificateRequestDTO certDTO = requestDTO.getCertificates().get(i);

                ReraCertificate certificate = new ReraCertificate();
                certificate.setCompletionPercentage(certDTO.getCompletionPercentage()); 
                certificate.setCertificateDate(certDTO.getCertificateDate());
                certificate.setRemarks(certDTO.getRemarks());
                certificate.setCertifiedBy(certDTO.getCertifiedBy());
                certificate.setReraProject(reraProject);

              
                // Upload certificate file if provided at same index
                if (certificateFiles != null && i < certificateFiles.size()
                        && !certificateFiles.get(i).isEmpty()) {
                    String fileUrl = s3Service.uploadFile(certificateFiles.get(i));
                    certificate.setCertificateFileUrl(fileUrl);
                }

                reraProject.getCertificates().add(certificate);
            }
        }

        // ── 6. Build N Quarter Updates ────────────────────────────────
        if (requestDTO.getQuarterUpdates() != null && !requestDTO.getQuarterUpdates().isEmpty()) {

            for (ReraProjectRequestDTO.QuarterUpdateRequestDTO updateDTO : requestDTO.getQuarterUpdates()) {
                ReraQuarterUpdate quarterUpdate = new ReraQuarterUpdate();
                quarterUpdate.setConstructionStatus(updateDTO.getConstructionStatus());
                quarterUpdate.setSalesStatus(updateDTO.getSalesStatus());
                quarterUpdate.setQuarterDate(updateDTO.getQuarterDate());
                quarterUpdate.setReraProject(reraProject);

                reraProject.getQuarterUpdates().add(quarterUpdate);
            }
        }

        // ── 7. Save everything (cascades handle certificates + updates)
        ReraProject saved = reraProjectRepository.save(reraProject);

        // ── 8. Return DTO ─────────────────────────────────────────────
        ResponseStructure<ReraProjectDTO> response = new ResponseStructure<>();
        response.setStatus(HttpStatus.CREATED.value());
        response.setMessage("RERA project saved successfully with " +
                (saved.getCertificates() != null ? saved.getCertificates().size() : 0) + " certificate(s) and " +
                (saved.getQuarterUpdates() != null ? saved.getQuarterUpdates().size() : 0) + " quarter update(s)");
        response.setData(reraMapper.toDTO(saved));

        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }
} 
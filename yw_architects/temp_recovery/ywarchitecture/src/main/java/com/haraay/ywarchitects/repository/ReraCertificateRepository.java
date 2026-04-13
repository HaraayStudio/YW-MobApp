package com.haraay.ywarchitects.repository;

import com.haraay.ywarchitects.model.ReraCertificate;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface ReraCertificateRepository extends JpaRepository<ReraCertificate, Long> {
	List<ReraCertificate> findByReraProject_Id(Long reraProjectId);
}
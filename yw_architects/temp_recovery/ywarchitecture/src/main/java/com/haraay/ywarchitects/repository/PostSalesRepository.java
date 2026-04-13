package com.haraay.ywarchitects.repository;

import com.haraay.ywarchitects.model.PostSales;
import com.haraay.ywarchitects.model.PostSalesStatus;
import com.haraay.ywarchitects.model.PreSales;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PostSalesRepository extends JpaRepository<PostSales, Long> {

    Page<PostSales> findByClientId(Long clientId, Pageable pageable);

    Page<PostSales> findByProject_ProjectId(Long projectId, Pageable pageable);


    Page<PostSales> findByPostSalesStatus(PostSalesStatus status, Pageable pageable);

    Page<PostSales> findByNotified(Boolean notified, Pageable pageable);

    Page<PostSales> findAllByOrderByPostSalesdateTimeDesc(Pageable pageable);
    
    boolean existsByPreSales(PreSales preSales);
}

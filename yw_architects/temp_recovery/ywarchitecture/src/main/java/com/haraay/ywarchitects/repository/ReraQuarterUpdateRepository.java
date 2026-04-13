package com.haraay.ywarchitects.repository;

import com.haraay.ywarchitects.model.ReraQuarterUpdate;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface ReraQuarterUpdateRepository extends JpaRepository<ReraQuarterUpdate, Long> {
    List<ReraQuarterUpdate> findByReraProject_IdOrderByQuarterDateDesc(Long reraProjectId);
}
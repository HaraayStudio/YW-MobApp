package com.haraay.ywarchitects.repository;

import com.haraay.ywarchitects.model.Project;
import com.haraay.ywarchitects.model.SiteVisit;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface SiteVisitRepository extends JpaRepository<SiteVisit, Long> {
    List<SiteVisit> findByProject(Project project);
}
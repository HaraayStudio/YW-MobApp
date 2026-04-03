package com.haraay.ywarchitects.website.repository;

import com.haraay.ywarchitects.website.model.WebProject;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface WebProjectRepository extends JpaRepository<WebProject, Long> {

    /** Used by the public website endpoint: GET /api/projects/{slug} */
    Optional<WebProject> findBySlug(String slug);

    /** Check slug uniqueness before save/update in admin. */
    boolean existsBySlug(String slug);

    /** Check slug uniqueness excluding the current project (for update). */
    boolean existsBySlugAndIdNot(String slug, Long id);

    /** Listing page — ordered by srNo so admin-controlled order is respected. */
    List<WebProject> findAllByOrderBySrNoAsc();
}
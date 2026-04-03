package com.haraay.ywarchitects.website.repository;

import com.haraay.ywarchitects.website.model.GalleryImage;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface GalleryImageRepository extends JpaRepository<GalleryImage, Long> {

    /** Fetch all gallery images for a project, ordered by srNo. */
    List<GalleryImage> findByProjectIdOrderBySrNoAsc(Long projectId);

    /** Delete all images belonging to a project (used during full gallery replace). */
    void deleteAllByProjectId(Long projectId);
}
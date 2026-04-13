package com.haraay.ywarchitects.service;


import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.haraay.ywarchitects.model.MediaType;
import com.haraay.ywarchitects.model.StageMedia;
import com.haraay.ywarchitects.repository.StageMediaRepository;

import java.util.List;
import java.util.Optional;

@Service
public class StageMediaService {
    
    @Autowired
    private StageMediaRepository mediaRepository;
    
    
    // ═══════════════════════════════════════════════════════════════
    // READ OPERATIONS
    // ═══════════════════════════════════════════════════════════════
    
    /**
     * Get all media for a stage
     */
    
    
    /**
     * Get images for a stage
     */
    
    
    /**
     * Get videos for a stage
     */
   
    
    
    // ═══════════════════════════════════════════════════════════════
    // UPDATE OPERATIONS
    // ═══════════════════════════════════════════════════════════════
    
    /**
     * Update media
     */
    @Transactional
    public StageMedia updateMedia(StageMedia media) {
        return mediaRepository.save(media);
    }
    
    
    // ═══════════════════════════════════════════════════════════════
    // DELETE OPERATIONS
    // ═══════════════════════════════════════════════════════════════
    
    /**
     * Delete media
     */
    @Transactional
    public void deleteMedia(Long mediaId) {
        mediaRepository.deleteById(mediaId);
    }
    
    
    // ═══════════════════════════════════════════════════════════════
    // STATISTICS
    // ═══════════════════════════════════════════════════════════════
    
    /**
     * Count media files for a stage
     */
   
}

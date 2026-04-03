//package com.haraay.ywarchitects.controller;
//
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.http.HttpStatus;
//import org.springframework.http.ResponseEntity;
//import org.springframework.web.bind.annotation.*;
//
//import com.haraay.ywarchitects.model.MediaType;
//import com.haraay.ywarchitects.model.StageMedia;
//import com.haraay.ywarchitects.service.StageMediaService;
//
//import java.util.HashMap;
//import java.util.List;
//import java.util.Map;
//
//@RestController
//@RequestMapping("/api/stages/{stageId}/media")
//@CrossOrigin(origins = "*")
//public class StageMediaController {
//    
//    @Autowired
//    private StageMediaService mediaService;
//    
//    
//    // ═══════════════════════════════════════════════════════════════
//    // GET OPERATIONS
//    // ═══════════════════════════════════════════════════════════════
//    
//    /**
//     * Get all media for a stage
//     * 
//     * GET /api/stages/9/media
//     */
//    @GetMapping
//    public ResponseEntity<List<StageMedia>> getAllMedia(@PathVariable Long stageId) {
//        List<StageMedia> media = mediaService.getMediaByStage(stageId);
//        return ResponseEntity.ok(media);
//    }
//    
//    /**
//     * Get media by ID
//     * 
//     * GET /api/stages/9/media/140
//     */
//    @GetMapping("/{mediaId}")
//    public ResponseEntity<StageMedia> getMediaById(
//            @PathVariable Long stageId,
//            @PathVariable Long mediaId) {
//        
//        return mediaService.getMediaById(mediaId)
//            .map(ResponseEntity::ok)
//            .orElse(ResponseEntity.notFound().build());
//    }
//    
//    /**
//     * Get media by type
//     * 
//     * GET /api/stages/9/media/type/VIDEO
//     */
//    @GetMapping("/type/{mediaType}")
//    public ResponseEntity<List<StageMedia>> getMediaByType(
//            @PathVariable Long stageId,
//            @PathVariable String mediaType) {
//        
//        MediaType type = MediaType.valueOf(mediaType);
//        List<StageMedia> media = mediaService.getMediaByType(stageId, type);
//        return ResponseEntity.ok(media);
//    }
//    
//    /**
//     * Get images
//     * 
//     * GET /api/stages/9/media/images
//     */
//    @GetMapping("/images")
//    public ResponseEntity<List<StageMedia>> getImages(@PathVariable Long stageId) {
//        List<StageMedia> images = mediaService.getImages(stageId);
//        return ResponseEntity.ok(images);
//    }
//    
//    /**
//     * Get videos
//     * 
//     * GET /api/stages/9/media/videos
//     */
//    @GetMapping("/videos")
//    public ResponseEntity<List<StageMedia>> getVideos(@PathVariable Long stageId) {
//        List<StageMedia> videos = mediaService.getVideos(stageId);
//        return ResponseEntity.ok(videos);
//    }
//    
//    /**
//     * Get media ordered by date
//     * 
//     * GET /api/stages/9/media/ordered-by-date
//     */
//    @GetMapping("/ordered-by-date")
//    public ResponseEntity<List<StageMedia>> getMediaOrderedByDate(@PathVariable Long stageId) {
//        List<StageMedia> media = mediaService.getMediaOrderedByDate(stageId);
//        return ResponseEntity.ok(media);
//    }
//    
//    /**
//     * Get media by location
//     * 
//     * GET /api/stages/9/media/location?location=Driveway
//     */
//    @GetMapping("/location")
//    public ResponseEntity<List<StageMedia>> getMediaByLocation(
//            @PathVariable Long stageId,
//            @RequestParam String location) {
//        
//        List<StageMedia> media = mediaService.getMediaByLocation(stageId, location);
//        return ResponseEntity.ok(media);
//    }
//    
//    /**
//     * Get media by user
//     * 
//     * GET /api/stages/9/media/user/123
//     */
//    @GetMapping("/user/{userId}")
//    public ResponseEntity<List<StageMedia>> getMediaByUser(
//            @PathVariable Long stageId,
//            @PathVariable Long userId) {
//        
//        List<StageMedia> media = mediaService.getMediaByUser(stageId, userId);
//        return ResponseEntity.ok(media);
//    }
//    
//    
//    // ═══════════════════════════════════════════════════════════════
//    // UPDATE OPERATIONS
//    // ═══════════════════════════════════════════════════════════════
//    
//    /**
//     * Update media
//     * 
//     * PUT /api/stages/9/media/140
//     */
//    @PutMapping("/{mediaId}")
//    public ResponseEntity<StageMedia> updateMedia(
//            @PathVariable Long stageId,
//            @PathVariable Long mediaId,
//            @RequestBody StageMedia media) {
//        
//        media.setId(mediaId);
//        StageMedia updated = mediaService.updateMedia(media);
//        return ResponseEntity.ok(updated);
//    }
//    
//    
//    // ═══════════════════════════════════════════════════════════════
//    // DELETE OPERATIONS
//    // ═══════════════════════════════════════════════════════════════
//    
//    /**
//     * Delete media
//     * 
//     * DELETE /api/stages/9/media/140
//     */
//    @DeleteMapping("/{mediaId}")
//    public ResponseEntity<Void> deleteMedia(
//            @PathVariable Long stageId,
//            @PathVariable Long mediaId) {
//        
//        mediaService.deleteMedia(mediaId);
//        return ResponseEntity.noContent().build();
//    }
//    
//    
//    // ═══════════════════════════════════════════════════════════════
//    // STATISTICS
//    // ═══════════════════════════════════════════════════════════════
//    
//    /**
//     * Get media statistics
//     * 
//     * GET /api/stages/9/media/statistics
//     */
//    @GetMapping("/statistics")
//    public ResponseEntity<Map<String, Object>> getMediaStatistics(@PathVariable Long stageId) {
//        Map<String, Object> stats = new HashMap<>();
//        
//        stats.put("totalMedia", mediaService.countMedia(stageId));
//        
//        return ResponseEntity.ok(stats);
//    }
//}

package com.haraay.ywarchitects.controller;

import com.haraay.ywarchitects.dto.MeetingDTO;
import com.haraay.ywarchitects.dto.MeetingMessageDTO;
import com.haraay.ywarchitects.util.ResponseStructure;
import com.haraay.ywarchitects.model.Meeting;
import com.haraay.ywarchitects.model.MeetingMessage;
import com.haraay.ywarchitects.service.MeetingService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/meetings")
public class MeetingController {

    @Autowired
    private MeetingService meetingService;

    // POST /api/meetings/create?projectId=1&createdBy=2
    @PostMapping("/create")
    public ResponseEntity<ResponseStructure<MeetingDTO>> createMeeting(
            @RequestParam long projectId,
            @RequestParam Long createdBy,
            @RequestBody Meeting meeting) {
        return meetingService.createMeeting(projectId, createdBy, meeting);
    }

    // GET /api/meetings/project/1
    @GetMapping("/project/{projectId}")
    public ResponseEntity<ResponseStructure<List<MeetingDTO>>> getMeetingsByProject(
            @PathVariable long projectId) {
        return meetingService.getMeetingsByProject(projectId);
    }

    // GET /api/meetings/1
    @GetMapping("/{meetingId}")
    public ResponseEntity<ResponseStructure<MeetingDTO>> getMeetingById(
            @PathVariable Long meetingId) {
        return meetingService.getMeetingById(meetingId);
    }

    // PUT /api/meetings/update/1
    @PutMapping("/update/{meetingId}")
    public ResponseEntity<ResponseStructure<MeetingDTO>> updateMeeting(
            @PathVariable Long meetingId,
            @RequestBody Meeting meeting) {
        return meetingService.updateMeeting(meetingId, meeting);
    }

    // POST /api/meetings/1/attendee?userId=3
    @PostMapping("/{meetingId}/attendee")
    public ResponseEntity<ResponseStructure<MeetingDTO>> addAttendee(
            @PathVariable Long meetingId,
            @RequestParam Long userId) {
        return meetingService.addAttendee(meetingId, userId);
    }

    // POST /api/meetings/1/message?senderId=2&replyToId=5 (replyToId optional)
    @PostMapping("/{meetingId}/message")
    public ResponseEntity<ResponseStructure<MeetingMessageDTO>> sendMessage(
            @PathVariable Long meetingId,
            @RequestParam Long senderId,
            @RequestParam(required = false) Long replyToId,
            @RequestBody MeetingMessage message) {
        return meetingService.sendMessage(meetingId, senderId, message, replyToId);
    }

    // GET /api/meetings/1/messages
    @GetMapping("/{meetingId}/messages")
    public ResponseEntity<ResponseStructure<List<MeetingMessageDTO>>> getMessages(
            @PathVariable Long meetingId) {
        return meetingService.getMessages(meetingId);
    }

    // DELETE /api/meetings/delete/1
    @DeleteMapping("/delete/{meetingId}")
    public ResponseEntity<ResponseStructure<String>> deleteMeeting(
            @PathVariable Long meetingId) {
        return meetingService.deleteMeeting(meetingId);
    }
}
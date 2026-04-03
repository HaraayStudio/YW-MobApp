package com.haraay.ywarchitects.service;

import com.haraay.ywarchitects.dto.MeetingDTO;
import com.haraay.ywarchitects.dto.MeetingMessageDTO;
import com.haraay.ywarchitects.util.ResponseStructure;
import com.haraay.ywarchitects.mapper.MeetingMapper;
import com.haraay.ywarchitects.model.*;
import com.haraay.ywarchitects.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class MeetingService {

	@Autowired
	private MeetingRepository meetingRepository;
	@Autowired
	private MeetingMessageRepository messageRepository;
	@Autowired
	private ProjectRepository projectRepository;
	@Autowired
	private UserRepository userRepository;
	@Autowired
	private MeetingMapper meetingMapper;

	// ── Create Meeting ─────────────────────────────────
	@Transactional
	public ResponseEntity<ResponseStructure<MeetingDTO>> createMeeting(long projectId, Long createdByUserId,
			Meeting meeting) {

		Project project = projectRepository.findById(projectId)
				.orElseThrow(() -> new IllegalArgumentException("Project not found: " + projectId));

		User createdBy = userRepository.findById(createdByUserId)
				.orElseThrow(() -> new IllegalArgumentException("User not found: " + createdByUserId));

		meeting.setProject(project);
		meeting.setCreatedBy(createdBy);

		// ✅ Fetch full User entities from DB using IDs sent in request
		if (!meeting.getAttendees().isEmpty()) {
			List<User> resolvedAttendees = meeting.getAttendees().stream()
					.map(user -> userRepository.findById(user.getId())
							.orElseThrow(() -> new IllegalArgumentException("Attendee not found: " + user.getId())))
					.collect(Collectors.toList());

			meeting.setAttendees(resolvedAttendees);
		}

		Meeting saved = meetingRepository.save(meeting);

		return buildResponse(HttpStatus.CREATED, "Meeting created successfully", saved);
	}

	// ── Get All Meetings for Project ───────────────────
	public ResponseEntity<ResponseStructure<List<MeetingDTO>>> getMeetingsByProject(long projectId) {

		List<MeetingDTO> dtos = meetingRepository.findByProjectProjectIdOrderByScheduledAtDesc(projectId).stream()
				.map(meetingMapper::toDTO).collect(Collectors.toList());

		ResponseStructure<List<MeetingDTO>> response = new ResponseStructure<>();
		response.setStatus(HttpStatus.OK.value());
		response.setMessage("Meetings fetched successfully");
		response.setData(dtos);
		return ResponseEntity.ok(response);
	}

	// ── Get Meeting By ID ──────────────────────────────
	public ResponseEntity<ResponseStructure<MeetingDTO>> getMeetingById(Long meetingId) {

		Meeting meeting = meetingRepository.findById(meetingId)
				.orElseThrow(() -> new IllegalArgumentException("Meeting not found: " + meetingId));

		return buildResponse(HttpStatus.OK, "Meeting fetched", meeting);
	}

	// ── Update MOM / Meeting Details ───────────────────
	@Transactional
	public ResponseEntity<ResponseStructure<MeetingDTO>> updateMeeting(Long meetingId, Meeting updated) {

		Meeting meeting = meetingRepository.findById(meetingId)
				.orElseThrow(() -> new IllegalArgumentException("Meeting not found: " + meetingId));

		// Update only non-null fields
		if (updated.getTitle() != null)
			meeting.setTitle(updated.getTitle());
		if (updated.getAgenda() != null)
			meeting.setAgenda(updated.getAgenda());
		if (updated.getMeetingType() != null)
			meeting.setMeetingType(updated.getMeetingType());
		if (updated.getStatus() != null)
			meeting.setStatus(updated.getStatus());
		if (updated.getScheduledAt() != null)
			meeting.setScheduledAt(updated.getScheduledAt());
		if (updated.getStartedAt() != null)
			meeting.setStartedAt(updated.getStartedAt());
		if (updated.getEndedAt() != null)
			meeting.setEndedAt(updated.getEndedAt());
		if (updated.getMeetingLink() != null)
			meeting.setMeetingLink(updated.getMeetingLink());
		if (updated.getMom() != null)
			meeting.setMom(updated.getMom());
		if (updated.getKeyHighlights() != null)
			meeting.setKeyHighlights(updated.getKeyHighlights());
		if (updated.getDecisions() != null)
			meeting.setDecisions(updated.getDecisions());
		if (updated.getActionItems() != null)
			meeting.setActionItems(updated.getActionItems());
		if (updated.getChangesRequested() != null)
			meeting.setChangesRequested(updated.getChangesRequested());
		if (updated.getClientInputs() != null)
			meeting.setClientInputs(updated.getClientInputs());
		if (updated.getRisks() != null)
			meeting.setRisks(updated.getRisks());
		if (updated.getNextSteps() != null)
			meeting.setNextSteps(updated.getNextSteps());
		if (updated.getFollowUpDate() != null)
			meeting.setFollowUpDate(updated.getFollowUpDate());

		Meeting saved = meetingRepository.save(meeting);
		return buildResponse(HttpStatus.OK, "Meeting updated successfully", saved);
	}

	// ── Add Attendee ───────────────────────────────────
	@Transactional
	public ResponseEntity<ResponseStructure<MeetingDTO>> addAttendee(Long meetingId, Long userId) {

		Meeting meeting = meetingRepository.findById(meetingId)
				.orElseThrow(() -> new IllegalArgumentException("Meeting not found"));

		User user = userRepository.findById(userId).orElseThrow(() -> new IllegalArgumentException("User not found"));

		boolean alreadyAdded = meeting.getAttendees().stream().anyMatch(u -> u.getId().equals(userId));

		if (!alreadyAdded) {
			meeting.getAttendees().add(user);
			meetingRepository.save(meeting);
		}

		return buildResponse(HttpStatus.OK, "Attendee added", meeting);
	}

	// ── Send Message (WhatsApp style) ──────────────────
	@Transactional
	public ResponseEntity<ResponseStructure<MeetingMessageDTO>> sendMessage(Long meetingId, Long senderId,
			MeetingMessage message, Long replyToId) {

		Meeting meeting = meetingRepository.findById(meetingId)
				.orElseThrow(() -> new IllegalArgumentException("Meeting not found"));

		if (!"COMPLETED".equals(meeting.getStatus().name())) {
			// Allow messaging only after meeting is completed or ongoing
			// Remove this guard if you want messaging during all statuses
		}

		User sender = userRepository.findById(senderId)
				.orElseThrow(() -> new IllegalArgumentException("User not found"));

		message.setMeeting(meeting);
		message.setSentBy(sender);

		// Handle reply
		if (replyToId != null) {
			MeetingMessage replyTo = messageRepository.findById(replyToId)
					.orElseThrow(() -> new IllegalArgumentException("Reply message not found"));
			message.setReplyTo(replyTo);
		}

		MeetingMessage saved = messageRepository.save(message);

		ResponseStructure<MeetingMessageDTO> response = new ResponseStructure<>();
		response.setStatus(HttpStatus.CREATED.value());
		response.setMessage("Message sent");
		response.setData(meetingMapper.toMessageDTO(saved));
		return ResponseEntity.status(HttpStatus.CREATED).body(response);
	}

	// ── Get Messages for Meeting ───────────────────────
	public ResponseEntity<ResponseStructure<List<MeetingMessageDTO>>> getMessages(Long meetingId) {

		List<MeetingMessageDTO> dtos = messageRepository.findByMeetingIdOrderBySentAtAsc(meetingId).stream()
				.map(meetingMapper::toMessageDTO).collect(Collectors.toList());

		ResponseStructure<List<MeetingMessageDTO>> response = new ResponseStructure<>();
		response.setStatus(HttpStatus.OK.value());
		response.setMessage("Messages fetched");
		response.setData(dtos);
		return ResponseEntity.ok(response);
	}

	// ── Delete Meeting ─────────────────────────────────
	@Transactional
	public ResponseEntity<ResponseStructure<String>> deleteMeeting(Long meetingId) {

		Meeting meeting = meetingRepository.findById(meetingId)
				.orElseThrow(() -> new IllegalArgumentException("Meeting not found"));

		meetingRepository.delete(meeting);

		ResponseStructure<String> response = new ResponseStructure<>();
		response.setStatus(HttpStatus.OK.value());
		response.setMessage("Meeting deleted successfully");
		response.setData("Deleted meeting id: " + meetingId);
		return ResponseEntity.ok(response);
	}

	// ── Helper ────────────────────────────────────────
	private ResponseEntity<ResponseStructure<MeetingDTO>> buildResponse(HttpStatus status, String message,
			Meeting meeting) {

		ResponseStructure<MeetingDTO> response = new ResponseStructure<>();
		response.setStatus(status.value());
		response.setMessage(message);
		response.setData(meetingMapper.toDTO(meeting));
		return ResponseEntity.status(status).body(response);
	}
}
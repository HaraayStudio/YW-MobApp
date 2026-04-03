package com.haraay.ywarchitects.mapper;

import com.haraay.ywarchitects.dto.MeetingDTO;
import com.haraay.ywarchitects.dto.MeetingMessageDTO;
import com.haraay.ywarchitects.dto.UserLiteDTO;
import com.haraay.ywarchitects.model.Meeting;
import com.haraay.ywarchitects.model.MeetingMessage;
import com.haraay.ywarchitects.model.User;
import org.springframework.stereotype.Component;

import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

@Component
public class MeetingMapper {

    // ── Meeting → MeetingDTO ───────────────────────────
    public MeetingDTO toDTO(Meeting meeting) {
        if (meeting == null) return null;

        MeetingDTO dto = new MeetingDTO();
        dto.setId(meeting.getId());
        dto.setTitle(meeting.getTitle());
        dto.setAgenda(meeting.getAgenda());
        dto.setMeetingType(meeting.getMeetingType());
        dto.setStatus(meeting.getStatus());
        dto.setScheduledAt(meeting.getScheduledAt());
        dto.setStartedAt(meeting.getStartedAt());
        dto.setEndedAt(meeting.getEndedAt());
        dto.setMeetingLink(meeting.getMeetingLink());

        // MOM
        dto.setMom(meeting.getMom());
        dto.setKeyHighlights(meeting.getKeyHighlights());
        dto.setDecisions(meeting.getDecisions());
        dto.setActionItems(meeting.getActionItems());
        dto.setChangesRequested(meeting.getChangesRequested());
        dto.setClientInputs(meeting.getClientInputs());
        dto.setRisks(meeting.getRisks());
        dto.setNextSteps(meeting.getNextSteps());
        dto.setFollowUpDate(meeting.getFollowUpDate());
        dto.setCreatedAt(meeting.getCreatedAt());
        dto.setUpdatedAt(meeting.getUpdatedAt());

        // Project
        if (meeting.getProject() != null) {
            dto.setProjectId(meeting.getProject().getProjectId());
            dto.setProjectName(meeting.getProject().getProjectName());
        }

        // CreatedBy
        dto.setCreatedBy(toUserLiteDTO(meeting.getCreatedBy()));

        // Attendees
        List<UserLiteDTO> attendees = meeting.getAttendees() == null
                ? Collections.emptyList()
                : meeting.getAttendees().stream()
                        .map(this::toUserLiteDTO)
                        .collect(Collectors.toList());
        dto.setAttendees(attendees);

        // Messages
        List<MeetingMessageDTO> messages = meeting.getMessages() == null
                ? Collections.emptyList()
                : meeting.getMessages().stream()
                        .map(this::toMessageDTO)
                        .collect(Collectors.toList());
        dto.setMessages(messages);

        return dto;
    }

    // ── MeetingMessage → MeetingMessageDTO ────────────
    public MeetingMessageDTO toMessageDTO(MeetingMessage msg) {
        if (msg == null) return null;

        MeetingMessageDTO dto = new MeetingMessageDTO();
        dto.setId(msg.getId());
        dto.setMessage(msg.getMessage());
        dto.setSentAt(msg.getSentAt());
        dto.setMessageType(msg.getMessageType());
        dto.setAttachmentUrl(msg.getAttachmentUrl());
        dto.setSentBy(toUserLiteDTO(msg.getSentBy()));

        if (msg.getMeeting() != null) {
            dto.setMeetingId(msg.getMeeting().getId());
        }

        // Reply chain preview
        if (msg.getReplyTo() != null) {
            dto.setReplyToId(msg.getReplyTo().getId());
            dto.setReplyToMessage(msg.getReplyTo().getMessage());
            if (msg.getReplyTo().getSentBy() != null) {
                dto.setReplyToSenderName(
                    msg.getReplyTo().getSentBy().getFirstName() + " " +
                    msg.getReplyTo().getSentBy().getLastName()
                );
            }
        }

        return dto;
    }

    // ── User → UserLiteDTO ─────────────────────────────
    private UserLiteDTO toUserLiteDTO(User user) {
        if (user == null) return null;
        UserLiteDTO dto = new UserLiteDTO();
        dto.setId(user.getId());
        dto.setFullName(user.getFirstName() + " " + user.getLastName());      
        dto.setProfileImage(user.getProfileImage());
        return dto;
    }
}
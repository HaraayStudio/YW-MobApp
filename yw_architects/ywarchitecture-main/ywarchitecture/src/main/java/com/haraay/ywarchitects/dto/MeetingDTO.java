package com.haraay.ywarchitects.dto;

import com.haraay.ywarchitects.model.MeetingStatus;
import com.haraay.ywarchitects.model.MeetingType;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class MeetingDTO {

	private Long id;
	private String title;
	private String agenda;
	private MeetingType meetingType;
	private MeetingStatus status;
	private LocalDateTime scheduledAt;
	private LocalDateTime startedAt;
	private LocalDateTime endedAt;
	private String meetingLink;

	// MOM fields
	private String mom;
	private String keyHighlights;
	private String decisions;
	private String actionItems;
	private String changesRequested;
	private String clientInputs;
	private String risks;
	private String nextSteps;
	private LocalDateTime followUpDate;

	private LocalDateTime createdAt;
	private LocalDateTime updatedAt;

	// Relations
	private Long projectId;
	private String projectName;
	private UserLiteDTO createdBy;
	private List<UserLiteDTO> attendees = new ArrayList<>();
	private List<MeetingMessageDTO> messages = new ArrayList<>();

	public MeetingDTO() {
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public String getTitle() {
		return title;
	}

	public void setTitle(String title) {
		this.title = title;
	}

	public String getAgenda() {
		return agenda;
	}

	public void setAgenda(String agenda) {
		this.agenda = agenda;
	}

	public MeetingType getMeetingType() {
		return meetingType;
	}

	public void setMeetingType(MeetingType meetingType) {
		this.meetingType = meetingType;
	}

	public MeetingStatus getStatus() {
		return status;
	}

	public void setStatus(MeetingStatus status) {
		this.status = status;
	}

	public LocalDateTime getScheduledAt() {
		return scheduledAt;
	}

	public void setScheduledAt(LocalDateTime scheduledAt) {
		this.scheduledAt = scheduledAt;
	}

	public LocalDateTime getStartedAt() {
		return startedAt;
	}

	public void setStartedAt(LocalDateTime startedAt) {
		this.startedAt = startedAt;
	}

	public LocalDateTime getEndedAt() {
		return endedAt;
	}

	public void setEndedAt(LocalDateTime endedAt) {
		this.endedAt = endedAt;
	}

	public String getMeetingLink() {
		return meetingLink;
	}

	public void setMeetingLink(String meetingLink) {
		this.meetingLink = meetingLink;
	}

	public String getMom() {
		return mom;
	}

	public void setMom(String mom) {
		this.mom = mom;
	}

	public String getKeyHighlights() {
		return keyHighlights;
	}

	public void setKeyHighlights(String keyHighlights) {
		this.keyHighlights = keyHighlights;
	}

	public String getDecisions() {
		return decisions;
	}

	public void setDecisions(String decisions) {
		this.decisions = decisions;
	}

	public String getActionItems() {
		return actionItems;
	}

	public void setActionItems(String actionItems) {
		this.actionItems = actionItems;
	}

	public String getChangesRequested() {
		return changesRequested;
	}

	public void setChangesRequested(String changesRequested) {
		this.changesRequested = changesRequested;
	}

	public String getClientInputs() {
		return clientInputs;
	}

	public void setClientInputs(String clientInputs) {
		this.clientInputs = clientInputs;
	}

	public String getRisks() {
		return risks;
	}

	public void setRisks(String risks) {
		this.risks = risks;
	}

	public String getNextSteps() {
		return nextSteps;
	}

	public void setNextSteps(String nextSteps) {
		this.nextSteps = nextSteps;
	}

	public LocalDateTime getFollowUpDate() {
		return followUpDate;
	}

	public void setFollowUpDate(LocalDateTime followUpDate) {
		this.followUpDate = followUpDate;
	}

	public LocalDateTime getCreatedAt() {
		return createdAt;
	}

	public void setCreatedAt(LocalDateTime createdAt) {
		this.createdAt = createdAt;
	}

	public LocalDateTime getUpdatedAt() {
		return updatedAt;
	}

	public void setUpdatedAt(LocalDateTime updatedAt) {
		this.updatedAt = updatedAt;
	}

	public Long getProjectId() {
		return projectId;
	}

	public void setProjectId(Long projectId) {
		this.projectId = projectId;
	}

	public String getProjectName() {
		return projectName;
	}

	public void setProjectName(String projectName) {
		this.projectName = projectName;
	}

	public UserLiteDTO getCreatedBy() {
		return createdBy;
	}

	public void setCreatedBy(UserLiteDTO createdBy) {
		this.createdBy = createdBy;
	}

	public List<UserLiteDTO> getAttendees() {
		return attendees;
	}

	public void setAttendees(List<UserLiteDTO> attendees) {
		this.attendees = attendees;
	}

	public List<MeetingMessageDTO> getMessages() {
		return messages;
	}

	public void setMessages(List<MeetingMessageDTO> messages) {
		this.messages = messages;
	}
}
package com.haraay.ywarchitects.model;

import jakarta.persistence.*;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "meetings")
public class Meeting {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	// ── Basic Info ─────────────────────────────────────
	private String title; // Subject of meeting
	private String agenda; // What was planned to discuss

	@Enumerated(EnumType.STRING)
	private MeetingType meetingType; // CALL, ZOOM, GOOGLE_MEET, FACE_TO_FACE, TEAMS

	@Enumerated(EnumType.STRING)
	private MeetingStatus status; // SCHEDULED, ONGOING, COMPLETED, CANCELLED

	private LocalDateTime scheduledAt; // When it was planned
	private LocalDateTime startedAt; // Actual start
	private LocalDateTime endedAt; // Actual end
	private String meetingLink; // Zoom/Meet link if online

	// ── MOM (Minutes of Meeting) ───────────────────────
	@Column(columnDefinition = "TEXT")
	private String mom; // Full minutes of meeting

	@Column(columnDefinition = "TEXT")
	private String keyHighlights; // Summary of key points

	@Column(columnDefinition = "TEXT")
	private String decisions; // Decisions taken

	@Column(columnDefinition = "TEXT")
	private String actionItems; // Who does what after meeting

	@Column(columnDefinition = "TEXT")
	private String changesRequested; // Design/plan changes requested

	@Column(columnDefinition = "TEXT")
	private String clientInputs; // What client said / asked

	@Column(columnDefinition = "TEXT")
	private String risks; // Any risks discussed

	private String nextSteps; // What happens next
	private LocalDateTime followUpDate; // Next meeting / follow-up date

	// ── Project Link ───────────────────────────────────
	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "project_id", nullable = false)
	@JsonIgnoreProperties({ "meetings", "stages", "structures", "siteVisits", "reraProjects", "postSales",
			"workingemployee" })
	private Project project;

	// ── Created by (who scheduled it) ─────────────────
	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "created_by")
	@JsonIgnoreProperties({ "projects" })
	private User createdBy;

	// ── Attendees ──────────────────────────────────────
	@ManyToMany
	@JoinTable(name = "meeting_attendees", joinColumns = @JoinColumn(name = "meeting_id"), inverseJoinColumns = @JoinColumn(name = "user_id"))
	@JsonIgnoreProperties({ "projects" })
	private List<User> attendees = new ArrayList<>();

	// ── WhatsApp-style messages after meeting ──────────
	@OneToMany(mappedBy = "meeting", cascade = CascadeType.ALL, orphanRemoval = true)
	@JsonIgnoreProperties("meeting")
	private List<MeetingMessage> messages = new ArrayList<>();

	private LocalDateTime createdAt;
	private LocalDateTime updatedAt;

	@PrePersist
	public void prePersist() {
		createdAt = LocalDateTime.now();
		updatedAt = LocalDateTime.now();
		if (status == null)
			status = MeetingStatus.SCHEDULED;
	}

	@PreUpdate
	public void preUpdate() {
		updatedAt = LocalDateTime.now();
	}

	public Meeting() {
	}

	// ── Getters & Setters ──────────────────────────────

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

	public Project getProject() {
		return project;
	}

	public void setProject(Project project) {
		this.project = project;
	}

	public User getCreatedBy() {
		return createdBy;
	}

	public void setCreatedBy(User createdBy) {
		this.createdBy = createdBy;
	}

	public List<User> getAttendees() {
		return attendees;
	}

	public void setAttendees(List<User> attendees) {
		this.attendees = attendees;
	}

	public List<MeetingMessage> getMessages() {
		return messages;
	}

	public void setMessages(List<MeetingMessage> messages) {
		this.messages = messages;
	}

	public LocalDateTime getCreatedAt() {
		return createdAt;
	}

	public LocalDateTime getUpdatedAt() {
		return updatedAt;
	}
}
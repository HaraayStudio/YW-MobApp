package com.haraay.ywarchitects.model;

import jakarta.persistence.*;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import java.time.LocalDateTime;

@Entity
@Table(name = "meeting_messages")
public class MeetingMessage {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	@Column(columnDefinition = "TEXT", nullable = false)
	private String message;

	private LocalDateTime sentAt;

	// Who sent this message
	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "sender_id", nullable = false)
	@JsonIgnoreProperties({ "projects" })
	private User sentBy;

	// Which meeting this message belongs to
	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "meeting_id", nullable = false)
	@JsonIgnoreProperties({ "messages", "project", "attendees", "createdBy" })
	private Meeting meeting;

	// Optional — reply to another message
	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "reply_to_id", nullable = true)
	@JsonIgnoreProperties({ "meeting", "sentBy", "replyTo" })
	private MeetingMessage replyTo;

	@Enumerated(EnumType.STRING)
	private MessageType messageType; // TEXT, FILE, IMAGE, LINK

	private String attachmentUrl; // if file/image shared

	@PrePersist
	public void prePersist() {
		sentAt = LocalDateTime.now();
		if (messageType == null)
			messageType = MessageType.TEXT;
	}

	public MeetingMessage() {
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public String getMessage() {
		return message;
	}

	public void setMessage(String message) {
		this.message = message;
	}

	public LocalDateTime getSentAt() {
		return sentAt;
	}

	public void setSentAt(LocalDateTime sentAt) {
		this.sentAt = sentAt;
	}

	public User getSentBy() {
		return sentBy;
	}

	public void setSentBy(User sentBy) {
		this.sentBy = sentBy;
	}

	public Meeting getMeeting() {
		return meeting;
	}

	public void setMeeting(Meeting meeting) {
		this.meeting = meeting;
	}

	public MeetingMessage getReplyTo() {
		return replyTo;
	}

	public void setReplyTo(MeetingMessage replyTo) {
		this.replyTo = replyTo;
	}

	public MessageType getMessageType() {
		return messageType;
	}

	public void setMessageType(MessageType messageType) {
		this.messageType = messageType;
	}

	public String getAttachmentUrl() {
		return attachmentUrl;
	}

	public void setAttachmentUrl(String attachmentUrl) {
		this.attachmentUrl = attachmentUrl;
	}
}
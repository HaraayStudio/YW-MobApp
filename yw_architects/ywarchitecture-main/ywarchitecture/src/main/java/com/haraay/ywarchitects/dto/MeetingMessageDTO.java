package com.haraay.ywarchitects.dto;

import com.haraay.ywarchitects.model.MessageType;
import java.time.LocalDateTime;

public class MeetingMessageDTO {

	private Long id;
	private String message;
	private LocalDateTime sentAt;
	private MessageType messageType;
	private String attachmentUrl;

	// Who sent it — WhatsApp style
	private UserLiteDTO sentBy;

	// Reply chain
	private Long replyToId;
	private String replyToMessage; // preview of replied message
	private String replyToSenderName; // name of original sender

	private Long meetingId;

	public MeetingMessageDTO() {
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

	public UserLiteDTO getSentBy() {
		return sentBy;
	}

	public void setSentBy(UserLiteDTO sentBy) {
		this.sentBy = sentBy;
	}

	public Long getReplyToId() {
		return replyToId;
	}

	public void setReplyToId(Long replyToId) {
		this.replyToId = replyToId;
	}

	public String getReplyToMessage() {
		return replyToMessage;
	}

	public void setReplyToMessage(String replyToMessage) {
		this.replyToMessage = replyToMessage;
	}

	public String getReplyToSenderName() {
		return replyToSenderName;
	}

	public void setReplyToSenderName(String replyToSenderName) {
		this.replyToSenderName = replyToSenderName;
	}

	public Long getMeetingId() {
		return meetingId;
	}

	public void setMeetingId(Long meetingId) {
		this.meetingId = meetingId;
	}
}
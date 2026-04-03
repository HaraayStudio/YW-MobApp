package com.haraay.ywarchitects.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.haraay.ywarchitects.model.MeetingMessage;

public interface MeetingMessageRepository extends JpaRepository<MeetingMessage, Long> {

	List<MeetingMessage> findByMeetingIdOrderBySentAtAsc(Long meetingId);
}

package com.haraay.ywarchitects.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.haraay.ywarchitects.model.Payment;

public interface PaymentRepositoty extends JpaRepository<Payment, Long> {

}

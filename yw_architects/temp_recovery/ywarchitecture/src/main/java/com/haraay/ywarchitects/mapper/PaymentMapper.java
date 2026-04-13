package com.haraay.ywarchitects.mapper;

import org.springframework.stereotype.Component;

import com.haraay.ywarchitects.dto.PaymentDTO;
import com.haraay.ywarchitects.model.Payment;

@Component
public class PaymentMapper {

    public PaymentDTO toDTO(Payment entity) {
        if (entity == null) return null;

        PaymentDTO dto = new PaymentDTO();
        dto.setId(entity.getId());
        dto.setPaymentDate(entity.getPaymentDate());
        dto.setAmountPaid(entity.getAmountPaid());
        dto.setPaymentMode(entity.getPaymentMode());
        dto.setTransactionId(entity.getTransactionId());
        dto.setRemarks(entity.getRemarks());

        

        return dto;
    }

    public Payment toEntity(PaymentDTO dto) {
        if (dto == null) return null;

        Payment entity = new Payment();
        entity.setId(dto.getId());
        entity.setPaymentDate(dto.getPaymentDate());
        entity.setAmountPaid(dto.getAmountPaid());
        entity.setPaymentMode(dto.getPaymentMode());
        entity.setTransactionId(dto.getTransactionId());
        entity.setRemarks(dto.getRemarks());

        return entity;
    }
}

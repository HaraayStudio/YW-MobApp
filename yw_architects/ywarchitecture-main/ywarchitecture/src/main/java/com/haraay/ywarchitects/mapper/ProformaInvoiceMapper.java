package com.haraay.ywarchitects.mapper;

import org.springframework.stereotype.Component;

import com.haraay.ywarchitects.dto.ProformaInvoiceDTO;
import com.haraay.ywarchitects.model.ProformaInvoice;

@Component
public class ProformaInvoiceMapper {

    public ProformaInvoiceDTO toDTO(ProformaInvoice entity) {
        if (entity == null) return null;

        ProformaInvoiceDTO dto = new ProformaInvoiceDTO();

        // BaseInvoice fields
        dto.setId(entity.getId());
        dto.setInvoiceNumber(entity.getInvoiceNumber());
        dto.setIssueDate(entity.getIssueDate());
        dto.setValidTill(entity.getValidTill());
        dto.setClientName(entity.getClientName());
        dto.setClientEmail(entity.getClientEmail());
        dto.setClientPhone(entity.getClientPhone());
        dto.setClientAddress(entity.getClientAddress());
        dto.setClientGstin(entity.getClientGstin());
        dto.setNetAmount(entity.getNetAmount());
        dto.setCgstAmount(entity.getCgstAmount());
        dto.setSgstAmount(entity.getSgstAmount());
        dto.setGrossAmount(entity.getGrossAmount());
        dto.setAmountInWords(entity.getAmountInWords());
        dto.setNotified(entity.isNotified());

        // specific
        dto.setPaid(entity.isPaid());

        if (entity.getPostSales() != null) {
            dto.setPostSalesId(entity.getPostSales().getId());
        }

        return dto;
    }

    public ProformaInvoice toEntity(ProformaInvoiceDTO dto) {
        if (dto == null) return null;

        ProformaInvoice entity = new ProformaInvoice();

        entity.setId(dto.getId());
        entity.setInvoiceNumber(dto.getInvoiceNumber());
        entity.setIssueDate(dto.getIssueDate());
        entity.setValidTill(dto.getValidTill());
        entity.setClientName(dto.getClientName());
        entity.setClientEmail(dto.getClientEmail());
        entity.setClientPhone(dto.getClientPhone());
        entity.setClientAddress(dto.getClientAddress());
        entity.setClientGstin(dto.getClientGstin());
        entity.setNetAmount(dto.getNetAmount());
        entity.setCgstAmount(dto.getCgstAmount());
        entity.setSgstAmount(dto.getSgstAmount());
        entity.setGrossAmount(dto.getGrossAmount());
        entity.setAmountInWords(dto.getAmountInWords());
        entity.setNotified(dto.isNotified());

        entity.setPaid(dto.isPaid());

        return entity;
    }
}

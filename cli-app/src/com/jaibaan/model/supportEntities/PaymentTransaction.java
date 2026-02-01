package com.jaibaan.model.supportEntities;

import java.time.LocalDateTime;

public class PaymentTransaction {

    // Attributes
    private String transactionId;
    private String slipImageUrl;
    private LocalDateTime uploadedAt;
    private Boolean isVerified;

    // Constructor
    public PaymentTransaction(String transactionId, String slipImageUrl) {
        this.transactionId = transactionId;
        this.slipImageUrl = slipImageUrl;
        this.uploadedAt = LocalDateTime.now();
        this.isVerified = false; // เริ่มต้นยังไม่ตรวจสอบ
    }


    public Boolean verify(Boolean isValid) {
        this.isVerified = isValid;
        if (isValid) {
            System.out.println("Transaction " + transactionId + " verified: VALID");
        } else {
            System.out.println("Transaction " + transactionId + " verified: INVALID");
        }
        return this.isVerified;
    }

    // Getters
    public String getTransactionId() { return transactionId; }
    public String getSlipImageUrl() { return slipImageUrl; }
    public LocalDateTime getUploadedAt() { return uploadedAt; }
    public Boolean getVerified() { return isVerified; }
}
package com.jaibaan.model.coreEntities;

import java.time.LocalDate;

public class Bill {

    // Attributes
    private String billId;
    private Double amount;
    private LocalDate dueDate; // วันครบกำหนดชำระ
    private String type; // "WATER", "COMMON_FEE"
    private String status; // "UNPAID", "PAID", "PENDING"

    // --- 2. Constructor ---
    public Bill(String billId, Double amount, LocalDate dueDate, String type) {
        this.billId = billId;
        this.amount = amount;
        this.dueDate = dueDate;
        this.type = type;
        this.status = "UNPAID"; // เริ่มต้นเป็นยังไม่จ่าย
    }

    public String generateQR() {
        // Mock QR Code generation logic
        String qrData = "QR-" + this.billId + "-" + this.amount;
        System.out.println("QR Code Generated: " + qrData);
        return qrData; // Return QR string
    }

    public void attachSlip(String image) {
        // จำลองการแนบสลิป (อาจจะไปสร้าง PaymentTransaction ต่อในอนาคต)
        this.status = "PENDING"; // เปลี่ยนสถานะเป็นรอตรวจสอบ
        System.out.println("Slip attached: " + image + ". Status updated to PENDING.");
    }

    // --- 4. Getters ---
    public String getBillId() { return billId; }
    public Double getAmount() { return amount; }
    public LocalDate getDueDate() { return dueDate; }
    public String getType() { return type; }
    public String getStatus() { return status; }
}
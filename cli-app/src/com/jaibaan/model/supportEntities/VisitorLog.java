package com.jaibaan.model.supportEntities;

import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit; // ใช้คำนวณระยะเวลา

public class VisitorLog {

    // Attributes
    private String logId;
    private LocalDateTime entryTime;
    private LocalDateTime exitTime;
    private Double fee;

    // Constructor
    public VisitorLog(String logId) {
        this.logId = logId;
        this.entryTime = LocalDateTime.now(); // เริ่มจับเวลาทันทีที่สร้าง
        this.exitTime = null; // ยังไม่ออก
        this.fee = 0.0;
    }

    public Double calculateFee(int hours) {
        // สมมติค่าปรับ ชั่วโมงละ 50 บาท (หรือแก้ราคาตามใจชอบ)
        double ratePerHour = 20.0;
        
        this.fee = hours * ratePerHour;
        
        // บันทึกเวลาออกเป็นปัจจุบัน
        this.exitTime = LocalDateTime.now();
        
        System.out.println(">> Fee Calculated: " + hours + " hrs x " + ratePerHour + " = " + this.fee + " THB");
        return this.fee;
    }

    // Setter สำหรับตอนรถออก
    public void setExitTime(LocalDateTime exitTime) {
        this.exitTime = exitTime;
    }

    // Getters
    public String getLogId() { return logId; }
    public LocalDateTime getEntryTime() { return entryTime; }
    public LocalDateTime getExitTime() { return exitTime; }
    public Double getFee() { return fee; }
}
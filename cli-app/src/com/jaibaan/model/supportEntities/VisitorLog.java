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

    public Double calculateFee() {
        if (exitTime == null) {
            // ถ้ายังไม่ออก ให้สมมติว่าออกตอนนี้เพื่อคำนวณ
            this.exitTime = LocalDateTime.now();
        }

        // คำนวณชั่วโมงจอด (ตัวอย่างคิดชั่วโมงละ 20 บาท)
        long hoursParked = ChronoUnit.HOURS.between(entryTime, exitTime);
        if (hoursParked < 0) {
            hoursParked = 0;
        }
        
        this.fee = hoursParked * 20.0;
        
        System.out.println("Parking Fee Calculated: " + fee + " THB (" + hoursParked + " hrs)");
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
package com.jaibaan.model.supportEntities;

import java.time.LocalDateTime;
import java.util.UUID; // ใช้สุ่ม ID

public class Reservation {

    // Attributes
    private String reservationId;
    private LocalDateTime startTime;
    private LocalDateTime endTime;
    private String status; // "CONFIRMED", "CANCELLED"
    private String ePassCode; // รหัสสำหรับสแกนเข้า
    private String residentId;  // เพิ่ม: ใครจอง
    private String facilityId;  // เพิ่ม: จองที่ไหน
    // Constructor
    public Reservation(String residentId, String facilityId, LocalDateTime startTime) {
        this.reservationId = "RES-" + UUID.randomUUID().toString().substring(0, 8);
        this.residentId = residentId;
        this.facilityId = facilityId;
        this.startTime = startTime;
        this.endTime = startTime.plusHours(1); // จองครั้งละ 1 ชม. อัตโนมัติ
        this.status = "CONFIRMED";
        this.ePassCode = "PASS-" + UUID.randomUUID().toString().substring(0, 6);
    }

    public Boolean cancelReservation() {
        this.status = "CANCELLED";
        this.ePassCode = null; 
        return true;
    }


    // Getters
    public String getReservationId() { return reservationId; }
    public LocalDateTime getStartTime() { return startTime; }
    public LocalDateTime getEndTime() { return endTime; }
    public String getStatus() { return status; }
    public String getEPassCode() { return ePassCode; }
    public String getResidentId() { return residentId; } // เพิ่ม Getter
    public String getFacilityId() { return facilityId; }   // เพิ่ม Getter
}
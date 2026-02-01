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

    // Constructor
    public Reservation(String reservationId, LocalDateTime startTime, LocalDateTime endTime) {
        this.reservationId = reservationId;
        this.startTime = startTime;
        this.endTime = endTime;
        this.status = "CONFIRMED";
        this.ePassCode = "PASS-" + UUID.randomUUID().toString().substring(0, 6);
    }

    public static Reservation makeReservation(String facilityId, LocalDateTime time) {
        // จำลองการจอง (ปกติ 1 slot = 1 ชั่วโมง)
        String newId = "RES-" + UUID.randomUUID().toString().substring(0, 8);
        LocalDateTime endTime = time.plusHours(1);
        
        System.out.println("Booking Facility: " + facilityId + " at " + time);
        return new Reservation(newId, time, endTime);
    }

    public Boolean cancelReservation() {
        this.status = "CANCELLED";
        this.ePassCode = null; 
        System.out.println("Reservation " + reservationId + " has been cancelled.");
        return true;
    }

    // Getters
    public String getReservationId() { return reservationId; }
    public LocalDateTime getStartTime() { return startTime; }
    public LocalDateTime getEndTime() { return endTime; }
    public String getStatus() { return status; }
    public String getEPassCode() { return ePassCode; }
}
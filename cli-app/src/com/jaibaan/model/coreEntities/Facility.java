package com.jaibaan.model.coreEntities;

import java.time.LocalDate;
import java.time.LocalTime;

public class Facility {

    // Attributes
    private String facilityId;
    private String name;
    private Integer capacity;
    private LocalTime openTime;
    private LocalTime closeTime;

    // Constructor
    public Facility(String facilityId, String name, Integer capacity, LocalTime openTime, LocalTime closeTime) {
        this.facilityId = facilityId;
        this.name = name;
        this.capacity = capacity;
        this.openTime = openTime;
        this.closeTime = closeTime;
    }

    public Boolean checkAvailability(LocalDate date, LocalTime time) {
        // เช็คเวลาเปิด-ปิด
        if (time.isBefore(openTime) || time.isAfter(closeTime)) {
            System.out.println("Facility " + name + " is closed at " + time);
            return false;
        }
        
        // เช็คว่าวันที่นี้เต็มหรือยัง
        System.out.println("Facility " + name + " is available on " + date + " at " + time);
        return true;
    }

    // Getters
    public String getFacilityId() { return facilityId; }
    public String getName() { return name; }
    public Integer getCapacity() { return capacity; }
    public LocalTime getOpenTime() { return openTime; }
    public LocalTime getCloseTime() { return closeTime; }
}
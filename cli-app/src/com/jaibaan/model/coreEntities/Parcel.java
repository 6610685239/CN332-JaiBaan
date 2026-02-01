package com.jaibaan.model.coreEntities;

import java.time.LocalDateTime;

public class Parcel {

    // Attributes
    private String parcelId;
    private String trackingNumber;
    private String carrier; // บริษัทขนส่ง เช่น Kerry, Flash
    private String recipientUnitNumber;
    private LocalDateTime arrivalDate;
    private String status; // "ARRIVED", "PICKED_UP"

    // Constructor
    public Parcel(String parcelId, String trackingNumber, String carrier,String recipientUnitNumber) {
        this.parcelId = parcelId;
        this.trackingNumber = trackingNumber;
        this.carrier = carrier;
        this.recipientUnitNumber = recipientUnitNumber; 
        this.arrivalDate = LocalDateTime.now(); // บันทึกเวลาปัจจุบันที่ของมาถึง
        this.status = "ARRIVED"; // สถานะเริ่มต้น
    }

    public void confirmReceipt() {
        this.status = "PICKED_UP";
        System.out.println("Parcel " + this.trackingNumber + " has been picked up.");
    }

    public void notifyResident() {
        // จำลองการส่ง Notification
        System.out.println("Notification sent to resident: Your parcel (" + this.carrier + ") has arrived.");
    }

    // Getters
    public String getParcelId() { return parcelId; }
    public String getTrackingNumber() { return trackingNumber; }
    public String getCarrier() { return carrier; }
    public String getRecipientUnitNumber() { return recipientUnitNumber; }
    public LocalDateTime getArrivalDate() { return arrivalDate; }
    public String getStatus() { return status; }
}
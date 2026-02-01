package com.jaibaan.model.coreEntities;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID; // ใช้สำหรับสุ่ม ID อัตโนมัติ

public class RepairTicket {

    // Attributes
    private String ticketId;
    private String description;
    private String location;
    private List<String> photoUrls;
    private LocalDateTime createdDate;
    private String status;

    // Constructor
    public RepairTicket(String ticketId, String description, String location, LocalDateTime createdDate) {
        this.ticketId = ticketId;
        this.description = description;
        this.location = location;
        this.createdDate = createdDate;
        this.photoUrls = new ArrayList<>();
        this.status = "PENDING";
    }

    public static RepairTicket createTicket(String desc, String location, String photoUrl) {
        // สร้าง ID อัตโนมัติ (Mock ID)
        String newId = "TKT-" + UUID.randomUUID().toString().substring(0, 8);
        
        // สร้าง Object
        RepairTicket ticket = new RepairTicket(newId, desc, location, LocalDateTime.now());
        
        // เพิ่มรูปภาพ
        if (photoUrl != null && !photoUrl.isEmpty()) {
            ticket.photoUrls.add(photoUrl);
        }
        
        System.out.println("Ticket Created: " + newId);
        return ticket;
    }

    public void assignTechnician(String techId) {
        // Update logic
        this.status = "ASSIGNED";
        System.out.println("Ticket " + this.ticketId + " has been assigned to Technician ID: " + techId);
    }

    public void updateStatus(String newStatus) {
        this.status = newStatus;
        System.out.println("Ticket " + this.ticketId + " status updated to: " + newStatus);
    }

    // Getters
    public String getTicketId() { return ticketId; }
    public String getDescription() { return description; }
    public String getLocation() { return location; }
    public String getStatus() { return status; }
    public LocalDateTime getCreatedDate() { return createdDate; }
    public List<String> getPhotoUrls() { return photoUrls; }
}
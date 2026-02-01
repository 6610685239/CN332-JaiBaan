package com.jaibaan.model.coreEntities;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class RepairTicket {

    // Attributes
    private String ticketId;
    private String description;
    private String location;
    private String reporterId;
    private List<String> photoUrls;
    private LocalDateTime createdDate;
    private String status;

    // Constructor
    public RepairTicket(String ticketId, String description, String location, LocalDateTime createdDate, String reporterId) {
        this.ticketId = ticketId;
        this.description = description;
        this.location = location;
        this.reporterId = reporterId;
        this.createdDate = createdDate;
        this.photoUrls = new ArrayList<>();
        this.status = "PENDING";
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
    public String getReporterId() { return reporterId; }
    public LocalDateTime getCreatedDate() { return createdDate; }
    public List<String> getPhotoUrls() { return photoUrls; }
}
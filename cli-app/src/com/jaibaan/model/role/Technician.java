package com.jaibaan.model.role;

import com.jaibaan.model.coreEntities.RepairTicket;
import java.util.ArrayList;
import java.util.List;

public class Technician extends User {
    // Attributes
    private String specialty;
    private String currentStatus;

    // Constructor
    public Technician(String userId, String username, String passwordHash,String firstName, String lastName, String phoneNumber,String specialty) {
        super(userId, username, passwordHash, firstName, lastName, phoneNumber);

        this.specialty = specialty;
        this.currentStatus = "AVAILABLE";
    }

    public void updateJobStatus(String ticketId, String status) {
        // หา ticket แล้วอัปเดต
        System.out.println("Technician updated Ticket " + ticketId + " to status: " + status);
        this.currentStatus = "AVAILABLE";
    }

    public List<RepairTicket> viewAssignedJobs() {
        System.out.println("Viewing assigned jobs for technician: " + this.firstName);
        // Return list ว่างไปก่อน
        return new ArrayList<RepairTicket>();
    }

    // Getter
    public String getSpecialty() {
        return specialty;
    }
    public String getCurrentStatus() {
        return currentStatus;
    }
}
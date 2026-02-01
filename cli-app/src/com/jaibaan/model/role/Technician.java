package com.jaibaan.model.role;

import com.jaibaan.data.DataStore;
import com.jaibaan.model.coreEntities.RepairTicket;
import java.util.ArrayList;
import java.util.List;
import java.util.Scanner;

public class Technician extends User {
    // Attributes
    private String specialty;
    private String currentStatus;

    // Constructor
    public Technician(String userId, String username, String passwordHash, String firstName, String lastName,
            String phoneNumber, String specialty) {
        super(userId, username, passwordHash, firstName, lastName, phoneNumber);

        this.specialty = specialty;
        this.currentStatus = "AVAILABLE";
    }

    public void updateJobStatus() {
        Scanner scanner = new Scanner(System.in);
        List<RepairTicket> allTickets = DataStore.getInstance().getRepairTickets();
        
        List<RepairTicket> myJobs = new ArrayList<>();
        
        for (RepairTicket t : allTickets) {
            String assignedId = t.getAssignedTechnicianId();
            if (assignedId != null && assignedId.equals(this.getUserId())) {
                myJobs.add(t);
            }
        }

        System.out.println("\n--- Update Job Status ---");
        
        if (myJobs.isEmpty()) {
            System.out.println("You have no assigned jobs.");
            return;
        }

        int index = 1;
        for (RepairTicket t : myJobs) {
            System.out.printf("%d. [Room: %s] %s (Current: %s)\n", 
                index, t.getReporterId(), t.getDescription(), t.getStatus());
            index++;
        }
        System.out.println("0. Cancel");

        System.out.print("Select job number to update: ");
        int jobChoice = -1;
        try {
            String input = scanner.nextLine();
            jobChoice = Integer.parseInt(input);
        } catch (NumberFormatException e) {
            jobChoice = -1;
        }

        if (jobChoice == 0) return;

        if (jobChoice < 1 || jobChoice > myJobs.size()) {
            System.out.println("Invalid selection.");
            return;
        }

        RepairTicket selectedTicket = myJobs.get(jobChoice - 1);
        System.out.println("\nSelected: " + selectedTicket.getDescription());

        System.out.println("Select new status:");
        System.out.println("1. IN_PROGRESS");
        System.out.println("2. COMPLETED");
        System.out.println("3. PENDING");
        System.out.print("Choose status number: ");

        String newStatus = null;
        try {
            int statusChoice = Integer.parseInt(scanner.nextLine());
            switch (statusChoice) {
                case 1: newStatus = "IN_PROGRESS"; break;
                case 2: newStatus = "COMPLETED"; break;
                case 3: newStatus = "PENDING"; break;
                default: System.out.println("Invalid status choice."); return;
            }
        } catch (NumberFormatException e) {
            System.out.println("Invalid input.");
            return;
        }

        if (newStatus != null) {
            selectedTicket.updateStatus(newStatus);
        }
    }

    public void viewAssignedJobs() {
        List<RepairTicket> allRepairTickets = DataStore.getInstance().getRepairTickets();
        System.out.println("Viewing assigned jobs for technician: " + this.firstName);

        for (RepairTicket t : allRepairTickets) {
            String assignedId = t.getAssignedTechnicianId();
            if (assignedId != null && assignedId.equals(this.userId)) {
                System.out.printf("ID: %-20s | House No.: %-5s | Status: %-10s | Assign to: %s\n", 
                    t.getTicketId(), t.getReporterId(), t.getStatus(), t.getAssignedTechnicianId());
                System.out.println("Description: " + t.getDescription());
            }
        }
    }

    // Getter
    public String getSpecialty() {
        return specialty;
    }

    public String getCurrentStatus() {
        return currentStatus;
    }
}
package com.jaibaan.model.role;

import java.util.ArrayList;
import java.util.List;
import java.util.Scanner;

import com.jaibaan.data.DataStore;
import com.jaibaan.model.coreEntities.RepairTicket;

public class JuristicPerson extends User {

    // Attributes
    private String employeeId;

    // Constructor
    public JuristicPerson(String userId, String username, String passwordHash, String firstName, String lastName,
            String phoneNumber, String employeeId) {

        super(userId, username, passwordHash, firstName, lastName, phoneNumber);
        this.employeeId = employeeId;
    }

    public void viewAndAssignRepairTickets() {
        Scanner scanner = new Scanner(System.in);
        List<RepairTicket> allTickets = DataStore.getInstance().getRepairTickets();

        System.out.println("\n--- Manage Repair Tickets ---");

        if (allTickets.isEmpty()) {
            System.out.println("No tickets currently in the system.");
            return;
        }

        // แสดง Ticket 
        System.out.println("Select a ticket to assign:");
        int tIndex = 1;
        for (RepairTicket t : allTickets) {
            String assignedInfo = (t.getAssignedTechnicianId() == null) ? "None" : t.getAssignedTechnicianId();

            System.out.printf("%d. [Room: %s] %s (Status: %s) -> Tech: %s\n",
                    tIndex, t.getReporterId(), t.getDescription(), t.getStatus(), assignedInfo);
            tIndex++;
        }
        System.out.println("0. Exit");

        // เลือก Ticket
        System.out.print("Select ticket number: ");
        int ticketChoice = -1;
        try {
            String input = scanner.nextLine();
            ticketChoice = Integer.parseInt(input);
        } catch (NumberFormatException e) {
            ticketChoice = -1;
        }

        if (ticketChoice == 0)
            return; 

        if (ticketChoice < 1 || ticketChoice > allTickets.size()) {
            System.out.println("Invalid ticket number.");
            return;
        }

        // ดึง Ticket ที่เลือก
        RepairTicket selectedTicket = allTickets.get(ticketChoice - 1);
        System.out.println("\nSelected Ticket: " + selectedTicket.getDescription());

        // แสดงรายชื่อช่าง 
        List<User> allUsers = DataStore.getInstance().getUsers();
        List<Technician> availableTechs = new ArrayList<>();

        System.out.println("Select Technician to assign:");

        int uIndex = 1;
        for (User u : allUsers) {
            if (u instanceof Technician) {
                Technician tech = (Technician) u;
                availableTechs.add(tech);
                System.out.println(uIndex + ". " + tech.getFirstName() + " " + tech.getLastName() + " (ID: "
                        + tech.getUserId() + ")");
                uIndex++;
            }
        }
        System.out.println("0. Cancel");

        // รับค่าเลือกช่าง
        System.out.print("Select technician number: ");
        int techChoice = -1;
        try {
            String input = scanner.nextLine();
            techChoice = Integer.parseInt(input);
        } catch (NumberFormatException e) {
            techChoice = -1;
        }

        if (techChoice > 0 && techChoice <= availableTechs.size()) {
            // ดึงช่างที่เลือก
            Technician selectedTech = availableTechs.get(techChoice - 1);

            // Assign งาน 
            selectedTicket.assignTechnician(selectedTech.getUserId());
            System.out.println("Success! Ticket assigned to " + selectedTech.getFirstName());

        } else if (techChoice != 0) {
            System.out.println("Invalid technician number.");
        } else {
            System.out.println("Assignment cancelled.");
        }
    }

    public Boolean approvePayment(String billId) {
        // สำหรับค้นหา Bill และเปลี่ยนสถานะเป็น PAID
        System.out.println("Approved payment for Bill ID: " + billId);
        return true;
    }

    public void broadcastAnnouncement(String content) {
        // สำหรับสร้าง object Announcement ใหม่และบันทึกลงระบบ
        System.out.println("Broadcasting Announcement: " + content);
    }

    public void recordParcelEntry(String tracking) {
        // สำหรับสร้าง object Parcel ใหม่เมื่อของมาถึง
        System.out.println("Recorded new Parcel entry. Tracking: " + tracking);
    }
     
    // Getters
    public String getEmployeeId() {
        return employeeId;
    }
}
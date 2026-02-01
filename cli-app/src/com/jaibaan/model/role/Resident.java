package com.jaibaan.model.role;

import java.lang.reflect.Array;
import java.util.ArrayList;
import java.util.List;
import java.util.Scanner;


import com.jaibaan.model.coreEntities.Bill;
import com.jaibaan.model.coreEntities.Parcel;
import com.jaibaan.model.coreEntities.RepairTicket;
import com.jaibaan.data.DataStore;

public class Resident extends User {

    // Attributes
    private String unitNumber;
    private List<String> familyMembers;

    // Constructor
    public Resident(String userId, String username, String passwordHash, String firstName, String lastName,
            String phoneNumber, String unitNumber) {

        super(userId, username, passwordHash, firstName, lastName, phoneNumber);

        this.unitNumber = unitNumber;
        this.familyMembers = new ArrayList<>();
    }

    public List<Bill> viewMyBills() {
        System.out.println("DEBUG: Fetching bills for unit " + this.unitNumber);
        return new ArrayList<Bill>();
    }

    public List<Parcel> viewMyParcels() {
        System.out.println("DEBUG: Fetching parcels for unit " + this.unitNumber);

        // ดึงพัสดุจาก DataStore ของจริง
        List<Parcel> allParcels = DataStore.getInstance().getParcels();

        ArrayList<Parcel> myParcels = new ArrayList<>();

        for (Parcel p : allParcels) {
            if (p.getRecipientUnitNumber().equals(this.unitNumber)) {
                myParcels.add(p);
            }
        }

        // แสดงผล
        if (!myParcels.isEmpty()) {
            System.out.println("Parcels for unit " + this.unitNumber + ":");
            for (Parcel p : myParcels) {
                System.out.println(
                        " - " + p.getCarrier() + " (Track: " + p.getTrackingNumber() + ") Status: " + p.getStatus());
            }
        }

        return myParcels;
    }

    public void createRepairTicket() {
        Scanner scanner = new Scanner(System.in);
        System.out.println("Create Repair Ticket...");

        System.out.print("Enter description of the issue: ");
        String description = scanner.nextLine();

        System.out.print("Enter location of the issue: ");
        String location = scanner.nextLine();

        
        String ticketId = "TICKET-" + System.currentTimeMillis(); 
        RepairTicket newTicket = new RepairTicket(ticketId, description, location, java.time.LocalDateTime.now(), this.unitNumber);

        
        DataStore.getInstance().addRepairTicket(newTicket);

        System.out.println("Repair Ticket created with ID: " + ticketId);
    }

    public List<RepairTicket> viewMyTickets() {
        System.out.println("Viewing repair tickets for unit " + this.unitNumber);
        List<RepairTicket> allRepairTickets = DataStore.getInstance().getRepairTickets();
        List<RepairTicket> rt = new ArrayList<RepairTicket>();
        for (RepairTicket ticket : allRepairTickets) {
            if (ticket.getReporterId().equals(this.unitNumber)) {
                rt.add(ticket);
            }
        }
        for (RepairTicket rtItem : rt) {
            System.out.println(" - Ticket ID: " + rtItem.getTicketId() + ", Status: " + rtItem.getStatus());
            System.out.println("   Assigned Technician: " + rtItem.getAssignedTechnicianId());
            System.out.println("   Description: " + rtItem.getDescription());
        }
        return rt;
    }

    // +registerVisitorVehicle(plate) Void
    public void registerVisitorVehicle(String plate) {
        // จำลองการลงทะเบียนป้ายทะเบียนรถ
        System.out.println("Registered Visitor Vehicle: " + plate + " for Unit " + this.unitNumber);
    }


    // Getters/Setters

    public String getUnitNumber() {
        return unitNumber;
    }

    public void addFamilyMember(String name) {
        this.familyMembers.add(name);
    }

    public List<String> getFamilyMembers() {
        return familyMembers;
    }
}
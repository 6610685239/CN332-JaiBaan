package com.jaibaan.service;

import com.jaibaan.model.role.Resident;
import com.jaibaan.model.role.User;
import com.jaibaan.model.coreEntities.Bill;
import com.jaibaan.model.coreEntities.Parcel;
import com.jaibaan.model.coreEntities.RepairTicket;
import java.util.Scanner;
import java.util.List;

public class ResidentService {
    
    public void showMenu(User user, Scanner scanner) {
        Resident resident = (Resident) user; 

        // ใส่ Loop ตรงนี้ เพื่อให้โปรแกรมวนถามเมนูเรื่อยๆ
        while (true) {
            System.out.println("\n--- Resident Menu (Unit: " + resident.getUnitNumber() + ") ---");
            System.out.println("1. View My Parcels");
            System.out.println("2. View My Bills");
            System.out.println("3. Create Repair Ticket");
            System.out.println("4. View My Repair Tickets");
            System.out.println("0. Logout");
            System.out.print("Select: ");

            String choice = scanner.nextLine();
            
            if (choice.equals("1")) {
                List<Parcel> parcels = resident.viewMyParcels();
                if(parcels.isEmpty()) System.out.println("No parcels found.");
                
            }
            
            else if (choice.equals("2")) {
                List<Bill> bills = resident.viewMyBills();
                if(bills.isEmpty()) System.out.println("No pending bills.");
            
            }

            else if (choice.equals("3")) {
                resident.createRepairTicket();
            }
            
            else if (choice.equals("4")) {
                List<RepairTicket> tickets = resident.viewMyTickets();
                if(tickets.isEmpty()) System.out.println("No repair tickets found.");
            }
            
            else if (choice.equals("0")) {
                // ถ้ากด 0 ให้ return ออกจาก method นี้ กลับไปที่ Main ทันที
                return; 
            }
            
            else {
                System.out.println("Invalid choice, please try again.");
            }
        }
    }
}
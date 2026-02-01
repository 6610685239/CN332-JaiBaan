package com.jaibaan.service;

import com.jaibaan.model.role.JuristicPerson;
import com.jaibaan.model.role.User;
import com.jaibaan.model.coreEntities.Parcel; // Import Parcel
import com.jaibaan.data.DataStore; // Import DataStore
import java.util.Scanner;

public class JuristicService {
    
    public void showMenu(User user, Scanner scanner) {
        JuristicPerson juristic = (JuristicPerson) user;

        while (true) {
            System.out.println("\n--- Juristic Menu (Staff: " + juristic.getEmployeeId() + ") ---");
            System.out.println("1. Record Parcel Entry");
            System.out.println("2. Broadcast Announcement");
            System.out.println("3. View and Assign Repair Tickets");
            System.out.println("0. Logout");
            System.out.print("Select: ");

            String choice = scanner.nextLine();

            if (choice.equals("1")) {
                System.out.print("Enter Tracking Number: ");
                String tracking = scanner.nextLine();
                
                System.out.print("Enter Carrier (e.g. Kerry): ");
                String carrier = scanner.nextLine();

                System.out.print("Enter Recipient Unit Number (e.g. 101/55): ");
                String recipientUnitNumber = scanner.nextLine();
                
                // สร้าง ID มั่วๆ ขึ้นมา
                String pid = "P-" + System.currentTimeMillis(); 
                Parcel newParcel = new Parcel(pid, tracking, carrier, recipientUnitNumber);
                
                // บันทึกเข้าส่วนกลาง
                DataStore.getInstance().addParcel(newParcel);
                
                // เรียก method ของ model (เพื่อคง concept diagram)
                juristic.recordParcelEntry(tracking); 
                System.out.println("(System) Saved parcel " + tracking + " to database.");

            } else if (choice.equals("2")) {
                System.out.print("Enter Announcement Content: ");
                String content = scanner.nextLine();
                juristic.broadcastAnnouncement(content);
            } 
            
            else if (choice.equals("3")) {
                juristic.viewAndAssignRepairTickets();
            }

            else if (choice.equals("0")) {
                return;
            }
        }
    }
}
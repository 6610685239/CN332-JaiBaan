package com.jaibaan.service;

import com.jaibaan.model.role.JuristicPerson;
import com.jaibaan.model.role.User;
import com.jaibaan.model.coreEntities.Bill;
import com.jaibaan.model.coreEntities.Facility;
import com.jaibaan.model.coreEntities.Parcel; // Import Parcel
import com.jaibaan.data.DataStore; // Import DataStore
import com.jaibaan.model.coreEntities.Facility;
import java.time.LocalTime;

import java.util.List;
import java.util.Scanner;

public class JuristicService {

    public void showMenu(User user, Scanner scanner) {
        JuristicPerson juristic = (JuristicPerson) user;

        while (true) {
            System.out.println("\n--- Juristic Menu (Staff: " + juristic.getEmployeeId() + ") ---");
            System.out.println("1. Record Parcel Entry");
            System.out.println("2. Broadcast Announcement");
            System.out.println("3. View and Assign Repair Tickets");
            System.out.println("4. Manage Facility");
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
                System.out.println("\n--- Create Announcement ---");

                System.out.print("Enter Title: ");
                String title = scanner.nextLine();

                System.out.print("Enter Content: ");
                String content = scanner.nextLine();

                System.out.println("Choose Category: 1.NEWS  2.MAINTENANCE  3.WARNING");
                System.out.print("Select: ");
                String catChoice = scanner.nextLine();
                String category = "NEWS"; // default
                if(catChoice.equals("2")) category = "MAINTENANCE";
                if(catChoice.equals("3")) category = "WARNING";

                juristic.broadcastAnnouncement(title, content, category);
            } 
            
            else if (choice.equals("3")) {
                juristic.viewAndAssignRepairTickets();
            }

            else if (choice.equals("4")) {
                facilityManagement(scanner);

            } else if (choice.equals("0")) {
                return;
            }
        }
    }

    private void facilityManagement(Scanner scanner) {
        DataStore ds = DataStore.getInstance();
        while (true) {
            System.out.println("\n===== Facility Management =====");
            System.out.println("1. List All Facilities");
            System.out.println("2. Add New Facility");
            System.out.println("3. Edit Facility");
            System.out.println("4. Remove Facility");
            System.out.println("0. Back to Main Menu");
            System.out.print("Select: ");

            String choice = scanner.nextLine();

            if (choice.equals("1")) { // LIST
                System.out.println("\nID\t\tName\t\t\tCap\t\tTime");
                for (Facility f : ds.getFacilities()) {
                    System.out.println(f.getFacilityId() + "\t\t" + f.getName() + "\t\t\t" + f.getCapacity() + "\t\t\t" + f.getOpenTime() + "-" + f.getCloseTime());
                }

            } else if (choice.equals("2")) { // ADD
                System.out.print("Name: ");
                String name = scanner.nextLine();
                System.out.print("Capacity: ");
                int cap = Integer.parseInt(scanner.nextLine());
                System.out.print("Open (HH:mm): ");
                LocalTime open = LocalTime.parse(scanner.nextLine());
                System.out.print("Close (HH:mm): ");
                LocalTime close = LocalTime.parse(scanner.nextLine());

                Facility nf = new Facility("F00" + Facility.facilityCounter , name, cap, open, close);
                Facility.facilityCounter++;
                ds.addFacility(nf);
                System.out.println("Added successfully!");

            } else if (choice.equals("3")) { // EDIT
                System.out.print("Enter Facility ID to edit: ");
                String id = scanner.nextLine();
                Facility f = ds.findFacilityById(id);
                if (f != null) {
                    System.out.print("New Name (Current: " + f.getName() + "): ");
                    f.setName(scanner.nextLine());
                    System.out.print("New Capacity: ");
                    f.setCapacity(Integer.parseInt(scanner.nextLine()));
                    System.out.println("Updated successfully!");
                } else {
                    System.out.println("Facility not found!");
                }

            } else if (choice.equals("4")) { // REMOVE
                System.out.print("Enter Facility ID to remove: ");
                String id = scanner.nextLine();
                Facility f = ds.findFacilityById(id);
                if (f != null) {
                    ds.removeFacility(f);
                    System.out.println("Removed successfully!");
                } else {
                    System.out.println("Facility not found!");
                }

            } else if (choice.equals("0"))
                break;
        }
    }
    }

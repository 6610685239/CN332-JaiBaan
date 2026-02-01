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
            System.out.println("3. Manage Facility");
            System.out.println("0. Logout");
            System.out.print("Select: ");

            String choice = scanner.nextLine();

            if (choice.equals("1")) {
                System.out.print("Enter Tracking Number: ");
                String tracking = scanner.nextLine();

                System.out.print("Enter Carrier (e.g. Kerry): ");
                String carrier = scanner.nextLine();

                // สร้าง ID มั่วๆ ขึ้นมา
                String pid = "P-" + System.currentTimeMillis();
                Parcel newParcel = new Parcel(pid, tracking, carrier);

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
                System.out.println("\nID\t\tName\t\tCap\tTime");
                for (Facility f : ds.getFacilities()) {
                    System.out.println(f.getFacilityId() + "\t" + f.getName() + "\t" + f.getCapacity() + "\t"
                            + f.getOpenTime() + "-" + f.getCloseTime());
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

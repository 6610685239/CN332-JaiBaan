package com.jaibaan.service;

import com.jaibaan.data.DataStore;
import com.jaibaan.model.role.Resident;
import com.jaibaan.model.role.User;
import com.jaibaan.model.supportEntities.Reservation;
import com.jaibaan.model.coreEntities.Bill;
import com.jaibaan.model.coreEntities.Facility;
import com.jaibaan.model.coreEntities.Parcel;
import com.jaibaan.model.coreEntities.RepairTicket;
import com.jaibaan.model.supportEntities.PaymentTransaction; 
import java.util.Scanner;
import java.util.ArrayList;
import java.util.List;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.LocalDateTime;

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
            System.out.println("5. Facility Reservation");
            System.out.println("6. Register Arrival via E-Pass");
            System.out.println("7. View & Pay Bills"); 
            System.out.println("0. Logout");
            System.out.print("Select: ");

            String choice = scanner.nextLine();

            if (choice.equals("1")) {
                List<Parcel> parcels = resident.viewMyParcels();
                if (parcels.isEmpty())
                    System.out.println("No parcels found.");

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
                if (bills.isEmpty())
                    System.out.println("No pending bills.");

            } else if (choice.equals("5")) {
                facilityMenu(resident, scanner);
            } else if (choice.equals("6")) {
                 System.out.print("Enter License Plate (e.g. กก-9999): ");
                String plate = scanner.nextLine().trim();
                
                // 2. รับยี่ห้อ/รุ่นรถ (เพิ่มส่วนนี้)
                System.out.print("Enter Car Model (e.g. Toyota Yaris): ");
                String model = scanner.nextLine().trim();

                if (!plate.isEmpty() && !model.isEmpty()) {
                    // ส่งทั้ง 2 ค่าไปที่ Model
                    resident.registerVisitorVehicle(plate, model);
                } else {
                    System.out.println(">> Error: Plate and Model cannot be empty.");
                }
            } 
            else if (choice.equals("7")) { // << อย่าลืมเชื่อมตรงนี้!
                paymentMenu(resident, scanner);
            }else if (choice.equals("0")) {
                // ถ้ากด 0 ให้ return ออกจาก method นี้ กลับไปที่ Main ทันที
                return;
            }

            else {
                System.out.println("Invalid choice, please try again.");
            }
        }

    }

    private void facilityMenu(Resident resident, Scanner scanner) {
        DataStore ds = DataStore.getInstance();
        while (true) {
            System.out.println("\n===== Facility Reservation =====");
            System.out.println("1. List All Facilities & Check Availability");
            System.out.println("2. Make a Reservation");
            System.out.println("3. View My Bookings");
            System.out.println("0. Back");
            System.out.print("Select: ");

            String choice = scanner.nextLine();
            if (choice.equals("1")) {
                for (Facility f : ds.getFacilities()) {
                    System.out.println("- [" + f.getFacilityId() + "] " + f.getName() +
                            " (Open: " + f.getOpenTime() + "-" + f.getCloseTime() + ")");
                }
            } else if (choice.equals("2")) {
                System.out.print("Enter Facility ID: ");
                String fid = scanner.nextLine();
                Facility f = ds.findFacilityById(fid);

                if (f != null) {
                    System.out.print("Enter Date (YYYY-MM-DD เช่น 2024-12-25): ");
                    LocalDate date = LocalDate.parse(scanner.nextLine());
                    System.out.print("Enter Time (HH:mm เช่น 10:00): ");
                    LocalTime time = LocalTime.parse(scanner.nextLine());

                    // เช็คว่าสถานที่เปิดไหม
                    if (f.checkAvailability(date, time)) {
                        Reservation res = new Reservation(resident.getUserId(), f.getFacilityId(),
                                LocalDateTime.of(date, time));
                        ds.addReservation(res);
                        System.out.println(">> Booking Successful! Your E-Pass: " + res.getEPassCode());
                    }
                } else {
                    System.out.println(">> Facility not found!");
                }
            } else if (choice.equals("3")) {
                List<Reservation> myRes = ds.findReservationsByResident(resident.getUserId());
                System.out.println("\n--- Your Bookings ---");
                for (Reservation r : myRes) {
                    // ใช้ getFacilityId() เพื่อไปดึงชื่อสถานที่มาโชว์
                    Facility f = ds.findFacilityById(r.getFacilityId());
                    if (f != null) {
                        System.out.println("ID: " + r.getReservationId() + " | " + f.getName() +
                                " | Time: " + r.getStartTime() + " | Status: " + r.getStatus());
                    }
                }
            } else if (choice.equals("0"))
                break;
        }
    }

    private void paymentMenu(Resident resident, Scanner scanner) {
    while (true) {
        System.out.println("\n-------------------------------------------");
        System.out.println("PAYMENT");
        System.out.println("-------------------------------------------");
        
        // 1. ดึงบิลที่ยังไม่ได้จ่ายของบ้านตัวเอง
        List<Bill> myUnpaidBills = new ArrayList<>();
        for (Bill b : DataStore.getInstance().getBills()) {
            if (b.getUnitNumber().equals(resident.getUnitNumber()) && b.getStatus().equals("UNPAID")) {
                myUnpaidBills.add(b);
            }
        }

        if (myUnpaidBills.isEmpty()) {
            System.out.println("All bills are paid! No outstanding balances.");
            return;
        }

        System.out.println("Outstanding bills:");
        for (Bill b : myUnpaidBills) {
            System.out.printf("- %-20s : %.2f THB\n", b.getType(), b.getAmount());
        }

        System.out.println("\nPayment option:");
        System.out.println("1) Pay all bills");
        System.out.println("2) Pay selected bills");
        System.out.println("0) Back");
        System.out.print("> ");
        String option = scanner.nextLine();

        List<Bill> selectedToPay = new ArrayList<>();
        if (option.equals("1")) {
            selectedToPay.addAll(myUnpaidBills);
        } else if (option.equals("2")) {
            System.out.println("\nSelect bills to pay:");
            for (Bill b : myUnpaidBills) {
                System.out.print("Pay " + b.getType() + " (" + b.getAmount() + " THB)? (y/n): ");
                if (scanner.nextLine().equalsIgnoreCase("y")) {
                    selectedToPay.add(b);
                }
            }
        } else { return; }

        if (selectedToPay.isEmpty()) continue;

        // 2. แสดงสรุปยอด (Payment Summary)
        System.out.println("\n-------------------------------------------");
        System.out.println("PAYMENT SUMMARY");
        System.out.println("-------------------------------------------");
        double total = 0;
        for (Bill b : selectedToPay) {
            System.out.printf("- %-20s : %.2f THB\n", b.getType(), b.getAmount());
            total += b.getAmount();
        }
        System.out.println("TOTAL AMOUNT          " + total + " THB");

        System.out.println("\nSelect payment method:");
        System.out.println("1) PromptPay (Show QR)");
        System.out.println("2) Bank Transfer");
        System.out.print("> ");
        scanner.nextLine(); // ข้ามการเลือกวิธีไปที่ขั้นตอนการจ่ายเลย

        // 3. จำลองการจ่ายเงิน (The Jaibaan Logic)
        System.out.println("\nGenerating QR Code...");
        System.out.println("-------------------------------------------");
        System.out.println("     [ " + selectedToPay.get(0).generateQR() + " ]");
        System.out.println("-------------------------------------------");
        
        System.out.print("Please enter slip image filename to upload (e.g. slip.jpg): ");
        String slipName = scanner.nextLine();

        if (!slipName.isEmpty()) {
            System.out.println("\n⏳ Uploading evidence...");
            // อัปเดตสถานะบิลทุกใบที่เลือกเป็น PENDING
            for (Bill b : selectedToPay) {
                b.setStatus("PENDING");
            }
            System.out.println(" Evidence submitted successfully!");
            System.out.println(" Status: PENDING (Waiting for Juristic verification)");
        } else {
            System.out.println("Payment cancelled. No slip attached.");
        }
        
        System.out.println("\nPress Enter to continue...");
        scanner.nextLine();
        break; // กลับไปเมนูหลัก
    }
}
}
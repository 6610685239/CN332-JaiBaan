package com.jaibaan.service;

import com.jaibaan.data.DataStore;
import com.jaibaan.model.role.SecurityGuard;
import com.jaibaan.model.role.User;
import com.jaibaan.model.supportEntities.Vehicle;
import com.jaibaan.model.supportEntities.VisitorLog;

import java.util.List;
import java.util.Scanner;

public class GuardService {

    public void showMenu(User user, Scanner scanner) {
        SecurityGuard guard = (SecurityGuard) user;

        while (true) {
            System.out.println("\nSecurity Guard Menu (Gate: " + guard.getStationId() + ")");
            System.out.println("1. Verify Visitor Vehicle");
            System.out.println("2. Collect Overdue Fee");
            System.out.println("0. Logout");
            System.out.print("Select: ");

            String choice = scanner.nextLine();

            if (choice.equals("1")) {
                // 1. ดึงข้อมูลรถทั้งหมดมาแสดง
                List<Vehicle> vehicles = DataStore.getInstance().getRegisteredVehicles();

                if (vehicles.isEmpty()) {
                    System.out.println(">> No registered vehicles found.");
                    continue;
                }

                System.out.println("\n--- Registered Vehicles List ---");
                for (int i = 0; i < vehicles.size(); i++) {
                    Vehicle v = vehicles.get(i);
                    System.out.println((i + 1) + ") " + v.getLicensePlate() + " [" + v.getModel() + "]");
                }
                System.out.println("--------------------------------");
                System.out.print("Select vehicle number to verify (or 0 to cancel): ");

                // 2. รับค่าตัวเลขเพื่อเลือก
                try {
                    int vIndex = Integer.parseInt(scanner.nextLine());

                    if (vIndex > 0 && vIndex <= vehicles.size()) {
                        // 3. ดึงทะเบียนรถที่เลือกมาตรวจสอบ
                        Vehicle selectedCar = vehicles.get(vIndex - 1);
                        guard.verifyVisitor(selectedCar.getLicensePlate());
                    } else if (vIndex != 0) {
                        System.out.println("Invalid number.");
                    }
                } catch (NumberFormatException e) {
                    System.out.println("Please enter a number.");
                }

            } else if (choice.equals("2")) {
                // --- ฟีเจอร์ใหม่: เก็บค่าปรับแบบง่าย ---
                System.out.println("\n--- Collect Overdue Fee ---");
                System.out.print("Enter Overdue Hours (int): ");

                try {
                    int hours = Integer.parseInt(scanner.nextLine());
                    if (hours > 0) {
                        Double totalFee = guard.collectOverdueFee(hours);
                        System.out.println(">> Total Fee to Collect: " + totalFee + " THB");
                    } else {
                        System.out.println(">> Hours must be greater than 0.");
                    }
                } catch (NumberFormatException e) {
                    System.out.println(">> Error: Please enter a valid number.");
                }
            } else if (choice.equals("0"))
                break;
        }

    }
}
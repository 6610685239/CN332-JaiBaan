package com.jaibaan.service;

import com.jaibaan.model.role.Technician;
import com.jaibaan.model.role.User;
import java.util.Scanner;

public class TechnicianService {
    
    public void showMenu(User user, Scanner scanner) {
        Technician tech = (Technician) user;

        while (true) {
            System.out.println("\n--- Technician Menu (Spec: " + tech.getSpecialty() + ") ---");
            System.out.println("1. View Assigned Jobs");
            System.out.println("2. Update Job Status");
            System.out.println("0. Logout");
            System.out.print("Select: ");
            
            String choice = scanner.nextLine().trim(); // เพิ่ม trim() ตัดช่องว่าง
            
            if (choice.equals("1")) {
                tech.viewAssignedJobs();
                
            } else if (choice.equals("2")) {
                tech.updateJobStatus();

            } else if (choice.equals("0")) {
                return;
            } else {
                System.out.println("Invalid choice.");
            }
        }
    }
}
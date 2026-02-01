package com.jaibaan.service;

import com.jaibaan.model.role.SecurityGuard;
import com.jaibaan.model.role.User;
import java.util.Scanner;

public class GuardService {

    public void showMenu(User user, Scanner scanner) {
        SecurityGuard guard = (SecurityGuard) user;

        while (true) {
            System.out.println("\nSecurity Guard Menu (Gate: " + guard.getStationId() + ")");
            System.out.println("1. Verify Visitor Vehicle");
            System.out.println("0. Logout");
            System.out.print("Select: ");

            String choice = scanner.nextLine();

            if (choice.equals("1")) {
                System.out.print("Enter License Plate: ");
                String plate = scanner.nextLine();
                if (guard.verifyVisitor(plate)) {
                    System.out.println("Allow Entry");
                } else {
                    System.out.println("Deny Entry");
                }
            } else if (choice.equals("0")) {
                return; // ออกจากเมนู
            } else {
                System.out.println("Invalid choice, please try again.");
            }
        }

    }
}
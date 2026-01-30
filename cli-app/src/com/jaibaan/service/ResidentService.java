package com.jaibaan.service;

import com.jaibaan.model.User;
import java.util.Scanner;

public class ResidentService {
    public void showMenu(User user, Scanner scanner) {
        System.out.println("\n--- Resident Menu (Unit: " + user.getFirstName() + ") ---");
        System.out.println("1. View Parcels (TODO)");
        System.out.println("2. Pay Bills (TODO)");
        System.out.println("0. Logout");
        
        // กรทำต่อ
        System.out.print("Select: ");
        String choice = scanner.nextLine();
    }
}
package com.jaibaan.service;

import com.jaibaan.model.User;
import java.util.Scanner;

public class OperationService {
    public void showMenu(User user, Scanner scanner) {
        System.out.println("\n--- Operation Menu (Technician & Guard) ---");
        System.out.println("1. View Jobs / Log Visitor (TODO)");
        System.out.println("0. Logout");
        
        System.out.print("Select: ");
        String choice = scanner.nextLine();
    }
}
package com.jaibaan;

import com.jaibaan.model.role.User;
import com.jaibaan.model.role.Resident;
import com.jaibaan.model.role.JuristicPerson;
import com.jaibaan.model.role.Technician;
import com.jaibaan.model.role.SecurityGuard;
import com.jaibaan.service.*;

import java.util.Scanner;

public class Main {
    private static AuthService authService = new AuthService();
    private static Scanner scanner = new Scanner(System.in);
    private static User currentUser = null;

    public static void main(String[] args) {
        System.out.println("========================================");
        System.out.println(" Welcome to JaiBaan Living OS ");
        System.out.println("========================================");

        while (true) {
            if (currentUser == null) {
                showLoginScreen();
            } else {
                // เข้าสู่เมนูตาม Role
                showUserMenu();
                
                // เมื่อออกจากเมนู (method showUserMenu จบการทำงาน) 
                // ให้ทำการ Logout อัตโนมัติทันที ไม่ต้องถามซ้ำ
                System.out.println("Logging out...");
                currentUser.logout();
                currentUser = null; 
            }
        }
    }

    private static void showLoginScreen() {
        System.out.println("\n--- PLEASE LOGIN ---");
        System.out.print("Username: ");
        String username = scanner.nextLine();
        System.out.print("Password: ");
        String password = scanner.nextLine();

        User user = authService.login(username, password);

        if (user != null) {
            currentUser = user;
            System.out.println("\nLogin Success! Welcome " + user.getFirstName());
        } else {
            System.out.println("\nLogin Failed!");
        }
    }

    private static void showUserMenu() {
        // เรียก Service และให้ Service คุม Loop เอง
        if (currentUser instanceof Resident) {
            new ResidentService().showMenu(currentUser, scanner);
        } else if (currentUser instanceof JuristicPerson) {
            new JuristicService().showMenu(currentUser, scanner);
        } else if (currentUser instanceof Technician) {
            new TechnicianService().showMenu(currentUser, scanner);
        } else if (currentUser instanceof SecurityGuard) {
            new GuardService().showMenu(currentUser, scanner);
        }
    }
}
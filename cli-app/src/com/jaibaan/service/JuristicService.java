package com.jaibaan.service;

import com.jaibaan.model.User;
import java.util.Scanner;

public class JuristicService {
    public void showMenu(User user, Scanner scanner) {
        System.out.println("\n--- Juristic Menu ---");
        System.out.println("1. Record Parcel (TODO)");
        System.out.println("2. Verify Payment (TODO)");
        System.out.println("0. Logout");

        // ปั้นทำส่วนนี้
        System.out.print("Select: ");
        String choice = scanner.nextLine();
    }
}
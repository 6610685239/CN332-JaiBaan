package com.jaibaan;

import com.jaibaan.model.*;
import com.jaibaan.service.*;
import java.util.Scanner;

public class Main {
    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        
        // Mock User เพื่อทดสอบ (เดี๋ยวค่อยทำ AuthService เต็มรูปแบบ)
        User currentUser = new Resident("res01", "1234", "Pun", UserRole.RESIDENT); // ลองแก้ตรงนี้เป็น JURISTIC ดู
        
        System.out.println("Welcome to JaiBaan CLI");
        
        while(true) {
            if (currentUser.getRole() == UserRole.RESIDENT) {
                new ResidentService().showMenu(currentUser, scanner);
            } else if (currentUser.getRole() == UserRole.JURISTIC) {
                new JuristicService().showMenu(currentUser, scanner);
            } else {
                new OperationService().showMenu(currentUser, scanner);
            }
            
            // Break loop for testing
            break; 
        }
    }
}
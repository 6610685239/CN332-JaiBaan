package com.jaibaan.model;

public class Resident extends User {
    // เพิ่ม field เฉพาะของลูกบ้าน (ถ้ามี)
    private String unitNumber;

    // Constructor ต้องรับค่าให้ตรงกับที่เรียกใช้ใน Main.java
    public Resident(String username, String password, String firstName, UserRole role) {
        super(username, password, firstName, role); // ส่งค่าไปให้ Class แม่ (User)
    }
    
    // Constructor แบบเต็ม (เผื่อใช้ในอนาคต)
    public Resident(String username, String password, String firstName, UserRole role, String unitNumber) {
        super(username, password, firstName, role);
        this.unitNumber = unitNumber;
    }

    public String getUnitNumber() { return unitNumber; }
}
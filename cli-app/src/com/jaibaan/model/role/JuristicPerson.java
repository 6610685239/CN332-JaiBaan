package com.jaibaan.model.role;

public class JuristicPerson extends User {

    // Attributes
    private String employeeId;

    // Constructor
    public JuristicPerson(String userId, String username, String passwordHash, String firstName, String lastName, String phoneNumber, String employeeId) {

        super(userId, username, passwordHash, firstName, lastName, phoneNumber);
        this.employeeId = employeeId;
    }

    public Boolean approvePayment(String billId) {
        // สำหรับค้นหา Bill และเปลี่ยนสถานะเป็น PAID
        System.out.println("Approved payment for Bill ID: " + billId);
        return true;
    }

    public void broadcastAnnouncement(String content) {
        // สำหรับสร้าง object Announcement ใหม่และบันทึกลงระบบ
        System.out.println("Broadcasting Announcement: " + content);
    }

    public void recordParcelEntry(String tracking) {
        // สำหรับสร้าง object Parcel ใหม่เมื่อของมาถึง
        System.out.println("Recorded new Parcel entry. Tracking: " + tracking);
    }
     
    // Getters
    public String getEmployeeId() {
        return employeeId;
    }
}
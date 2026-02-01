package com.jaibaan.data;

import com.jaibaan.model.role.*; // Import จากโฟลเดอร์ role
import com.jaibaan.model.coreEntities.*; // Import พวก Parcel, Bill
import java.util.ArrayList;
import java.util.List;
import java.time.LocalDate;

public class DataStore {
    private static DataStore instance;
    
    // เก็บ User ทุกประเภทใน List เดียว (Polymorphism)
    private List<User> users;
    private List<Parcel> parcels;
    private List<Bill> bills;

    private DataStore() {
        users = new ArrayList<>();
        parcels = new ArrayList<>();
        bills = new ArrayList<>();
        seedData();
    }

    public static DataStore getInstance() {
        if (instance == null) instance = new DataStore();
        return instance;
    }

    private void seedData() {
        // 1. Resident (ลูกบ้าน) - ส่ง 7 ค่า (6 User + 1 Unit)
        users.add(new Resident("U001", "pun", "1234", "Pun", "Kung", "089-111-1111", "101/55"));
        users.add(new Resident("U002", "baibua", "1234", "Baibua", "Ipenn", "081-222-2222", "101/56"));

        // 2. JuristicPerson (นิติ) - ส่ง 7 ค่า (6 User + 1 EmpID)
        users.add(new JuristicPerson("U003", "admin", "admin", "Park", "Manage", "02-111-1111", "EMP-001"));

        // 3. Technician (ช่าง) - ส่ง 7 ค่า (6 User + 1 Specialty)
        users.add(new Technician("U004", "tech", "1234", "Non", "AC", "083-333-3333", "Electrician"));

        // 4. SecurityGuard (รปภ) - ส่ง 7 ค่า (6 User + 1 StationID)
        users.add(new SecurityGuard("U005", "guard", "1234", "Ake", "Secure", "084-444-4444", "GATE-A"));

        // 5. Mock Data: Parcel & Bill
        parcels.add(new Parcel("P001", "KER-8888", "Kerry")); // ของใครเดี๋ยวค่อย Link
        bills.add(new Bill("B001", 500.0, LocalDate.now().plusDays(7), "WATER"));
    }

    public List<User> getUsers() { return users; }
    public List<Parcel> getParcels() { return parcels; }
    public List<Bill> getBills() { return bills; }
    
    // Method ช่วยเพิ่มข้อมูล
    public void addParcel(Parcel p) { parcels.add(p); }
}
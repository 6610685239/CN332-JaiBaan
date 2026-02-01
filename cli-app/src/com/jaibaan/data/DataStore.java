package com.jaibaan.data;

import com.jaibaan.model.role.*; // Import จากโฟลเดอร์ role
import com.jaibaan.model.coreEntities.*; // Import พวก Parcel, Bill
import java.util.ArrayList;
import java.util.List;
import java.time.LocalDate;
import java.time.LocalTime;

public class DataStore {
    private static DataStore instance;

    // เก็บ User ทุกประเภทใน List เดียว (Polymorphism)
    private List<User> users;
    private List<Parcel> parcels;
    private List<Bill> bills;
    private List<Facility> facilities;

    private DataStore() {
        users = new ArrayList<>();
        parcels = new ArrayList<>();
        bills = new ArrayList<>();
        facilities = new ArrayList<>();
        seedData();
    }

    public static DataStore getInstance() {
        if (instance == null)
            instance = new DataStore();
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

        addFacility(new Facility("F001", "Swimming Pool", 20, LocalTime.of(8, 0), LocalTime.of(20, 0)));
        addFacility(new Facility("F002", "Fitness Center", 10, LocalTime.of(6, 0), LocalTime.of(22, 0)));
    }

    public List<User> getUsers() {
        return users;
    }

    public List<Parcel> getParcels() {
        return parcels;
    }

    public List<Bill> getBills() {
        return bills;
    }

    // Method ช่วยเพิ่มข้อมูล
    public void addParcel(Parcel p) {
        parcels.add(p);
    }

    // Facility Methods
    public List<Facility> getFacilities() {
        return facilities;
    }

    public void addFacility(Facility facility) {
        if (facilities == null) {
            facilities = new ArrayList<>();
        }
        facilities.add(facility);
    }

    public void removeFacility(Facility facility) {
        if (facilities != null) {
            facilities.remove(facility);
        }

    }
    public Facility findFacilityById(String id) {
        for (Facility f : facilities) {
            if (f.getFacilityId().equalsIgnoreCase(id)) return f;
        }
        return null;
    }
}
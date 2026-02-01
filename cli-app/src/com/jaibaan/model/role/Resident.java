package com.jaibaan.model.role;

import java.lang.reflect.Array;
import java.util.ArrayList;
import java.util.List;

import com.jaibaan.model.coreEntities.Bill;
import com.jaibaan.model.coreEntities.Parcel;
import com.jaibaan.data.DataStore;

public class Resident extends User {

    // Attributes
    private String unitNumber;
    private List<String> familyMembers;

    // Constructor
    public Resident(String userId, String username, String passwordHash, String firstName, String lastName,
            String phoneNumber, String unitNumber) {

        super(userId, username, passwordHash, firstName, lastName, phoneNumber);

        this.unitNumber = unitNumber;
        this.familyMembers = new ArrayList<>();
    }

    public List<Bill> viewMyBills() {
        System.out.println("DEBUG: Fetching bills for unit " + this.unitNumber);
        return new ArrayList<Bill>();
    }

    public List<Parcel> viewMyParcels() {
        System.out.println("DEBUG: Fetching parcels for unit " + this.unitNumber);

        // ดึงพัสดุจาก DataStore ของจริง
        List<Parcel> allParcels = DataStore.getInstance().getParcels();

        ArrayList<Parcel> myParcels = new ArrayList<>();

        for (Parcel p : allParcels) {
            if (p.getRecipientUnitNumber().equals(this.unitNumber)) {
                myParcels.add(p);
            }
        }

        // แสดงผล
        if (!myParcels.isEmpty()) {
            System.out.println("Parcels for unit " + this.unitNumber + ":");
            for (Parcel p : myParcels) {
                System.out.println(
                        " - " + p.getCarrier() + " (Track: " + p.getTrackingNumber() + ") Status: " + p.getStatus());
            }
        }

        return myParcels;
    }

    // +registerVisitorVehicle(plate) Void
    public void registerVisitorVehicle(String plate) {
        // จำลองการลงทะเบียนป้ายทะเบียนรถ
        System.out.println("Registered Visitor Vehicle: " + plate + " for Unit " + this.unitNumber);
    }

    // Getters/Setters

    public String getUnitNumber() {
        return unitNumber;
    }

    public void addFamilyMember(String name) {
        this.familyMembers.add(name);
    }

    public List<String> getFamilyMembers() {
        return familyMembers;
    }
}
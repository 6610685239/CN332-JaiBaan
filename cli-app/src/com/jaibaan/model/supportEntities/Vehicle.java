package com.jaibaan.model.supportEntities;

public class Vehicle {

    // Attributes
    private String licensePlate;
    private String model;
    private String type; // e.g., "CAR", "MOTORCYCLE", "TRUCK"

    // Constructor
    public Vehicle(String licensePlate, String model, String type) {
        this.licensePlate = licensePlate;
        this.model = model;
        this.type = type;
    }

    public Boolean validatePlate() {
        // เช็คความถูกต้องของป้ายทะเบียน
        if (licensePlate != null && !licensePlate.isEmpty()) {
            System.out.println("License plate valid: " + licensePlate);
            return true;
        }
        System.out.println("Invalid license plate");
        return false;
    }

    // Getters
    public String getLicensePlate() { return licensePlate; }
    public String getModel() { return model; }
    public String getType() { return type; }
}
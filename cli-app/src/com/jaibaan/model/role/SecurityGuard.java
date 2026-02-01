package com.jaibaan.model.role;

public class SecurityGuard extends User {
    // Attributes
    private String stationId;

    // Constructor
    public SecurityGuard(String userId, String username, String passwordHash, String firstName, String lastName, String phoneNumber, String stationId) {
        super(userId, username, passwordHash, firstName, lastName, phoneNumber);
        this.stationId = stationId;
    }

    public Boolean verifyVisitor(String plateNumber) {
        // Check registration
        System.out.println("Verifying visitor vehicle: " + plateNumber);
        return true; 
    }

    public Double collectOverstayFee(String logId) {
        // Calculate fee
        System.out.println("Collecting fee for Log ID: " + logId);
        return 100.0; 
    }
    
    // Getter
    public String getStationId() { return stationId; }
}
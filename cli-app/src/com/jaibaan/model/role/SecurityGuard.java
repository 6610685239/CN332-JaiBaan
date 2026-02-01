package com.jaibaan.model.role;

import com.jaibaan.data.DataStore;
import com.jaibaan.model.supportEntities.Vehicle;
import com.jaibaan.model.supportEntities.VisitorLog;

public class SecurityGuard extends User {
    // Attributes
    private String stationId;

    // Constructor
    public SecurityGuard(String userId, String username, String passwordHash, String firstName, String lastName,
            String phoneNumber, String stationId) {
        super(userId, username, passwordHash, firstName, lastName, phoneNumber);
        this.stationId = stationId;
    }

    public Boolean verifyVisitor(String plateNumber) {
        Vehicle v = DataStore.getInstance().findRegisteredVehicle(plateNumber);

        if (v != null) {
            System.out.println(">> [VERIFIED] Vehicle " + plateNumber + " (" + v.getModel() + ") is ALLOWED.");
            return true;
        } else {
            System.out.println(">> [DENIED] Vehicle " + plateNumber + " is NOT registered.");
            return false;
        }
    }

    public Double collectOverdueFee(int hours) {
        // สร้าง Log จำลองขึ้นมาเพื่อคำนวณ (หรือจะดึง Log จริงก็ได้ แต่แบบนี้ง่ายกว่าสำหรับ Demo)
        VisitorLog tempLog = new VisitorLog("TEMP-LOG");
        return tempLog.calculateFee(hours);
    }

    // Getter
    public String getStationId() {
        return stationId;
    }
}
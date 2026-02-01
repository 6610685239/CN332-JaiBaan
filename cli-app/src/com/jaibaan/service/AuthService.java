package com.jaibaan.service;

import com.jaibaan.data.DataStore;
import com.jaibaan.model.role.User;
import java.util.List;

public class AuthService {
    private DataStore dataStore;

    public AuthService() {
        this.dataStore = DataStore.getInstance();
    }

    public User login(String username, String password) {
        List<User> users = dataStore.getUsers();

        for (User user : users) {
            // ใช้ method login() ที่อยู่ใน Class User ตาม Diagram
            if (user.login(username, password)) {
                return user;
            }
        }
        return null;
    }
}
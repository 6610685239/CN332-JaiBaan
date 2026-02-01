package com.jaibaan.model.role;

public abstract class User {
    protected String userId;
    protected String username;
    private String passwordHash;
    protected String firstName;
    protected String lastName;
    protected String phoneNumber;

    public User(String userId, String username, String passwordHash, String firstName, String lastName, String phoneNumber) {
        this.userId = userId;
        this.username = username;
        this.passwordHash = passwordHash;
        this.firstName = firstName;
        this.lastName = lastName;
        this.phoneNumber = phoneNumber;
    }

    public boolean login(String username, String password) {
        return this.username.equals(username) && this.passwordHash.equals(password);
    }

    public void logout() {
        System.out.println("User " + username + " logged out.");
    }

    public boolean updateProfile(String data) {
        System.out.println("Profile updated: " + data);
        return true;
    }

    // Getters ไว้เรียกให้ class อื่นๆ เรียกใช้ (ใครมาอ่านอย่างงนะทำไมไม่เหมือน class diagram)
    public String getUsername() { return username; }
    public String getFirstName() { return firstName; }
    public String getLastName() { return lastName; }
    public String getPhoneNumber() { return phoneNumber; }
    public String getUserId() { return userId; }


}
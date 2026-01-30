package com.jaibaan.model;

public abstract class User {
    protected String username;
    protected String password;
    protected String firstName;
    protected UserRole role;

    public User(String username, String password, String firstName, UserRole role) {
        this.username = username;
        this.password = password;
        this.firstName = firstName;
        this.role = role;
    }

    public String getUsername() { return username; }
    public UserRole getRole() { return role; }
    public String getFirstName() { return firstName; }
    
    public boolean verifyPassword(String input) {
        return this.password.equals(input);
    }
}
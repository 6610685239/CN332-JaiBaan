package com.jaibaan.model.supportEntities;

public class Announcement {

    // Attributes
    private String announceId;
    private String title;
    private String content;
    private String category; //"NEWS", "MAINTENANCE", "WARNING"

    // Constructor
    public Announcement(String announceId, String title, String content, String category) {
        this.announceId = announceId;
        this.title = title;
        this.content = content;
        this.category = category;
    }


    public void publish() {
        // จำลองการประกาศ
        System.out.println("\n[ANNOUNCEMENT] " + title.toUpperCase() + " (" + category + ")");
        System.out.println("------------------------------------------------");
        System.out.println(content);
        System.out.println("------------------------------------------------\n");
    }

    // Getters
    public String getAnnounceId() { return announceId; }
    public String getTitle() { return title; }
    public String getContent() { return content; }
    public String getCategory() { return category; }
}
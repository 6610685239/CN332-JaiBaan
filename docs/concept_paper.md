# Concept Paper: JaiBaan Project (Digital Transformation Management System)

![Project Status](https://img.shields.io/badge/Status-Proposal_Phase-blue?style=flat-square)
![Platform](https://img.shields.io/badge/Platform-Mobile_%26_Web-orange?style=flat-square)
![License](https://img.shields.io/badge/License-GPL--3.0-green?style=flat-square)

**Course:** CN332 Object-Oriented Analysis and Design (OOAD)
**Department:** Computer Engineering, Thammasat University

---

## 1. Overview
**"JaiBaan" (ใจบ้าน)** is an innovative **"Living OS"** designed to elevate high-end housing estates into a fully realized **Smart Community**.

This project aims to transform traditional Juristic Person management (manual-based) into a **Fully Digital Ecosystem**. By shifting all operations and communications to a dedicated **Mobile Application** for residents and a **Web Dashboard** for administration, JaiBaan ensures convenience, transparency, and enhanced security. The system is built upon **"Human-Centric Design"** principles, ensuring technology integrates seamlessly into daily life, providing warmth and privacy just like being at home.

---

## 2. Problem Statement

An analysis of current housing estate management reveals several critical pain points:

1.  **Visitor Congestion:** Traditional ID exchange at gates causes traffic jams and poses risks to resident data privacy.
2.  **Fragmented Communication:** Important announcements via paper notices or general chat apps (e.g., Line Groups) are often overlooked, leading to missed urgent information.
3.  **Inefficient Maintenance:** Reporting repairs via phone lacks status tracking, resulting in lost requests and delayed service.
4.  **Lack of Transparency:** Residents cannot independently verify financial statements or budget utilization.
5.  **Facility Access Issues:** The inability to check real-time facility availability leads to double bookings and wasted trips.

---

## 3. Project Objectives

1.  To develop a unified platform that seamlessly connects Residents, Juristic Persons, and Security Personnel.
2.  To integrate **AI and Automation** to reduce redundant manual tasks and enhance security precision.
3.  To apply **Object-Oriented Analysis and Design (OOAD)** principles to create a flexible, scalable, and maintainable software architecture.

---

## 4. System Modules & Key Features

The system comprises two main interfaces: **JaiBaan Mobile App** (for Residents) and **Juristic Web Dashboard** (for Admin), covering 5 key modules:

### 4.1 Smart Gate & LPR Access
> *Concept: "No Card, Just Plate" - Seamless access via license plate recognition.*

* **Pre-Register License Plate:** Residents register their guest's vehicle license plate in advance via the Mobile App.
* **AI-Driven Access:** Upon arrival, the **AI Camera (LPR)** scans the plate. If it matches the pre-registered data, the barrier opens automatically without ID exchange.
* **Real-time Visitor Alert:** Residents receive an instant **Push Notification** when their guest enters the premises.
* **Enhanced Security:** Unregistered vehicles are denied automatic entry and must go through standard security protocols with guards.

### 4.2 Smart Repair Request
> *Concept: "One-Click Service" - Report and track issues anywhere, anytime.*

* **In-App Reporting:** Residents report issues by taking photos and pinning locations directly in the app. The system automatically creates a ticket for the technician team.
* **Status Tracking:** Monitor repair progress in real-time (Received -> In Progress -> Completed) via the app dashboard.
* **Smart Feedback:** Residents can rate services and view service history for quality assurance.

### 4.3 Smart Facility Reservation
> *Concept: "Digital Booking" - Manage your lifestyle effortlessly.*

* **Live Availability Check:** View real-time schedules for facilities (Gym, Pool, Meeting Room).
* **Instant Booking:** Book slots via the app and receive a digital **E-Pass** to confirm access rights.
* **Fair Usage Policy:** Automated quota management prevents monopoly of shared spaces.

### 4.4 Financial Transparency Dashboard
> *Concept: "Trust & Verify" - Confidence through visible data.*

* **Visual Dashboard:** Residents can view intuitive graphs summarizing the Juristic Person's income, expenses, and balance.
* **Bill Management:** Automated notifications for common fees and utility bills, with a secure history of digital receipts.

### 4.5 Smart Announcement & Notification
> *Concept: "Reach Everyone" - Instant updates directly to residents.*

* **Targeted Push Notification:** Admins can broadcast urgent alerts (e.g., "Water Pipe Burst", "Parcel Arrived") directly to residents' mobile lock screens.
* **Categorized News Feed:** A dedicated news hub within the app, categorized for easy browsing (Urgent / Activities / Maintenance).

---

## 5. Technology Stack

### Core Architecture
![NodeJS](https://img.shields.io/badge/Backend-Node.js-339933?style=for-the-badge&logo=nodedotjs&logoColor=white)
![React](https://img.shields.io/badge/Web_Admin-React-61DAFB?style=for-the-badge&logo=react&logoColor=black)
![Flutter](https://img.shields.io/badge/Mobile_App-Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/Database-PostgreSQL-336791?style=for-the-badge&logo=postgresql&logoColor=white)

* **Backend:** Node.js (Express) - High-performance API handling and scalable server-side logic.
* **Web Frontend:** React.js - Dynamic dashboard for Juristic management.
* **Mobile App:** Flutter - Cross-platform mobile application (iOS/Android) for residents.
* **Database:** PostgreSQL - Reliable relational database management system.

### Integration & Infrastructure
![Firebase](https://img.shields.io/badge/Notification-Firebase_FCM-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![n8n](https://img.shields.io/badge/Automation-n8n-FF6D5A?style=for-the-badge&logo=n8n&logoColor=white)
![YOLO](https://img.shields.io/badge/AI-YOLOv8-00FFFF?style=for-the-badge&logo=opencv&logoColor=black)

* **Notification Service:** Firebase Cloud Messaging (FCM) - Precise and fast push notification delivery.
* **Automation:** n8n - Workflow automation middleware connecting various services.
* **Artificial Intelligence:** YOLOv8 - Advanced object detection model for License Plate Recognition (LPR).

---

## 6. Expected Benefits

1.  **Enhanced Security:** AI-driven screening reduces human error and unauthorized access.
2.  **Operational Efficiency:** Reduces manual paperwork and administrative overhead by over 60%.
3.  **Real-time Communication:** Ensures 100% reach for urgent news, eliminating communication gaps.
4.  **Transparency & Trust:** verifiable financial data builds stronger trust between residents and management.

---

## 7. Project Team

| Student ID | Name | Role & Responsibility |
| :--- | :--- | :--- |
| **6610685239** | Parunchai Timklip |-|
| **6610685056** | Chonchanan Jitrawang |-|
| **6610685122** | Chayawat Kanjanakaew |-|
| **6610685205** | Nonthapat Boonprasith |-|
| **6610685098** | Kittidet Wichaidit |-|

---
*Drafted for CN332 Project Proposal - 2nd Revision*
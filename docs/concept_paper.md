# Concept Paper: JaiBaan Project (Digital Transformation Management System)

![Project Status](https://img.shields.io/badge/Status-Proposal_Phase-blue?style=flat-square)
![Platform](https://img.shields.io/badge/Platform-Mobile_%26_Web-orange?style=flat-square)
![License](https://img.shields.io/badge/License-GPL--3.0-green?style=flat-square)

**Course:** CN332 Object-Oriented Analysis and Design (OOAD)
**Department:** Computer Engineering, Thammasat University

---

## 1. Executive Summary

**"JaiBaan" (ใจบ้าน)** is an innovative **"Living OS"** designed to elevate high-end residential projects into a fully realized **Smart Community**.

This project aims to transform traditional Juristic Person management (manual-based) into a **Fully Digital Ecosystem**. By shifting operations and communications to a dedicated **Mobile Application** for residents and a **Web Dashboard** for administration, JaiBaan ensures convenience, transparency, and enhanced security. The system is built upon **"Human-Centric Design"** principles, seamlessly integrating technology into daily life to provide safety, warmth, and responsiveness.

---

## 2. Problem Statement

An analysis of current housing estate management reveals several critical pain points:

1.  **Visitor Congestion:** Traditional ID exchange at gates causes traffic jams and poses data privacy risks.
2.  **Fragmented Communication:** Important announcements via paper notices or general chat apps (e.g., Line Groups) are often overlooked.
3.  **Inefficient Maintenance:** Reporting repairs via phone lacks status tracking, leading to lost requests and delayed service.
4.  **Lack of Financial Transparency:** Residents struggle to access or verify the Juristic Person's financial statements.
5.  **Facility Management Issues:** The lack of real-time schedule visibility leads to double bookings and conflicts.
6.  **Disorganized Parcel Management:** Manual parcel logging is time-consuming for staff, and residents are not notified immediately, leading to unclaimed packages.
7.  **Unheard Voices:** Residents lack a formal channel for general suggestions or complaints (non-repair related), feeling that their feedback is ignored.

---

## 3. Project Objectives

1.  To develop a **Unified Platform** that seamlessly connects Residents, Juristic Persons, and Security Personnel.
2.  To integrate **AI (LPR) and Automation** to reduce manual paperwork and enhance security precision.
3.  To establish a management system that ensures **Transparency, Traceability, and Efficiency**.
4.  To apply **Object-Oriented Analysis and Design (OOAD)** principles to create a scalable and maintainable software architecture.

---

## 4. System Modules & Key Features

The system consists of two main interfaces: **JaiBaan Mobile App** (for Residents) and **Juristic Web Dashboard** (for Admin), covering 7 key modules:

### 4.1 Smart Gate & LPR Access
> *Concept: "No Card, Just Plate"*
* **License Plate Recognition:** Uses AI (YOLOv8) to scan plates and automatically open barriers.
* **Visitor Pre-registration:** Residents register guest vehicles in advance via the app.
* **Arrival Notification:** Residents receive an instant notification when their guest arrives.

### 4.2 Smart Repair Request
> *Concept: "One-Click Service"*
* **Digital Ticketing:** Report issues (e.g., plumbing, electrical) with photos and location pins.
* **Status Tracking:** Monitor repair progress in real-time (Received -> In Progress -> Completed).
* **Technician Assignment:** Admins assign tasks to technicians via the backend system.

### 4.3 Smart Facility Reservation
> *Concept: "Digital Booking"*
* **Real-time Availability:** Check schedules for facilities (Gym, Pool, Meeting Room) instantly.
* **Booking & Cancellation:** Reserve slots and cancel bookings digitally based on community rules.
* **E-Pass:** Generate a digital pass/QR code to verify access rights.

### 4.4 Financial Transparency Dashboard
> *Concept: "Trust & Verify"*
* **Financial Overview:** Residents can view intuitive graphs summarizing income and expenses.
* **Bill Management:** Automated notifications for utilities/common fees with a history of digital receipts.

### 4.5 Smart Announcement
> *Concept: "Reach Everyone"*
* **Push Notifications:** Broadcast urgent alerts (e.g., power outage, emergency) directly to resident screens.
* **News Feed:** A centralized hub for community news and updates.

### 4.6 Smart Parcel Management
> *Concept: "Safe & Sound"*
* **Rapid Entry:** Juristic staff can quickly log incoming parcels (via photo/room number).
* **Instant Alert:** Residents receive immediate push notifications when a parcel arrives.
* **Pickup Verification:** Residents view their pending parcel list and confirm pickup via the app.

### 4.7 Community Feedback System
> *Concept: "Your Voice Matters"*
* **Suggestion Box:** A dedicated channel for general suggestions, complaints, or compliments (separate from repairs).
* **Feedback Loop:** Residents can track the status of their feedback (e.g., "Acknowledged", "In Progress") to ensure responsiveness.

---

## 5. Technology Stack

### Core Architecture
* **Frontend (User):** Flutter (Cross-platform Mobile App)
* **Frontend (Admin):** React.js (Web Dashboard)
* **Backend API:** Node.js (Express Framework)
* **Database:** PostgreSQL (Managed by Supabase)

### Services & Infrastructure
* **AI Engine:** YOLOv8 (License Plate Recognition)
* **Notification:** Firebase Cloud Messaging (FCM)
* **Automation:** n8n (Workflow Automation)
* **Deployment:** Vercel (Frontend), Render (Backend)

---

## 6. Expected Benefits

1.  **Enhanced Security:** AI-driven screening reduces human error and unauthorized access.
2.  **Operational Efficiency:** Reduces manual paperwork and administrative overhead by over 60%.
3.  **Real-time Communication:** Ensures 100% reach for urgent news and parcel notifications.
4.  **Transparency & Trust:** Verifiable financial data builds stronger trust within the community.
5.  **Service Excellence:** Increases resident satisfaction through convenient services and active listening via the feedback system.

---

## 7. Project Team

| Student ID | Name | Role & Responsibility |
| :---: | :--- | :--- |
| **6610685056** | Chonchanan Jitrawang | - |
| **6610685098** | Kittidet Wichaidit | - |
| **6610685122** | Chayawat Kanjanakaew | - |
| **6610685205** | Nonthapat Boonprasith | - |
| **6610685239** | Parunchai Timklip | - |

---
*Drafted for CN332 Project Proposal*
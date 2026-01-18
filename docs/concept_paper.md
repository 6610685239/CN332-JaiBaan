# Concept Paper: JaiBaan Project (Digital Transformation Management System)

![Project Status](https://img.shields.io/badge/Status-Proposal_Phase-blue?style=flat-square)
![License](https://img.shields.io/badge/License-GPL--3.0-green?style=flat-square)

**Course:** CN332 Object-Oriented Analysis and Design  
**Department:** Computer Engineering, Thammasat University

---

## Table of Contents
1. [Overview](#1-overview)
2. [Problem Statement](#2-problem-statement)
3. [Proposed Solution](#3-proposed-solution)
4. [System Modules & Key Features](#4-system-modules--key-features)
5. [Technology Stack](#5-technology-stack)
6. [Project Team](#6-project-team)

---

## 1. Overview 

**"JaiBaan" (ใจบ้าน)** is not just a juristic management software, but a **"Living OS"** designed to elevate high-end housing estates into a **Smart Community**. By integrating **Object-Oriented Analysis and Design (OOAD)** principles with modern web technologies, JaiBaan transforms traditional manual operations (paper-based/logbooks) into a fully digital, automated, and transparent ecosystem.

Our core philosophy is **"Human-Centric Design"**, ensuring that technology feels warm, relaxing, and private—just like being at home.

## 2. Problem Statement
Residents and Juristic Persons currently face several operational pain points:
1.  **Visitor Congestion:** Guests waste time exchanging ID cards at the gate; residents worry about privacy and security.
2.  **Inefficient Maintenance:** Reporting repairs (e.g., broken pipes) after office hours is difficult. The process relies on manual coordination, causing delays and lack of tracking.
3.  **Facility Uncertainty:** Residents cannot check facility availability (e.g., swimming pool, meeting room) in real-time, leading to wasted trips.
4.  **Financial Opacity:** Residents lack visibility into how common fees are spent, relying on paper reports or annual meetings.
5.  **Delayed Communication:** Urgent announcements (e.g., water cuts) via paper notices are often missed, causing inconvenience.

## 3. Proposed Solution
**JaiBaan** offers a seamless solution by connecting the **Line Official Account (Line OA)** for residents with a **Web-based Dashboard** for Juristic staff and Technicians. The system leverages **Automation (n8n)** and **AI (LPR)** to streamline interactions.

### 3.1 Actors
* **Resident:** Uses Line OA for all living services (invite guests, report repairs, pay bills).
* **Juristic Person (Admin):** Manages the community via a centralized web dashboard.
* **Technician:** Receives jobs directly via the system and updates status in real-time.
* **Security Guard / Gate System:** Automated by AI (LPR) and QR Code scanning.

---

## 4. System Modules & Key Features

The system is designed around 5 key scenarios covering the complete living experience:

### 4.1 Smart Gate & Visitor Management
> *Feature: License Plate Recognition & Pre-Registration*

* **Pre-Registration:** Residents generate a QR Code for guests via Line OA by entering license plate and name.
* **Key Sharing:** Easily share the QR Key to guests via Line/Chat.
* **Automated Access:** Guests use the QR Code or License Plate Recognition (LPR) to open the barrier automatically.
* **Instant Alert:** Residents receive immediate Line notifications when guests arrive.
* **E-Stamp:** Paperless parking validation via the resident's mobile.

### 4.2 Smart Repair Request (Maintenance System)
> *Feature: Direct Technician Assignment*

* **Direct Request:** Residents report issues (photo/location) via Line. The system uses **Smart Categorization** (e.g., Electrical, Plumbing) to route jobs directly to the right technician without waiting for Admin approval.
* **Job Filtering & Acceptance:** Technicians see only relevant jobs and can "Lock" a job (First-come, first-served basis).
* **Real-time Tracking:** Residents track status (Pending -> En Route -> Completed).
* **Quality Control:**
    * **Proof of Work:** Technicians upload Before/After photos to close the job.
    * **Rating & Feedback:** Residents rate service (1-5 stars) immediately after completion.
    * **SLA Warning:** System alerts Admin if a job remains "Pending" > 24 hours.

### 4.3 Smart Facility Reservation
> *Feature: Real-time Booking & IoT Access*

* **Real-time Availability:** Check status of facilities (Gym, Pool, Meeting Room) via Line OA Calendar.
* **QR Access:** Booking generates a QR Code used to unlock facility doors (IoT Integration).
* **Juristic Management:** Admins can view logs, edit bookings, and cross-check with **CCTV Footage** for security.

### 4.4 Financial Transparency Dashboard
> *Feature: Visual Analytics & Digital Receipts*

* **Transparency Portal:** Residents access a dashboard via Line OA to view Juristic financial status.
* **Visual Analytics:** Graphs showing Income vs. Expenses and common fee usage breakdown.
* **Transaction History:** Verify transaction periods and view digital receipts/proof of payment.

### 4.5 Smart Announcement
> *Feature: Targeted Broadcasting*

* **Broadcast System:** Juristic staff sends urgent notifications (e.g., Urgent Repair) or General News directly to residents' Line OA.
* **History Board:** Residents can view past announcements categorized by type.

---

## 5. Technology Stack

### Core Architecture
![NodeJS](https://img.shields.io/badge/Backend-Node.js-339933?style=for-the-badge&logo=nodedotjs&logoColor=white)
![React](https://img.shields.io/badge/Frontend-React-61DAFB?style=for-the-badge&logo=react&logoColor=black)
![PostgreSQL](https://img.shields.io/badge/Database-PostgreSQL-336791?style=for-the-badge&logo=postgresql&logoColor=white)

* **Core Backend:** Node.js - *Fast, Scalable, and Real-time Ready.*
* **Frontend:** React JS - *Dynamic, Responsive, and Component-Based.*
* **Database:** PostgreSQL - *Reliable relational database management.*

### Integration & Infrastructure
![Line](https://img.shields.io/badge/Interface-Line_OA-00C300?style=for-the-badge&logo=line&logoColor=white)
![n8n](https://img.shields.io/badge/Automation-n8n-FF6584?style=for-the-badge&logo=n8n&logoColor=white)
![Vercel](https://img.shields.io/badge/Deployment-Vercel-000000?style=for-the-badge&logo=vercel&logoColor=white)

* **Messaging Interface:** LINE Official Account (Line OA) - *Primary user interface for residents.*
* **Workflow Automation:** n8n - *Middleware for connecting Line API and Backend logic.*
* **Deployment:** Vercel - *Cloud hosting and deployment platform.*

### Advanced Technology
![YOLO](https://img.shields.io/badge/AI-YOLOv8-00FFFF?style=for-the-badge&logo=opencv&logoColor=black)

* **Artificial Intelligence:** LPR (License Plate Recognition) integration for Smart Gate.

---

## 6. Project Team

| Student ID | Name | Role | GitHub |
| :--- | :--- | :--- | :--- |
| **6610685056** | Chonchanan Jitrawang | Team Member | [Link](https://github.com/SETPOINT1) |
| **6610685098** | Kittidet Wichaidit | Team Member | [Link](https://github.com/6610685098) |
| **6610685122** | Chayawat Kanjanakaew | Team Member | [Link](https://github.com/6610685122) |
| **6610685205** | Nonthapat Boonprasith | Team Member | [Link](https://github.com/6610685205) |
| **6610685239** | Parunchai Timklip | Team Member | [Link](https://github.com/6610685239) |

---
*Drafted for CN332 Project Proposal - Week 1*
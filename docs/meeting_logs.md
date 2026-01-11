#  Meeting Logs

## Meeting No. 1: Project Kick-off & Proposal Preparation
**Date:** January 11, 2026
**Time:** 15:00 - 23:00
**Location:** Online (Discord)
**Attendees:**
1. Parunchai Timklip
2. Chonchanan Jitrawang
3. Chayawat Kanjanakaew
4. Nonthapat Boonprasith
5. Kittidet Wichaidit

---

###  Agenda
1.  **Feature Finalization:** Confirm the 9 core system modules and the new "Digital Resident Lifecycle" concept.
2.  **Technology Stack Confirmation:** Finalize the tools and architecture (Django, Line OA, n8n, YOLO).
3.  **Proposal Presentation Planning:** Divide responsibilities for creating the slide deck for the first project presentation.

---

### Summary of Discussions & Decisions

#### 1. System Features & Scope
The team unanimously agreed on the **"Digital Transformation Management System"** project. The system will consist of 9 modules divided into 3 parts:
* **Part 1 (Core & Security):** Smart Member System (with real-time ownership transfer), Update Account, and Automated LPR.
* **Part 2 (Communication & Finance):** Smart Announcement, Billing, Financial Transparency, and Electricity Analytics.
* **Part 3 (Services & Maintenance):** Facility Booking and Maintenance Ticket System.

#### 2. Technology Stack

* **Backend:** Django (Python) for core logic and database management.
* **Frontend (Technologies):** HTML5, CSS3, JavaScript (Rendered via Django Templates).
* **User Interfaces:**
    * **Web Application:** For Juristic Admin dashboard.
    * **Line Official Account (Line OA):** For Residents interaction.
* **Automation:** n8n for connecting Line API with the backend.
* **AI:** YOLOv8 for the License Plate Recognition (LPR) feature.

---

### Task Assignments (Slide Deck & Concept Design)

The team has divided the responsibility for designing the concepts and drafting the proposal slides as follows:

| Member | Assigned Section / Topic | Status |
| :--- | :--- | :--- |
| Chonchanan Jitrawang | Communication & Analytics Concept: Designs the workflow for Smart Announcement and Electricity Analytics. Responsible for structuring the GitHub repository and documentation. | Completed |
| Kittidet Wichaidit | Finance & Facilities Concept: Outlines the requirements for the Financial Transparency dashboard and Facility Booking system. Compiles related presentation slides. | Completed |
| Chayawat Kanjanakaew | Maintenance Module Concept: Defines the logic and user flow for the Direct Repair system (Technician matching/Tracking). Compiles related presentation slides. | Completed |
| Nonthapat Boonprasith | Core User Management Concept: Designs the architecture for the Digital Juristic Registrar, Member System, and Account Update workflows. Compiles related presentation slides. | Completed |
| Parunchai Timklip | Security & AI Architecture: Designs the system architecture for the License Plate Recognition (LPR) and automated access control integration. | Completed |

---
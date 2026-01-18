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


## Meeting No. 2: Scope Refinement & Week 2 Requirement Analysis
**Date:** January 19, 2026
**Time:** 20:00 - 23:00
**Location:** Online (Discord)
**Attendees:**
1. Parunchai Timklip
2. Chonchanan Jitrawang
3. Chayawat Kanjanakaew
4. Nonthapat Boonprasith
5. Kittidet Wichaidit

---

### Agenda
1.  **Project Rebranding:** Renaming the project to reflect the new direction.
2.  **Scope Reduction:** Reviewing and cutting non-essential features to ensure feasibility within the timeline.
3.  **Week 2 Assignment:** Requirement Analysis using Noun-Verb extraction method.
4.  **Presentation Overhaul:** Redesigning the slide deck from scratch.
5.  **Repository Maintenance:** License change and README updates.

---

### Decisions & Summary

#### 1. Rebranding & License
* **New Project Name:** Officially renamed to **"JaiBaan Project - Digital Transformation Management System"**.
* **License:** Changed the repository license to **GPL-3.0** (GNU General Public License v3.0) to support open-source collaboration.

#### 2. Feature De-scoping (Scope Reduction)
The team decided to remove complex predictive features to focus on the core "Buy-Sell" and "Security" logic.
* **Removed:** Electricity Cost Prediction (Advanced Analytics).


#### 3. Week 2 Methodology: Noun & Verb Analysis
* Adopted the linguistic analysis approach for requirements.
* **Method:** Identifying Nouns (Candidate Classes) and Verbs (Methods/Relationships) from the problem statement.
* **Structure:** Mapping `Subject (Noun) -> Verb -> Object (Noun)` to define system interactions.

---

### Task Assignments

The workload was distributed to cover the presentation overhaul, documentation, and the Week 2 analysis requirements.

| Member | Task / Responsibility | Scope / Details | Status |
| :--- | :--- | :--- | :--- |
| **Parunchai Timklip** | **Slide Deck Redesign (Part 1)** | Responsible for the **Technical & Architecture** slides (Tech Stack, System Overview, Security/AI Logic). | Completed |
| **Nonthapat Boonprasith** | **Slide Deck Redesign (Part 2)** | Responsible for the **Business & User Flow** slides (Problem, Solution, User Journey). | Completed |
| **Nonthapat Boonprasith** | **README.md** | Rewrite the main `README.md` to reflect the new "JaiBaan" name, members, and updated features. | Completed |
| **Kittidet Wichaidit** | **Week 2 Requirement Analysis (Part 1)** | **Noun-Verb Grouping:** Extracting nouns/verbs for **Core & Security modules** (Member, Guard, LPR). Creating `Subject->Verb->Object` mappings. | Completed |
| **Chayawat Kanjanakaew** | **Week 2 Requirement Analysis (Part 2)** | **Noun-Verb Grouping:** Extracting nouns/verbs for **Services & Communication modules** (Bill, Booking, Maintenance). Creating `Subject->Verb->Object` mappings. | Completed |
| **Chonchanan Jitrawang** | **Documentation Updates** | Updating `concept_paper.md` with the new feature list and `meeting_logs.md` with today's summary. | Completed |
| **Team** | **Repository Config** | Changed LICENSE file to **GPL-3.0**. | Completed |

---
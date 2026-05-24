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

## Meeting No. 3: Class Diagram Finalization
**Date:** February 14, 2026
**Time:** 20:00 - 23:00
**Location:** Online (Discord)
**Attendees:**
1. Parunchai Timklip
2. Chonchanan Jitrawang
3. Chayawat Kanjanakaew
4. Nonthapat Boonprasith
5. Kittidet Wichaidit


### Agenda
1. Finalize Class Diagram for core modules.
2. Map Noun-Verb analysis to class responsibilities.
3. Assign owners for each domain class and prepare UML artifacts.


### Summary of Discussions & Decisions

#### 1. Class Diagram Scope
The team agreed that the Class Diagram should cover the core modules including Member/Registrar, LPR, Announcement, Billing, Facility, and Maintenance, and should specify the relationships (aggregations, associations) and responsibilities of each class.

#### 2. Design Conclusions
* Define `Announcement` as an aggregate root linked to attachments and resident notifications.
* Specify an interface/contract for LPR so backend implementations (e.g., YOLOv8) can be swapped easily.

---

### Task Assignments

| Member | Assigned Section / Topic | Status |
| :--- | :--- | :--- |
| Parunchai Timklip | Led LPR interface design and security; authored access-control specs and review notes | In Progress |
| Chonchanan Jitrawang | Produced polished UML diagrams, exported PNG/SVGs, and prepared slide-ready assets | In Progress |
| Chayawat Kanjanakaew | Modeled Maintenance & Facility domain, defined relationships, methods and example flows | In Progress |
| Nonthapat Boonprasith | Specified `Member` and `Registrar` attributes, validation rules and migration notes | In Progress |

---

## Meeting No. 4: CLI Implementation
**Date:** March 7, 2026
**Time:** 20:00 - 23:00
**Location:** Online (Discord)
**Attendees:**
1. Parunchai Timklip
2. Chonchanan Jitrawang
3. Chayawat Kanjanakaew
4. Nonthapat Boonprasith

---

### Agenda
1. Define scope and commands for the project CLI (prototype).
2. Decide technology and repo location for CLI (`cli-app`).

---

### Summary of Discussions & Decisions

* Agreed to build a lightweight CLI to assist with admin/seed tasks and basic deployment processes.


| Member | Task / Responsibility | Status |
| :--- | :--- | :--- |
| Parunchai Timklip | Defined CLI command set, integration points and overall CLI UX spec | Not Started |
| Chonchanan Jitrawang | Scaffold CLI commands and docs; drafted usage examples and help text | Not Started |
| Chayawat Kanjanakaew | Implemented initial command handlers and Gradle tasks for `cli-app` | Not Started |
| Nonthapat Boonprasith | Implement `create-user` and test seed flow; verify DB hooks | Not Started |
| Kittidet Wichaidit | Add `export-uml` integration to output diagrams and exports | Not Started |

---

**Date:** April 18, 2026
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
1. Implement Web & Mobile Login/Register interfaces.
2. Integrate Google Sign-In (OAuth) for authentication.
3. Define user flow for first-time registration vs existing members.

---

### Summary of Discussions & Decisions

* Agreed to use Google OAuth as a sign-in option to improve convenience for residents.
* Separate flows between regular `Register` (email/password) and `Sign in with Google`, while retaining ownership verification for residents.
* Defined that the `AuthService` (backend) should provide an endpoint to accept Google tokens and convert them into application sessions.

---

### Task Assignments

| Member | Task / Responsibility | Status |
| :--- | :--- | :--- |
| Parunchai Timklip | Configure Google OAuth client IDs (web + mobile), define security flows and consent screens | In Progress |
| Chonchanan Jitrawang | Implement frontend UI for Google Sign-In, design UX for first-time linking | In Progress |
| Chayawat Kanjanakaew | Implement mobile/native sign-in flows and handle platform differences | In Progress |
| Nonthapat Boonprasith | Add backend token verification, account linking and user provisioning logic | In Progress |
| Kittidet Wichaidit | Prepare test cases, QA checklist and regression tests for auth flows | In Progress |

---

## Meeting No. 6: Facility Announcement Kickoff
**Date:** April 21, 2026
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
1. Begin development of the `Facility Announcement` feature (notices related to facilities).
2. Design API, data models, and attachment upload flow.
3. Define initial UI/UX and the notification flow via Line OA.

---

### Summary of Discussions & Decisions

* Start with CRUD endpoints for `FacilityAnnouncement` with support for image/file attachments.
* Use the existing `announcementService` as a base and extend its scope for facility-related notices.
* Plan to send notifications via Line OA and display them on an admin dashboard.

---

### Task Assignments

| Member | Task / Responsibility | Status |
| :--- | :--- | :--- |
| Parunchai Timklip | Oversaw feature scope, approved data model and access control for facility announcements | In Progress |
| Chonchanan Jitrawang | API design, routes and documentation for facility announcements and attachments | In Progress |
| Chayawat Kanjanakaew | Built frontend components, upload handling and preview UX for announcements | In Progress |
| Nonthapat Boonprasith | Drafted announcement templates, content strategy and scheduling rules | In Progress |
| Kittidet Wichaidit | Integrated Line OA notification flow and tested delivery scenarios | In Progress |

---

## Meeting No. 7: Final Integration & Polish
**Date:** May 13, 2026
**Time:** 18:00 - 23:00
**Location:** Online (Discord)
**Attendees:**
1. Parunchai Timklip
2. Chonchanan Jitrawang
3. Chayawat Kanjanakaew
4. Nonthapat Boonprasith
5. Kittidet Wichaidit

---

### Agenda
1. Final integration of implemented features.
2. Bug fixes, polishing UI, and prepare final presentation/demo.
3. Verify migrations, seeds, and deployment checklist.

---

### Summary of Discussions & Decisions

* Consolidated outputs from all modules and tested end-to-end flows (register/login, announcement, facility booking, billing).
* Addressed major bugs and prepared scripts for the demo presentation.
* Assigned final polishing tasks to each member and finalized slides for the presentation.

---

### Task Assignments

### Task Assignments

| Member | Task / Responsibility | Status |
| :--- | :--- | :--- |
| Parunchai Timklip | Final integration, security checks, scripted demo scenarios and lead presenter | In Progress |
| Chonchanan Jitrawang | Polished UI, finalized slides, exported final assets and handled slide deck design | In Progress |
| Chayawat Kanjanakaew | Fixed cross-platform issues, prepared mobile demo and validated user flows | In Progress |
| Nonthapat Boonprasith | Finalized business flows, prepared narration and coordinate Q&A | In Progress |
| Kittidet Wichaidit | Ran final tests, prepared deployment checklist and verified migrations/seeds | In Progress |

---

## Meeting No. 8: Final Completion & Celebration
**Date:** May 17, 2026
**Time:** 18:00 - 21:30
**Location:** Online (Discord)
**Attendees:**
1. Parunchai Timklip
2. Chonchanan Jitrawang
3. Chayawat Kanjanakaew
4. Nonthapat Boonprasith
5. Kittidet Wichaidit

---

### Agenda
1. Confirm all features implemented and mark items as complete.
2. Run final end-to-end tests and validate deployment artifacts.
3. Prepare and rehearse the final demo; celebrate milestones.

---

### Summary of Discussions & Decisions

This meeting was the definitive wrap-up: every planned feature, fix and presentation asset was declared complete. The team ran full end-to-end verification (registration, Google sign-in, announcements, facility booking, LPR, billing flows), validated migration and seed scripts, and prepared a polished demo script. All demo scenarios passed and final slide exports were approved.

Key outcomes:
- All feature tickets moved to **Completed** in the tracker.
- End-to-end smoke tests passed across backend, web, and mobile clients.
- Deployment artifacts (migrations, seeds, CLI helpers, UML exports) verified and archived.
- Presentation deck finalized and rehearsal completed.

---

### Task Assignments (All Completed)

| Member | Completed Work / Highlights | Status |
| :--- | :--- | :--- |
| Parunchai Timklip | Led final integration and security validation; authored demo scenarios and performed the lead demo run; approved production migration runbook. | Completed |
| Chonchanan Jitrawang | Finalized UI polish, exported final slides and assets, produced final UML/diagram exports for the repo, and updated documentation. | Completed |
| Chayawat Kanjanakaew | Completed mobile demo flows, fixed cross-platform UI issues, and validated upload/attachment UX for announcements. | Completed |
| Nonthapat Boonprasith | Completed backend account linking, Google OAuth provisioning, and data migrations; verified seed/fixture flows. | Completed |
| Kittidet Wichaidit | Completed billing reconciliations, test suites, deployment checklist, and end-to-end regression runs; signed off QA. | Completed |

---

### Notes
The team celebrated the milestone and agreed to a short maintenance window schedule for post-demo follow-ups. Repository and release notes were tagged and pushed for archival.


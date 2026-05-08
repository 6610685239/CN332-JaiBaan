<div align="center">

<img src="https://readme-typing-svg.demolab.com?font=Fira+Code&size=28&duration=2500&pause=800&color=00C2FF&center=true&vCenter=true&width=900&lines=JaiBaan+Project;Living+OS+for+Smart+Community;CN332+OOAD+%E2%80%94+Thammasat+University" alt="Typing SVG" />

<br/>

A comprehensive **Living OS** solution for modernizing **Juristic Person Management**.  
Transforming manual workflows into a **Fully Digital Ecosystem** via Mobile App & Web Dashboard.

---

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg?style=flat-square)](https://www.gnu.org/licenses/gpl-3.0)
![Platform](https://img.shields.io/badge/Platform-Mobile_%26_Web-orange?style=flat-square)
![Status](https://img.shields.io/badge/Status-In_Development-green?style=flat-square)

</div>

## Course & Institution

> **Course:** CN332 Object-Oriented Analysis and Design (OOAD)  
> **Institution:** Thammasat University  

---

<div align="center">
  
## Tech Stack & Ecosystem

| **CLI Prototype** | **Mobile App** | **Web Dashboard** |
| :---: | :---: | :---: |
| ![Java](https://img.shields.io/badge/Java-ED8B00?style=for-the-badge&logo=openjdk&logoColor=white) | ![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white) | ![React](https://img.shields.io/badge/React-20232A?style=for-the-badge&logo=react&logoColor=61DAFB) |

| **Design & Prototype** | **Database** | **Backend API** |
| :---: | :---: | :---: |
| ![Figma](https://img.shields.io/badge/Figma-F24E1E?style=for-the-badge&logo=figma&logoColor=white) | ![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white) | ![NodeJS](https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=nodedotjs&logoColor=white) |

| **AI & Notification** | **Automation** | **Deployment** |
| :---: | :---: | :---: |
| ![YOLOv8](https://img.shields.io/badge/YOLOv8-00FFFF?style=for-the-badge&logo=opencv&logoColor=black) <br/> ![Firebase](https://img.shields.io/badge/Firebase_FCM-FFCA28?style=for-the-badge&logo=firebase&logoColor=black) | ![n8n](https://img.shields.io/badge/n8n-FF6D5A?style=for-the-badge&logo=n8n&logoColor=white) | ![Vercel](https://img.shields.io/badge/Vercel-000000?style=for-the-badge&logo=vercel&logoColor=white) <br/> ![Render](https://img.shields.io/badge/Render-46E3B7?style=for-the-badge&logo=render&logoColor=white) |

</div>

---

## Key Features

### Smart Gate & LPR Access
* **No Card, Just Plate:** Automated barrier access using **AI License Plate Recognition**.
* **Visitor Pre-registration:** Residents register guest vehicles via the app.

### Smart Repair Request
* **One-Click Report:** Report issues (plumbing, electric) with photos and location.
* **Real-time Tracking:** Monitor repair status from "Received" to "Completed".

### Smart Facility Reservation
* **Digital Booking:** Check availability and book facilities (Gym, Pool) instantly.
* **Cancellation System:** Flexible booking management to prevent no-shows.

### Financial Transparency
* **Dashboard:** View Juristic income/expenses graphs.
* **Digital Receipt:** Bill payment history and auto-generated receipts.

### Smart Announcement
* **Push Notifications:** Urgent alerts sent directly to residents' mobile lock screens via Firebase.

---

## Core Logic Simulation (CLI)

Before integrating with the User Interface (Mobile/Web), we have implemented a **Command Line Interface (CLI)** using **Java** to validate our **Software Architecture** and **Business Logic**.

This CLI acts as a **Prototype** to simulate real-world usage scenarios, ensuring that:
1.  **Data Flow** between different User Roles (Resident, Juristic, Technician, Guard) works seamlessly.
2.  **Polymorphism** and **OOP Principles** are correctly applied.
3.  **In-Memory DataStore** correctly manages state during the application runtime.

### Backend Structure (Java)

```text
cli-app
 └── src/
     └── com/
         └── jaibaan/
             │
             ├── Main.java                   # Application Entry Point & Routing
             │
             ├── data/                       # In-Memory Mock Database
             │   └── DataStore.java          # Centralized data storage (Lists of Objects)
             │
             ├── model/                      # Domain Models & Roles
             │   ├── role/                   # User Hierarchy
             │   │   ├── User.java           # Abstract Base Class
             │   │   ├── Resident.java       # Resident Role
             │   │   ├── JuristicPerson.java # Juristic Staff Role
             │   │   ├── Technician.java     # Technician Role
             │   │   └── SecurityGuard.java  # Security Guard Role
             │   │
             │   ├── coreEntities/           # Core Business Objects
             │   │   ├── Bill.java           # Water/Common Fee Bills
             │   │   ├── Parcel.java         # Delivery Packages
             │   │   ├── RepairTicket.java   # Maintenance Requests
             │   │   ├── Facility.java       # Common Areas (Gym/Pool)
             │   │   └── Vehicle.java        # Resident & Visitor Vehicles
             │   │
             │   └── supportEntities/        # Transaction & Log Objects
             │       ├── Announcement.java   # News Broadcasts
             │       ├── Reservation.java    # Facility Booking Records
             │       ├── VisitorLog.java     # Entry/Exit Logs
             │       └── PaymentTransaction.java # Payment Slips
             │
             └── service/                    # Business Logic (Separated by Role)
                 ├── AuthService.java        # Login & Security Logic
                 ├── ResidentService.java    # Actions for Residents
                 ├── JuristicService.java    # Actions for Juristic Staff
                 ├── TechnicianService.java  # Actions for Technicians
                 └── GuardService.java       # Actions for Security Guards
```
<div align="center">

## How to Run & Test (CLI Prototype)

<p>
  1. <b>Clone</b> the repository and open in <b>VS Code</b>.<br>
  2. Run <code>src/com/jaibaan/Main.java</code>.<br>
  3. Use the following <b>Mock Credentials</b> to test different user roles and scenarios:
</p>

<table>
  <thead>
    <tr>
      <th align="center">Role</th>
      <th align="center">Username</th>
      <th align="center">Password</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td align="center"><b>Resident</b></td>
      <td align="center"><code>pun</code></td>
      <td align="center"><code>1234</code></td>
    </tr>
    <tr>
      <td align="center"><b>Juristic</b></td>
      <td align="center"><code>admin</code></td>
      <td align="center"><code>admin</code></td>
    </tr>
    <tr>
      <td align="center"><b>Technician</b></td>
      <td align="center"><code>tech</code></td>
      <td align="center"><code>1234</code></td>
    </tr>
    <tr>
      <td align="center"><b>Security</b></td>
      <td align="center"><code>guard</code></td>
      <td align="center"><code>1234</code></td>
    </tr>
  </tbody>
</table>

</div>

---

<div align="center">
  
## Project Members

<table>
  <thead>
    <tr>
      <th align="center">Student ID</th>
      <th align="left">Name</th>
      <th align="left">Role & Responsibility</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td align="center"><b>6610685056</b></td>
      <td>Chonchanan Jitrawang</td>
      <td>-</td>
    </tr>
    <tr>
      <td align="center"><b>6610685098</b></td>
      <td>Kittidet Wichaidit</td>
      <td>-</td>
    </tr>
    <tr>
      <td align="center"><b>6610685122</b></td>
      <td>Chayawat Kanjanakaew</td>
      <td>-</td>
    </tr>
    <tr>
      <td align="center"><b>6610685205</b></td>
      <td>Nonthapat Boonprasith</td>
      <td>-</td>
    </tr>
    <tr>
      <td align="center"><b>6610685239</b></td>
      <td>Parunchai Timklip</td>
      <td>-</td>
    </tr>
  </tbody>
</table>

---

## Design & Slides

<div align="center">

<a href="https://www.figma.com/proto/n3McNAhstvGYcdtzi9dBgB/332?node-id=74-1203" target="_blank">
  <img src="https://img.shields.io/badge/Figma-GUI_Prototype-F24E1E?style=for-the-badge&logo=figma&logoColor=white" alt="Figma Prototype" />
</a>

</div>
<br>
    <a href="https://www.canva.com/design/DAG-GTz4SEA/qIboK-DglKiTsCFo_rzSeA/view?utm_content=DAG-GTz4SEA&utm_campaign=designshare&utm_medium=link2&utm_source=uniquelinks&utlId=h94c65cc7eb">
    <img src="https://img.shields.io/badge/Canva-Week_1_Concept-00C4CC?style=for-the-badge&logo=canva&logoColor=white" alt="Week 1 Slides" />
    </a>
</br>
    <a href="https://www.canva.com/design/DAG-x67lH8g/6mgE1tJihe294j1pzOv7Mg/view?utm_content=DAG-x67lH8g&utm_campaign=designshare&utm_medium=link2&utm_source=uniquelinks&utlId=he09656b283">
    <img src="https://img.shields.io/badge/Canva-Week_2_Requirements-00C4CC?style=for-the-badge&logo=canva&logoColor=white" alt="Week 2 Slides" />
    </a>
<br>
    <a href="https://www.canva.com/design/DAG_dIobgos/5u-nA9_Q7cZAXXzgKPuSrA/view?utm_content=DAG_dIobgos&utm_campaign=designshare&utm_medium=link2&utm_source=uniquelinks&utlId=h582fbb0d21">
    <img src="https://img.shields.io/badge/Canva-Week_3_use_case_diagram_&_class diagram-00C4CC?style=for-the-badge&logo=canva&logoColor=white" alt="Week 3 Slides" />
    </a>
</br>
    <a href="https://www.canva.com/design/DAHAFJmlls4/GA3YTewO8UXsmbn_-NIkRw/view?utm_content=DAHAFJmlls4&utm_campaign=designshare&utm_medium=link2&utm_source=uniquelinks&utlId=hf75cb9804c">
      <img src="https://img.shields.io/badge/Canva-Week_4_CLI_Implementation-00C4CC?style=for-the-badge&logo=canva&logoColor=white" alt="Week 4 Slides" />
    </a>

---

</div>

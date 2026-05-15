# Financial Transparency System — Design

---

## Architecture Overview

```
Web (นิติบุคคล)                    Flutter App (ลูกบ้าน)
──────────────────────              ──────────────────────
Dashboard (กราฟ + สรุป)      ←→    Dashboard (กราฟ + สรุป)
บันทึกรายการ (Form)                 รายการธุรกรรม (List)
รายการธุรกรรม (Table)               รายละเอียด + ไฟล์แนบ
                    ↕
              Node.js API
              PostgreSQL (Prisma)
```

---

## Database Schema

```prisma
model FinancialTransaction {
  id              String        @id @default(uuid())
  type            TxType        // INCOME | EXPENSE
  category        TxCategory
  amount          Decimal       @db.Decimal(12, 2)
  description     String
  transactionDate DateTime      // วันที่เกิดรายการจริง
  year            Int           // calendar year (index สำหรับ filter)
  month           Int           // 1-12 (index สำหรับ filter)
  attachments     FinancialAttachment[]
  createdBy       String        // userId นิติ
  createdAt       DateTime      @default(now())
  updatedAt       DateTime      @updatedAt

  @@index([year, month])
  @@index([type])
  @@index([category])
}

model FinancialAttachment {
  id            String               @id @default(uuid())
  transactionId String
  transaction   FinancialTransaction @relation(...)
  filename      String               // stored name
  originalName  String
  url           String
  mimeType      String
  size          Int
  createdAt     DateTime             @default(now())
}

enum TxType {
  INCOME
  EXPENSE
}

enum TxCategory {
  // INCOME
  COMMON_FEE          // ค่าส่วนกลาง
  RENTAL              // ค่าเช่าพื้นที่
  OTHER_INCOME        // รายรับอื่นๆ

  // EXPENSE
  ELECTRICITY         // ค่าไฟฟ้าส่วนกลาง
  WATER               // ค่าน้ำประปา
  MAINTENANCE         // ซ่อมบำรุง
  OTHER_EXPENSE       // รายจ่ายอื่นๆ
}
```

---

## API Endpoints

| Method | Path | หน้าที่ |
|---|---|---|
| `GET` | `/api/financial/dashboard` | ยอดสรุป + กราฟ + Pie ของปีนั้น |
| `GET` | `/api/financial/transactions` | รายการ + filter + pagination |
| `GET` | `/api/financial/transactions/:id` | รายละเอียด + attachments |
| `POST` | `/api/financial/transactions` | บันทึกรายการใหม่ |
| `PUT` | `/api/financial/transactions/:id` | แก้ไข |
| `DELETE` | `/api/financial/transactions/:id` | ลบ |
| `POST` | `/api/financial/upload` | อัพโหลดไฟล์แนบ |
| `GET` | `/api/financial/years` | ดึงปีที่มีข้อมูล (สำหรับ year selector) |

### Dashboard Response Structure
```json
{
  "year": 2025,
  "summary": {
    "totalIncome": 450000,
    "totalExpense": 312000,
    "balance": 138000
  },
  "monthlyChart": [
    { "month": 1, "income": 38000, "expense": 24000 },
    ...
  ],
  "expensePieChart": [
    { "category": "ELECTRICITY", "label": "ค่าไฟฟ้า", "amount": 120000, "percent": 38.5 },
    { "category": "WATER",       "label": "ค่าน้ำ",   "amount": 80000,  "percent": 25.6 },
    { "category": "MAINTENANCE", "label": "ซ่อมบำรุง","amount": 112000, "percent": 35.9 }
  ]
}
```

---

## File & Folder Structure (ต่อจาก monorepo เดิม)

```
backend/src/
├── routes/
│   └── financial.js            ← NEW
├── controllers/
│   └── financialController.js  ← NEW
├── services/
│   ├── financialService.js     ← NEW (CRUD + dashboard aggregation)
│   └── fileService.js          ← ใช้ร่วมกับ Announcement
└── middleware/
    ├── auth.js                  ← ของเดิม

frontend-web/src/
├── pages/
│   ├── FinancialList.jsx        ← NEW (Table เหมือน AnnouncementList)
│   └── FinancialForm.jsx        ← NEW (Form เหมือน AnnouncementForm)
├── components/
│   └── FinancialDashboard.jsx   ← NEW (กราฟ + Pie)
└── api/
    └── financial.js             ← NEW

frontend-mobile/lib/
├── pages/
│   ├── financial_list_page.dart     ← NEW
│   └── financial_detail_page.dart  ← NEW
└── widgets/
    └── financial_dashboard.dart    ← NEW (กราฟ + Pie)
```

---

## สิ่งที่ Reuse จากระบบ Announcement ได้เลย

| Component | นำมาใช้ |
|---|---|
| `announcementFileService.js` | upload/delete ไฟล์ แต่เปลี่ยน bucket เป็น Financial_file |
| `middleware/auth.js` | JWT เดิม |
| `FileUploader.jsx` | อัพโหลดไฟล์แนบ |
| `PreviewModal` concept | ดูรายละเอียด |
| `AnnouncementItemCard` style | `FinancialItemCard` |
| Prisma client | เพิ่ม model ในไฟล์เดิมได้เลย |

---

## ⚠️ ข้อสังเกตเพิ่มเติม

**1. `year` และ `month` field**
แม้ดึงจาก `transactionDate` ได้ แต่เก็บแยกไว้ใน column ทำให้ query Dashboard เร็วกว่ามาก โดยเฉพาะเมื่อข้อมูลเยอะขึ้น

**2. `balance` ไม่ควรเก็บใน DB**
คำนวณ `totalIncome - totalExpense` ใน service แทน เพราะถ้าเก็บแล้วมีการแก้ไขรายการเก่าจะ inconsistent

**3. หมวดหมู่ INCOME vs EXPENSE แยก enum หรือรวม?**
ตอนนี้เสนอให้รวม enum เดียว แต่ใน Form และ Filter จะ filter ให้แสดงเฉพาะ category ที่ตรงกับ type ที่เลือก

**4. ปีที่แล้ว (historical data)**
API `/years` จะ query `SELECT DISTINCT year` เพื่อให้ dropdown ใน app แสดงเฉพาะปีที่มีข้อมูลจริง ไม่ต้อง hardcode

---
โดย Dashboard กราฟรายรับรายจ่ายปัจจุบัน และสัดส่วนค่าใช้จ่ายแยกประเภท (Pie chart) 
รายงานเป็น calendar year

---
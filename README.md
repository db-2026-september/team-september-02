<div align="center">

<img src="https://capsule-render.vercel.app/api?type=waving&color=6C63FF&height=200&section=header&text=Database%20Design&fontSize=52&fontColor=ffffff&fontAlignY=38&desc=Group%20Project&descAlignY=58&descSize=20&descColor=c4b5fd" width="100%" alt="image"/>
<br/>

[![Made with SQL](https://img.shields.io/badge/Made%20with-SQL-6C63FF?style=for-the-badge&logo=postgresql&logoColor=white)](.)
[![Team Project](https://img.shields.io/badge/Type-Group%20Project-a78bfa?style=for-the-badge&logo=github&logoColor=white)](.)
[![Status](https://img.shields.io/badge/Status-In%20Progress-34d399?style=for-the-badge&logo=statuspage&logoColor=white)](.)

<br/>

> *Apply theoretical knowledge and practical skills to real-world scenarios.*
> *Work in teams to design and implement a fully functional database.*

<br/>

</div>

---

## 📌 Table of Contents

- [🎯 Project Goal](#-project-goal)
- [🛠️ Skills Covered](#%EF%B8%8F-skills-covered)
- [👥 Team Work](#-team-work)
- [📋 Task Variants](#-task-variants)
    - [📚 Variant 1 — Library Management System](#-variant-1----library-management-system)
    - [🏋️ Variant 2 — Fitness Center Management](#%EF%B8%8F-variant-2----fitness-center-management)
    - [🍽️ Variant 3 — Restaurant Management System](#%EF%B8%8F-variant-3----restaurant-management-system)
- [📝 Notes](#-notes)

---

## 🎯 Project Goal

<div align="center">

*Design and implement a complete, functional database system based on your assigned variant,*
*demonstrating mastery of core database concepts covered in the course.*

</div>

---

## 🛠️ Skills Covered

<div align="center">

|  #   | Skill | Description |
|:----:|:------|:------------|
| `03` | **Database Design** | Entity-relationship modeling, normalization, schema design |
| `04` | **DDL** | Data Definition Language — creating and managing database structures |
| `09` | **DML** | Data Manipulation Language — inserting, updating, and querying data |
| `10` | **Views** | Creating and using virtual tables for simplified data access |
| `11` | **DB Administration** | Managing users, permissions, and database settings |
| `12` | **Stored Procedures** | Writing reusable logic encapsulated in the database |

</div>

---

## 👥 Team Work

<div align="center">

| | |
|:---:|:---|
| 🤝 | Work is completed in **teams** |
| 🎯 | Each team is assigned a specific **variant** |
| 📅 | Coordinate roles and responsibilities **early** |
| ⚖️ | All members are expected to **contribute equally** |

</div>

---

## 📋 Task Variants

<div align="center">

*Choose one of the three variants below.*
*Each describes a real-world scenario with its own entities, requirements, and scope.*

</div>

<br/>

---

### 📚 Variant 1 — Library Management System
<div align="center">

![Level](https://img.shields.io/badge/Level-Easy-34d399?style=flat-square&logo=checkmarx&logoColor=white)
![Tables](https://img.shields.io/badge/MVP%20Tables-3-6C63FF?style=flat-square)
![Final Tables](https://img.shields.io/badge/Final%20Tables-6-a78bfa?style=flat-square)

</div>

> Design a database for a local library that manages books, members, and borrowing operations.

**What the system covers:**

- Each book has a title, authors, ISBN, publication year, and category (`fiction`, `non-fiction`, etc.)
- Library members can borrow books for a specific period
- Members can leave reviews and ratings for books they've read
- The library tracks inventory and manages multiple copies of popular books
- Members can reserve books that are currently borrowed

<details>
<summary><b>🚀 MVP Features</b></summary>

<br/>

- Basic book management — title, authors, ISBN, publication year
- Member management
- Simple borrowing operations — check-out and return
- Basic inventory tracking

</details>

<details>
<summary><b>✨ Final Version Features</b></summary>

<br/>

- Book categories and classification system
- Member reviews and ratings
- Book reservation system
- Multiple copies management
- Reading history tracking

</details>

<details>
<summary><b>🗄️ Tables & Fields</b></summary>

<br/>

**Base Tables**

| Stage | Tables |
|:-----:|:-------|
| MVP | `Members` `Books` `Borrowings` |
| Final | `Reviews` `Reservations` `BookCopies` |

**Minimum Fields**

| Stage | Fields |
|:-----:|:-------|
| MVP | Member ID, Member name, Contact info, Book title, Book ISBN, Borrowing date, Due date, Return date |
| Final | Book category, Publication year, Review text, Rating (1–5), Reservation date, Reservation status, Copy status, Reading history |

</details>

<br/>

---

### 🏋️ Variant 2 — Fitness Center Management

<div align="center">

![Level](https://img.shields.io/badge/Level-Medium-fbbf24?style=flat-square&logo=checkmarx&logoColor=white)
![Tables](https://img.shields.io/badge/MVP%20Tables-5-6C63FF?style=flat-square)
![Final Tables](https://img.shields.io/badge/Final%20Tables-9-a78bfa?style=flat-square)

</div>

> Design a database for a fitness center that manages memberships, classes, and trainers.

**What the system covers:**

- The fitness center offers membership types: `monthly`, `yearly`, `premium`
- Members can attend various fitness classes — yoga, spinning, strength training
- Trainers are assigned to specific classes and can have multiple specializations
- The center tracks attendance and manages equipment inventory
- Members can book personal training sessions with trainers
- The system tracks member progress and fitness goals

<details>
<summary><b>🚀 MVP Features</b></summary>

<br/>

- Basic membership management
- Class schedule management
- Trainer profiles and assignments
- Simple attendance tracking

</details>

<details>
<summary><b>✨ Final Version Features</b></summary>

<br/>

- Personal training session booking
- Equipment inventory management
- Member progress tracking
- Fitness goals management
- Advanced scheduling system
- Trainer specializations

</details>

<details>
<summary><b>🗄️ Tables & Fields</b></summary>

<br/>

**Base Tables**

| Stage | Tables |
|:-----:|:-------|
| MVP | `Members` `Memberships` `Trainers` `Classes` `Attendance` |
| Final | `Equipment` `PersonalTraining` `Progress` `TrainerSpecializations` |

**Minimum Fields**

| Stage | Fields |
|:-----:|:-------|
| MVP | Member ID, Member name, Membership type, Start/end dates, Trainer ID, Trainer name, Class name, Class schedule, Attendance date |
| Final | Trainer specialization, Equipment name, Equipment status, Personal training date, Progress metrics, Fitness goals, Goal achievement date, Trainer availability |

</details>

<br/>

---

### 🍽️ Variant 3 — Restaurant Management System

<div align="center">

![Level](https://img.shields.io/badge/Level-Hard-f87171?style=flat-square&logo=checkmarx&logoColor=white)
![Tables](https://img.shields.io/badge/MVP%20Tables-5-6C63FF?style=flat-square)
![Final Tables](https://img.shields.io/badge/Final%20Tables-10-a78bfa?style=flat-square)

</div>

> Design a database for a restaurant chain that manages multiple locations, menus, orders, and staff.

**What the system covers:**

- Each restaurant location has its own kitchen staff, servers, and managers
- The menu includes various categories — appetizers, main courses, desserts
- Each menu item has ingredients, preparation time, and cost
- The system tracks inventory of ingredients and manages suppliers
- Customers can place orders: `dine-in`, `takeaway`, or `delivery`
- The system handles table reservations and manages seating arrangements
- Staff schedules and shifts are managed per location
- The system tracks customer feedback and ratings

<details>
<summary><b>🚀 MVP Features</b></summary>

<br/>

- Basic restaurant location management
- Menu items and categories
- Basic order processing — dine-in and takeaway
- Staff management and basic scheduling
- Simple inventory tracking

</details>

<details>
<summary><b>✨ Final Version Features</b></summary>

<br/>

- Table reservations
- Advanced inventory management with suppliers
- Detailed staff scheduling and shift management
- Customer feedback and rating system

</details>

<details>
<summary><b>🗄️ Tables & Fields</b></summary>

<br/>

**Base Tables**

| Stage | Tables |
|:-----:|:-------|
| MVP | `Locations` `Staff` `MenuItems` `Orders` `BasicInventory` |
| Final | `Reservations` `Ingredients` `Suppliers` `CustomerFeedback` `ShiftSchedules` |

**Minimum Fields**

| Stage | Fields |
|:-----:|:-------|
| MVP | Location ID, Location address, Staff ID, Staff role, Menu item name, Menu category, Item price, Order number, Order type, Order status, Inventory count |
| Final | Reservation date/time, Table number, Ingredient name & quantity, Supplier details, Feedback rating, Feedback comment, Customer info, Shift details |

</details>

<br/>

---

## 📝 Notes

> [!TIP]
> Make sure your SQL scripts are **well-commented** and readable.

> [!IMPORTANT]
> **Test all queries and procedures** before final submission.

> [!NOTE]
> Follow the **naming conventions** discussed in class.

---

<div align="center">

<img src="https://capsule-render.vercel.app/api?type=waving&color=6C63FF&height=120&section=footer" width="100%"/>

*Good luck to all teams!* 🚀

</div>
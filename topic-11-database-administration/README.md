# Subtaks for topic 11
# Database Administration

> **As a team**, create a SQL script that defines roles, users, and permission structures for your database. This topic demonstrates your understanding of access control and security practices in PostgreSQL.

---

## 📌 Project Milestones

<table>
<tr>
<td width="50%" valign="top">

### 🟢 MVP - Minimum Viable Product

![MVP](https://img.shields.io/badge/Level-MVP-10b981?style=for-the-badge)

The required baseline - enough to demonstrate role-based access control.

- ✅ Create at least 2 distinct roles with different permissions
- ✅ Create at least 2 users assigned to those roles
- ✅ Use explicit `GRANT` statements for each role
- ✅ Provide one executable `.sql` script

</td>
<td width="50%" valign="top">

### 🟣 Final Version - Enhanced Learning

![Final](https://img.shields.io/badge/Level-Final%20Version-7c3aed?style=for-the-badge)

For teams that want stronger security design and clean maintainability.

- 🚀 Use `REVOKE` statements to explicitly restrict access
- 🚀 Add commented-out `DROP` statements for cleanup after testing
- 🚀 Explain permission design choices in comments
- 🚀 Cover table-level and schema-level granularity

</td>
</tr>
</table>

---

## 📐 Tasks
For your chosen variant, complete the following:

| # | Task | Details |
|---|------|---------|
| **01** | 👥 **Create at least 2 roles** | Define distinct roles with clearly different permission sets |
| **02** | 🔒 **Set role permissions** | At minimum: one read-only role and one read-write role |
| **03** | 👤 **Create at least 2 users** | Each user must be assigned to one of the defined roles |
| **04** | 🔑 **Use GRANT statements** | Explicitly grant permissions — do not rely on defaults |
| **05** | 🚫 **Use REVOKE where needed** | Revoke unnecessary permissions to enforce least-privilege |
| **06** | 🧹 **Document the permission design** | Add comments explaining why each role/permission exists |
| **07** | 🐘 **Ensure PostgreSQL compatibility** | Script must execute in PostgreSQL without errors |
| **08** | 🗑️ **Optional cleanup block** | Add `DROP USER` / `DROP ROLE` at the end, commented out by default |

> [!IMPORTANT]
> Roles must have **meaningfully different** permission levels — not just different names.

> [!TIP]
> Structure the script in sections: roles → users → grants → optional revokes → optional cleanup.

---

## 🎬 Additional Requirement - Video Recording

![Video](https://img.shields.io/badge/Required-~2%20min%20per%20person-f59e0b?style=for-the-badge&logo=zoom)

Each team member must record a **short video (~2 minutes)** describing:

- 🎯 The part of the solution you were responsible for
- 🧩 Challenges you faced
- 💡 How you addressed them

**Recording options:**

| Platform | How |
|----------|-----|
| 🟦 Zoom | Free version supports recording during a conference call |
| 📁 Google Drive | Upload and share the link |
| 🎞️ YouTube | Upload as **unlisted** video and share the link |

> [!WARNING]
> Video links **must be submitted** as part of the graded material with your code and documentation.

---

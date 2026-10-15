# RaceDay — Design Decisions

This document explains the reasoning behind the key structural choices in the RaceDay data model, as a companion to `erd.pdf`, `raceday-database.sql`, and `data-dictionary.md`.

---

## Why is Roles a separate table instead of a text column on Users?

Roles could have been stored as a single VARCHAR column on Users (e.g. `Role = 'Organiser'`). Instead it's a separate lookup table with a foreign key.

**Reasoning:**
- It prevents typos or inconsistent values — with a free-text column, nothing stops `'organiser'`, `'Organiser'`, and `'ORGANISER'` all existing as different values. A lookup table with a UNIQUE constraint on `RoleName` guarantees there are only ever the roles that are meant to exist.
- It matches the brief's requirement to "demonstrate understanding of role-based system design before writing any application code" — a normalized Roles table is the standard way to model role-based access control (RBAC) in a relational database.
- It's easy to extend later if a third role were ever needed, without touching every existing Users row.

---

## Why do Organiser and Participant share a single Users table?

Rather than having separate `Organisers` and `Participants` tables, both roles are stored in one `Users` table, distinguished by `RoleId`.

**Reasoning:**
- Both roles share the same core fields — name, email, password, phone number, created date. Splitting them into two tables would duplicate all of these fields and duplicate the authentication logic (login has to work the same way regardless of role).
- A single Users table also makes the two Foreign Keys on Events (`OrganiserId`) and Enrolments (`ParticipantId`) straightforward — both simply point back to `Users.UserId`, with the role check happening at the application/API level (Part 2), not the database level.

---

## Why does Categories belong to Events, not the other way round?

An Event has many Categories (e.g. a marathon event might offer a 10km, 21km, and 42km category), rather than a Category having many Events.

**Reasoning:**
- In real road events, the categories (distances/price tiers) are specific to one event — a "21km Half Marathon" category created for the Joburg City Marathon isn't reused by a different event. This is a genuine one-to-many relationship, not many-to-many.
- This also matches how Organisers will actually use the system in Part 3: create an Event first, then add its Categories underneath it — reflected directly in the nested endpoint route `/api/events/{eventId}/categories`.

---

## Why is there a separate Enrolments table instead of linking Users directly to Categories?

A Participant enrolling in a Category is modelled as its own table (`Enrolments`), rather than a direct many-to-many relationship between Users and Categories.

**Reasoning:**
- A plain many-to-many relationship (a join table with just two foreign keys) can only say *that* a link exists — it can't store anything *about* that link. Enrolments needs to store extra information: `EnrolmentDate` and `Status` (Confirmed/Cancelled). This is the standard pattern for turning a many-to-many relationship into a proper entity once it needs its own attributes.
- The UNIQUE constraint on `(ParticipantId, CategoryId)` still enforces the core business rule — a participant can't enrol in the same category twice — while allowing them to freely enrol in multiple different categories or events.

---

## Why is Results a separate table from Enrolments, with a 1:1 relationship?

Results could have been extra columns added directly onto the Enrolments table (`FinishTime`, `Position`, `Status`). Instead it's a separate table linked one-to-one via `EnrolmentId`.

**Reasoning:**
- An Enrolment and a Result don't come into existence at the same time — a participant enrols *before* the race happens, and a result only exists *after* the race happens (and only if the Organiser has captured it). Keeping them separate means an Enrolment can validly exist with no Result yet, rather than every Enrolment row carrying empty/NULL result columns from the moment it's created.
- It also reflects who's responsible for each: a Participant creates their own Enrolment, but only an Organiser is allowed to write to Results (see the API endpoint plan) — separating them into different tables makes that permission boundary cleaner to enforce in Part 2.
- The UNIQUE constraint on `Results.EnrolmentId` enforces that an enrolment can have at most one result, matching the 1:1 cardinality shown on the ERD.

---

## Why are RouteInfo and ImageUrl on Events instead of separate tables?

The project brief mentions live weather and route information, and Part 3 requires Azure Blob Storage integration for images — yet these aren't modelled as their own database tables.

**Reasoning:**
- `RouteInfo` is treated as a simple static description (terrain, water points, road closures) written by the Organiser when creating the event — a single text field is sufficient, it doesn't need its own table with relationships.
- Live weather is explicitly *not* stored in the database — it's fetched in real time from a third-party weather API when a Participant views the event in Part 3, since weather data changes constantly and storing stale weather would be actively misleading.
- `ImageUrl` stores a link to wherever the image lives in Azure Blob Storage, rather than storing the image itself in the database — this is standard practice, since databases are inefficient at storing large binary files compared to dedicated blob storage.

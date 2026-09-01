Race Day for South African resident


RaceDay, a full stack, web based, event management system, has been designed for the South African road running, walking and cycling community. It enables Event Organisers to create and manage events, categories and results; Participants can browse events, enter into categories and view their own results and registration history.

This is an individual's Portfolio of Evidence (POE) that is developed over three sections:

Part 1 — Planning: An Entity Relationship Diagram (ERD), the full API endpoint plan and a SQL Server database script. No code written for application in this part.

Roles

There are two different types of users that RaceDay accommodates:

Organiser — create, edit and delete events, manage event categories, capture results for participants, and see all event enrollments for their events.
Participant — registers and logs in, views events, enters an event by selecting a category and sees their result history.

Project Structure

RaceDay/
├── docs/                          # Part 1 planning documents
│   ├── erd.pdf                    # Entity Relationship Diagram
│   ├── api-endpoint-plan.md       # Full API endpoint plan
│   ├── raceday-database.sql       # SQL Server database script (schema + seed data)
│   ├── data-dictionary.md         # Plain-language reference for every table/column
│   └── design-decisions.md        # Reasoning behind key ERD design choices
├── .github/workflows/             # GitHub Actions CI/CD
│   └── validate-structure.yml     # Validates /docs contains the required Part 1 files
└── README.md

CI/CD

A GitHub Actions workflow runs automatically on every push to main, validating that the /docs folder exists and contains the required Part 1 deliverables (ERD, API endpoint plan, SQL script).

Latest successful run:

<img width="902" height="344" alt="image" src="https://github.com/user-attachments/assets/3cc36dad-4609-4536-ad20-aa7e8898f522" />





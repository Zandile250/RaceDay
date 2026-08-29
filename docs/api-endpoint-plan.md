# RaceDay — API Endpoint Plan (Part 1, Section B)

This table lists every endpoint planned for the RaceDay RESTful API, to be implemented in Part 2. No API code has been written at this stage — this is a plan only.

**Roles:** `Public` = no authentication required · `Participant` · `Organiser`
Where a route contains `{id}`, the resource owner must match the authenticated user for `Organiser`-restricted write actions (e.g. an Organiser can only edit their own Events/Categories).

## Authentication

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|---|---|---|---|---|---|
| POST | /api/auth/register | Register a new account as either a Participant or an Organiser | Public | `{ fullName, email, password, role }` | 201 Created — user id, email, role |
| POST | /api/auth/login | Authenticate and receive a JWT access token | Public | `{ email, password }` | 200 OK — `{ token, expiresAt, role }` |

## User Profile

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|---|---|---|---|---|---|
| GET | /api/users/me | Retrieve the logged-in user's own profile | Participant, Organiser | — | 200 OK — user profile object |
| PUT | /api/users/me | Update the logged-in user's own profile (name, phone number) | Participant, Organiser | `{ fullName, phoneNumber }` | 200 OK — updated profile object |

## Events

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|---|---|---|---|---|---|
| GET | /api/events | List all events (supports filtering by upcoming/date) | Public | — | 200 OK — array of events |
| GET | /api/events/{id} | Get full details of a single event | Public | — | 200 OK — event object (incl. categories) |
| POST | /api/events | Create a new event | Organiser | `{ eventName, description, eventDate, location, routeInfo }` | 201 Created — created event object |
| PUT | /api/events/{id} | Update an event owned by the logged-in Organiser | Organiser (owner) | `{ eventName, description, eventDate, location, routeInfo }` | 200 OK — updated event object |
| DELETE | /api/events/{id} | Delete an event owned by the logged-in Organiser | Organiser (owner) | — | 204 No Content |

## Categories

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|---|---|---|---|---|---|
| GET | /api/events/{eventId}/categories | List all categories for a given event | Public | — | 200 OK — array of categories |
| POST | /api/events/{eventId}/categories | Add a new category to an event | Organiser (owner of event) | `{ categoryName, distanceKm, price, maxParticipants }` | 201 Created — created category object |
| PUT | /api/categories/{id} | Update a category | Organiser (owner of parent event) | `{ categoryName, distanceKm, price, maxParticipants }` | 200 OK — updated category object |
| DELETE | /api/categories/{id} | Delete a category | Organiser (owner of parent event) | — | 204 No Content |

## Event Enrolments

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|---|---|---|---|---|---|
| POST | /api/enrolments | Enter an event by enrolling in a category | Participant | `{ categoryId }` | 201 Created — enrolment object |
| GET | /api/enrolments/me | View the logged-in Participant's own enrolments | Participant | — | 200 OK — array of enrolments |
| GET | /api/events/{eventId}/enrolments | View all enrolments for an event (roster) | Organiser (owner of event) | — | 200 OK — array of enrolments with participant info |
| DELETE | /api/enrolments/{id} | Cancel the logged-in Participant's own enrolment | Participant (owner) | — | 204 No Content |

## Results

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|---|---|---|---|---|---|
| POST | /api/results | Capture a result for a participant's enrolment | Organiser (owner of event) | `{ enrolmentId, finishTime, position, status }` | 201 Created — result object |
| PUT | /api/results/{id} | Update/correct a captured result | Organiser (owner of event) | `{ finishTime, position, status }` | 200 OK — updated result object |
| GET | /api/results/me | View the logged-in Participant's personal result history | Participant | — | 200 OK — array of results across events |
| GET | /api/events/{eventId}/results | View all results for an event (results/leaderboard) | Public | — | 200 OK — array of results |

## Assumptions

- JWT bearer authentication is used for role checks (`Participant` / `Organiser` claim), enforced at the API level in Part 2.
- "Route/live weather information" mentioned in the project brief is treated as a Part 3 concern — a static `RouteInfo` field is stored per event (Section A/C), while live weather is fetched from a third-party weather API at the MVC layer rather than stored in the database.
- Event photos/images (Azure Blob Storage, Part 3) are referenced via an `ImageUrl` field on `Events`, with the actual upload endpoint to be finalised when Part 3's blob storage integration is planned.
- Ownership checks (an Organiser only editing their own Events/Categories, a Participant only cancelling their own Enrolment) are enforced via the authenticated user's id, not just their role.

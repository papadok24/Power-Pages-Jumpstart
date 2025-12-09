# PawsFirst Veterinary Portal - Data Model Design

## Overview

This document outlines the complete data model design for the PawsFirst Veterinary Portal, leveraging Microsoft Dataverse's out-of-the-box (OOTB) entities alongside custom tables to create a comprehensive appointment booking system.

**Schema Prefix**: `pa911_` (custom prefix - adjust based on your environment's solution publisher)

---

## Entity-Relationship Diagram

```
┌─────────────────┐
│    Contact      │ (OOTB)
│  (Pet Owner)    │◄─────────────────────────────┐
└────────┬────────┘                              │
         │ 1                                     │ (created via Flow)
         │                                       │
         │ M                                     │
┌────────▼────────┐                     ┌────────┴────────┐
│      Pet        │                     │ Booking Request │
│   (Custom)      │                     │    (Custom)     │
│                 │                     └────────┬────────┘
│  + SharePoint   │                             │ M:1
│    Documents    │                             │
└────────┬────────┘                             │ M:1
         │ M                                    │
         │                                      │
         │                  ┌────────────────────┤
         │                  │                    │
         │                  ▼ M:1                ▼ M:1
         │         ┌──────────────────┐  ┌─────────────────┐
         │         │ Appointment Slot │◄─│    Service      │
         │         │    (Custom)      │  │   (Custom)      │
         │         └──────────────────┘  └────────┬────────┘
         │                                         │
         │                                         │ M
         │                                  ┌──────▼──────────┐
         │                                  │   Appointment  │ (OOTB Activity)
         │                                  │                │
         │                                  └────────────────┘
```

**Relationship Summary:**
- **Contact** (1) → **Pet** (M): One pet owner can have multiple pets
- **Contact** (1) ← **Booking Request** (M): Contact created via Power Automate flow from booking request
- **Pet** (M) → **Appointment** (1): Multiple appointments per pet
- **Service** (1) → **Appointment** (M): Multiple appointments per service
- **Service** (1) → **Appointment Slot** (M): Multiple slots per service
- **Appointment Slot** (1) ← **Booking Request** (M): One slot can have multiple requests (triage)
- **Pet** → **SharePoint Documents**: Pet medical documents stored in SharePoint (not a Dataverse table)

---

## Portal-Facing Tables

The PawsFirst portal exposes only a subset of tables directly to customers. This section clarifies which tables are customer-facing versus supporting/internal.

### Portal-Facing Core Tables

These tables are directly exposed to customers through Entity Lists, Entity Forms, and dashboard views:

| Table | Logical Name | Purpose | Portal Usage |
|-------|--------------|---------|--------------|
| **Contact** | `contact` | Pet owner identity | Users manage their own profile; used for authentication and data scoping |
| **Pet** | `pa911_pet` | Pet information | Customers view and manage their pets via **My Pets** list and forms; used to filter appointments |
| **Booking Request** | `pa911_bookingrequest` | Appointment booking requests | Created from public **Book Appointment** page; authenticated users view their requests on Dashboard and **My Booking Requests** page |
| **Appointment** | `appointment` | Scheduled appointments | Customers view **Active Appointments** and **Appointment History** on Dashboard and **My Appointments** page; status tracked via `pa911_servicestatus` |

### Supporting/Internal Tables

These tables support the booking and appointment flow but are **not exposed as customer-facing lists**:

| Table | Logical Name | Purpose | Portal Usage |
|-------|--------------|---------|--------------|
| **Service** | `pa911_service` | Available veterinary services | Used in booking form dropdowns and appointment displays; not shown as a standalone list to customers |
| **Appointment Slot** | `pa911_appointmentslot` | Available time slots | Used in booking form to show available times; managed by staff, not exposed as a list to customers |
| **SharePoint Documents** | N/A | Pet medical documents | Accessed via Pet detail pages and document management features; not a Dataverse table |

**Key Architectural Principle**: Customers interact with **Pets**, **Booking Requests**, and **Appointments** through dedicated portal pages. Services and Appointment Slots are reference data that support the booking workflow but remain behind-the-scenes.

---

## Entity Definitions

### Contact (OOTB Entity)

**Purpose**: Represents pet owners who are external portal users.

**Key Columns Used**:
| Column | Type | Required | Notes |
|--------|------|----------|-------|
| `contactid` | GUID | Yes | Primary key (OOTB) |
| `firstname` | String(50) | No | Owner first name |
| `lastname` | String(50) | No | Owner last name |
| `emailaddress1` | String(100) | Yes | Login email (Power Pages auth) |
| `telephone1` | String(50) | No | Primary phone |
| `address1_line1` | String(250) | No | Street address |
| `address1_city` | String(80) | No | City |
| `address1_stateorprovince` | String(50) | No | State/Province |
| `address1_postalcode` | String(20) | No | ZIP/Postal code |

**Power Pages Considerations**:
- Used for portal authentication (external users)
- Table permissions must be configured for Contact read/write access
- Users can only see/edit their own Contact record

**Portal Usage**:
- Contact records serve as the identity for external portal users
- Users manage their profile information via the **Profile** page
- Contact ID is used to scope all related data (Pets, Appointments, Booking Requests) to the current user
- Contact is created automatically when users register or are invited via Power Automate flow

**Reference**: [Contact entity documentation](https://learn.microsoft.com/en-us/dynamics365/customer-engagement/web-api/contact)

---

### Pet (Custom Entity)

**Purpose**: Stores pet information linked to their owners.

**Table Name**: `pa911_pet`  
**Display Name**: Pet  
**Plural Name**: Pets

**Columns**:

| Column | Logical Name | Type | Required | Max Length | Notes |
|--------|--------------|------|----------|------------|-------|
| Primary Key | `pa911_petid` | GUID | Yes | - | Auto-generated |
| Primary Name | `pa911_name` | Single Line of Text | Yes | 100 | Pet's name |
| Species | `pa911_species` | Choice | Yes | - | See Choice Values below |
| Breed | `pa911_breed` | Single Line of Text | No | 100 | Pet breed |
| Date of Birth | `pa911_dateofbirth` | Date Only | No | - | Pet's birth date |
| Weight | `pa911_weight` | Decimal | No | - | Weight in pounds (precision: 2) |
| Owner | `pa911_petowner` | Lookup (Contact) | Yes | - | Pet owner relationship |
| Medical Notes | `pa911_notes` | Multiple Lines of Text | No | 2000 | Medical history/notes |

**Choice Values - Species** (`pa911_species`):
- `144400000` - Dog
- `144400001` - Cat
- `144400002` - Bird
- `144400003` - Reptile
- `144400004` - Other

**Relationships**:
- **Many-to-One** with Contact (`pa911_petowner` → `contactid`)
- **One-to-Many** with Appointment (via `regardingobjectid` polymorphic lookup)
- **SharePoint Document Management**: Pet medical documents stored in SharePoint document locations (not a Dataverse table)

**SharePoint Integration**:
- The Pet table is enabled for SharePoint document management
- Documents are stored in SharePoint, not in Dataverse
- Documents are associated with Pet records via SharePoint document locations
- See [SharePoint Integration Guide](../day-3/sharepoint-integration.md) for setup instructions

**Table Permissions** (Power Pages):
- **Read**: Users can read pets where `pa911_petowner` = current user's Contact
- **Write**: Users can create/update pets where `pa911_petowner` = current user's Contact
- **Delete**: Optional - typically restricted to prevent accidental deletion

**Portal Usage**:
- Customers view and manage their pets via the **My Pets** page (Entity List)
- Pet records are displayed on the **Dashboard** in a summary section
- Pet information is used to filter and display appointments (only appointments for the user's pets are shown)
- Pet detail pages allow customers to view pet information and upload/manage documents via SharePoint integration
- Pet records are created and edited through Entity Forms accessible from the My Pets list

---

### Service (Custom Entity)

**Purpose**: Defines veterinary services offered by the clinic.

**Table Name**: `pa911_service`  
**Display Name**: Service  
**Plural Name**: Services

**Columns**:

| Column | Logical Name | Type | Required | Max Length | Notes |
|--------|--------------|------|----------|------------|-------|
| Primary Key | `pa911_serviceid` | GUID | Yes | - | Auto-generated |
| Primary Name | `pa911_name` | Single Line of Text | Yes | 100 | Service name |
| Description | `pa911_description` | Multiple Lines of Text | No | 2000 | Service description |
| Duration | `pa911_duration` | Whole Number | Yes | - | Duration in minutes |
| Price | `pa911_price` | Currency | No | - | Service cost |
| Status | `statecode` | Status | Yes | - | Active/Inactive (standard Dataverse status field) |

**Relationships**:
- **One-to-Many** with Appointment (`pa911_serviceid` → `appointment.pa911_service`)

**Table Permissions** (Power Pages):
- **Read**: Public read access (all authenticated users)
- **Write**: Restricted to internal users/admins only
- **Delete**: Restricted to admins only

**Example Services**:
- Annual Checkup (30 minutes, $75)
- Vaccination (15 minutes, $45)
- Grooming (60 minutes, $50)
- Surgery Consultation (45 minutes, $150)

**Portal Usage**:
- **Not exposed as a customer-facing list** - Services are reference data used in booking workflows
- Services appear in dropdowns on the **Book Appointment** form (anonymous booking request)
- Service information is displayed within appointment views and detail pages
- Service data is managed by staff in model-driven apps, not by customers in the portal

---

### Appointment (OOTB Activity Entity)

**Purpose**: Individual appointment instances for pet visits.

**Table Name**: `appointment` (OOTB)  
**Display Name**: Appointment

**OOTB Columns Used**:

| Column | Logical Name | Type | Required | Notes |
|--------|--------------|------|----------|-------|
| Primary Key | `activityid` | GUID | Yes | OOTB primary key |
| Subject | `subject` | Single Line of Text | Yes | Appointment title |
| Scheduled Start | `scheduledstart` | Date and Time | Yes | Appointment start time |
| Scheduled End | `scheduledend` | Date and Time | Yes | Appointment end time |
| Regarding | `regardingobjectid` | Lookup (Polymorphic) | No | Links to Pet entity |

**Custom Columns Added**:

| Column | Logical Name | Type | Required | Notes |
|--------|--------------|------|----------|-------|
| Pet | `pa911_pet` | Lookup (Pet) | Yes | Which pet the appointment is for |
| Service | `pa911_service` | Lookup (Service) | Yes | Service being performed |
| Service Status | `pa911_servicestatus` | Choice | Yes | **Primary status field** - Used for all appointment status tracking |

**Note**: This implementation uses only the custom `pa911_servicestatus` field for status tracking. The OOTB `statecode` and `statuscode` fields are not used.

**Custom Choice Values - Service Status** (`pa911_servicestatus`):
- `144400000` - Requested
- `144400001` - Confirmed
- `144400002` - Completed
- `144400003` - Cancelled
- `144400004` - No-Show

**Relationships**:
- **Many-to-One** with Pet (`pa911_pet` → `pa911_pet.pa911_petid`)
- **Many-to-One** with Pet (via `regardingobjectid` polymorphic lookup)
- **Many-to-One** with Service (`pa911_service` → `pa911_service.pa911_serviceid`)

**Table Permissions** (Power Pages):
- **Read**: Users can read appointments where `pa911_pet.pa911_petowner` = current user's Contact
- **Write**: Users can create appointments for their own pets; update/cancel their own appointments
- **Delete**: Typically restricted (use cancellation status instead)

**Portal Usage**:
- Customers view appointments through **My Appointments** page with two views:
  - **My Active Appointments**: Shows appointments with status "Requested" or "Confirmed" (`pa911_servicestatus`)
  - **My Appointment History**: Shows completed, cancelled, or no-show appointments
- Active appointments are displayed on the **Dashboard** in a summary section
- Appointment status is tracked via the `pa911_servicestatus` field (not the OOTB status fields)
- Customers can view appointment details including scheduled time, pet, service, and status

**Reference**: [Appointment entity documentation](https://learn.microsoft.com/en-us/dynamics365/customer-engagement/web-api/appointment)

---

---

### Appointment Slot (Custom Entity)

**Purpose**: Pre-defined available time slots that administrators can manage for booking requests.

**Table Name**: `pa911_appointmentslot`  
**Display Name**: Appointment Slot  
**Plural Name**: Appointment Slots

**Columns**:

| Column | Logical Name | Type | Required | Max Length | Notes |
|--------|--------------|------|----------|------------|-------|
| Primary Key | `pa911_appointmentslotid` | GUID | Yes | - | Auto-generated |
| Primary Name | `pa911_name` | Single Line of Text | Yes | 100 | Auto-generated display (e.g., "Dec 15, 2025 10:00 AM") |
| Start Time | `pa911_starttime` | Date and Time | Yes | - | Slot start time |
| End Time | `pa911_endtime` | Date and Time | Yes | - | Slot end time |
| Service | `pa911_service` | Lookup (Service) | Yes | - | Which service this slot is for |
| Is Available | `pa911_isavailable` | Two Options | Yes | - | Default: Yes (true), set to No when booked |
| Status | `statecode` | Status | Yes | - | Active/Inactive (standard Dataverse status field) |

**Relationships**:
- **Many-to-One** with Service (`pa911_service` → `pa911_service.pa911_serviceid`)
- **One-to-Many** with Booking Request (`pa911_appointmentslotid` → `pa911_bookingrequest.pa911_appointmentslot`)

**Table Permissions** (Power Pages):
- **Read**: Public read access (all users, including anonymous) - needed for booking form
- **Write**: Restricted to internal users/admins only
- **Delete**: Restricted to admins only

**Usage Notes**:
- Administrators create slots in advance based on service availability
- Slots are filtered by Service type on the booking form
- When a booking request is approved, the slot's `pa911_isavailable` is set to false
- Slots can be reused if a booking is cancelled

**Portal Usage**:
- **Not exposed as a customer-facing list** - Appointment Slots are reference data used in booking workflows
- Slots appear in dropdowns on the **Book Appointment** form, filtered by selected Service
- Slot availability is managed by staff in model-driven apps
- Customers do not see or manage slots directly; they only select from available slots when booking

---

### Booking Request (Custom Entity)

**Purpose**: Anonymous intake form submissions for appointment booking triage.

**Table Name**: `pa911_bookingrequest`  
**Display Name**: Booking Request  
**Plural Name**: Booking Requests

**Columns**:

| Column | Logical Name | Type | Required | Max Length | Notes |
|--------|--------------|------|----------|------------|-------|
| Primary Key | `pa911_bookingrequestid` | GUID | Yes | - | Auto-generated |
| Primary Name | `pa911_name` | Single Line of Text | Yes | 100 | Auto-generated request number |
| First Name | `pa911_firstname` | Single Line of Text | Yes | 50 | Requester first name |
| Last Name | `pa911_lastname` | Single Line of Text | Yes | 50 | Requester last name |
| Email | `pa911_email` | Single Line of Text | Yes | 100 | Requester email (used for portal invitation) |
| Phone | `pa911_phone` | Single Line of Text | No | 50 | Contact phone number |
| Pet Name | `pa911_petname` | Single Line of Text | Yes | 100 | Pet's name |
| Pet Species | `pa911_petspecies` | Choice | Yes | - | See Choice Values below |
| Pet Notes | `pa911_petnotes` | Multiple Lines of Text | No | 2000 | Additional pet information |
| Service | `pa911_service` | Lookup (Service) | Yes | - | Requested service |
| Preferred Slot | `pa911_appointmentslot` | Lookup (Appointment Slot) | Yes | - | Selected time slot |
| Request Status | `pa911_requeststatus` | Choice | Yes | - | See Choice Values below |
| Contact | `pa911_contact` | Lookup (Contact) | No | - | Linked after portal invitation (set by Power Automate) |
| Status | `statecode` | Status | Yes | - | Active/Inactive (standard Dataverse status field) |

**Choice Values - Pet Species** (`pa911_petspecies`):
- `144400000` - Dog
- `144400001` - Cat
- `144400002` - Bird
- `144400003` - Reptile
- `144400004` - Other

**Choice Values - Request Status** (`pa911_requeststatus`):
- `144400000` - Pending (default)
- `144400001` - Approved
- `144400002` - Rejected

**Relationships**:
- **Many-to-One** with Service (`pa911_service` → `pa911_service.pa911_serviceid`)
- **Many-to-One** with Appointment Slot (`pa911_appointmentslot` → `pa911_appointmentslot.pa911_appointmentslotid`)
- **Many-to-One** with Contact (`pa911_contact` → `contact.contactid`) - Set after invitation

**Table Permissions** (Power Pages):
- **Read**: Anonymous create access (for booking form), authenticated users can read their own requests
- **Write**: Anonymous create access (for booking form), authenticated users can update their own requests
- **Delete**: Restricted to admins only (use status changes instead)

**Workflow**:
1. Anonymous user submits booking request via Entity Form
2. Power Automate flow triggers on record creation
3. Flow creates/finds Contact record using email
4. Flow sends portal invitation email
5. Flow links Contact to Booking Request
6. Flow sets Request Status to "Pending"
7. Staff reviews and approves/rejects in model-driven app
8. Approved requests can be converted to actual Appointments

**Portal Usage**:
- Booking Requests are created from the public **Book Appointment** page (anonymous Entity Form)
- After a Contact is linked (via Power Automate flow), authenticated users can view their booking requests
- Customers see their booking requests on the **Dashboard** in a summary section
- Full list of booking requests is available on the **My Booking Requests** page (Entity List)
- Booking requests show status (Pending, Approved, Rejected) and can be viewed in detail
- The `pa911_contact` lookup links the request to the user's Contact record after invitation

---

## Table Permissions Summary

### Recommended Power Pages Table Permissions

| Entity | Read Scope | Write Scope | Delete Scope |
|--------|------------|-------------|--------------|
| **Contact** | Self | Self | None |
| **Pet** | Own pets | Own pets | None (or Self) |
| **Service** | All | None | None |
| **Appointment Slot** | All (including anonymous) | None | None |
| **Booking Request** | Anonymous create, Self read | Anonymous create, Self write | None |
| **Appointment** | Own pets' appointments | Own pets' appointments | None |
| **SharePoint Documents** | Own pets' documents (via SharePoint) | Own pets' documents (via SharePoint) | Own pets' documents (via SharePoint) |

**Scope Definitions**:
- **Self**: User can only access their own record
- **Own pets**: User can access records where the pet's owner matches the current user
- **All**: All authenticated users can read
- **None**: No access for portal users (admin-only)

---

## Implementation Checklist

### Phase 1: Core Tables
- [x] Create Pet custom table with all columns
- [x] Create Service custom table with all columns
- [ ] Create Appointment Slot custom table with all columns
- [ ] Create Booking Request custom table with all columns
- [x] Configure Choice/OptionSet values for all entities
- [ ] Enable SharePoint document management for Pet table

### Phase 2: Relationships
- [x] Create Pet → Contact relationship (Many-to-One)
- [x] Create Appointment → Pet relationship (Many-to-One, custom column)
- [x] Create Appointment → Service relationship (Many-to-One, custom column)
- [ ] Create Appointment Slot → Service relationship (Many-to-One)
- [ ] Create Booking Request → Service relationship (Many-to-One)
- [ ] Create Booking Request → Appointment Slot relationship (Many-to-One)
- [ ] Create Booking Request → Contact relationship (Many-to-One)

### Phase 3: Appointment Extensions
- [x] Add custom columns to Appointment entity
- [x] Configure Appointment → Pet polymorphic relationship (regardingobjectid)

### Phase 4: Power Pages Configuration
- [ ] Configure table permissions for all entities
- [ ] Test portal user access and data isolation
- [ ] Verify relationship navigation works in portal context

---

## Sample Data Scenarios

### Scenario 1: New Pet Owner Registration
1. Contact record created via Power Pages registration
2. Pet owner logs in and creates Pet records
3. Pet owner books first Appointment
4. Pet owner uploads vaccination documents to SharePoint (associated with Pet record)

### Scenario 2: Appointment History
1. Portal displays list of Appointments filtered by current user's pets
2. Each appointment shows related Service information
3. User can drill into appointment details

### Scenario 3: Anonymous Booking Request
1. Anonymous user visits site and selects a Service
2. Available Appointment Slots are displayed (filtered by Service)
3. User fills out Booking Request form with pet and contact details
4. Power Automate flow triggers on Booking Request creation
5. Flow creates/finds Contact record using email
6. Flow sends portal invitation email
7. Flow links Contact to Booking Request and sets status to "Pending"
8. Staff reviews request in model-driven app (triage)
9. Invited user receives email, registers/logs in to portal
10. User can view their booking status via authenticated Entity List

---

## References

- [Microsoft Dataverse Entity Reference](https://learn.microsoft.com/en-us/dynamics365/customer-engagement/web-api/entitytypes)
- [Power Pages Table Permissions](https://learn.microsoft.com/en-us/power-pages/configure/table-permissions)
- [Contact Entity Documentation](https://learn.microsoft.com/en-us/dynamics365/customer-engagement/web-api/contact)
- [Appointment Entity Documentation](https://learn.microsoft.com/en-us/dynamics365/customer-engagement/web-api/appointment)


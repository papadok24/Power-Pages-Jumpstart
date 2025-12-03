# PawsFirst Veterinary Portal - Data Model Design

## Overview

This document outlines the complete data model design for the PawsFirst Veterinary Portal, leveraging Microsoft Dataverse's out-of-the-box (OOTB) entities alongside custom tables to create a comprehensive appointment booking system.

**Schema Prefix**: `pa911_` (custom prefix - adjust based on your environment's solution publisher)

---

## Entity-Relationship Diagram

```
┌─────────────────┐
│    Contact      │ (OOTB)
│  (Pet Owner)    │
└────────┬────────┘
         │ 1
         │
         │ M
┌────────▼────────┐       ┌─────────────────┐
│      Pet        │       │    Service      │
│   (Custom)      │       │   (Custom)      │
└────────┬────────┘       └────────┬────────┘
         │ M                       │ 1
         │                         │
         │                         │ M
         │                  ┌──────▼──────────┐
         │                  │   Appointment  │ (OOTB Activity)
         │                  │                │
         │                  └──────┬─────────┘
         │                         │
         │                         │ M
         │                  ┌──────▼──────────┐
         │                  │ RecurringAppt   │ (OOTB Activity)
         │                  │    Master       │
         │                  └─────────────────┘
         │
         │ M
┌────────▼────────┐
│    Document     │
│   (Custom)      │
└─────────────────┘
```

**Relationship Summary:**
- **Contact** (1) → **Pet** (M): One pet owner can have multiple pets
- **Pet** (M) → **Appointment** (1): Multiple appointments per pet
- **Service** (1) → **Appointment** (M): Multiple appointments per service
- **Pet** (M) → **Document** (1): Multiple documents per pet

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
- **One-to-Many** with Document (`pa911_petid` → `pa911_document.pa911_pet`)

**Table Permissions** (Power Pages):
- **Read**: Users can read pets where `pa911_petowner` = current user's Contact
- **Write**: Users can create/update pets where `pa911_petowner` = current user's Contact
- **Delete**: Optional - typically restricted to prevent accidental deletion

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
| Status | `statecode` | Status | Yes | Open (0) / Completed (1) / Cancelled (2) |
| Status Reason | `statuscode` | Status Reason | Yes | See Status Reasons below |

**Custom Columns Added**:

| Column | Logical Name | Type | Required | Notes |
|--------|--------------|------|----------|-------|
| Pet | `pa911_pet` | Lookup (Pet) | Yes | Which pet the appointment is for |
| Service | `pa911_service` | Lookup (Service) | Yes | Service being performed |
| Service Status | `pa911_servicestatus` | Choice | Yes | Custom status tracking |

**Status Reasons** (OOTB `statuscode`):
- **Open**: Requested (1), Confirmed (2), Arrived (3)
- **Completed**: Completed (4)
- **Cancelled**: Cancelled (5), No-Show (6)

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
- **Many-to-One** with RecurringAppointmentMaster (`seriesid` → `activityid`)

**Table Permissions** (Power Pages):
- **Read**: Users can read appointments where `pa911_pet.pa911_petowner` = current user's Contact
- **Write**: Users can create appointments for their own pets; update/cancel their own appointments
- **Delete**: Typically restricted (use cancellation status instead)

**Reference**: [Appointment entity documentation](https://learn.microsoft.com/en-us/dynamics365/customer-engagement/web-api/appointment)

---

### RecurringAppointmentMaster (OOTB Activity Entity)

**Purpose**: Manages recurring appointment series (e.g., monthly grooming, quarterly checkups).

**Table Name**: `recurringappointmentmaster` (OOTB)  
**Display Name**: Recurring Appointment Series

**Key Columns**:

| Column | Logical Name | Type | Required | Notes |
|--------|--------------|------|----------|-------|
| Primary Key | `activityid` | GUID | Yes | OOTB primary key |
| Subject | `subject` | Single Line of Text | Yes | Series title |
| Pattern Start Date | `patternstartdate` | Date and Time | Yes | First occurrence date |
| Pattern End Date | `patternenddate` | Date and Time | No | Last occurrence (null = no end) |
| Recurrence Pattern | `recurrencepatterntype` | Choice | Yes | Daily, Weekly, Monthly, Yearly |
| Interval | `interval` | Whole Number | Yes | Frequency (e.g., every 2 weeks) |
| Days of Week | `daysofweekmask` | Integer | No | Bitmask for weekly patterns |
| Day of Month | `dayofmonth` | Integer | No | For monthly patterns |
| Regarding | `regardingobjectid` | Lookup (Polymorphic) | No | Links to Pet entity |

**Custom Columns Added**:

| Column | Logical Name | Type | Required | Notes |
|--------|--------------|------|----------|-------|
| Pet | `pa911_pet` | Lookup (Pet) | Yes | Which pet the series is for |
| Service | `pa911_service` | Lookup (Service) | Yes | Service for recurring appointments |

**Recurrence Pattern Types** (`recurrencepatterntype`):
- `0` - Daily
- `1` - Weekly
- `2` - Monthly
- `3` - Yearly

**How It Works**:
- Dataverse automatically creates individual `appointment` instances based on the recurrence pattern
- Uses partial expansion model (creates instances in phases, not all at once)
- Individual instances can be modified without affecting the series
- Deleting the master deletes all associated instances

**Table Permissions** (Power Pages):
- **Read**: Users can read recurring appointments where `pa911_pet.pa911_petowner` = current user's Contact
- **Write**: Users can create recurring appointments for their own pets
- **Delete**: Users can delete their own recurring appointment series

**Reference**: See `docs/day-1/recurring-appointments.md` for detailed implementation guide.

---

### Document (Custom Entity)

**Purpose**: Stores file attachments related to pets.

**Table Name**: `pa911_document`  
**Display Name**: Document  
**Plural Name**: Documents

**Columns**:

| Column | Logical Name | Type | Required | Max Length | Notes |
|--------|--------------|------|----------|------------|-------|
| Primary Key | `pa911_documentid` | GUID | Yes | - | Auto-generated |
| Primary Name | `pa911_name` | Single Line of Text | Yes | 200 | Document name |
| Document Type | `pa911_type` | Choice | Yes | - | See Choice Values below |
| Pet | `pa911_pet` | Lookup (Pet) | No | - | Related pet |

**Choice Values - Document Type** (`pa911_type`):
- `144400000` - Vaccination Record
- `144400001` - Medical History
- `144400002` - Insurance Document
- `144400003` - Prescription
- `144400004` - Lab Results
- `144400005` - Other

**Relationships**:
- **Many-to-One** with Pet (`pa911_pet` → `pa911_pet.pa911_petid`)

**Table Permissions** (Power Pages):
- **Read**: Users can read documents where `pa911_pet.pa911_petowner` = current user's Contact
- **Write**: Users can create/update documents for their own pets
- **Delete**: Users can delete their own documents

---

## Table Permissions Summary

### Recommended Power Pages Table Permissions

| Entity | Read Scope | Write Scope | Delete Scope |
|--------|------------|-------------|--------------|
| **Contact** | Self | Self | None |
| **Pet** | Own pets | Own pets | None (or Self) |
| **Service** | All | None | None |
| **Appointment** | Own pets' appointments | Own pets' appointments | None |
| **RecurringAppointmentMaster** | Own pets' recurring | Own pets' recurring | Own pets' recurring |
| **Document** | Own pets' documents | Own pets' documents | Own pets' documents |

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
- [x] Create Document custom table with all columns
- [x] Configure Choice/OptionSet values for all entities

### Phase 2: Relationships
- [x] Create Pet → Contact relationship (Many-to-One)
- [x] Create Appointment → Pet relationship (Many-to-One, custom column)
- [x] Create Appointment → Service relationship (Many-to-One, custom column)
- [x] Create Document → Pet relationship (Many-to-One)
- [x] Create RecurringAppointmentMaster → Pet relationship (Many-to-One, custom column)
- [x] Create RecurringAppointmentMaster → Service relationship (Many-to-One, custom column)

### Phase 3: Appointment Extensions
- [x] Add custom columns to Appointment entity
- [x] Configure Appointment → Pet polymorphic relationship (regardingobjectid)
- [x] Test RecurringAppointmentMaster integration

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
4. Pet owner uploads vaccination Document

### Scenario 2: Recurring Appointment Setup
1. Pet owner creates RecurringAppointmentMaster for monthly grooming
2. Dataverse generates Appointment instances automatically
3. Pet owner can modify individual instances if needed

### Scenario 3: Appointment History
1. Portal displays list of Appointments filtered by current user's pets
2. Each appointment shows related Service information
3. User can drill into appointment details

---

## References

- [Microsoft Dataverse Entity Reference](https://learn.microsoft.com/en-us/dynamics365/customer-engagement/web-api/entitytypes)
- [Power Pages Table Permissions](https://learn.microsoft.com/en-us/power-pages/configure/table-permissions)
- [Recurring Appointments Guide](./recurring-appointments.md)
- [Contact Entity Documentation](https://learn.microsoft.com/en-us/dynamics365/customer-engagement/web-api/contact)
- [Appointment Entity Documentation](https://learn.microsoft.com/en-us/dynamics365/customer-engagement/web-api/appointment)


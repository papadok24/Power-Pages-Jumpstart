# PawsFirst Veterinary Portal - Data Model Design

## Overview

This document outlines the complete data model design for the PawsFirst Veterinary Portal, leveraging Microsoft Dataverse's out-of-the-box (OOTB) entities alongside custom tables to create a comprehensive appointment booking system.

**Schema Prefix**: `cr_` (custom prefix - adjust based on your environment's solution publisher)

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
- **Contact** (M) → **Document** (1): Multiple documents per owner
- **Appointment** (M) → **Document** (1): Multiple documents per appointment

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

**Table Name**: `cr_pet`  
**Display Name**: Pet  
**Plural Name**: Pets

**Columns**:

| Column | Logical Name | Type | Required | Max Length | Notes |
|--------|--------------|------|----------|------------|-------|
| Primary Key | `cr_petid` | GUID | Yes | - | Auto-generated |
| Primary Name | `cr_name` | Single Line of Text | Yes | 100 | Pet's name |
| Species | `cr_species` | Choice | Yes | - | See Choice Values below |
| Breed | `cr_breed` | Single Line of Text | No | 100 | Pet breed |
| Date of Birth | `cr_dateofbirth` | Date Only | No | - | Pet's birth date |
| Weight | `cr_weight` | Decimal | No | - | Weight in pounds (precision: 2) |
| Owner | `cr_ownerid` | Lookup (Contact) | Yes | - | Pet owner relationship |
| Medical Notes | `cr_notes` | Multiple Lines of Text | No | 2000 | Medical history/notes |

**Choice Values - Species** (`cr_species`):
- `100000000` - Dog
- `100000001` - Cat
- `100000002` - Bird
- `100000003` - Reptile
- `100000004` - Other

**Relationships**:
- **Many-to-One** with Contact (`cr_ownerid` → `contactid`)
- **One-to-Many** with Appointment (via `regardingobjectid` polymorphic lookup)
- **One-to-Many** with Document (`cr_petid` → `cr_document.cr_petid`)

**Table Permissions** (Power Pages):
- **Read**: Users can read pets where `cr_ownerid` = current user's Contact
- **Write**: Users can create/update pets where `cr_ownerid` = current user's Contact
- **Delete**: Optional - typically restricted to prevent accidental deletion

---

### Service (Custom Entity)

**Purpose**: Defines veterinary services offered by the clinic.

**Table Name**: `cr_service`  
**Display Name**: Service  
**Plural Name**: Services

**Columns**:

| Column | Logical Name | Type | Required | Max Length | Notes |
|--------|--------------|------|----------|------------|-------|
| Primary Key | `cr_serviceid` | GUID | Yes | - | Auto-generated |
| Primary Name | `cr_name` | Single Line of Text | Yes | 100 | Service name |
| Description | `cr_description` | Multiple Lines of Text | No | 2000 | Service description |
| Duration | `cr_duration` | Whole Number | Yes | - | Duration in minutes |
| Price | `cr_price` | Currency | No | - | Service cost |
| Is Active | `cr_isactive` | Two Options | Yes | - | Active/Inactive toggle |

**Relationships**:
- **One-to-Many** with Appointment (`cr_serviceid` → `cr_appointment.cr_serviceid`)

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
| Pet | `cr_petid` | Lookup (Pet) | Yes | Which pet the appointment is for |
| Service | `cr_serviceid` | Lookup (Service) | Yes | Service being performed |
| Appointment Status | `cr_appointmentstatus` | Choice | Yes | Custom status tracking |

**Status Reasons** (OOTB `statuscode`):
- **Open**: Requested (1), Confirmed (2), Arrived (3)
- **Completed**: Completed (4)
- **Cancelled**: Cancelled (5), No-Show (6)

**Custom Choice Values - Appointment Status** (`cr_appointmentstatus`):
- `100000000` - Requested
- `100000001` - Confirmed
- `100000002` - Completed
- `100000003` - Cancelled
- `100000004` - No-Show

**Relationships**:
- **Many-to-One** with Pet (`cr_petid` → `cr_pet.cr_petid`)
- **Many-to-One** with Pet (via `regardingobjectid` polymorphic lookup)
- **Many-to-One** with Service (`cr_serviceid` → `cr_service.cr_serviceid`)
- **Many-to-One** with RecurringAppointmentMaster (`seriesid` → `activityid`)
- **One-to-Many** with Document (`activityid` → `cr_document.cr_appointmentid`)

**Table Permissions** (Power Pages):
- **Read**: Users can read appointments where `cr_petid.cr_ownerid` = current user's Contact
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
| Pet | `cr_petid` | Lookup (Pet) | Yes | Which pet the series is for |
| Service | `cr_serviceid` | Lookup (Service) | Yes | Service for recurring appointments |

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
- **Read**: Users can read recurring appointments where `cr_petid.cr_ownerid` = current user's Contact
- **Write**: Users can create recurring appointments for their own pets
- **Delete**: Users can delete their own recurring appointment series

**Reference**: See `docs/day-1/recurring-appointments.md` for detailed implementation guide.

---

### Document (Custom Entity)

**Purpose**: Stores file attachments related to pets, owners, and appointments.

**Table Name**: `cr_document`  
**Display Name**: Document  
**Plural Name**: Documents

**Columns**:

| Column | Logical Name | Type | Required | Max Length | Notes |
|--------|--------------|------|----------|------------|-------|
| Primary Key | `cr_documentid` | GUID | Yes | - | Auto-generated |
| Primary Name | `cr_name` | Single Line of Text | Yes | 200 | Document name |
| Document Type | `cr_documenttype` | Choice | Yes | - | See Choice Values below |
| Pet | `cr_petid` | Lookup (Pet) | No | - | Related pet (at least one relationship required) |
| Owner | `cr_ownerid` | Lookup (Contact) | No | - | Related owner |
| Appointment | `cr_appointmentid` | Lookup (Appointment) | No | - | Related visit/appointment |
| Upload Date | `cr_uploaddate` | Date and Time | Yes | - | Upload timestamp |
| File Attachment | `cr_file` | File | Yes | - | Actual file (stored in SharePoint) |

**Choice Values - Document Type** (`cr_documenttype`):
- `100000000` - Vaccination Record
- `100000001` - Medical History
- `100000002` - Insurance Document
- `100000003` - Prescription
- `100000004` - Lab Results
- `100000005` - Other

**Relationships**:
- **Many-to-One** with Pet (`cr_petid` → `cr_pet.cr_petid`)
- **Many-to-One** with Contact (`cr_ownerid` → `contact.contactid`)
- **Many-to-One** with Appointment (`cr_appointmentid` → `appointment.activityid`)

**Business Rules**:
- At least one relationship (Pet, Owner, or Appointment) must be populated
- File storage handled via SharePoint integration (Day 3 topic)

**Table Permissions** (Power Pages):
- **Read**: Users can read documents where:
  - `cr_petid.cr_ownerid` = current user's Contact, OR
  - `cr_ownerid` = current user's Contact, OR
  - `cr_appointmentid.cr_petid.cr_ownerid` = current user's Contact
- **Write**: Users can create/update documents for their own pets/owners/appointments
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
| **Document** | Own pets/owners/appointments | Own pets/owners/appointments | Own pets/owners/appointments |

**Scope Definitions**:
- **Self**: User can only access their own record
- **Own pets**: User can access records where the pet's owner matches the current user
- **All**: All authenticated users can read
- **None**: No access for portal users (admin-only)

---

## Implementation Checklist

### Phase 1: Core Tables
- [ ] Create Pet custom table with all columns
- [ ] Create Service custom table with all columns
- [ ] Create Document custom table with all columns
- [ ] Configure Choice/OptionSet values for all entities

### Phase 2: Relationships
- [ ] Create Pet → Contact relationship (Many-to-One)
- [ ] Create Appointment → Pet relationship (Many-to-One, custom column)
- [ ] Create Appointment → Service relationship (Many-to-One, custom column)
- [ ] Create Document → Pet relationship (Many-to-One)
- [ ] Create Document → Contact relationship (Many-to-One)
- [ ] Create Document → Appointment relationship (Many-to-One)

### Phase 3: Appointment Extensions
- [ ] Add custom columns to Appointment entity
- [ ] Configure Appointment → Pet polymorphic relationship (regardingobjectid)
- [ ] Test RecurringAppointmentMaster integration

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
4. Documents can be attached to specific appointment instances

### Scenario 3: Appointment History
1. Portal displays list of Appointments filtered by current user's pets
2. Each appointment shows related Service and Document count
3. User can drill into appointment details and view associated documents

---

## References

- [Microsoft Dataverse Entity Reference](https://learn.microsoft.com/en-us/dynamics365/customer-engagement/web-api/entitytypes)
- [Power Pages Table Permissions](https://learn.microsoft.com/en-us/power-pages/configure/table-permissions)
- [Recurring Appointments Guide](./recurring-appointments.md)
- [Contact Entity Documentation](https://learn.microsoft.com/en-us/dynamics365/customer-engagement/web-api/contact)
- [Appointment Entity Documentation](https://learn.microsoft.com/en-us/dynamics365/customer-engagement/web-api/appointment)


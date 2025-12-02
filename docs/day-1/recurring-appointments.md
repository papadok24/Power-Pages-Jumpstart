# Recurring Appointments - OOTB Integration Guide

## Overview

Microsoft Dataverse provides out-of-the-box (OOTB) support for recurring appointments through the **RecurringAppointmentMaster** entity. This guide explains how to leverage this functionality in the PawsFirst Veterinary Portal for scenarios like monthly grooming, quarterly checkups, or annual vaccinations.

---

## What is RecurringAppointmentMaster?

The `RecurringAppointmentMaster` entity is a special activity entity in Dataverse that:
- Defines a **recurrence pattern** (daily, weekly, monthly, yearly)
- Automatically generates individual **Appointment** instances based on the pattern
- Manages the lifecycle of appointment series (create, update, delete)
- Supports **exceptions** (modifying individual instances without affecting the series)

**Key Benefit**: No custom code required - Dataverse handles instance creation and management automatically.

---

## Entity Structure

### RecurringAppointmentMaster (OOTB)

**Table Name**: `recurringappointmentmaster`  
**Entity Type**: Activity (inherits from `activitypointer`)

### Core Columns

| Column | Logical Name | Type | Required | Description |
|--------|--------------|------|----------|-------------|
| Primary Key | `activityid` | GUID | Yes | Unique identifier for the series |
| Subject | `subject` | String | Yes | Title of the recurring appointment |
| Pattern Start Date | `patternstartdate` | DateTime | Yes | Date/time of first occurrence |
| Pattern End Date | `patternenddate` | DateTime | No | Date/time of last occurrence (null = no end) |
| Recurrence Pattern | `recurrencepatterntype` | Choice | Yes | Type of recurrence (see below) |
| Interval | `interval` | Integer | Yes | Frequency (e.g., every 2 weeks) |
| Days of Week Mask | `daysofweekmask` | Integer | No | Bitmask for weekly patterns |
| Day of Month | `dayofmonth` | Integer | No | Day number for monthly patterns |
| Regarding | `regardingobjectid` | Lookup | No | Polymorphic lookup (links to Pet) |

### Custom Columns for PawsFirst

| Column | Logical Name | Type | Required | Description |
|--------|--------------|------|----------|-------------|
| Pet | `cr_petid` | Lookup (Pet) | Yes | Which pet the series is for |
| Service | `cr_serviceid` | Lookup (Service) | Yes | Service for recurring appointments |

---

## Recurrence Pattern Types

### 1. Daily (`recurrencepatterntype = 0`)

**Use Case**: Daily medication reminders, daily check-ins

**Required Fields**:
- `patternstartdate`: Start date/time
- `patternenddate`: End date (optional)
- `interval`: Every N days (e.g., 1 = daily, 2 = every other day)

**Example**: Daily medication reminder
```json
{
  "subject": "Daily Medication - Fluffy",
  "patternstartdate": "2024-01-01T09:00:00Z",
  "patternenddate": "2024-01-31T09:00:00Z",
  "recurrencepatterntype": 0,
  "interval": 1
}
```

### 2. Weekly (`recurrencepatterntype = 1`)

**Use Case**: Weekly grooming, bi-weekly checkups

**Required Fields**:
- `patternstartdate`: Start date/time
- `patternenddate`: End date (optional)
- `interval`: Every N weeks (e.g., 1 = weekly, 2 = bi-weekly)
- `daysofweekmask`: Bitmask for days of week

**Days of Week Mask Values**:
- Sunday: `1` (2^0)
- Monday: `2` (2^1)
- Tuesday: `4` (2^2)
- Wednesday: `8` (2^3)
- Thursday: `16` (2^4)
- Friday: `32` (2^5)
- Saturday: `64` (2^6)

**Combining Days**: Add values together (e.g., Monday + Wednesday = 2 + 8 = 10)

**Example**: Weekly grooming every Monday
```json
{
  "subject": "Weekly Grooming - Fluffy",
  "patternstartdate": "2024-01-01T10:00:00Z",
  "patternenddate": null,
  "recurrencepatterntype": 1,
  "interval": 1,
  "daysofweekmask": 2
}
```

### 3. Monthly (`recurrencepatterntype = 2`)

**Use Case**: Monthly checkups, monthly medication refills

**Required Fields**:
- `patternstartdate`: Start date/time
- `patternenddate`: End date (optional)
- `interval`: Every N months (e.g., 1 = monthly, 3 = quarterly)
- `dayofmonth`: Day of month (1-31)

**Example**: Monthly checkup on the 15th
```json
{
  "subject": "Monthly Checkup - Fluffy",
  "patternstartdate": "2024-01-15T14:00:00Z",
  "patternenddate": null,
  "recurrencepatterntype": 2,
  "interval": 1,
  "dayofmonth": 15
}
```

### 4. Yearly (`recurrencepatterntype = 3`)

**Use Case**: Annual vaccinations, yearly checkups

**Required Fields**:
- `patternstartdate`: Start date/time
- `patternenddate`: End date (optional)
- `interval`: Every N years (typically 1)

**Example**: Annual vaccination
```json
{
  "subject": "Annual Vaccination - Fluffy",
  "patternstartdate": "2024-03-15T10:00:00Z",
  "patternenddate": null,
  "recurrencepatterntype": 3,
  "interval": 1
}
```

---

## Partial Expansion Model

Dataverse uses a **partial expansion model** to efficiently manage recurring appointment instances:

### How It Works

1. **Initial Creation**: When a `RecurringAppointmentMaster` is created, Dataverse does NOT immediately create all appointment instances.

2. **Phased Expansion**: Instances are created in phases:
   - **First Phase**: Creates instances for the next 2 months
   - **Subsequent Phases**: Creates additional instances as time progresses
   - **Look-ahead Window**: Always maintains ~2 months of future instances

3. **Benefits**:
   - Prevents database bloat for long-running series
   - Handles infinite series (no end date) efficiently
   - Automatically manages instance lifecycle

### Implications for Power Pages

- **Querying Future Appointments**: Use `appointment` entity queries, not `recurringappointmentmaster`
- **Instance Availability**: Only expanded instances appear in queries
- **No Manual Expansion**: Dataverse handles expansion automatically

---

## Creating Recurring Appointments

### Via Power Pages Web API

**Endpoint**: `/api/data/v9.2/recurringappointmentmasters`

**Example: Monthly Grooming**

```javascript
// Create recurring appointment via Portals Web API
const recurringAppointment = {
  "subject": "Monthly Grooming - Fluffy",
  "patternstartdate": "2024-01-15T10:00:00Z",
  "patternenddate": null, // No end date
  "recurrencepatterntype": 2, // Monthly
  "interval": 1, // Every month
  "dayofmonth": 15, // 15th of each month
  "scheduledstart": "2024-01-15T10:00:00Z",
  "scheduledend": "2024-01-15T11:00:00Z", // 1 hour duration
  "cr_petid@odata.bind": "/cr_pets(<pet-guid>)",
  "cr_serviceid@odata.bind": "/cr_services(<service-guid>)",
  "regardingobjectid@odata.bind": "/cr_pets(<pet-guid>)"
};

fetch('/api/data/v9.2/recurringappointmentmasters', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify(recurringAppointment)
})
.then(response => response.json())
.then(data => {
  console.log('Recurring appointment created:', data);
});
```

### Via Liquid Template

**Note**: Liquid templates cannot directly create recurring appointments via Web API in Power Pages. Use client-side JavaScript or server-side plugins instead.

---

## Querying Recurring Appointments

### Get Recurring Appointment Series

**FetchXML Example**:

```liquid
{% fetchxml recurring_appointments %}
  <fetch>
    <entity name="recurringappointmentmaster">
      <attribute name="activityid" />
      <attribute name="subject" />
      <attribute name="patternstartdate" />
      <attribute name="patternenddate" />
      <attribute name="recurrencepatterntype" />
      <filter>
        <condition attribute="cr_petid" operator="eq" value="{{ pet.cr_petid }}" />
      </filter>
    </entity>
  </fetch>
{% endfetchxml %}

{% for series in recurring_appointments.results.entities %}
  <div>
    <h3>{{ series.subject }}</h3>
    <p>Starts: {{ series.patternstartdate | date: "%B %d, %Y" }}</p>
  </div>
{% endfor %}
```

### Get Individual Appointment Instances

**Important**: Query the `appointment` entity, not `recurringappointmentmaster`. Instances are linked via `seriesid`.

**FetchXML Example**:

```liquid
{% fetchxml upcoming_appointments %}
  <fetch>
    <entity name="appointment">
      <attribute name="activityid" />
      <attribute name="subject" />
      <attribute name="scheduledstart" />
      <attribute name="scheduledend" />
      <filter>
        <condition attribute="cr_petid" operator="eq" value="{{ pet.cr_petid }}" />
        <condition attribute="scheduledstart" operator="ge" value="{{ 'now' | date: '%Y-%m-%dT%H:%M:%SZ' }}" />
      </filter>
      <order attribute="scheduledstart" />
    </entity>
  </fetch>
{% endfetchxml %}
```

---

## Managing Recurring Appointments

### Update a Series

**Updating the master** propagates changes to all future instances (unless exceptions exist).

**Example: Change time for all future appointments**

```javascript
// Update recurring appointment series
const seriesId = '<recurring-appointment-guid>';

fetch(`/api/data/v9.2/recurringappointmentmasters(${seriesId})`, {
  method: 'PATCH',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    "scheduledstart": "2024-02-15T14:00:00Z", // New time
    "scheduledend": "2024-02-15T15:00:00Z"
  })
});
```

### Create Exceptions

**Exceptions** allow modifying individual instances without affecting the series.

**Steps**:
1. Query the specific `appointment` instance
2. Update the instance directly
3. Dataverse automatically marks it as an exception

**Example: Reschedule one appointment**

```javascript
// Update individual appointment instance
const appointmentId = '<appointment-instance-guid>';

fetch(`/api/data/v9.2/appointments(${appointmentId})`, {
  method: 'PATCH',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    "scheduledstart": "2024-02-20T10:00:00Z", // Different date
    "scheduledend": "2024-02-20T11:00:00Z"
  })
});
```

### Delete a Series

**Deleting the master** removes all associated instances.

**Example**:

```javascript
// Delete recurring appointment series
const seriesId = '<recurring-appointment-guid>';

fetch(`/api/data/v9.2/recurringappointmentmasters(${seriesId})`, {
  method: 'DELETE'
});
```

**Warning**: This action cannot be undone. All instances will be deleted.

---

## Power Pages Considerations

### Table Permissions

Configure table permissions for `recurringappointmentmaster`:

- **Read**: Users can read recurring appointments where `cr_petid.cr_ownerid` = current user's Contact
- **Write**: Users can create recurring appointments for their own pets
- **Delete**: Users can delete their own recurring appointment series

### User Experience

**Best Practices**:

1. **Display Series Summary**: Show the recurring appointment master with pattern details
2. **Show Upcoming Instances**: Query `appointment` entity to show next N occurrences
3. **Allow Exception Creation**: Let users reschedule individual instances
4. **Clear Communication**: Explain that modifying the series affects all future appointments

### Sample Portal Page Flow

1. **View Recurring Appointments**: List all recurring series for user's pets
2. **Create Recurring Appointment**: Form to create new series (pattern, frequency, service)
3. **View Upcoming Instances**: Show next 5-10 appointment instances
4. **Manage Series**: Edit series details or delete series
5. **Handle Exceptions**: Reschedule individual instances

---

## Common Scenarios

### Scenario 1: Monthly Grooming

**Pattern**: Every month on the 15th at 10:00 AM

```json
{
  "subject": "Monthly Grooming - {{ pet.name }}",
  "patternstartdate": "2024-01-15T10:00:00Z",
  "recurrencepatterntype": 2,
  "interval": 1,
  "dayofmonth": 15,
  "scheduledstart": "2024-01-15T10:00:00Z",
  "scheduledend": "2024-01-15T11:00:00Z"
}
```

### Scenario 2: Quarterly Checkup

**Pattern**: Every 3 months on the 1st at 2:00 PM

```json
{
  "subject": "Quarterly Checkup - {{ pet.name }}",
  "patternstartdate": "2024-01-01T14:00:00Z",
  "recurrencepatterntype": 2,
  "interval": 3,
  "dayofmonth": 1,
  "scheduledstart": "2024-01-01T14:00:00Z",
  "scheduledend": "2024-01-01T14:30:00Z"
}
```

### Scenario 3: Weekly Medication Pickup

**Pattern**: Every Monday at 9:00 AM

```json
{
  "subject": "Weekly Medication Pickup - {{ pet.name }}",
  "patternstartdate": "2024-01-01T09:00:00Z",
  "recurrencepatterntype": 1,
  "interval": 1,
  "daysofweekmask": 2, // Monday
  "scheduledstart": "2024-01-01T09:00:00Z",
  "scheduledend": "2024-01-01T09:15:00Z"
}
```

---

## Limitations and Considerations

### Limitations

1. **Attachments**: Cannot attach files directly to `RecurringAppointmentMaster`. Attach to individual `appointment` instances or related entities (Pet, Contact).

2. **Complex Patterns**: Limited to standard recurrence patterns. Custom patterns (e.g., "first Monday of every month") require workarounds.

3. **Time Zone**: `patternstartdate` uses UTC. Consider time zone handling for portal users.

4. **Instance Limits**: Very long series (100+ years) may have performance implications.

### Best Practices

1. **Set Reasonable End Dates**: Avoid infinite series when possible (set `patternenddate`).

2. **Monitor Instance Count**: For very frequent patterns, consider archiving old instances.

3. **User Education**: Explain how recurring appointments work to portal users.

4. **Error Handling**: Handle cases where instances cannot be created (e.g., invalid dates).

---

## References

- [Create Recurring Appointment Series](https://learn.microsoft.com/en-us/power-apps/developer/data-platform/create-recurring-appointment-series-instance-exception)
- [Update Recurring Appointments](https://learn.microsoft.com/en-us/power-apps/developer/data-platform/update-recurring-appointment)
- [Recurring Appointment Partial Expansion Model](https://learn.microsoft.com/en-us/power-apps/developer/data-platform/recurring-appointment-partial-expansion-model)
- [RecurringAppointmentMaster Entity Reference](https://learn.microsoft.com/en-us/dynamics365/customer-engagement/web-api/recurringappointmentmaster)
- [Data Model Design](./data-model.md)


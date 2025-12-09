# Lists and Views - OOTB Entity Lists

## Overview

This guide covers creating and configuring Entity Lists in Power Pages to display Dataverse data to portal users. Entity Lists provide out-of-the-box (OOTB) functionality for showing filtered, searchable, and paginated data.

**Prerequisites**:
- Complete [Data Model Design](../day-1/data-model.md) - Tables and relationships created
- Understand Dataverse views concept

**Note**: Table permissions will be configured as part of this guide. Basic table permission concepts are covered in the Data Model Design document.

---

## What are Entity Lists?

Entity Lists are Power Pages components that display Dataverse data in a table format. They provide:

- **Automatic Filtering**: Based on table permissions and Dataverse views
- **Search Functionality**: Built-in search across displayed columns
- **Pagination**: Automatic pagination for large datasets
- **Sorting**: Click column headers to sort
- **Actions**: View details, edit, delete (based on permissions)
- **Responsive Design**: Mobile-friendly table layout

---

## Step 1: Create Dataverse Views

Before creating an Entity List, you need Dataverse views that define what data to display. The PawsFirst portal uses three customer-facing views: **My Pets**, **My Booking Requests**, and **My Appointments** (with Active and History variants).

**Note**: Each Dataverse table has an active view OOTB (out-of-the-box). You can use the default active view or create custom views. Filters are automatically applied based on table permissions configured in the portal, so you don't need to add filters to the views themselves.

### View for Pets

1. Navigate to **Power Apps** → **Dataverse** → **Tables** → **Pet** (`pa911_pet`)
2. Go to **Views** tab
3. Click **New view** → **Public view**
4. Configure view:

#### Columns

| Column | Width | Sort |
|--------|-------|------|
| Pet Name (pa911_name) | 150 | Ascending |
| Species (pa911_species) | 100 | - |
| Breed (pa911_breed) | 120 | - |
| Date of Birth (pa911_dateofbirth) | 120 | - |
| Weight (pa911_weight) | 100 | - |

5. **Save** the view as: **My Pets**

### View for Booking Requests

1. Navigate to **Power Apps** → **Dataverse** → **Tables** → **Booking Request** (`pa911_bookingrequest`)
2. Go to **Views** tab
3. Click **New view** → **Public view**
4. Configure view:

#### Columns

| Column | Width | Sort |
|--------|-------|------|
| Request Number (pa911_name) | 150 | Ascending |
| Pet Name (pa911_petname) | 120 | - |
| Service (pa911_service) | 150 | - |
| Preferred Slot (pa911_appointmentslot) | 200 | - |
| Request Status (pa911_requeststatus) | 120 | - |
| Created On (createdon) | 120 | Descending |

5. **Save** the view as: **My Booking Requests**

**Note**: Table permissions will automatically filter records to show only the current user's booking requests (via the `pa911_contact` lookup field set by Power Automate after invitation).

### View for Active Appointments

1. Navigate to **Power Apps** → **Dataverse** → **Tables** → **Appointment** (`appointment`)
2. Go to **Views** tab
3. Click **New view** → **Public view**
4. Configure view:

#### Columns

| Column | Width | Sort |
|--------|-------|------|
| Subject (subject) | 200 | - |
| Scheduled Start (scheduledstart) | 150 | Ascending |
| Scheduled End (scheduledend) | 150 | - |
| Pet (pa911_pet) | 120 | - |
| Service (pa911_service) | 150 | - |
| Service Status (pa911_servicestatus) | 120 | - |

5. **Save** the view as: **My Active Appointments**

**Note**: Table permissions will automatically filter records to show only appointments for the current user's pets. You can optionally filter by service status in the view if you want to separate active and completed appointments.

### View for Appointment History (Optional)

1. Navigate to **Power Apps** → **Dataverse** → **Tables** → **Appointment** (`appointment`)
2. Go to **Views** tab
3. Click **New view** → **Public view**
4. Configure view with the same columns as **My Active Appointments**
5. **Save** the view as: **My Appointment History**

**Note**: Table permissions will automatically filter records to show only appointments for the current user's pets. You can optionally filter by service status in the view to show completed (`144400002`), cancelled (`144400003`), or no-show (`144400004`) appointments.

**Note**: You can create a single "All Appointments" view if you prefer to let users filter by status in the Entity List interface, or create separate views for different statuses.

---

## Step 2: Configure Table Permissions

Entity Lists respect table permissions. Ensure permissions are configured correctly for the three customer-facing tables. See the [Data Model Design](../day-1/data-model.md) for complete table permission details.

### Pet Permissions

1. Navigate to **Power Pages** → **Your Site** → **Security** → **Table Permissions**
2. Create or verify permission:

| Setting | Value |
|---------|-------|
| **Name** | Pet - User Read Own |
| **Table** | Pet (`pa911_pet`) |
| **Web Role** | Authenticated Users |
| **Scope** | Contact |
| **Privileges** | Read, Write |
| **Contact Scope** | Current user's Contact (via `pa911_petowner` field) |

This allows users to read and manage pets where they are the owner.

### Booking Request Permissions

1. Navigate to **Power Pages** → **Your Site** → **Security** → **Table Permissions**
2. Create or verify permission:

| Setting | Value |
|---------|-------|
| **Name** | Booking Request - User Read Own |
| **Table** | Booking Request (`pa911_bookingrequest`) |
| **Web Role** | Authenticated Users |
| **Scope** | Contact |
| **Privileges** | Read, Write |
| **Contact Scope** | Current user's Contact (via `pa911_contact` field) |

This allows users to read and update their own booking requests (after the Contact is linked via Power Automate).

**Note**: You also need an anonymous permission for the booking form:
- **Web Role**: Anonymous Users
- **Scope**: Global
- **Privileges**: Create only

### Appointment Permissions

1. Navigate to **Power Pages** → **Your Site** → **Security** → **Table Permissions**
2. Create or verify permission:

| Setting | Value |
|---------|-------|
| **Name** | Appointment - User Read Own Pets |
| **Table** | Appointment (`appointment`) |
| **Web Role** | Authenticated Users |
| **Scope** | Parent |
| **Privileges** | Read, Write |
| **Parent Table** | Pet (`pa911_pet`) |
| **Contact Scope** | Current user's Contact (via `pa911_pet.pa911_petowner`) |

This allows users to read and manage appointments for their own pets.

### Internal-Only Tables (Reference)

**Service** and **Appointment Slot** tables require read permissions for anonymous/authenticated users (for booking form dropdowns), but these are **not exposed as customer-facing Entity Lists**. Any views created for these tables are for staff use in model-driven apps, not for the customer portal.

---

## Step 3: Create Entity Lists

Create Entity Lists for each of the three customer-facing tables. Each list will be used on dedicated portal pages.

### My Pets List

1. Navigate to **Power Pages** → **Your Site** → **Content** → **Entity Lists**
2. Click **New** to create a new list
3. Configure basic settings:

| Setting | Value |
|---------|-------|
| **Name** | My Pets |
| **Table** | Pet (`pa911_pet`) |
| **View** | My Pets (the view you created) |

4. Configure display options:

| Setting | Value | Notes |
|---------|-------|-------|
| **Enable Search** | Yes | Allow users to search their pets |
| **Records Per Page** | 10 | Adjust based on data volume |
| **Show View Selector** | No | Hide view dropdown (using single view) |
| **Show Bulk Actions** | No | Disable bulk operations |
| **Enable Sorting** | Yes | Allow column sorting |

5. Configure actions:
   - **View Details**: Enable (opens pet detail page)
   - **Edit**: Enable (users can edit their pets)
   - **Delete**: Optional (typically disabled to prevent accidental deletion)

6. Click **Save**

### My Booking Requests List

1. Navigate to **Power Pages** → **Your Site** → **Content** → **Entity Lists**
2. Click **New** to create a new list
3. Configure basic settings:

| Setting | Value |
|---------|-------|
| **Name** | My Booking Requests |
| **Table** | Booking Request (`pa911_bookingrequest`) |
| **View** | My Booking Requests (the view you created) |

4. Configure display options (same as My Pets list above)
5. Configure actions:
   - **View Details**: Enable
   - **Edit**: Enable (users can update their requests)
   - **Delete**: Disable (use status changes instead)

6. Click **Save**

### My Appointments List

1. Navigate to **Power Pages** → **Your Site** → **Content** → **Entity Lists**
2. Click **New** to create a new list
3. Configure basic settings:

| Setting | Value |
|---------|-------|
| **Name** | My Appointments |
| **Table** | Appointment (`appointment`) |
| **View** | My Active Appointments (default view) |

4. Configure display options (same as above)
5. If you created both Active and History views, enable **Show View Selector** so users can switch between them
6. Configure actions:
   - **View Details**: Enable
   - **Edit**: Enable (users can update/cancel appointments)
   - **Delete**: Disable (use cancellation status instead)

7. Click **Save**

---

## Step 4: Create Detail Pages (Optional)

For "View Details" actions, create detail pages for each entity type. These pages will display Entity Forms in read-only or edit mode.

### Pet Detail Page

1. Navigate to **Power Pages** → **Your Site** → **Content** → **Web Pages**
2. Create new page:
   - **Name**: Pet Details
   - **Partial URL**: `pet-details`
   - **Parent Page**: My Pets (or appropriate parent)

3. Add Entity Form:
   ```liquid
   {% entityform name:"Pet View Form" mode:"readonly" %}
   ```

4. Configure Entity Form:
   - **Table**: Pet (`pa911_pet`)
   - **Mode**: Read-only or Edit (based on requirements)
   - **Fields**: Display pet fields (name, species, breed, date of birth, weight, notes)

### Booking Request Detail Page

1. Create new page:
   - **Name**: Booking Request Details
   - **Partial URL**: `booking-request-details`
   - **Parent Page**: My Booking Requests

2. Add Entity Form:
   ```liquid
   {% entityform name:"Booking Request View Form" mode:"readonly" %}
   ```

3. Configure Entity Form:
   - **Table**: Booking Request (`pa911_bookingrequest`)
   - **Mode**: Read-only or Edit
   - **Fields**: Display booking request fields

### Appointment Detail Page

1. Create new page:
   - **Name**: Appointment Details
   - **Partial URL**: `appointment-details`
   - **Parent Page**: My Appointments

2. Add Entity Form:
   ```liquid
   {% entityform name:"Appointment View Form" mode:"readonly" %}
   ```

3. Configure Entity Form:
   - **Table**: Appointment (`appointment`)
   - **Mode**: Read-only or Edit
   - **Fields**: Display appointment fields (subject, scheduled start/end, pet, service, status)

---

## Step 5: Create Portal Pages and Add Lists

Create dedicated pages for each Entity List. These pages will be part of the authenticated customer portal area.

### My Pets Page

1. Navigate to **Power Pages** → **Your Site** → **Content** → **Web Pages**
2. Create new page:
   - **Name**: My Pets
   - **Partial URL**: `my-pets`
   - **Parent Page**: Dashboard (or appropriate authenticated parent)

3. Add Entity List to page:
   ```liquid
   <div class="container mt-4">
       <h1>My Pets</h1>
       <p class="lead">Manage your pets' information and medical records.</p>
       
       {% entitylist name:"My Pets" %}
       
       <div class="mt-3">
           <a href="/pet-form" class="btn btn-primary">Add New Pet</a>
       </div>
   </div>
   ```

4. **Page Permissions**: 
   - Allow **Authenticated Users** to view
   - Require login to access

### My Booking Requests Page

1. Create new page:
   - **Name**: My Booking Requests
   - **Partial URL**: `my-booking-requests`
   - **Parent Page**: Dashboard

2. Add Entity List:
   ```liquid
   <div class="container mt-4">
       <h1>My Booking Requests</h1>
       <p class="lead">View and manage your appointment booking requests.</p>
       
       {% entitylist name:"My Booking Requests" %}
       
       <div class="mt-3">
           <a href="/book-appointment" class="btn btn-primary">Request New Appointment</a>
       </div>
   </div>
   ```

3. **Page Permissions**: 
   - Allow **Authenticated Users** to view
   - Require login to access

### My Appointments Page

1. Create new page:
   - **Name**: My Appointments
   - **Partial URL**: `my-appointments`
   - **Parent Page**: Dashboard

2. Add Entity List:
   ```liquid
   <div class="container mt-4">
       <h1>My Appointments</h1>
       <p class="lead">View your active appointments and appointment history.</p>
       
       {% entitylist name:"My Appointments" %}
   </div>
   ```

3. **Page Permissions**: 
   - Allow **Authenticated Users** to view
   - Require login to access

### Dashboard Page with Summary Lists

The Dashboard is the default landing page for authenticated users. It displays summary sections for each entity type with "View all" links.

1. Create new page:
   - **Name**: Dashboard
   - **Partial URL**: `dashboard`
   - **Parent Page**: Home (or root)

2. Add summary sections using Liquid and Entity Lists:
   ```liquid
   <div class="container mt-4">
       <h1>Welcome, {{ user.firstname }}!</h1>
       <p class="lead">Here's an overview of your account.</p>
       
       <!-- My Pets Summary -->
       <div class="card mb-4">
           <div class="card-header d-flex justify-content-between align-items-center">
               <h2>My Pets</h2>
               <a href="/my-pets" class="btn btn-sm btn-outline-primary">View All</a>
           </div>
           <div class="card-body">
               {% entitylist name:"My Pets" recordsperpage:5 %}
           </div>
       </div>
       
       <!-- My Active Appointments Summary -->
       <div class="card mb-4">
           <div class="card-header d-flex justify-content-between align-items-center">
               <h2>Active Appointments</h2>
               <a href="/my-appointments" class="btn btn-sm btn-outline-primary">View All</a>
           </div>
           <div class="card-body">
               {% entitylist name:"My Appointments" view:"My Active Appointments" recordsperpage:5 %}
           </div>
       </div>
       
       <!-- My Booking Requests Summary -->
       <div class="card mb-4">
           <div class="card-header d-flex justify-content-between align-items-center">
               <h2>Booking Requests</h2>
               <a href="/my-booking-requests" class="btn btn-sm btn-outline-primary">View All</a>
           </div>
           <div class="card-body">
               {% entitylist name:"My Booking Requests" recordsperpage:5 %}
           </div>
       </div>
   </div>
   ```

3. **Page Permissions**: 
   - Allow **Authenticated Users** to view
   - Require login to access
   - Configure as default landing page for authenticated users (via site settings or login redirect)

**Note**: The `recordsperpage:5` parameter limits the summary lists to 5 items. Users can click "View All" to see the full list on the dedicated page.

---

## Step 6: Customize List Appearance

### Using Liquid

Customize the list display with Liquid on each page. Examples are shown in Step 5 above. You can add:
- Page headers and descriptions
- Action buttons (e.g., "Add New Pet", "Request New Appointment")
- Custom HTML structure around the Entity List
- Conditional content based on user roles or data

### Custom Styling

Add custom CSS to web files or page-specific CSS:

```css
.entitylist-table {
    border-collapse: collapse;
    width: 100%;
}

.entitylist-table th {
    background-color: #f8f9fa;
    font-weight: bold;
    padding: 12px;
    text-align: left;
}

.entitylist-table td {
    padding: 10px;
    border-bottom: 1px solid #dee2e6;
}

.entitylist-table tr:hover {
    background-color: #f8f9fa;
}
```

### Dashboard Summary Styling

For the Dashboard summary sections, you can use Bootstrap cards or custom styling:

```css
.dashboard-summary-card {
    margin-bottom: 2rem;
    border: 1px solid #dee2e6;
    border-radius: 0.25rem;
}

.dashboard-summary-card .card-header {
    background-color: #f8f9fa;
    padding: 1rem;
    border-bottom: 1px solid #dee2e6;
}
```

---

## Step 7: Filtering and Search

### Built-in Search

Entity Lists automatically provide search functionality:
- Users can type in search box
- Searches across all displayed columns
- Real-time filtering as user types

### URL Parameters

Filter lists using URL parameters:

```liquid
{% assign statusFilter = request.params['status'] %}

{% if statusFilter %}
    {% entitylist name:"My Booking Requests" view:"My Booking Requests - Filtered" %}
{% else %}
    {% entitylist name:"My Booking Requests" %}
{% endif %}
```

---

## Step 8: Pagination

### Default Pagination

Entity Lists automatically paginate:
- Shows "Records Per Page" setting
- Displays page numbers
- Shows "Previous" and "Next" buttons

### Custom Pagination

Override default pagination:

1. Set **Records Per Page** to desired number
2. Use JavaScript to customize pagination controls
3. Implement custom pagination with FetchXML and Liquid

---

## Step 9: Actions and Workflows

### Row Actions

Configure actions available for each row:

1. **View**: Opens detail page
2. **Edit**: Opens edit form (if permissions allow)
3. **Delete**: Deletes record (if permissions allow)
4. **Custom Actions**: Add custom buttons with JavaScript

### Custom Action Example

Add "Cancel Request" button:

```javascript
function cancelBookingRequest(requestId) {
    // Call Power Pages Web API to update status
    fetch('/_api/pa911_bookingrequests(' + requestId + ')', {
        method: 'PATCH',
        headers: {
            'Content-Type': 'application/json',
            'X-Requested-With': 'XMLHttpRequest'
        },
        body: JSON.stringify({
            'pa911_requeststatus': 144400002 // Rejected
        })
    })
    .then(response => {
        if (response.ok) {
            location.reload(); // Refresh list
        }
    });
}
```

---

## Step 10: Performance Optimization

### View Optimization

1. **Limit Columns**: Only include necessary columns in view
2. **Add Indexes**: Index columns used in table permission scopes (e.g., `pa911_petowner`, `pa911_contact`)
3. **Limit Records**: Set appropriate page size
4. **Table Permissions**: Ensure table permissions are properly scoped to reduce data volume automatically

### Caching

Entity Lists use server-side caching:
- Data is cached for performance
- Cache refreshes periodically
- Consider cache duration for real-time data needs

---

## Advanced Scenarios

### Multi-Table Lists

Display related data from multiple tables in views:

1. Use FetchXML in view with `link-entity` to join related tables
2. Include related table columns (e.g., `pa911_pet.pa911_name` for pet name in appointments)
3. Entity List will display joined data automatically

Example: In the Appointment view, include `pa911_pet.pa911_name` to show the pet's name directly in the list.

### Conditional Display

Show different lists or content based on user role or data:

```liquid
{% if user.roles contains 'Administrator' %}
    {% entitylist name:"All Booking Requests" %}
{% else %}
    {% entitylist name:"My Booking Requests" %}
{% endif %}
```

### Dynamic Views

Switch views based on URL parameters:

```liquid
{% assign viewName = request.params['view'] | default: 'My Active Appointments' %}
{% entitylist name:"My Appointments" view:viewName %}
```

This allows users to switch between "My Active Appointments" and "My Appointment History" views via URL parameters.

### Empty State Messages

Display helpful messages when lists are empty:

```liquid
{% entitylist name:"My Pets" %}
{% if entities.pa911_pet.total_record_count == 0 %}
    <div class="alert alert-info mt-3">
        <p>You haven't added any pets yet. <a href="/pet-form">Add your first pet</a> to get started!</p>
    </div>
{% endif %}
```

---

## Internal-Only Views (Optional)

**Service** and **Appointment Slot** tables are not exposed as customer-facing Entity Lists. If you create views for these tables, they are for staff use in model-driven apps or Power Automate flows, not for the customer portal.

### Service Views (Staff Only)

If needed for internal processes:
- **Active Services**: All active services for staff reference
- **Service Catalog**: Services with pricing and duration details

### Appointment Slot Views (Staff Only)

If needed for internal processes:
- **Available Slots**: Slots available for booking
- **Booked Slots**: Slots that have been assigned to appointments
- **Upcoming Slots**: Future slots by service type

These views are managed in Dataverse but are not used in Power Pages Entity Lists.

---

## Troubleshooting

### Common Issues

**Issue**: List shows no records
- **Check**: Table permissions are configured correctly (Contact scope for Pets, Booking Requests, Appointments)
- **Check**: User has appropriate web role (Authenticated Users)
- **Check**: For Booking Requests, verify `pa911_contact` is linked (set by Power Automate flow)
- **Check**: For Appointments, verify the pet's owner matches the current user's Contact
- **Check**: View is set as the active view or is properly selected in the Entity List configuration

**Issue**: Search not working
- **Check**: "Enable Search" is enabled in Entity List settings
- **Check**: Columns in view are searchable (text fields are searchable by default)
- **Check**: Table permissions allow read access

**Issue**: Actions not appearing
- **Check**: Table permissions include appropriate privileges (Read and Write for edit actions)
- **Check**: Action settings are enabled in Entity List configuration
- **Check**: Detail/edit pages exist and are accessible (if using "View Details" action)

**Issue**: Performance issues
- **Check**: Table permissions are properly scoped (Contact/Account scope reduces data volume automatically)
- **Check**: Number of columns is reasonable (limit to essential fields)
- **Check**: Records per page is not too high (10-20 records is typical)
- **Check**: Indexes are created on columns used in table permission scopes (especially `pa911_petowner`, `pa911_contact`)

**Issue**: Dashboard summary lists showing too many records
- **Check**: Use `recordsperpage:5` parameter in Entity List tag to limit summary display
- **Check**: Verify "View All" links point to correct detail pages

---

## Best Practices

### View Design

1. **Keep Views Focused**: One view per use case
2. **Limit Columns**: Only show necessary information
3. **Sort Appropriately**: Default sort by most relevant field
4. **Use OOTB Active Views**: Consider using the default active view if it meets your needs, or create custom views for specific use cases

### Permissions

1. **Principle of Least Privilege**: Grant minimum necessary access
2. **Scope Correctly**: Use Contact/Account scope for user-specific data
3. **Test Permissions**: Verify users see only their data

### User Experience

1. **Clear Labels**: Use descriptive view and list names
2. **Helpful Messages**: Show messages when no records found
3. **Quick Actions**: Provide easy access to common actions
4. **Responsive Design**: Ensure lists work on mobile devices

---

## References

- [Entity Lists Documentation](https://learn.microsoft.com/en-us/power-pages/configure/entity-lists)
- [Dataverse Views](https://learn.microsoft.com/en-us/power-apps/user/model-driven-apps-create-edit-views)
- [Table Permissions](https://learn.microsoft.com/en-us/power-pages/security/table-permissions)
- [Liquid Entity List Tag](https://learn.microsoft.com/en-us/power-pages/configure/liquid/liquid-objects#entitylist)

---

## Next Steps

- **[Custom Web Templates](custom-web-templates.md)** - Build custom components for enhanced data display
- **[Power Automate Integration](power-automate-integration.md)** - Add automation to list actions


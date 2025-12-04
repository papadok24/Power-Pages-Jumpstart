# Lists and Views - OOTB Entity Lists

## Overview

This guide covers creating and configuring Entity Lists in Power Pages to display Dataverse data to portal users. Entity Lists provide out-of-the-box (OOTB) functionality for showing filtered, searchable, and paginated data.

**Prerequisites**:
- Complete [Data Model Design](../day-1/data-model.md) - Tables and relationships created
- Complete [Identity and Contacts](identity-and-contacts.md) - Table permissions configured
- Understand Dataverse views concept

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

Before creating an Entity List, you need Dataverse views that define what data to display.

### View for Booking Requests

1. Navigate to **Power Apps** → **Dataverse** → **Tables** → **Booking Request**
2. Go to **Views** tab
3. Click **New view** → **Public view**
4. Configure view:

#### Columns

| Column | Width | Sort |
|--------|-------|------|
| Request Number (pa911_name) | 150 | Ascending |
| First Name (pa911_firstname) | 100 | - |
| Last Name (pa911_lastname) | 100 | - |
| Pet Name (pa911_petname) | 100 | - |
| Service (pa911_service) | 150 | - |
| Preferred Slot (pa911_appointmentslot) | 200 | - |
| Request Status (pa911_requeststatus) | 120 | - |
| Created On (createdon) | 120 | Descending |

#### Filters

Add filters to show only relevant records:

```
pa911_contact eq [Current User Contact]
```

This ensures users only see their own booking requests.

5. **Save** the view as: **My Booking Requests**

### View for Services

1. Navigate to **Power Apps** → **Dataverse** → **Tables** → **Service**
2. Go to **Views** tab
3. Click **New view** → **Public view**
4. Configure view:

#### Columns

| Column | Width | Sort |
|--------|-------|------|
| Name (pa911_name) | 200 | Ascending |
| Description (pa911_description) | 300 | - |
| Duration (pa911_duration) | 100 | - |
| Price (pa911_price) | 100 | - |

#### Filters

```
statecode eq 0
```

Show only active services.

5. **Save** the view as: **Active Services - Portal**

### View for Appointment Slots

1. Navigate to **Power Apps** → **Dataverse** → **Tables** → **Appointment Slot**
2. Go to **Views** tab
3. Click **New view** → **Public view**
4. Configure view:

#### Columns

| Column | Width | Sort |
|--------|-------|------|
| Name (pa911_name) | 200 | Ascending |
| Start Time (pa911_starttime) | 150 | Ascending |
| End Time (pa911_endtime) | 150 | - |
| Service (pa911_service) | 150 | - |
| Is Available (pa911_isavailable) | 100 | - |

#### Filters

```
pa911_isavailable eq true
AND
statecode eq 0
AND
pa911_starttime ge [Today]
```

Show only available, active slots in the future.

5. **Save** the view as: **Available Slots - Portal**

---

## Step 2: Configure Table Permissions

Entity Lists respect table permissions. Ensure permissions are configured correctly.

### Booking Request Permissions

1. Navigate to **Power Pages** → **Your Site** → **Security** → **Table Permissions**
2. Create or verify permission:

| Setting | Value |
|---------|-------|
| **Name** | Booking Request - User Read Own |
| **Table** | Booking Request |
| **Web Role** | Authenticated Users |
| **Scope** | Contact |
| **Privileges** | Read |
| **Contact Scope** | Current user's Contact |

This allows users to read their own booking requests.

### Service Permissions

| Setting | Value |
|---------|-------|
| **Name** | Service - Public Read |
| **Table** | Service |
| **Web Role** | Authenticated Users (or Anonymous Users if needed) |
| **Scope** | Global |
| **Privileges** | Read |

### Appointment Slot Permissions

| Setting | Value |
|---------|-------|
| **Name** | Appointment Slot - Public Read |
| **Table** | Appointment Slot |
| **Web Role** | Authenticated Users (or Anonymous Users if needed) |
| **Scope** | Global |
| **Privileges** | Read |

---

## Step 3: Create Entity List

### Booking Requests List

1. Navigate to **Power Pages** → **Your Site** → **Content** → **Entity Lists**
2. Click **New** to create a new list
3. Configure basic settings:

| Setting | Value |
|---------|-------|
| **Name** | My Booking Requests |
| **Table** | Booking Request (pa911_bookingrequest) |
| **View** | My Booking Requests (the view you created) |

4. Click **Save**

### Display Options

Configure how the list appears:

| Setting | Value | Notes |
|---------|-------|-------|
| **Enable Search** | Yes | Allow users to search records |
| **Records Per Page** | 10 | Adjust based on data volume |
| **Show View Selector** | No | Hide view dropdown (using single view) |
| **Show Bulk Actions** | No | Disable bulk operations |
| **Enable Sorting** | Yes | Allow column sorting |

### Actions Configuration

Configure what actions users can perform:

1. **View Details**: Enable (opens detail page)
2. **Edit**: Enable (if users should edit their requests)
3. **Delete**: Disable (use status changes instead)

### Advanced Options

- **Custom CSS Class**: Add custom styling
- **JavaScript**: Add custom JavaScript for interactions
- **Toolbar**: Show/hide toolbar buttons

---

## Step 4: Create Detail Page (Optional)

For "View Details" action, create a detail page:

1. Navigate to **Power Pages** → **Your Site** → **Content** → **Web Pages**
2. Create new page:
   - **Name**: Booking Request Details
   - **Partial URL**: `booking-request-details`

3. Add Entity Form for viewing:
   ```liquid
   {% entityform name:"Booking Request View Form" mode:"readonly" %}
   ```

4. Configure Entity Form:
   - **Table**: Booking Request
   - **Mode**: Read-only
   - **Fields**: Display all booking request fields

---

## Step 5: Add List to Web Page

### Create My Bookings Page

1. Navigate to **Power Pages** → **Your Site** → **Content** → **Web Pages**
2. Create new page:
   - **Name**: My Bookings
   - **Partial URL**: `my-bookings`
   - **Parent Page**: Home (or appropriate parent)

3. Add Entity List to page:
   - In page content, add: `{% entitylist name:"My Booking Requests" %}`
   - Or use Design Studio to drag the list component onto the page

4. **Page Permissions**: 
   - Allow **Authenticated Users** to view
   - Require login to access

### Service Catalog Page

1. Create new page:
   - **Name**: Services
   - **Partial URL**: `services`

2. Add Entity List:
   ```liquid
   {% entitylist name:"Active Services" %}
   ```

3. **Page Permissions**:
   - Allow **Authenticated Users** (or **Anonymous Users** if public)

---

## Step 6: Customize List Appearance

### Using Liquid

Customize the list display with Liquid:

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

### Custom Styling

Add custom CSS:

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

---

## Step 7: Filtering and Search

### Built-in Search

Entity Lists automatically provide search functionality:
- Users can type in search box
- Searches across all displayed columns
- Real-time filtering as user types

### Advanced Filtering

For more complex filtering, use FetchXML in the view:

1. Edit the Dataverse view
2. Switch to **Advanced Find** view
3. Add complex filters:
   ```
   pa911_requeststatus eq 144400000
   AND
   createdon ge [Last 30 Days]
   ```

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
2. **Add Indexes**: Index frequently filtered columns
3. **Filter Early**: Use view filters to reduce data volume
4. **Limit Records**: Set appropriate page size

### Caching

Entity Lists use server-side caching:
- Data is cached for performance
- Cache refreshes periodically
- Consider cache duration for real-time data needs

---

## Advanced Scenarios

### Multi-Table Lists

Display related data from multiple tables:

1. Use FetchXML in view with `link-entity`
2. Include related table columns
3. Entity List will display joined data

### Conditional Display

Show different lists based on user role:

```liquid
{% if user.roles contains 'Administrator' %}
    {% entitylist name:"All Booking Requests" %}
{% else %}
    {% entitylist name:"My Booking Requests" %}
{% endif %}
```

### Dynamic Views

Switch views based on parameters:

```liquid
{% assign viewName = request.params['view'] | default: 'My Booking Requests' %}
{% entitylist name:"My Booking Requests" view:viewName %}
```

---

## Troubleshooting

### Common Issues

**Issue**: List shows no records
- **Check**: Table permissions are configured correctly
- **Check**: View filters are not too restrictive
- **Check**: User has appropriate web role
- **Check**: Scope filters match user's Contact ID

**Issue**: Search not working
- **Check**: "Enable Search" is enabled in Entity List settings
- **Check**: Columns in view are searchable
- **Check**: Table permissions allow read access

**Issue**: Actions not appearing
- **Check**: Table permissions include appropriate privileges
- **Check**: Action settings are enabled in Entity List
- **Check**: Detail/edit pages exist and are accessible

**Issue**: Performance issues
- **Check**: View has appropriate filters
- **Check**: Number of columns is reasonable
- **Check**: Records per page is not too high
- **Check**: Indexes are created on filtered columns

---

## Best Practices

### View Design

1. **Keep Views Focused**: One view per use case
2. **Use Filters**: Filter at view level, not just list level
3. **Limit Columns**: Only show necessary information
4. **Sort Appropriately**: Default sort by most relevant field

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


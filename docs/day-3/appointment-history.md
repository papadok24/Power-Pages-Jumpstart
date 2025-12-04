# View Appointment History

## Overview

This guide covers displaying appointment history for pet owners using both out-of-the-box (OOTB) Entity Lists and custom implementations. Users can view their pets' past and upcoming appointments with filtering, sorting, and detailed views.

**Prerequisites**:
- Complete [Data Model Design](../day-1/data-model.md) - Appointment and Pet tables created
- Complete [Lists and Views](../day-2/lists-and-views.md) - Understand Entity Lists
- Table permissions configured for Appointment and Pet tables

---

## Part 1: OOTB Approach

The OOTB approach uses Entity Lists with Dataverse views, providing a quick implementation with built-in features.

### Step 1: Create Dataverse View

Create a view that filters appointments for the current user's pets.

#### Create Appointment History View

1. Navigate to **Power Apps** → **Dataverse** → **Tables** → **Appointment**
2. Go to **Views** tab
3. Click **New view** → **Public view**
4. Configure view:

##### Columns

| Column | Width | Sort |
|--------|-------|------|
| Subject (subject) | 200 | - |
| Pet (pa911_pet) | 150 | - |
| Service (pa911_service) | 150 | - |
| Scheduled Start (scheduledstart) | 180 | Descending |
| Scheduled End (scheduledend) | 180 | - |
| Status (statecode) | 100 | - |
| Status Reason (statuscode) | 120 | - |

##### Filters

Add filters to show only appointments for the current user's pets:

```
pa911_pet.pa911_petowner eq [Current User Contact]
```

This ensures users only see appointments for their own pets.

5. **Save** the view as: **My Pet Appointments**

#### Create Upcoming Appointments View

Create a separate view for upcoming appointments:

1. Duplicate the "My Pet Appointments" view
2. Add additional filter:

```
scheduledstart ge [Today]
```

3. **Save** as: **My Upcoming Appointments**

#### Create Past Appointments View

Create a view for past appointments:

1. Duplicate the "My Pet Appointments" view
2. Add additional filter:

```
scheduledstart lt [Today]
```

3. **Save** as: **My Past Appointments**

---

### Step 2: Configure Table Permissions

Ensure users have appropriate permissions to read appointments.

#### Appointment Table Permissions

1. Navigate to **Power Pages** → **Your Site** → **Security** → **Table Permissions**
2. Create or verify permission:

| Setting | Value |
|---------|-------|
| **Name** | Appointment - User Read Own Pets |
| **Table** | Appointment |
| **Web Role** | Authenticated Users |
| **Scope** | Contact |
| **Privileges** | Read |
| **Contact Scope** | Current user's Contact (via Pet relationship) |

**Note**: The filter `pa911_pet.pa911_petowner eq [Current User Contact]` in the view ensures users only see their own pets' appointments.

---

### Step 3: Create Entity List

Create an Entity List to display appointments.

#### Create Appointment History List

1. Navigate to **Power Pages** → **Your Site** → **Content** → **Entity Lists**
2. Click **New** to create a new list
3. Configure basic settings:

| Setting | Value |
|---------|-------|
| **Name** | My Pet Appointments |
| **Table** | Appointment |
| **View** | My Pet Appointments (the view you created) |

4. Click **Save**

#### Display Options

Configure how the list appears:

| Setting | Value | Notes |
|---------|-------|-------|
| **Enable Search** | Yes | Allow users to search appointments |
| **Records Per Page** | 10 | Adjust based on expected volume |
| **Show View Selector** | Yes | Allow switching between views |
| **Show Bulk Actions** | No | Disable bulk operations |
| **Enable Sorting** | Yes | Allow column sorting |

#### Actions Configuration

Configure what actions users can perform:

1. **View Details**: Enable (opens detail page)
2. **Edit**: Enable (if users should edit appointments)
3. **Delete**: Disable (use cancellation status instead)

---

### Step 4: Create Appointment Detail Page

Create a detail page for viewing appointment information.

#### Create Detail Page

1. Navigate to **Power Pages** → **Your Site** → **Content** → **Web Pages**
2. Create new page:
   - **Name**: Appointment Details
   - **Partial URL**: `appointment-details`
   - **Parent Page**: Home (or appropriate parent)

#### Add Entity Form

Add a read-only Entity Form for viewing appointment details:

```liquid
<div class="container mt-4">
    <h1>Appointment Details</h1>
    
    {% entityform name:"Appointment View Form" mode:"readonly" %}
</div>
```

#### Configure Entity Form

1. Create Entity Form:
   - **Name**: Appointment View Form
   - **Table**: Appointment
   - **Mode**: Read-only
   - **Fields**: Display all appointment fields including Pet, Service, dates, status

---

### Step 5: Create Appointment History Page

Create a page where users can view their appointment history.

#### Create Web Page

1. Navigate to **Power Pages** → **Your Site** → **Content** → **Web Pages**
2. Create new page:
   - **Name**: My Appointments
   - **Partial URL**: `my-appointments`
   - **Parent Page**: Home (or appropriate parent)

#### Add Entity List to Page

Add the Entity List to the page:

```liquid
<div class="container mt-4">
    <h1>My Pet Appointments</h1>
    <p class="lead">View and manage appointments for your pets.</p>
    
    {% entitylist name:"My Pet Appointments" %}
    
    <div class="mt-3">
        <a href="/book-appointment" class="btn btn-primary">Book New Appointment</a>
    </div>
</div>
```

Or use Design Studio to drag the list component onto the page.

#### Page Permissions

Configure page access:

1. Go to **Page Permissions** tab
2. Allow **Authenticated Users** to view
3. This ensures only logged-in users can access appointment history

---

### Step 6: Customize List Appearance

#### Custom Styling

Add custom CSS to style the appointment list:

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

/* Status badges */
.status-open {
    color: #0d6efd;
}

.status-completed {
    color: #198754;
}

.status-cancelled {
    color: #dc3545;
}
```

---

## Part 2: Custom Approach

The custom approach provides full control over the display, filtering, and user experience.

### Step 1: Create Custom Web Template

Create a custom web template for displaying appointment history.

#### Create Web Template

1. Navigate to **Power Pages** → **Your Site** → **Content** → **Web Templates**
2. Click **New** to create a new template
3. Configure:
   - **Name**: Appointment History Custom
   - **Type**: Web Template

#### Template Content

```liquid
{% assign petId = request.params['petId'] %}
{% assign statusFilter = request.params['status'] %}

<div class="appointment-history-container">
    <h1>Appointment History</h1>
    
    <!-- Filters -->
    <div class="filters mb-3">
        <select id="statusFilter" class="form-select">
            <option value="">All Statuses</option>
            <option value="0">Open</option>
            <option value="1">Completed</option>
            <option value="2">Cancelled</option>
        </select>
        
        <select id="petFilter" class="form-select">
            <option value="">All Pets</option>
            {% for pet in user.contact.pa911_pets %}
                <option value="{{ pet.pa911_petid }}" {% if petId == pet.pa911_petid %}selected{% endif %}>
                    {{ pet.pa911_name }}
                </option>
            {% endfor %}
        </select>
    </div>
    
    <!-- Appointment List -->
    <div id="appointmentList" class="appointment-list">
        {% fetchxml appointments %}
            <fetch>
                <entity name="appointment">
                    <attribute name="activityid" />
                    <attribute name="subject" />
                    <attribute name="scheduledstart" />
                    <attribute name="scheduledend" />
                    <attribute name="statecode" />
                    <attribute name="statuscode" />
                    <link-entity name="pa911_pet" from="pa911_petid" to="pa911_pet">
                        <attribute name="pa911_name" />
                        <filter>
                            <condition attribute="pa911_petowner" operator="eq" value="{{ user.contact.contactid }}" />
                        </filter>
                    </link-entity>
                    <link-entity name="pa911_service" from="pa911_serviceid" to="pa911_service">
                        <attribute name="pa911_name" />
                    </link-entity>
                    <filter>
                        {% if petId %}
                            <condition attribute="pa911_pet" operator="eq" value="{{ petId }}" />
                        {% endif %}
                        {% if statusFilter %}
                            <condition attribute="statecode" operator="eq" value="{{ statusFilter }}" />
                        {% endif %}
                    </filter>
                    <order attribute="scheduledstart" descending="true" />
                </entity>
            </fetch>
        {% endfetchxml %}
        
        {% if appointments.results.entities.size > 0 %}
            <div class="row">
                {% for appointment in appointments.results.entities %}
                    <div class="col-md-6 mb-3">
                        <div class="card">
                            <div class="card-body">
                                <h5 class="card-title">{{ appointment.subject }}</h5>
                                <p class="card-text">
                                    <strong>Pet:</strong> {{ appointment.pa911_pet.pa911_name }}<br>
                                    <strong>Service:</strong> {{ appointment.pa911_service.pa911_name }}<br>
                                    <strong>Date:</strong> {{ appointment.scheduledstart | date: "%B %d, %Y" }}<br>
                                    <strong>Time:</strong> {{ appointment.scheduledstart | date: "%I:%M %p" }} - {{ appointment.scheduledend | date: "%I:%M %p" }}<br>
                                    <strong>Status:</strong> 
                                    <span class="badge status-{{ appointment.statecode | statecode_to_class }}">
                                        {{ appointment.statecode | statecode_to_label }}
                                    </span>
                                </p>
                                <a href="/appointment-details?id={{ appointment.activityid }}" class="btn btn-sm btn-primary">View Details</a>
                            </div>
                        </div>
                    </div>
                {% endfor %}
            </div>
        {% else %}
            <div class="alert alert-info">
                <p>No appointments found.</p>
            </div>
        {% endif %}
    </div>
</div>

<script>
// Filter handling
document.getElementById('statusFilter').addEventListener('change', function() {
    applyFilters();
});

document.getElementById('petFilter').addEventListener('change', function() {
    applyFilters();
});

function applyFilters() {
    const status = document.getElementById('statusFilter').value;
    const pet = document.getElementById('petFilter').value;
    
    let url = '/my-appointments?';
    if (status) url += 'status=' + status + '&';
    if (pet) url += 'petId=' + pet;
    
    window.location.href = url;
}
</script>
```

---

### Step 2: Create Responsive Card Layout

Create a card-based layout for better mobile experience.

#### Card Layout CSS

```css
.appointment-history-container {
    max-width: 1200px;
    margin: 0 auto;
    padding: 20px;
}

.appointment-list .card {
    border: 1px solid #dee2e6;
    border-radius: 8px;
    transition: box-shadow 0.3s;
}

.appointment-list .card:hover {
    box-shadow: 0 4px 8px rgba(0,0,0,0.1);
}

.status-badge {
    padding: 4px 8px;
    border-radius: 4px;
    font-size: 0.875rem;
}

.status-open {
    background-color: #cfe2ff;
    color: #084298;
}

.status-completed {
    background-color: #d1e7dd;
    color: #0f5132;
}

.status-cancelled {
    background-color: #f8d7da;
    color: #842029;
}

.filters {
    display: flex;
    gap: 10px;
    flex-wrap: wrap;
}

.filters .form-select {
    min-width: 200px;
}

@media (max-width: 768px) {
    .filters {
        flex-direction: column;
    }
    
    .filters .form-select {
        width: 100%;
    }
}
```

---

### Step 3: Add JavaScript Enhancements

Add JavaScript for enhanced filtering and sorting.

#### Advanced Filtering

```javascript
// Client-side filtering
function filterAppointments() {
    const statusFilter = document.getElementById('statusFilter').value;
    const petFilter = document.getElementById('petFilter').value;
    const searchTerm = document.getElementById('searchInput').value.toLowerCase();
    
    const cards = document.querySelectorAll('.appointment-card');
    
    cards.forEach(card => {
        const status = card.dataset.status;
        const pet = card.dataset.petId;
        const text = card.textContent.toLowerCase();
        
        let show = true;
        
        if (statusFilter && status !== statusFilter) show = false;
        if (petFilter && pet !== petFilter) show = false;
        if (searchTerm && !text.includes(searchTerm)) show = false;
        
        card.style.display = show ? 'block' : 'none';
    });
}

// Search input
const searchInput = document.createElement('input');
searchInput.type = 'text';
searchInput.id = 'searchInput';
searchInput.className = 'form-control';
searchInput.placeholder = 'Search appointments...';
searchInput.addEventListener('input', filterAppointments);

// Add to filters section
document.querySelector('.filters').appendChild(searchInput);
```

#### Sorting

```javascript
function sortAppointments(sortBy) {
    const container = document.getElementById('appointmentList');
    const cards = Array.from(container.querySelectorAll('.appointment-card'));
    
    cards.sort((a, b) => {
        let aValue, bValue;
        
        switch(sortBy) {
            case 'date':
                aValue = new Date(a.dataset.date);
                bValue = new Date(b.dataset.date);
                return bValue - aValue; // Descending (newest first)
            case 'pet':
                aValue = a.dataset.petName;
                bValue = b.dataset.petName;
                return aValue.localeCompare(bValue);
            case 'service':
                aValue = a.dataset.serviceName;
                bValue = b.dataset.serviceName;
                return aValue.localeCompare(bValue);
            default:
                return 0;
        }
    });
    
    cards.forEach(card => container.appendChild(card));
}
```

---

### Step 4: Add Pagination

Implement pagination for large appointment lists.

#### Pagination Implementation

```liquid
{% assign page = request.params['page'] | default: 1 | plus: 0 %}
{% assign pageSize = 10 %}
{% assign offset = page | minus: 1 | times: pageSize %}

{% fetchxml appointments %}
    <fetch count="{{ pageSize }}" page="{{ page }}">
        <!-- ... fetchxml content ... -->
    </fetch>
{% endfetchxml %}

<!-- Display appointments -->
{% for appointment in appointments.results.entities %}
    <!-- Appointment card -->
{% endfor %}

<!-- Pagination controls -->
<div class="pagination mt-4">
    {% if page > 1 %}
        <a href="?page={{ page | minus: 1 }}" class="btn btn-secondary">Previous</a>
    {% endif %}
    
    <span class="mx-3">Page {{ page }} of {{ appointments.results.total_record_count | divided_by: pageSize | plus: 1 }}</span>
    
    {% assign totalPages = appointments.results.total_record_count | divided_by: pageSize | plus: 1 %}
    {% if page < totalPages %}
        <a href="?page={{ page | plus: 1 }}" class="btn btn-secondary">Next</a>
    {% endif %}
</div>
```

---

## Comparison: OOTB vs. Custom

### OOTB Approach

**Pros**:
- ✅ Quick to implement
- ✅ Built-in search, sorting, pagination
- ✅ Automatic table permissions enforcement
- ✅ Standard UI/UX
- ✅ Low maintenance

**Cons**:
- ❌ Limited customization
- ❌ Fixed table layout
- ❌ Less mobile-friendly
- ❌ Limited filtering options

### Custom Approach

**Pros**:
- ✅ Full UI/UX control
- ✅ Custom layouts (cards, grids)
- ✅ Advanced filtering and sorting
- ✅ Better mobile experience
- ✅ Custom branding

**Cons**:
- ❌ More development time
- ❌ Requires JavaScript knowledge
- ❌ More maintenance
- ❌ Need to handle pagination manually

---

## Best Practices

### Performance

1. **Limit Records**: Use pagination to limit records per page
2. **Index Columns**: Ensure filtered columns are indexed in Dataverse
3. **Cache Views**: Leverage Dataverse view caching
4. **Lazy Loading**: Load appointment details on demand

### User Experience

1. **Clear Status Indicators**: Use color-coded status badges
2. **Quick Filters**: Provide common filter options (Upcoming, Past, All)
3. **Search Functionality**: Enable search across appointment fields
4. **Responsive Design**: Ensure mobile-friendly layouts

### Security

1. **Table Permissions**: Always enforce table permissions
2. **Scope Filters**: Use Contact scope filters in views
3. **Validate Access**: Verify users can only see their own pets' appointments

---

## Troubleshooting

### Common Issues

**Issue**: Appointments not appearing
- **Solution**: Verify table permissions are configured correctly
- **Solution**: Check view filters match user's Contact ID
- **Solution**: Verify Pet relationship is correct

**Issue**: Performance issues with large lists
- **Solution**: Implement pagination
- **Solution**: Add indexes to filtered columns
- **Solution**: Limit number of columns in view

**Issue**: Custom template not displaying data
- **Solution**: Verify FetchXML syntax is correct
- **Solution**: Check Liquid variable names match entity attributes
- **Solution**: Verify user has appropriate permissions

---

## Next Steps

- **[ALM Overview](alm-overview.md)** - Learn about deployment and lifecycle management
- **[SharePoint Integration](sharepoint-integration.md)** - Add document management for pets

---

## References

- [Entity Lists Documentation](https://learn.microsoft.com/en-us/power-pages/configure/entity-lists)
- [Liquid FetchXML Tag](https://learn.microsoft.com/en-us/power-pages/configure/liquid/liquid-objects#fetchxml)
- [Dataverse Views](https://learn.microsoft.com/en-us/power-apps/user/model-driven-apps-create-edit-views)
- [Table Permissions](https://learn.microsoft.com/en-us/power-pages/security/table-permissions)


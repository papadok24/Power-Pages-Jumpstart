# User Stories - Liquid Syntax Fundamentals

## Overview

This document contains 8 user stories designed to teach Power Pages Liquid syntax through practical, real-world scenarios using the PawsFirst Veterinary Portal. Each story focuses on specific Liquid concepts while building functionality for Pets, Appointments, and Services.

**Prerequisites**: Complete the [Site Provisioning Guide](site-provisioning-guide.md) and [Home Page Build](home-page-build.md) before working through these stories.

---

## Story 1: Display My Pets

### User Story

**As a** pet owner  
**I want to** see a list of all my registered pets on my profile page  
**So that** I can quickly access their information and manage their records

### Acceptance Criteria

- [ ] Page displays all pets owned by the logged-in user
- [ ] Each pet shows name, species, and breed
- [ ] Pets are displayed in a card layout
- [ ] Message appears if user has no pets
- [ ] Page only shows pets belonging to the current user

### Liquid Concepts

- `fetchxml` - Query Dataverse for pet records
- `for` loop - Iterate through pet collection
- `user` object - Filter by current user's ID
- Relationship filtering - Filter pets by owner relationship

### Implementation

```liquid
<div class="container mt-4">
  <h1>My Pets</h1>
  
  {% fetchxml my_pets %}
  <fetch>
    <entity name="pa911_pet">
      <attribute name="pa911_petid" />
      <attribute name="pa911_name" />
      <attribute name="pa911_species" />
      <attribute name="pa911_breed" />
      <attribute name="pa911_dateofbirth" />
      <link-entity name="contact" from="contactid" to="pa911_petowner" alias="owner">
        <filter>
          <condition attribute="contactid" operator="eq" value="{{ user.id }}" />
        </filter>
      </link-entity>
      <order attribute="pa911_name" />
    </entity>
  </fetch>
  {% endfetchxml %}

  {% if my_pets.results.entities.size > 0 %}
    <div class="row">
      {% for pet in my_pets.results.entities %}
        <div class="col-md-4 mb-4">
          <div class="card">
            <div class="card-body">
              <h5 class="card-title">{{ pet.pa911_name }}</h5>
              <p class="card-text">
                <strong>Species:</strong> {{ pet.pa911_species }}<br>
                {% if pet.pa911_breed %}
                  <strong>Breed:</strong> {{ pet.pa911_breed }}<br>
                {% endif %}
                {% if pet.pa911_dateofbirth %}
                  <strong>Date of Birth:</strong> {{ pet.pa911_dateofbirth | date: "%B %d, %Y" }}
                {% endif %}
              </p>
              <a href="/pet-details?id={{ pet.pa911_petid }}" class="btn btn-primary">View Details</a>
            </div>
          </div>
        </div>
      {% endfor %}
    </div>
  {% else %}
    <div class="alert alert-info">
      <p>You don't have any pets registered yet. <a href="/add-pet">Add your first pet</a>!</p>
    </div>
  {% endif %}
</div>
```

### Key Learning Points

- Using `fetchxml` to query custom tables (`pa911_pet`)
- Filtering records by relationship using `link-entity`
- Checking collection size with `.size` property
- Using `for` loop to iterate through results

---

## Story 2: View Available Services

### User Story

**As a** site visitor  
**I want to** view all available veterinary services with their details  
**So that** I can understand what services are offered and make informed decisions

### Acceptance Criteria

- [ ] Page displays all active services
- [ ] Each service shows name, description, duration, and price
- [ ] Services are sorted alphabetically
- [ ] Inactive services are not displayed
- [ ] Page is accessible to anonymous users

### Liquid Concepts

- `fetchxml` - Query services from Dataverse
- `for` loop - Display service collection
- `date` filter - Format service creation date
- `truncate` filter - Limit description length

### Implementation

```liquid
<div class="container mt-4">
  <h1>Our Services</h1>
  
  {% fetchxml services_list %}
  <fetch>
    <entity name="pa911_service">
      <attribute name="pa911_serviceid" />
      <attribute name="pa911_name" />
      <attribute name="pa911_description" />
      <attribute name="pa911_duration" />
      <attribute name="pa911_price" />
      <attribute name="createdon" />
      <filter>
        <condition attribute="statecode" operator="eq" value="0" />
      </filter>
      <order attribute="pa911_name" />
    </entity>
  </fetch>
  {% endfetchxml %}

  {% if services_list.results.entities.size > 0 %}
    <div class="row">
      {% for service in services_list.results.entities %}
        <div class="col-md-6 mb-4">
          <div class="card">
            <div class="card-body">
              <h5 class="card-title">{{ service.pa911_name }}</h5>
              <p class="card-text">
                {{ service.pa911_description | truncate: 150 }}
              </p>
              <ul class="list-unstyled">
                {% if service.pa911_duration %}
                  <li><strong>Duration:</strong> {{ service.pa911_duration }} minutes</li>
                {% endif %}
                {% if service.pa911_price %}
                  <li><strong>Price:</strong> ${{ service.pa911_price | divided_by: 100.0 | round: 2 }}</li>
                {% endif %}
                <li><small class="text-muted">Added: {{ service.createdon | date: "%B %Y" }}</small></li>
              </ul>
              {% if user %}
                <a href="/book-appointment?service={{ service.pa911_serviceid }}" class="btn btn-primary">Book Now</a>
              {% else %}
                <a href="/signin" class="btn btn-outline-primary">Sign In to Book</a>
              {% endif %}
            </div>
          </div>
        </div>
      {% endfor %}
    </div>
  {% else %}
    <div class="alert alert-warning">
      <p>No services are currently available.</p>
    </div>
  {% endif %}
</div>
```

### Key Learning Points

- Filtering by status using `statecode`
- Using `truncate` filter to limit text length
- Formatting currency with `divided_by` and `round` filters
- Conditional content based on authentication status

---

## Story 3: Show Upcoming Appointments

### User Story

**As a** pet owner  
**I want to** see my upcoming appointments with pet and service details  
**So that** I can keep track of my schedule and prepare for visits

### Acceptance Criteria

- [ ] Page displays only future appointments
- [ ] Each appointment shows pet name, service, date, and time
- [ ] Appointments are sorted by date (soonest first)
- [ ] Only shows appointments for the logged-in user's pets
- [ ] Message appears if no upcoming appointments exist

### Liquid Concepts

- `fetchxml` - Query appointment records
- Date filtering - Filter by `scheduledstart` date
- Linked entity - Join with Pet and Service tables
- `date` filter - Format appointment dates and times

### Implementation

```liquid
<div class="container mt-4">
  <h1>Upcoming Appointments</h1>
  
  {% fetchxml upcoming_appointments %}
  <fetch>
    <entity name="appointment">
      <attribute name="activityid" />
      <attribute name="subject" />
      <attribute name="scheduledstart" />
      <attribute name="scheduledend" />
      <link-entity name="pa911_pet" from="pa911_petid" to="pa911_pet" alias="pet">
        <attribute name="pa911_name" />
        <link-entity name="contact" from="contactid" to="pa911_petowner" alias="owner">
          <filter>
            <condition attribute="contactid" operator="eq" value="{{ user.id }}" />
          </filter>
        </link-entity>
      </link-entity>
      <link-entity name="pa911_service" from="pa911_serviceid" to="pa911_service" alias="service">
        <attribute name="pa911_name" />
      </link-entity>
      <filter>
        <condition attribute="scheduledstart" operator="ge" value="{{ now | date: '%Y-%m-%dT%H:%M:%SZ' }}" />
        <condition attribute="statecode" operator="eq" value="0" />
      </filter>
      <order attribute="scheduledstart" />
    </entity>
  </fetch>
  {% endfetchxml %}

  {% if upcoming_appointments.results.entities.size > 0 %}
    <div class="list-group">
      {% for appointment in upcoming_appointments.results.entities %}
        <div class="list-group-item">
          <div class="d-flex w-100 justify-content-between">
            <h5 class="mb-1">{{ appointment.subject }}</h5>
            <small>{{ appointment.scheduledstart | date: "%B %d" }}</small>
          </div>
          <p class="mb-1">
            <strong>Pet:</strong> {{ appointment.pet.pa911_name }}<br>
            <strong>Service:</strong> {{ appointment.service.pa911_name }}<br>
            <strong>Date:</strong> {{ appointment.scheduledstart | date: "%A, %B %d, %Y" }}<br>
            <strong>Time:</strong> {{ appointment.scheduledstart | date: "%I:%M %p" }} - {{ appointment.scheduledend | date: "%I:%M %p" }}
          </p>
          <a href="/appointment-details?id={{ appointment.activityid }}" class="btn btn-sm btn-outline-primary">View Details</a>
        </div>
      {% endfor %}
    </div>
  {% else %}
    <div class="alert alert-info">
      <p>You have no upcoming appointments. <a href="/book-appointment">Schedule one now</a>!</p>
    </div>
  {% endif %}
</div>
```

### Key Learning Points

- Using `now` object for date comparisons
- Multiple `link-entity` tags for complex relationships
- Filtering by date using operators (`ge` = greater than or equal)
- Formatting dates with different formats for display

---

## Story 4: Conditional Welcome Message

### User Story

**As a** user  
**I want to** see a personalized welcome message based on my role and authentication status  
**So that** I understand my access level and available features

### Acceptance Criteria

- [ ] Anonymous users see guest welcome message
- [ ] Authenticated users see personalized greeting
- [ ] Administrators see additional admin-specific content
- [ ] Different messages based on user roles
- [ ] Fallback values for missing user data

### Liquid Concepts

- `if/elsif/else` - Multiple conditional branches
- `user.roles` - Check user role assignments
- `default` filter - Provide fallback values
- `contains` - Check if array contains value

### Implementation

```liquid
<div class="container mt-4">
  <div class="jumbotron">
    {% if user %}
      {% assign userRoles = user.roles | join: ',' | downcase %}
      
      {% if userRoles contains 'administrator' %}
        <h1 class="display-4">Welcome, Administrator {{ user.firstname | default: user.email }}!</h1>
        <p class="lead">You have full access to manage the PawsFirst portal.</p>
        <div class="alert alert-warning">
          <strong>Admin Actions:</strong>
          <ul>
            <li><a href="/admin/services">Manage Services</a></li>
            <li><a href="/admin/users">Manage Users</a></li>
            <li><a href="/admin/reports">View Reports</a></li>
          </ul>
        </div>
      {% elsif userRoles contains 'veterinarian' %}
        <h1 class="display-4">Welcome, Dr. {{ user.lastname | default: user.firstname }}!</h1>
        <p class="lead">Access your appointment schedule and patient records.</p>
      {% else %}
        <h1 class="display-4">Welcome back, {{ user.firstname | default: 'there' }}!</h1>
        <p class="lead">Manage your pets and appointments.</p>
      {% endif %}
      
      <p class="mt-3">
        <strong>Account:</strong> {{ user.email | default: 'No email on file' }}<br>
        <strong>Name:</strong> {{ user.fullname | default: 'Not set' }}
      </p>
    {% else %}
      <h1 class="display-4">Welcome to PawsFirst Veterinary Portal</h1>
      <p class="lead">Sign in to manage your pet's appointments and medical records.</p>
      <a href="/signin" class="btn btn-primary btn-lg">Sign In</a>
    {% endif %}
  </div>
</div>
```

### Key Learning Points

- Using `if/elsif/else` for multiple conditions
- Checking role membership with `contains` filter
- Using `default` filter for missing data
- Combining filters (`join`, `downcase`) for role checking

---

## Story 5: Pet Species Filter

### User Story

**As a** pet owner  
**I want to** filter my pets by species  
**So that** I can quickly find pets of a specific type

### Acceptance Criteria

- [ ] Page displays all user's pets
- [ ] Filter dropdown shows all species options
- [ ] Selecting a species filters the displayed pets
- [ ] Choice field values display correctly
- [ ] "All" option shows all pets

### Liquid Concepts

- `if/elsif` - Multiple conditional checks
- Choice field handling - Display choice labels
- `request.params` - Read query parameters
- Conditional filtering logic

### Implementation

```liquid
<div class="container mt-4">
  <h1>My Pets</h1>
  
  {% assign selectedSpecies = request.params['species'] %}
  
  <div class="mb-4">
    <label for="species-filter">Filter by Species:</label>
    <select id="species-filter" class="form-control" onchange="window.location.href='?species=' + this.value">
      <option value="">All Species</option>
      <option value="144400000" {% if selectedSpecies == '144400000' %}selected{% endif %}>Dog</option>
      <option value="144400001" {% if selectedSpecies == '144400001' %}selected{% endif %}>Cat</option>
      <option value="144400002" {% if selectedSpecies == '144400002' %}selected{% endif %}>Bird</option>
      <option value="144400003" {% if selectedSpecies == '144400003' %}selected{% endif %}>Reptile</option>
      <option value="144400004" {% if selectedSpecies == '144400004' %}selected{% endif %}>Other</option>
    </select>
  </div>

  {% fetchxml pets_query %}
  <fetch>
    <entity name="pa911_pet">
      <attribute name="pa911_petid" />
      <attribute name="pa911_name" />
      <attribute name="pa911_species" />
      <attribute name="pa911_breed" />
      <link-entity name="contact" from="contactid" to="pa911_petowner" alias="owner">
        <filter>
          <condition attribute="contactid" operator="eq" value="{{ user.id }}" />
        </filter>
      </link-entity>
      {% if selectedSpecies != blank %}
        <filter>
          <condition attribute="pa911_species" operator="eq" value="{{ selectedSpecies }}" />
        </filter>
      {% endif %}
      <order attribute="pa911_name" />
    </entity>
  </fetch>
  {% endfetchxml %}

  <div class="row">
    {% for pet in pets_query.results.entities %}
      {% assign speciesLabel = '' %}
      {% if pet.pa911_species == '144400000' %}
        {% assign speciesLabel = 'Dog' %}
      {% elsif pet.pa911_species == '144400001' %}
        {% assign speciesLabel = 'Cat' %}
      {% elsif pet.pa911_species == '144400002' %}
        {% assign speciesLabel = 'Bird' %}
      {% elsif pet.pa911_species == '144400003' %}
        {% assign speciesLabel = 'Reptile' %}
      {% elsif pet.pa911_species == '144400004' %}
        {% assign speciesLabel = 'Other' %}
      {% else %}
        {% assign speciesLabel = 'Unknown' %}
      {% endif %}

      <div class="col-md-4 mb-4">
        <div class="card">
          <div class="card-body">
            <h5 class="card-title">{{ pet.pa911_name }}</h5>
            <p class="card-text">
              <span class="badge bg-primary">{{ speciesLabel }}</span><br>
              {% if pet.pa911_breed %}
                <strong>Breed:</strong> {{ pet.pa911_breed }}
              {% endif %}
            </p>
          </div>
        </div>
      </div>
    {% endfor %}
  </div>
</div>
```

### Key Learning Points

- Using `request.params` to read query string values
- Conditional FetchXML filters based on parameters
- Handling Choice field values with `if/elsif`
- Using `assign` to set variables for display

---

## Story 6: Service Price Display

### User Story

**As a** customer  
**I want to** see service prices formatted correctly with currency  
**So that** I can understand the cost before booking

### Acceptance Criteria

- [ ] Prices display with dollar sign and two decimal places
- [ ] Currency values are correctly converted from Dataverse format
- [ ] Free services show "$0.00" or "Free"
- [ ] Prices are aligned consistently

### Liquid Concepts

- `divided_by` filter - Convert currency from cents to dollars
- `round` filter - Round to decimal places
- `default` filter - Handle null/zero values
- Mathematical operations

### Implementation

```liquid
<div class="container mt-4">
  <h1>Service Pricing</h1>
  
  {% fetchxml services_pricing %}
  <fetch>
    <entity name="pa911_service">
      <attribute name="pa911_serviceid" />
      <attribute name="pa911_name" />
      <attribute name="pa911_description" />
      <attribute name="pa911_price" />
      <attribute name="pa911_duration" />
      <filter>
        <condition attribute="statecode" operator="eq" value="0" />
      </filter>
      <order attribute="pa911_price" descending="true" />
    </entity>
  </fetch>
  {% endfetchxml %}

  <table class="table table-striped">
    <thead>
      <tr>
        <th>Service</th>
        <th>Description</th>
        <th>Duration</th>
        <th class="text-end">Price</th>
      </tr>
    </thead>
    <tbody>
      {% for service in services_pricing.results.entities %}
        <tr>
          <td><strong>{{ service.pa911_name }}</strong></td>
          <td>{{ service.pa911_description | truncate: 100 }}</td>
          <td>
            {% if service.pa911_duration %}
              {{ service.pa911_duration }} minutes
            {% else %}
              N/A
            {% endif %}
          </td>
          <td class="text-end">
            {% if service.pa911_price and service.pa911_price > 0 %}
              {% assign priceInDollars = service.pa911_price | divided_by: 100.0 %}
              ${{ priceInDollars | round: 2 }}
            {% else %}
              <span class="text-muted">Free</span>
            {% endif %}
          </td>
        </tr>
      {% endfor %}
    </tbody>
  </table>

  <div class="mt-4">
    <h3>Price Summary</h3>
    {% assign totalPrice = 0 %}
    {% for service in services_pricing.results.entities %}
      {% if service.pa911_price %}
        {% assign totalPrice = totalPrice | plus: service.pa911_price %}
      {% endif %}
    {% endfor %}
    
    {% if totalPrice > 0 %}
      {% assign totalInDollars = totalPrice | divided_by: 100.0 %}
      <p><strong>Total Value of All Services:</strong> ${{ totalInDollars | round: 2 }}</p>
    {% endif %}
  </div>
</div>
```

### Key Learning Points

- Converting Dataverse currency (stored in cents) to dollars
- Using `divided_by` with decimal values
- Using `round` to format currency
- Using `plus` filter for calculations
- Conditional display for free services

---

## Story 7: Appointment Status Badge

### User Story

**As a** pet owner  
**I want to** see appointment status with color-coded badges  
**So that** I can quickly identify appointment states

### Acceptance Criteria

- [ ] Each appointment displays a status badge
- [ ] Badge color matches status (green=confirmed, red=cancelled, etc.)
- [ ] Status text is human-readable
- [ ] Different statuses show different styling

### Liquid Concepts

- `case/when` - Switch-like conditional logic
- `assign` - Set CSS class variables
- Conditional CSS classes
- Status code handling

### Implementation

```liquid
<div class="container mt-4">
  <h1>Appointment Status</h1>
  
  {% fetchxml appointments_status %}
  <fetch>
    <entity name="appointment">
      <attribute name="activityid" />
      <attribute name="subject" />
      <attribute name="scheduledstart" />
      <attribute name="statuscode" />
      <attribute name="statecode" />
      <link-entity name="pa911_pet" from="pa911_petid" to="pa911_pet" alias="pet">
        <attribute name="pa911_name" />
        <link-entity name="contact" from="contactid" to="pa911_petowner" alias="owner">
          <filter>
            <condition attribute="contactid" operator="eq" value="{{ user.id }}" />
          </filter>
        </link-entity>
      </link-entity>
      <order attribute="scheduledstart" descending="true" />
    </entity>
  </fetch>
  {% endfetchxml %}

  <div class="list-group">
    {% for appointment in appointments_status.results.entities %}
      {% assign statusLabel = '' %}
      {% assign statusClass = '' %}
      
      {% case appointment.statuscode %}
        {% when '1' %}
          {% assign statusLabel = 'Requested' %}
          {% assign statusClass = 'warning' %}
        {% when '2' %}
          {% assign statusLabel = 'Confirmed' %}
          {% assign statusClass = 'success' %}
        {% when '3' %}
          {% assign statusLabel = 'Arrived' %}
          {% assign statusClass = 'info' %}
        {% when '4' %}
          {% assign statusLabel = 'Completed' %}
          {% assign statusClass = 'primary' %}
        {% when '5' %}
          {% assign statusLabel = 'Cancelled' %}
          {% assign statusClass = 'danger' %}
        {% when '6' %}
          {% assign statusLabel = 'No-Show' %}
          {% assign statusClass = 'secondary' %}
        {% else %}
          {% assign statusLabel = 'Unknown' %}
          {% assign statusClass = 'secondary' %}
      {% endcase %}

      <div class="list-group-item">
        <div class="d-flex w-100 justify-content-between">
          <h5 class="mb-1">{{ appointment.subject }}</h5>
          <span class="badge bg-{{ statusClass }}">{{ statusLabel }}</span>
        </div>
        <p class="mb-1">
          <strong>Pet:</strong> {{ appointment.pet.pa911_name }}<br>
          <strong>Date:</strong> {{ appointment.scheduledstart | date: "%B %d, %Y at %I:%M %p" }}
        </p>
      </div>
    {% endfor %}
  </div>
</div>
```

### Key Learning Points

- Using `case/when` for multiple value comparisons
- Assigning variables for reuse (`statusLabel`, `statusClass`)
- Dynamic CSS class assignment
- Handling status codes with readable labels

---

## Story 8: Pet Profile Card

### User Story

**As a** pet owner  
**I want to** view a detailed profile card for my pet  
**So that** I can see all their information in one place

### Acceptance Criteria

- [ ] Card displays all pet information
- [ ] Calculated fields show age and other derived data
- [ ] Related information (appointments count) is displayed
- [ ] Card is well-formatted and readable

### Liquid Concepts

- `assign` - Store calculated values
- `capture` - Capture content blocks
- `minus` filter - Date calculations
- `size` - Count related records
- Combined Liquid concepts

### Implementation

```liquid
{% assign petId = request.params['id'] %}

{% fetchxml pet_details %}
<fetch>
  <entity name="pa911_pet">
    <attribute name="pa911_petid" />
    <attribute name="pa911_name" />
    <attribute name="pa911_species" />
    <attribute name="pa911_breed" />
    <attribute name="pa911_dateofbirth" />
    <attribute name="pa911_weight" />
    <attribute name="pa911_notes" />
    <filter>
      <condition attribute="pa911_petid" operator="eq" value="{{ petId }}" />
      <condition attribute="pa911_petowner" operator="eq" value="{{ user.id }}" />
    </filter>
  </entity>
</fetch>
{% endfetchxml %}

{% if pet_details.results.entities.size > 0 %}
  {% assign pet = pet_details.results.entities.first %}
  
  {% comment %} Calculate pet age {% endcomment %}
  {% if pet.pa911_dateofbirth %}
    {% assign birthDate = pet.pa911_dateofbirth | date: '%s' %}
    {% assign currentDate = now | date: '%s' %}
    {% assign ageInSeconds = currentDate | minus: birthDate %}
    {% assign ageInYears = ageInSeconds | divided_by: 31536000.0 | round: 1 %}
  {% endif %}

  {% comment %} Get appointment count {% endcomment %}
  {% fetchxml pet_appointments %}
  <fetch>
    <entity name="appointment">
      <attribute name="activityid" />
      <filter>
        <condition attribute="pa911_pet" operator="eq" value="{{ pet.pa911_petid }}" />
      </filter>
    </entity>
  </fetch>
  {% endfetchxml %}
  {% assign appointmentCount = pet_appointments.results.entities.size %}

  {% comment %} Determine species label {% endcomment %}
  {% assign speciesLabel = 'Unknown' %}
  {% if pet.pa911_species == '144400000' %}
    {% assign speciesLabel = 'Dog' %}
  {% elsif pet.pa911_species == '144400001' %}
    {% assign speciesLabel = 'Cat' %}
  {% elsif pet.pa911_species == '144400002' %}
    {% assign speciesLabel = 'Bird' %}
  {% elsif pet.pa911_species == '144400003' %}
    {% assign speciesLabel = 'Reptile' %}
  {% elsif pet.pa911_species == '144400004' %}
    {% assign speciesLabel = 'Other' %}
  {% endif %}

  <div class="container mt-4">
    <div class="card">
      <div class="card-header">
        <h2>{{ pet.pa911_name }}</h2>
      </div>
      <div class="card-body">
        {% capture petInfo %}
          <div class="row">
            <div class="col-md-6">
              <p><strong>Species:</strong> {{ speciesLabel }}</p>
              {% if pet.pa911_breed %}
                <p><strong>Breed:</strong> {{ pet.pa911_breed }}</p>
              {% endif %}
              {% if pet.pa911_dateofbirth %}
                <p><strong>Date of Birth:</strong> {{ pet.pa911_dateofbirth | date: "%B %d, %Y" }}</p>
                <p><strong>Age:</strong> {{ ageInYears }} years</p>
              {% endif %}
            </div>
            <div class="col-md-6">
              {% if pet.pa911_weight %}
                <p><strong>Weight:</strong> {{ pet.pa911_weight }} lbs</p>
              {% endif %}
              <p><strong>Total Appointments:</strong> {{ appointmentCount }}</p>
            </div>
          </div>
        {% endcapture %}
        {{ petInfo }}

        {% if pet.pa911_notes %}
          <div class="mt-3">
            <h5>Medical Notes</h5>
            <p class="text-muted">{{ pet.pa911_notes }}</p>
          </div>
        {% endif %}

        <div class="mt-4">
          <a href="/pet-edit?id={{ pet.pa911_petid }}" class="btn btn-primary">Edit Pet</a>
          <a href="/appointments?pet={{ pet.pa911_petid }}" class="btn btn-outline-primary">View Appointments</a>
        </div>
      </div>
    </div>
  </div>
{% else %}
  <div class="container mt-4">
    <div class="alert alert-danger">
      <p>Pet not found or you don't have permission to view this pet.</p>
    </div>
  </div>
{% endif %}
```

### Key Learning Points

- Using `assign` for multiple calculated values
- Using `capture` to store HTML blocks
- Date calculations with `minus` and `divided_by`
- Counting related records with `.size`
- Combining multiple Liquid concepts in one template

---

## Summary

These 8 user stories cover the essential Liquid syntax concepts for Power Pages:

1. **Basic Queries** - FetchXML and filtering
2. **Loops and Collections** - Iterating through data
3. **Conditional Logic** - if/else, case/when
4. **Filters** - Formatting dates, text, numbers
5. **Objects** - user, request, now
6. **Variables** - assign, capture
7. **Relationships** - Linked entities and filtering

Continue practicing with these patterns as you build more complex pages in Day 2 and Day 3.

---

## References

- [Power Pages Liquid Objects](https://learn.microsoft.com/en-us/power-pages/configure/liquid/liquid-objects)
- [Power Pages Liquid Filters](https://learn.microsoft.com/en-us/power-pages/configure/liquid/liquid-filters)
- [FetchXML Query Syntax](https://learn.microsoft.com/en-us/power-pages/configure/fetchxml)
- [Data Model Design](data-model.md) - Table structure reference


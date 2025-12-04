# Custom Web Templates - Reusable Components

## Overview

This guide covers creating custom web template components using the `{% manifest %}` tag, enabling pro-developers to build reusable, configurable components that low-code makers can use in Design Studio.

**Prerequisites**:
- Complete [Liquid Syntax Fundamentals](../day-1/user-stories.md) - Understand Liquid basics
- Familiarity with HTML/CSS
- Basic JavaScript knowledge helpful

**Note**: This is an optional advanced topic. OOTB Entity Forms and Lists may be sufficient for many scenarios.

---

## What are Web Template Components?

Web template components are reusable Liquid templates that can be:
- **Added to pages** via Design Studio's "Add component" feature
- **Configured** with parameters through Design Studio UI
- **Reused** across multiple pages
- **Customized** per instance with different parameter values

### Benefits

- **Separation of Concerns**: Developers build components, makers configure them
- **Reusability**: Write once, use many times
- **Consistency**: Standardized components across the site
- **Flexibility**: Parameters allow customization per instance

---

## Component Architecture

### Manifest Structure

The `{% manifest %}` tag defines component metadata:

```liquid
{% manifest %}
{
  "type": "Functional",
  "displayName": "Component Name",
  "description": "Component description",
  "tables": ["table1", "table2"],
  "params": [
    {
      "id": "param1",
      "displayName": "Parameter 1",
      "description": "Parameter description"
    }
  ]
}
{% endmanifest %}
```

### Manifest Properties

| Property | Required | Description |
|----------|----------|-------------|
| `type` | Yes | Must be `"Functional"` for Design Studio components |
| `displayName` | Yes | Name shown in Design Studio component picker |
| `description` | No | Tooltip text in Design Studio |
| `tables` | No | Array of table logical names for Data workspace navigation |
| `params` | No | Array of parameter definitions |

### Parameter Structure

Each parameter in the `params` array:

| Property | Required | Description |
|----------|----------|-------------|
| `id` | Yes | Variable name used in Liquid code (must match variable name) |
| `displayName` | Yes | Label shown in Design Studio |
| `description` | No | Tooltip text for the parameter |

---

## Example 1: Service Card Component

### Use Case

Display a service card with configurable title, count, and columns.

### Web Template Code

Create a new web template: **Service Card Component**

```liquid
{% manifest %}
{
  "type": "Functional",
  "displayName": "Service Cards",
  "description": "Displays services in a card layout",
  "tables": ["pa911_service"],
  "params": [
    {
      "id": "title",
      "displayName": "Title",
      "description": "Heading for this component"
    },
    {
      "id": "count",
      "displayName": "Count",
      "description": "Number of services to display"
    },
    {
      "id": "columns",
      "displayName": "Columns",
      "description": "Number of columns (1-4)"
    }
  ]
}
{% endmanifest %}

{% comment %} Convert parameters to appropriate types {% endcomment %}
{% assign service_count = count | default: 10 | integer %}
{% assign column_count = columns | default: 3 | integer %}
{% assign column_class = 'col-md-' | append: 12 | divided_by: column_count %}

<div class="container mt-4">
  {% if title %}
    <h2>{{ title }}</h2>
  {% endif %}
  
  {% fetchxml services_query %}
  <fetch>
    <entity name="pa911_service">
      <attribute name="pa911_serviceid" />
      <attribute name="pa911_name" />
      <attribute name="pa911_description" />
      <attribute name="pa911_duration" />
      <attribute name="pa911_price" />
      <filter>
        <condition attribute="statecode" operator="eq" value="0" />
      </filter>
      <order attribute="pa911_name" />
    </entity>
  </fetch>
  {% endfetchxml %}
  
  {% if services_query.results.entities.size > 0 %}
    <div class="row">
      {% for service in services_query.results.entities limit: service_count %}
        <div class="{{ column_class }} mb-4">
          <div class="card h-100">
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
                  {% assign priceInDollars = service.pa911_price | divided_by: 100.0 %}
                  <li><strong>Price:</strong> ${{ priceInDollars | round: 2 }}</li>
                {% endif %}
              </ul>
              <a href="/book-appointment?service={{ service.pa911_serviceid }}" class="btn btn-primary">Book Now</a>
            </div>
          </div>
        </div>
      {% endfor %}
    </div>
  {% else %}
    <div class="alert alert-info">
      <p>No services are currently available.</p>
    </div>
  {% endif %}
</div>
```

### Usage in Design Studio

1. Open a web page in Design Studio
2. Click **Add component**
3. Select **Service Cards** from the component list
4. Configure parameters:
   - **Title**: "Our Services"
   - **Count**: 6
   - **Columns**: 3
5. Component is added to the page

### Usage in Code

Add to a web page using Liquid include:

```liquid
{% include 'Service Card Component' title: 'Our Services' count: '6' columns: '3' %}
```

---

## Example 2: Available Slots Component

### Use Case

Display available appointment slots filtered by service, with configurable display options.

### Web Template Code

Create a new web template: **Available Slots Component**

```liquid
{% manifest %}
{
  "type": "Functional",
  "displayName": "Available Slots",
  "description": "Shows available appointment slots for a service",
  "tables": ["pa911_appointmentslot", "pa911_service"],
  "params": [
    {
      "id": "service_id",
      "displayName": "Service",
      "description": "Service ID to filter slots"
    },
    {
      "id": "days_ahead",
      "displayName": "Days Ahead",
      "description": "Number of days in the future to show (default: 30)"
    },
    {
      "id": "show_time_only",
      "displayName": "Show Time Only",
      "description": "Show only time, not full date (true/false)"
    }
  ]
}
{% endmanifest %}

{% comment %} Convert and validate parameters {% endcomment %}
{% assign target_service = service_id | default: '' %}
{% assign days_lookahead = days_ahead | default: 30 | integer %}
{% assign time_only = show_time_only | default: 'false' %}

{% if target_service == blank %}
  <div class="alert alert-warning">
    <p>Please specify a service to display available slots.</p>
  </div>
{% else %}
  {% comment %} Calculate date range {% endcomment %}
  {% assign start_date = now | date: '%Y-%m-%dT%H:%M:%SZ' %}
  {% assign end_date = now | date: '%s' | plus: days_lookahead | times: 86400 | date: '%Y-%m-%dT%H:%M:%SZ' %}
  
  {% fetchxml slots_query %}
  <fetch>
    <entity name="pa911_appointmentslot">
      <attribute name="pa911_appointmentslotid" />
      <attribute name="pa911_name" />
      <attribute name="pa911_starttime" />
      <attribute name="pa911_endtime" />
      <filter>
        <condition attribute="pa911_service" operator="eq" value="{{ target_service }}" />
        <condition attribute="pa911_isavailable" operator="eq" value="true" />
        <condition attribute="statecode" operator="eq" value="0" />
        <condition attribute="pa911_starttime" operator="ge" value="{{ start_date }}" />
        <condition attribute="pa911_starttime" operator="le" value="{{ end_date }}" />
      </filter>
      <order attribute="pa911_starttime" />
    </entity>
  </fetch>
  {% endfetchxml %}
  
  {% if slots_query.results.entities.size > 0 %}
    <div class="available-slots">
      <h3>Available Time Slots</h3>
      <div class="row">
        {% for slot in slots_query.results.entities %}
          <div class="col-md-4 mb-3">
            <div class="card">
              <div class="card-body">
                {% if time_only == 'true' %}
                  <h6 class="card-title">
                    {{ slot.pa911_starttime | date: "%I:%M %p" }} - 
                    {{ slot.pa911_endtime | date: "%I:%M %p" }}
                  </h6>
                  <small class="text-muted">
                    {{ slot.pa911_starttime | date: "%B %d" }}
                  </small>
                {% else %}
                  <h6 class="card-title">
                    {{ slot.pa911_starttime | date: "%A, %B %d, %Y" }}
                  </h6>
                  <p class="card-text">
                    {{ slot.pa911_starttime | date: "%I:%M %p" }} - 
                    {{ slot.pa911_endtime | date: "%I:%M %p" }}
                  </p>
                {% endif %}
                <button class="btn btn-sm btn-primary" 
                        onclick="selectSlot('{{ slot.pa911_appointmentslotid }}')">
                  Select
                </button>
              </div>
            </div>
          </div>
        {% endfor %}
      </div>
    </div>
  {% else %}
    <div class="alert alert-info">
      <p>No available slots found for the selected service.</p>
    </div>
  {% endif %}
{% endif %}

<script>
function selectSlot(slotId) {
  // Set slot value in parent form
  const slotField = document.querySelector('[data-attribute="pa911_appointmentslot"]');
  if (slotField) {
    slotField.value = slotId;
    alert('Slot selected!');
  }
}
</script>
```

### Usage

```liquid
{% include 'Available Slots Component' service_id: 'SERVICE-GUID-HERE' days_ahead: '14' show_time_only: 'true' %}
```

---

## Example 3: Booking Request Status Badge

### Use Case

Display a status badge for booking requests with configurable styling.

### Web Template Code

Create a new web template: **Booking Status Badge**

```liquid
{% manifest %}
{
  "type": "Functional",
  "displayName": "Booking Status Badge",
  "description": "Displays booking request status with color coding",
  "tables": ["pa911_bookingrequest"],
  "params": [
    {
      "id": "status_value",
      "displayName": "Status Value",
      "description": "Status code value (144400000=Pending, 144400001=Approved, 144400002=Rejected)"
    },
    {
      "id": "size",
      "displayName": "Badge Size",
      "description": "Size: small, medium, or large (default: medium)"
    }
  ]
}
{% endmanifest %}

{% assign status_code = status_value | default: '144400000' %}
{% assign badge_size = size | default: 'medium' %}

{% comment %} Determine status label and color {% endcomment %}
{% assign status_label = '' %}
{% assign badge_class = '' %}

{% case status_code %}
  {% when '144400000' %}
    {% assign status_label = 'Pending' %}
    {% assign badge_class = 'warning' %}
  {% when '144400001' %}
    {% assign status_label = 'Approved' %}
    {% assign badge_class = 'success' %}
  {% when '144400002' %}
    {% assign status_label = 'Rejected' %}
    {% assign badge_class = 'danger' %}
  {% else %}
    {% assign status_label = 'Unknown' %}
    {% assign badge_class = 'secondary' %}
{% endcase %}

{% comment %} Determine size class {% endcomment %}
{% assign size_class = '' %}
{% case badge_size %}
  {% when 'small' %}
    {% assign size_class = 'badge-sm' %}
  {% when 'large' %}
    {% assign size_class = 'badge-lg' %}
  {% else %}
    {% assign size_class = '' %}
{% endcase %}

<span class="badge bg-{{ badge_class }} {{ size_class }}">{{ status_label }}</span>

<style>
.badge-sm {
  font-size: 0.75rem;
  padding: 0.25rem 0.5rem;
}
.badge-lg {
  font-size: 1rem;
  padding: 0.5rem 1rem;
}
</style>
```

### Usage

```liquid
{% include 'Booking Status Badge' status_value: '144400001' size: 'large' %}
```

---

## Best Practices

### Parameter Design

1. **Use Descriptive Names**: Parameter IDs should be clear (`service_id` not `s`)
2. **Provide Defaults**: Always provide default values in Liquid code
3. **Type Conversion**: Convert string parameters to appropriate types
4. **Validation**: Validate parameter values before use

### Code Organization

1. **Manifest First**: Always place manifest at the top of the template
2. **Comments**: Add comments explaining complex logic
3. **Error Handling**: Handle missing or invalid parameters gracefully
4. **Reusability**: Keep components focused and reusable

### Performance

1. **Limit Queries**: Use `limit` in FetchXML when appropriate
2. **Cache Results**: Consider caching for frequently accessed data
3. **Optimize Filters**: Use efficient FetchXML filters
4. **Minimize JavaScript**: Keep client-side code minimal

### User Experience

1. **Clear Messages**: Show helpful messages when no data found
2. **Loading States**: Consider showing loading indicators
3. **Responsive Design**: Ensure components work on mobile
4. **Accessibility**: Follow accessibility best practices

---

## Advanced Patterns

### Dynamic Parameter Lists

Use JavaScript to populate parameters dynamically:

```liquid
{% manifest %}
{
  "type": "Functional",
  "displayName": "Dynamic Service Selector",
  "description": "Service selector with dynamic options",
  "tables": ["pa911_service"],
  "params": [
    {
      "id": "selected_service",
      "displayName": "Selected Service",
      "description": "Service ID"
    }
  ]
}
{% endmanifest %}

{% fetchxml services_list %}
<fetch>
  <entity name="pa911_service">
    <attribute name="pa911_serviceid" />
    <attribute name="pa911_name" />
    <filter>
      <condition attribute="statecode" operator="eq" value="0" />
    </filter>
  </entity>
</fetch>
{% endfetchxml %}

<select id="service-selector" class="form-control">
  <option value="">Select a service</option>
  {% for service in services_list.results.entities %}
    <option value="{{ service.pa911_serviceid }}" 
            {% if selected_service == service.pa911_serviceid %}selected{% endif %}>
      {{ service.pa911_name }}
    </option>
  {% endfor %}
</select>
```

### Component Composition

Combine multiple components:

```liquid
{% comment %} Main page using multiple components {% endcomment %}
<div class="container">
  {% include 'Service Card Component' title: 'Our Services' count: '6' columns: '3' %}
  
  {% if request.params['service'] %}
    {% include 'Available Slots Component' 
       service_id: request.params['service'] 
       days_ahead: '30' 
       show_time_only: 'false' %}
  {% endif %}
</div>
```

### JavaScript Integration

Add interactive behavior:

```liquid
{% manifest %}
{
  "type": "Functional",
  "displayName": "Interactive Service Cards",
  "description": "Service cards with click handlers",
  "tables": ["pa911_service"],
  "params": [
    {
      "id": "on_click_action",
      "displayName": "Click Action",
      "description": "Action when card clicked: 'book', 'details', or 'custom'"
    }
  ]
}
{% endmanifest %}

{% assign click_action = on_click_action | default: 'book' %}

{% fetchxml services %}
<!-- FetchXML here -->
{% endfetchxml %}

<div class="service-cards" data-action="{{ click_action }}">
  {% for service in services.results.entities %}
    <div class="card service-card" 
         data-service-id="{{ service.pa911_serviceid }}"
         onclick="handleServiceClick(this)">
      <!-- Card content -->
    </div>
  {% endfor %}
</div>

<script>
function handleServiceClick(card) {
  const action = document.querySelector('.service-cards').dataset.action;
  const serviceId = card.dataset.serviceId;
  
  switch(action) {
    case 'book':
      window.location.href = '/book-appointment?service=' + serviceId;
      break;
    case 'details':
      window.location.href = '/service-details?id=' + serviceId;
      break;
    case 'custom':
      // Custom action
      break;
  }
}
</script>
```

---

## Limitations

### Known Limitations

1. **No Nesting**: Web template components cannot be nested inside other components
2. **String Parameters**: All parameters are passed as strings (must convert types)
3. **No Complex Types**: Parameters cannot be objects or arrays
4. **Design Studio Only**: Components appear in Design Studio, not in all editors

### Workarounds

- **Complex Data**: Use comma-separated values and parse in Liquid
- **Multiple Parameters**: Pass related values as separate parameters
- **Nested Logic**: Use includes within the component template itself

---

## Troubleshooting

### Common Issues

**Issue**: Component doesn't appear in Design Studio
- **Check**: Manifest `type` is set to `"Functional"`
- **Check**: Template is saved and published
- **Check**: No syntax errors in manifest JSON

**Issue**: Parameters not working
- **Check**: Parameter `id` matches variable name in code
- **Check**: Parameters are converted to correct types
- **Check**: Default values are provided

**Issue**: Component displays incorrectly
- **Check**: HTML structure is valid
- **Check**: CSS classes are correct
- **Check**: Bootstrap version compatibility

**Issue**: FetchXML errors
- **Check**: Table and column names are correct
- **Check**: Filters use correct operators
- **Check**: Relationship names are correct

---

## References

- [Web Templates as Components](https://learn.microsoft.com/en-us/power-pages/configure/web-templates-as-components)
- [How to Create Web Template Component](https://learn.microsoft.com/en-us/power-pages/configure/web-templates-as-components-how-to)
- [Liquid Objects](https://learn.microsoft.com/en-us/power-pages/configure/liquid/liquid-objects)
- [FetchXML Syntax](https://learn.microsoft.com/en-us/power-pages/configure/fetchxml)

---

## When to Use Components vs. OOTB

### Use Components When:
- You need custom layout/styling
- You need complex data relationships
- You need reusable logic across pages
- You want makers to configure without code

### Use OOTB (Entity Forms/Lists) When:
- Standard CRUD operations are sufficient
- You want minimal code maintenance
- You need quick implementation
- Standard Dataverse views work for your needs

---

## Next Steps

- Practice creating components for your specific use cases
- Experiment with different parameter types
- Build a component library for your organization
- Share components across multiple Power Pages sites


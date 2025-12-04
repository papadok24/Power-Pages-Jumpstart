# Booking Request Form - Anonymous Entity Form

## Overview

This guide walks through creating an anonymous Entity Form for booking requests, allowing unauthenticated users to submit appointment requests without logging in.

**Prerequisites**: 
- Complete [Data Model Design](../day-1/data-model.md) - Booking Request and Appointment Slot tables created
- Complete [Identity and Contacts](identity-and-contacts.md) - Understand anonymous access patterns

---

## Step 1: Configure Table Permissions

Before creating the form, we need to allow anonymous users to create Booking Request records.

### Create Anonymous Table Permission

1. Navigate to **Power Pages** → **Your Site** → **Security** → **Table Permissions**
2. Click **New** to create a new table permission
3. Configure as follows:

| Setting | Value |
|---------|-------|
| **Name** | Booking Request - Anonymous Create |
| **Table** | Booking Request (pa911_bookingrequest) |
| **Web Role** | Anonymous Users |
| **Scope** | Global |
| **Privileges** | Create only |

4. Click **Save**

**Important**: Only grant Create privilege to anonymous users. Never allow Read, Update, or Delete for anonymous access.

---

## Step 2: Create Entity Form

### Basic Form Configuration

1. Navigate to **Power Pages** → **Your Site** → **Content** → **Entity Forms**
2. Click **New** to create a new form
3. Configure basic settings:

| Setting | Value |
|---------|-------|
| **Name** | Booking Request Form |
| **Table** | Booking Request (pa911_bookingrequest) |
| **Mode** | Insert (Create new records) |
| **Type** | Web Form |

4. Click **Save**

### Form Fields Configuration

Add the following fields to the form:

#### Contact Information Section

| Field | Logical Name | Required | Notes |
|-------|--------------|----------|-------|
| First Name | `pa911_firstname` | Yes | Single line of text |
| Last Name | `pa911_lastname` | Yes | Single line of text |
| Email | `pa911_email` | Yes | Email validation enabled |
| Phone | `pa911_phone` | No | Single line of text |

#### Pet Information Section

| Field | Logical Name | Required | Notes |
|-------|--------------|----------|-------|
| Pet Name | `pa911_petname` | Yes | Single line of text |
| Pet Species | `pa911_petspecies` | Yes | Choice field (Dog, Cat, Bird, Reptile, Other) |
| Pet Notes | `pa911_petnotes` | No | Multiple lines of text |

#### Appointment Details Section

| Field | Logical Name | Required | Notes |
|-------|--------------|----------|-------|
| Service | `pa911_service` | Yes | Lookup to Service table |
| Preferred Slot | `pa911_appointmentslot` | Yes | Lookup to Appointment Slot (filtered by Service) |

### Field Configuration Tips

1. **Service Lookup**:
   - Set **Filter**: `statecode = 0` (Active services only)
   - Enable **Search**: Yes
   - Display **Name** field

2. **Preferred Slot Lookup**:
   - Set **Filter**: `pa911_service = [Service Field Value] AND pa911_isavailable = true AND statecode = 0`
   - This requires JavaScript to dynamically filter slots based on selected service
   - Enable **Search**: Yes
   - Display **Name** field (formatted as date/time)

3. **Email Field**:
   - Enable **Email validation**: Yes
   - Set **Input type**: Email

4. **Pet Species**:
   - Display as **Dropdown**
   - Show all choice values

---

## Step 3: Configure Form Display Options

### Form Settings

1. **Success Message**: "Thank you! Your booking request has been submitted. You will receive an email invitation to access your portal account shortly."
2. **Success Redirect**: Create a confirmation page (e.g., `/booking-confirmation`)
3. **Error Message**: "There was an error submitting your request. Please try again or contact support."
4. **Show Required Fields Indicator**: Yes
5. **Enable CAPTCHA**: Recommended for anonymous forms

### Form Sections

Organize fields into logical sections:

```
┌─────────────────────────────────┐
│ Contact Information              │
│ - First Name                     │
│ - Last Name                      │
│ - Email                          │
│ - Phone                          │
└─────────────────────────────────┘

┌─────────────────────────────────┐
│ Pet Information                  │
│ - Pet Name                       │
│ - Pet Species                    │
│ - Pet Notes                     │
└─────────────────────────────────┘

┌─────────────────────────────────┐
│ Appointment Details              │
│ - Service                        │
│ - Preferred Slot                 │
└─────────────────────────────────┘
```

---

## Step 4: Add JavaScript for Dynamic Slot Filtering

The Appointment Slot lookup needs to filter based on the selected Service. Add JavaScript to the form:

### JavaScript Code

```javascript
// Wait for form to load
window.addEventListener('DOMContentLoaded', function() {
    const serviceField = document.querySelector('[data-attribute="pa911_service"]');
    const slotField = document.querySelector('[data-attribute="pa911_appointmentslot"]');
    
    if (serviceField && slotField) {
        // Listen for service selection change
        serviceField.addEventListener('change', function() {
            const selectedServiceId = this.value;
            
            if (selectedServiceId) {
                // Clear current slot selection
                slotField.value = '';
                
                // Filter slots by service
                // This requires custom FetchXML or Web API call
                filterSlotsByService(selectedServiceId, slotField);
            } else {
                // Clear slot options if no service selected
                clearSlotOptions(slotField);
            }
        });
    }
});

function filterSlotsByService(serviceId, slotField) {
    // Use FetchXML to get available slots for the service
    const fetchXml = `
        <fetch>
            <entity name="pa911_appointmentslot">
                <attribute name="pa911_appointmentslotid" />
                <attribute name="pa911_name" />
                <attribute name="pa911_starttime" />
                <filter>
                    <condition attribute="pa911_service" operator="eq" value="${serviceId}" />
                    <condition attribute="pa911_isavailable" operator="eq" value="true" />
                    <condition attribute="statecode" operator="eq" value="0" />
                    <condition attribute="pa911_starttime" operator="ge" value="${new Date().toISOString()}" />
                </filter>
                <order attribute="pa911_starttime" />
            </entity>
        </fetch>
    `;
    
    // Call Web API to get slots
    // Implementation depends on your Power Pages Web API configuration
    fetchAvailableSlots(fetchXml, slotField);
}

function fetchAvailableSlots(fetchXml, slotField) {
    // Use Power Pages Web API or Liquid to populate slots
    // This is a simplified example - actual implementation may vary
    const apiUrl = '/_api/pa911_appointmentslots?$filter=pa911_service eq ' + serviceId;
    
    fetch(apiUrl)
        .then(response => response.json())
        .then(data => {
            populateSlotDropdown(data.value, slotField);
        })
        .catch(error => {
            console.error('Error fetching slots:', error);
        });
}

function populateSlotDropdown(slots, slotField) {
    // Clear existing options
    const select = slotField.querySelector('select');
    if (select) {
        select.innerHTML = '<option value="">Select a time slot</option>';
        
        slots.forEach(slot => {
            const option = document.createElement('option');
            option.value = slot.pa911_appointmentslotid;
            option.textContent = formatSlotDisplay(slot);
            select.appendChild(option);
        });
    }
}

function formatSlotDisplay(slot) {
    // Format: "Dec 15, 2025 10:00 AM - 11:00 AM"
    const start = new Date(slot.pa911_starttime);
    const end = new Date(slot.pa911_endtime);
    return start.toLocaleDateString() + ' ' + 
           start.toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'}) + ' - ' +
           end.toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'});
}
```

**Note**: This JavaScript example is simplified. In practice, you may need to:
- Use Power Pages Web API endpoints
- Handle authentication for API calls
- Use Liquid to pre-populate slot options
- Consider using a custom web template component instead

---

## Step 5: Create Web Page for Form

1. Navigate to **Power Pages** → **Your Site** → **Content** → **Web Pages**
2. Create a new page:
   - **Name**: Book Appointment
   - **Partial URL**: `book-appointment`
   - **Parent Page**: Home (or appropriate parent)

3. Add the Entity Form to the page:
   - In page content, add: `{% entityform name:"Booking Request Form" %}`
   - Or use Design Studio to drag the form component onto the page

4. **Page Permissions**: 
   - Allow **Anonymous Users** to view this page
   - This enables unauthenticated access

---

## Step 6: Configure Success Page

Create a confirmation page that users see after submitting:

1. Create new **Web Page**:
   - **Name**: Booking Confirmation
   - **Partial URL**: `booking-confirmation`

2. Add content:
```liquid
<div class="container mt-5">
    <div class="alert alert-success">
        <h2>Booking Request Submitted!</h2>
        <p>Thank you for your booking request. We've received your information and will process it shortly.</p>
        <p>You will receive an email invitation to access your portal account where you can:</p>
        <ul>
            <li>View your booking request status</li>
            <li>Manage your pet information</li>
            <li>Book additional appointments</li>
        </ul>
        <p><strong>What happens next?</strong></p>
        <ol>
            <li>Check your email for the portal invitation</li>
            <li>Click the invitation link to register</li>
            <li>Log in to view your booking status</li>
        </ol>
    </div>
    <a href="/" class="btn btn-primary">Return to Home</a>
</div>
```

3. Update form **Success Redirect** to point to this page

---

## Step 7: Test the Form

### Testing Checklist

- [ ] Anonymous user can access the form page
- [ ] All required fields are marked and validated
- [ ] Service dropdown shows only active services
- [ ] Slot dropdown filters correctly based on selected service
- [ ] Form submission creates Booking Request record
- [ ] Success page displays after submission
- [ ] Email validation works correctly
- [ ] CAPTCHA (if enabled) functions properly

### Test Scenarios

1. **Valid Submission**:
   - Fill all required fields
   - Select a service
   - Select an available slot
   - Submit form
   - Verify record created in Dataverse

2. **Invalid Email**:
   - Enter invalid email format
   - Verify validation error displays

3. **No Service Selected**:
   - Leave service blank
   - Verify slot dropdown is disabled/empty

4. **Slot Unavailable**:
   - Select a service with no available slots
   - Verify appropriate message displays

---

## Advanced Configuration

### Custom Validation

Add custom validation using JavaScript:

```javascript
// Validate that selected slot is in the future
function validateSlotDate(slotField) {
    const selectedSlot = slotField.value;
    if (selectedSlot) {
        // Fetch slot details and validate date
        // Show error if slot is in the past
    }
}
```

### Pre-populate Fields from URL

Allow pre-selecting service from URL:

```liquid
{% assign preSelectedService = request.params['service'] %}
{% if preSelectedService %}
    <script>
        window.addEventListener('DOMContentLoaded', function() {
            const serviceField = document.querySelector('[data-attribute="pa911_service"]');
            if (serviceField) {
                serviceField.value = '{{ preSelectedService }}';
                // Trigger change event to load slots
                serviceField.dispatchEvent(new Event('change'));
            }
        });
    </script>
{% endif %}
```

### Styling and Branding

Customize form appearance:
- Use Bootstrap classes in form sections
- Add custom CSS for field styling
- Match site theme and branding

---

## Troubleshooting

### Common Issues

**Issue**: Form not accessible to anonymous users
- **Solution**: Check page permissions allow Anonymous Users
- **Solution**: Verify table permission is configured correctly

**Issue**: Slots not filtering by service
- **Solution**: Verify JavaScript is loaded correctly
- **Solution**: Check FetchXML filter syntax
- **Solution**: Ensure Web API is enabled for Appointment Slot table

**Issue**: Form submission fails
- **Solution**: Check table permission has Create privilege
- **Solution**: Verify all required fields are included
- **Solution**: Check browser console for JavaScript errors

**Issue**: Email validation not working
- **Solution**: Enable email validation on email field
- **Solution**: Check field type is set to Email

---

## Next Steps

- **[Power Automate Integration](power-automate-integration.md)** - Create flow to handle booking request processing
- **[Lists and Views](lists-and-views.md)** - Display booking requests to authenticated users

---

## References

- [Entity Forms Documentation](https://learn.microsoft.com/en-us/power-pages/configure/entity-forms)
- [Table Permissions](https://learn.microsoft.com/en-us/power-pages/security/table-permissions)
- [Power Pages Web API](https://learn.microsoft.com/en-us/power-pages/configure/web-api-overview)
- [Form JavaScript Examples](https://learn.microsoft.com/en-us/power-pages/configure/entity-forms#javascript)


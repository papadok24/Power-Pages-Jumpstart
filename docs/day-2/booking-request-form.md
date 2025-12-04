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

## Step 5: Page Layout and Content Structure

Before creating the web page, plan the layout and prepare the web copy to create an engaging, professional booking experience for anonymous users.

### 5.1 Layout Options

Choose a layout approach that best fits your site's design and user experience goals:

#### Option 1: Centered Card Layout (Recommended)

**Best for**: Most use cases, especially when you want a focused, distraction-free booking experience.

**Structure**:
- **Hero Section**: Centered header area at the top with main heading and subheading text
- **Form Container**: Single centered column (approximately 8-10 columns wide on large screens) containing the form in a card-style container with subtle shadow
- **Trust Indicators**: Three-column section below the form displaying key benefits (Quick Booking, Secure & Private, Email Confirmation) with icons
- **Responsive Behavior**: On mobile devices, the layout stacks vertically with full-width elements

**Benefits**:
- Clean, focused user experience
- Excellent mobile responsiveness
- Easy to scan and complete
- Professional appearance

#### Option 2: Two-Column Layout

**Best for**: When you want to provide additional context, clinic information, or trust-building content alongside the form.

**Structure**:
- **Left Sidebar** (approximately 4 columns): Informational card containing:
  - Clinic benefits or "Why Choose Us" section
  - Contact information (phone, hours)
  - Trust indicators or testimonials
- **Right Column** (approximately 8 columns): Form area with:
  - Page heading and introductory text
  - Form container in a card-style layout
- **Responsive Behavior**: On mobile devices, sidebar stacks above the form

**Benefits**:
- Provides context and builds trust
- Maximizes use of page space
- Can reduce form abandonment with supporting information
- Good for sites with established brand presence

**Layout Selection Guide**:
- Use **Centered Card** if: Your site is modern/minimalist, you want users to focus solely on booking, or you have limited supporting content
- Use **Two-Column** if: You want to highlight clinic benefits, provide contact information, or include trust-building elements during the booking process

### 5.2 Page Structure Components

Regardless of which layout option you choose, include these key components:

**Hero/Header Section**:
- Main page heading (H1) - clear, action-oriented
- Subheading text - explains the value proposition and sets expectations
- Centered alignment for maximum impact
- Adequate spacing above and below

**Form Container**:
- Card-style container with subtle border or shadow to separate form from page background
- Generous padding for comfortable form completion
- Responsive width that adapts to screen size
- Clear visual hierarchy with section headers

**Trust Indicators Section** (for Centered Card layout):
- Three equal-width columns on desktop
- Each indicator includes: icon, bold heading, brief description
- Positioned below the form to reinforce confidence after completion
- Stacks vertically on mobile devices

**Supporting Information**:
- "What Happens Next?" informational section explaining the process
- Privacy/security statement for anonymous users
- Contact information or help text if needed
- Positioned below form or in sidebar (depending on layout)

### 5.3 Web Copy Content

Use the following copy structure to create an engaging, professional booking experience. All copy uses a balanced tone: friendly and approachable while maintaining professionalism.

#### Page Header Copy

**Main Heading**:
"Book Your Pet's Appointment"

**Subheading**:
"Schedule a visit with our experienced veterinary team. We're here to keep your furry, feathered, or scaled family members healthy and happy. After submitting your request, you'll receive instant access to your personal portal where you can track appointments and manage your pet's care."

#### Section Headers and Helper Text

**Contact Information Section**:
- **Section Header**: "Your Contact Information"
- **Helper Text**: "We'll use this information to confirm your appointment and send you portal access. Your data is secure and will only be used to manage your pet's appointments."

**Pet Information Section**:
- **Section Header**: "About Your Pet"
- **Helper Text**: "Help us prepare for your visit by sharing your pet's information. This ensures we can provide the best possible care."

**Appointment Details Section**:
- **Section Header**: "Appointment Preferences"
- **Helper Text**: "Choose a service and your preferred time slot. Available slots will appear after you select a service."

#### Field-Level Copy

**First Name**:
- **Help Text**: "As it appears on your ID"

**Last Name**:
- **Help Text**: "As it appears on your ID"

**Email**:
- **Help Text**: "We'll send your portal invitation and appointment confirmation to this address"
- **Placeholder**: "your.email@example.com"

**Phone**:
- **Help Text**: "Optional - We may call to confirm your appointment or discuss scheduling options"
- **Placeholder**: "(555) 123-4567"

**Pet Name**:
- **Help Text**: "What's your pet's name?"
- **Placeholder**: "Enter your pet's name"

**Pet Species**:
- **Help Text**: "Select the type of pet you're bringing in for care"

**Pet Notes**:
- **Help Text**: "Any special concerns, medical history, or information we should know? This helps us prepare for your visit."
- **Placeholder**: "Optional: Share any relevant information about your pet's health, behavior, or previous treatments..."

**Service**:
- **Help Text**: "What type of service does your pet need? Select from our available services."
- **Placeholder**: "Select a service"

**Preferred Slot**:
- **Help Text**: "Available appointment times will appear after you select a service. Times are shown in your local timezone."
- **Placeholder**: "Select a service first" (when no service selected) or "Choose your preferred time" (after service selected)

#### Supporting Content

**Trust Indicators** (for display below form in Centered Card layout):

1. **Quick Booking**
   - Description: "Get scheduled in minutes with our streamlined booking process"

2. **Secure & Private**
   - Description: "Your information is protected and will only be used to manage your pet's care"

3. **Email Confirmation**
   - Description: "Portal access sent instantly so you can track your appointment status"

**"What Happens Next?" Information Section**:

Heading: "What Happens Next?"

Content:
"After you submit your booking request:

1. **Check your email** - You'll receive a portal invitation within minutes (check your spam folder if you don't see it)
2. **Create your account** - Click the invitation link to set up your secure portal account
3. **Track your booking** - Log in anytime to view your booking status and manage your pet's information
4. **Confirmation call** - Our team will contact you to confirm your appointment details

You'll be able to view your booking request status, manage your pet information, and book additional appointments through your personal portal."

**Privacy/Security Statement**:

"Your information is secure and will only be used to manage your pet's appointments and provide veterinary care. We respect your privacy and follow industry-standard security practices. [Link to privacy policy if available]"

**Contact Information** (optional, for sidebar or footer):

"Need help? Contact us:
- **Phone**: (555) 123-4567
- **Hours**: Monday - Friday, 8:00 AM - 6:00 PM
- **Email**: appointments@pawsfirstvet.com"

---

## Step 6: Create Web Page for Form

1. Navigate to **Power Pages** → **Your Site** → **Content** → **Web Pages**
2. Create a new page:
   - **Name**: Book Appointment
   - **Partial URL**: `book-appointment`
   - **Parent Page**: Home (or appropriate parent)

3. **Apply Layout and Copy**:
   - Choose your preferred layout option from Step 5.1 (Centered Card recommended)
   - Implement the page structure components from Step 5.2
   - Add the web copy content from Step 5.3, including headers, section text, and helper text
   - Use Design Studio or web templates to structure the page according to your chosen layout

4. **Add the Entity Form**:
   - In page content, add: `{% entityform name:"Booking Request Form" %}`
   - Or use Design Studio to drag the form component onto the page
   - Ensure the form is placed within the form container area of your chosen layout

5. **Page Permissions**: 
   - Allow **Anonymous Users** to view this page
   - This enables unauthenticated access

---

## Step 7: Configure Success Page

Create a confirmation page that users see after submitting their booking request. This page should provide clear next steps and set expectations for what happens after submission.

1. Create new **Web Page**:
   - **Name**: Booking Confirmation
   - **Partial URL**: `booking-confirmation`
   - **Parent Page**: Home (or appropriate parent)

2. **Page Structure and Copy**:

**Main Heading**:
"Booking Request Submitted Successfully!"

**Confirmation Message**:
"Thank you for requesting an appointment with PawsFirst Veterinary Clinic. We've received your booking request and will process it shortly. Our team will review your information and confirm your appointment time."

**Portal Access Information**:
"You will receive an email invitation to access your personal portal account. This secure portal allows you to:"
- View your booking request status in real-time
- Manage your pet's information and medical history
- Book additional appointments at your convenience
- Access appointment reminders and important updates

**"What Happens Next?" Section**:

Heading: "Here's What Happens Next"

Step-by-step process:
1. **Check Your Email** - Within the next few minutes, you'll receive a portal invitation email. Please check your spam or junk folder if you don't see it in your inbox.
2. **Create Your Account** - Click the invitation link in the email to set up your secure portal account. This takes just a minute.
3. **Track Your Booking** - Once logged in, you can view your booking request status and see when it's been confirmed.
4. **Confirmation Call** - Our team will contact you within 24-48 hours to confirm your appointment details and answer any questions.

**Additional Information**:
"If you have any questions or need to make changes to your booking request, please contact us at (555) 123-4567 or appointments@pawsfirstvet.com. Our team is here to help!"

**Call-to-Action**:
- Primary button: "Return to Home" (links to homepage)
- Secondary link: "Learn More About Our Services" (optional, links to services page)

3. **Page Permissions**:
   - Allow **Anonymous Users** to view this page
   - This ensures users can access the confirmation page even if not logged in

4. Update form **Success Redirect** to point to this page:
   - In the Entity Form settings, set **Success Redirect** to `/booking-confirmation`

---

## Step 8: Test the Form

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


# Power Automate Integration - User Onboarding Flow

## Overview

This guide covers creating a Power Automate cloud flow that automatically processes booking requests, creates Contact records, and sends portal invitations to new users.

**Prerequisites**:
- Complete [Booking Request Form](booking-request-form.md) - Form must be functional
- Complete [Identity and Contacts](identity-and-contacts.md) - Understand Contact system
- Power Automate license (included with Power Pages)

---

## Flow Architecture

### High-Level Flow

```
Booking Request Created
        │
        ▼
┌───────────────────────┐
│ Check if Contact      │
│ exists (by email)     │
└───────────┬───────────┘
            │
    ┌───────┴───────┐
    │               │
    ▼               ▼
Exists?          Not Exists?
    │               │
    │               ▼
    │       ┌───────────────┐
    │       │ Create Contact│
    │       │ Record        │
    │       └───────┬───────┘
    │               │
    └───────┬───────┘
            │
            ▼
┌───────────────────────┐
│ Link Contact to        │
│ Booking Request        │
└───────────┬───────────┘
            │
            ▼
┌───────────────────────┐
│ Send Portal Invitation │
│ Email                  │
└───────────┬───────────┘
            │
            ▼
┌───────────────────────┐
│ Update Booking Request│
│ Status to "Pending"   │
└───────────────────────┘
```

---

## Step 1: Create Solution-Aware Flow

### Why Solution-Aware?

Storing flows in solutions enables:
- **Application Lifecycle Management (ALM)** - Version control and deployment
- **Environment Management** - Move flows between dev/test/prod
- **Dependency Tracking** - Understand what components work together
- **Backup and Recovery** - Easier to restore or replicate

### Create Solution

1. Navigate to **Power Platform Admin Center** → **Solutions**
2. Click **New solution**
3. Configure:
   - **Display Name**: PawsFirst Portal Flows
   - **Name**: PawsFirstPortalFlows (auto-generated)
   - **Publisher**: Your organization publisher
   - **Version**: 1.0.0.0

4. Click **Create**

### Create Flow in Solution

1. Open your solution
2. Click **New** → **Automation** → **Cloud flow** → **Automated**
3. Name the flow: **Process Booking Request - User Onboarding**
4. **Important**: The flow is automatically added to your solution

---

## Step 2: Configure Flow Trigger

### Dataverse Trigger

1. Search for **"When a row is added, modified or deleted"** trigger
2. Select **When a row is added**
3. Configure trigger:
   - **Environment**: Your Power Platform environment
   - **Table name**: Booking Request (pa911_bookingrequest)
   - **Scope**: Organization

4. Click **Show advanced options**:
   - **Filter rows**: `pa911_requeststatus eq 144400000` (Pending status only)
   - This ensures we only process new requests, not updates

---

## Step 3: Check if Contact Exists

### List Rows Action

1. Add action: **List rows** (Dataverse)
2. Configure:
   - **Table name**: Contacts
   - **Filter rows**: `emailaddress1 eq '@{triggerOutputs()?['body/pa911_email']}'`
   - **Select columns**: `contactid`, `emailaddress1`, `firstname`, `lastname`

3. **Purpose**: Check if a Contact with this email already exists

### Condition Check

1. Add **Condition** control
2. Configure:
   - **Condition**: `length(body('List_rows')?['value'])` is greater than `0`
   - This checks if any contacts were found

3. **If yes**: Contact exists → Use existing Contact
4. **If no**: Contact doesn't exist → Create new Contact

---

## Step 4: Create Contact (If Not Exists)

### Create Row Action (False Branch)

1. In the **If no** branch, add **Create a new row** (Dataverse)
2. Configure:
   - **Table name**: Contacts
   - **Fields**:
     - `firstname`: `@{triggerOutputs()?['body/pa911_firstname']}`
     - `lastname`: `@{triggerOutputs()?['body/pa911_lastname']}`
     - `emailaddress1`: `@{triggerOutputs()?['body/pa911_email']}`
     - `telephone1`: `@{triggerOutputs()?['body/pa911_phone']}`
     - `adx_identity_logon_enabled`: `true` (Enable portal login)

3. **Name the output**: `NewContact`

### Get Existing Contact (True Branch)

1. In the **If yes** branch, add **Get a row by ID** (Dataverse)
2. Configure:
   - **Table name**: Contacts
   - **Row ID**: `@{first(body('List_rows')?['value'])?['contactid']}`
   - **Select columns**: `contactid`, `emailaddress1`, `firstname`, `lastname`

3. **Name the output**: `ExistingContact`

---

## Step 5: Determine Contact ID

### Initialize Variable

1. After the Condition, add **Initialize variable**
2. Configure:
   - **Name**: ContactId
   - **Type**: String
   - **Value**: 
     ```
     @{if(equals(length(body('List_rows')?['value']), 0),
            outputs('NewContact')?['body/contactid'],
            outputs('ExistingContact')?['body/contactid'])}
     ```

This variable will contain the Contact ID whether it was created or found.

---

## Step 6: Link Contact to Booking Request

### Update Row Action

1. Add **Update a row** (Dataverse)
2. Configure:
   - **Table name**: Booking Request (pa911_bookingrequest)
   - **Row ID**: `@{triggerOutputs()?['body/pa911_bookingrequestid']}`
   - **Fields**:
     - `pa911_contact`: `@{variables('ContactId')}`
     - `pa911_requeststatus`: `144400000` (Keep as Pending - staff will approve)

---

## Step 7: Send Portal Invitation

### Send Portal Invitation Action

1. Add **Send an invitation** (Power Pages)
2. Configure:
   - **Site**: Select your Power Pages site
   - **Contact**: `@{variables('ContactId')}`
   - **Invitation Template**: Default (or create custom template)
   - **Email**: `@{triggerOutputs()?['body/pa911_email']}`

**Note**: If "Send an invitation" action is not available, use alternative:

### Alternative: Send Email with Invitation Link

1. Add **Send an email (V2)** action
2. Configure:
   - **To**: `@{triggerOutputs()?['body/pa911_email']}`
   - **Subject**: Welcome to PawsFirst Veterinary Portal
   - **Body**: 
     ```
     Dear @{triggerOutputs()?['body/pa911_firstname']},
     
     Thank you for your booking request. We've created your portal account.
     
     Click the link below to register and access your account:
     [Your Portal URL]/signin
     
     Once registered, you can:
     - View your booking request status
     - Manage your pet information
     - Book additional appointments
     
     Best regards,
     PawsFirst Veterinary Clinic
     ```

---

## Step 8: Update Appointment Slot Availability (Optional)

If you want to temporarily reserve the slot when a request is created:

1. Add **Update a row** (Dataverse)
2. Configure:
   - **Table name**: Appointment Slot (pa911_appointmentslot)
   - **Row ID**: `@{triggerOutputs()?['body/pa911_appointmentslot']}`
   - **Fields**:
     - `pa911_isavailable`: `false` (Mark as unavailable)

**Note**: You may want to make this conditional - only mark unavailable if request is approved, not just submitted.

---

## Step 9: Error Handling

### Add Try-Catch Pattern

1. Wrap critical actions in **Scope** controls
2. Add **Configure run after**:
   - Set to run even if previous action fails
   - Add error notification action

### Error Notification Example

1. Add **Send an email (V2)** action
2. Configure to run **If action failed**
3. Send notification to admin with:
   - Booking Request details
   - Error message
   - Flow run link

---

## Complete Flow Structure

```
┌─────────────────────────────────────┐
│ Trigger: When Booking Request Added │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│ List Contacts (by email)           │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│ Condition: Contact Exists?          │
└──────┬──────────────────────┬───────┘
       │                      │
       │ Yes                  │ No
       ▼                      ▼
┌──────────────┐      ┌──────────────────┐
│ Get Contact  │      │ Create Contact   │
│ by ID        │      │ Record           │
└──────┬───────┘      └────────┬─────────┘
       │                       │
       └───────────┬───────────┘
                   │
                   ▼
┌─────────────────────────────────────┐
│ Initialize Variable: ContactId        │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│ Update Booking Request               │
│ (Link Contact)                       │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│ Send Portal Invitation              │
└─────────────────────────────────────┘
```

---

## Step 10: Register Flow with Power Pages

### Enable Cloud Flow Integration

1. Navigate to **Power Pages** → **Your Site** → **Settings** → **Cloud flows**
2. Click **Add cloud flow**
3. Select your flow: **Process Booking Request - User Onboarding**
4. Click **Add**

**Note**: This step may not be required for all flow types, but ensures the flow is associated with your site for monitoring and management.

---

## Step 11: Test the Flow

### Test Scenarios

1. **New User (Contact Doesn't Exist)**:
   - Submit booking request with new email
   - Verify Contact is created
   - Verify invitation email is sent
   - Verify Booking Request is linked to Contact

2. **Existing User (Contact Exists)**:
   - Submit booking request with existing email
   - Verify existing Contact is used (not duplicated)
   - Verify invitation email is sent
   - Verify Booking Request is linked to Contact

3. **Error Handling**:
   - Test with invalid email format
   - Test with missing required fields
   - Verify error notifications work

### Manual Test

1. Go to **Power Automate** → **My flows**
2. Find your flow
3. Click **Run** → **Test**
4. Select **Manually** test option
5. Provide sample Booking Request data
6. Click **Run flow**
7. Monitor execution and verify each step

---

## Advanced Configuration

### Custom Invitation Email Template

1. Navigate to **Power Pages** → **Your Site** → **Content** → **Email Templates**
2. Create new template:
   - **Name**: Booking Request Invitation
   - **Subject**: Welcome to PawsFirst - Complete Your Registration
   - **Body**: Custom HTML with portal link, branding, etc.

3. Update flow to use custom template

### Conditional Logic

Add conditions for:
- Only send invitation if email is valid
- Skip invitation if Contact already has portal access
- Different invitation templates for new vs. existing users

### Additional Actions

Consider adding:
- **Create Activity**: Log invitation sent in timeline
- **Update Contact**: Set custom fields (source = "Booking Request")
- **Notifications**: Notify staff of new booking request
- **Business Rules**: Set default values on Contact creation

---

## Solution Export and Deployment

### Export Solution

1. Open your solution
2. Click **Export solution**
3. Choose:
   - **Managed** (for production)
   - **Unmanaged** (for development)

4. Download the solution file (.zip)

### Import to Another Environment

1. Navigate to target environment
2. Go to **Solutions**
3. Click **Import solution**
4. Upload the .zip file
5. Follow import wizard

**Note**: Ensure all dependencies (tables, columns) exist in target environment before importing.

---

## Monitoring and Troubleshooting

### Flow Run History

1. Go to **Power Automate** → **My flows**
2. Click on your flow
3. View **Run history** tab
4. Click on individual runs to see details

### Common Issues

**Issue**: Flow doesn't trigger
- **Check**: Trigger filter is correct
- **Check**: Booking Request record is actually created
- **Check**: Flow is enabled (not turned off)

**Issue**: Contact not created
- **Check**: Required fields are provided in Booking Request
- **Check**: Email format is valid
- **Check**: Table permissions allow flow to create Contacts

**Issue**: Invitation not sent
- **Check**: Power Pages action is configured correctly
- **Check**: Contact record has `adx_identity_logon_enabled = true`
- **Check**: Email address is valid

**Issue**: Flow fails with permissions error
- **Check**: Flow connection has appropriate Dataverse permissions
- **Check**: Service principal has access to required tables
- **Check**: Solution includes all dependencies

---

## Best Practices

### Performance

1. **Filter Early**: Use trigger filters to reduce unnecessary runs
2. **Batch Operations**: Process multiple requests together if possible
3. **Error Handling**: Don't let one failure stop the entire flow

### Security

1. **Least Privilege**: Grant only necessary permissions to flow
2. **Data Validation**: Validate email and other inputs
3. **Audit Trail**: Log important actions for compliance

### Maintainability

1. **Documentation**: Add comments explaining complex logic
2. **Naming**: Use clear, descriptive action names
3. **Version Control**: Export solutions regularly for backup
4. **Testing**: Test in development environment first

---

## References

- [Cloud Flow Integration](https://learn.microsoft.com/en-us/power-pages/configure/cloud-flow-integration)
- [Power Automate Documentation](https://learn.microsoft.com/en-us/power-automate/)
- [Dataverse Connector](https://learn.microsoft.com/en-us/connectors/commondataserviceforapps/)
- [Solution-Aware Flows](https://learn.microsoft.com/en-us/power-automate/create-solution-aware-flow)

---

## Next Steps

- **[Lists and Views](lists-and-views.md)** - Display booking requests to authenticated users
- **[Custom Web Templates](custom-web-templates.md)** - Build custom components for enhanced UX


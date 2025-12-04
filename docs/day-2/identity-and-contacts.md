# Identity Providers and Contact System

## Overview

This document covers Power Pages authentication architecture, Microsoft Entra ID (Azure AD) integration, and how the Contact system enables external user access to your portal.

**Prerequisites**: Complete [Site Provisioning Guide](../day-1/site-provisioning-guide.md) before working through this material.

---

## Power Pages Authentication Architecture

Power Pages supports multiple authentication methods, allowing you to choose the best approach for your external users:

### Supported Identity Providers

1. **Microsoft Entra ID (Azure AD)** - Recommended for enterprise scenarios
   - Single Sign-On (SSO) with Microsoft 365
   - Multi-factor authentication support
   - Conditional access policies
   - Guest user support

2. **Local Authentication** - Built-in username/password
   - Simple email/password registration
   - Password reset functionality
   - Email verification

3. **External Providers** - OAuth 2.0 / OpenID Connect
   - Google, Facebook, LinkedIn, etc.
   - Custom OAuth providers

### Authentication Flow

```
┌─────────────┐
│   User      │
│  (Browser)  │
└──────┬──────┘
       │
       │ 1. Request protected page
       ▼
┌─────────────────┐
│  Power Pages    │
│   Site          │
└──────┬──────────┘
       │
       │ 2. Check authentication
       │
       ├─── Authenticated? ──► Display page
       │
       └─── Not authenticated? ──► Redirect to sign-in
                                    │
                                    ▼
                          ┌─────────────────┐
                          │ Identity Provider│
                          │ (Entra ID, etc.) │
                          └────────┬────────┘
                                    │
                                    │ 3. Authenticate
                                    │
                                    ▼
                          ┌─────────────────┐
                          │  Create/Find    │
                          │  Contact Record │
                          └────────┬────────┘
                                    │
                                    │ 4. Link user
                                    │
                                    ▼
                          ┌─────────────────┐
                          │  Power Pages    │
                          │  Session        │
                          └─────────────────┘
```

---

## Microsoft Entra ID Configuration

### Why Entra ID?

Microsoft Entra ID (formerly Azure AD) is the recommended authentication method for Power Pages because:

- **Enterprise Integration**: Seamless SSO with Microsoft 365
- **Security**: Advanced security features (MFA, conditional access)
- **User Management**: Centralized user directory
- **Guest Access**: Invite external users without creating full accounts

### Configuration Steps

1. **Enable Entra ID in Power Pages**
   - Navigate to **Site Settings** → **Authentication**
   - Select **Microsoft Entra ID** as primary provider
   - Configure application registration (automatic or manual)

2. **Application Registration** (Automatic)
   - Power Pages can create the app registration automatically
   - Recommended for most scenarios
   - Handles redirect URIs and permissions

3. **Application Registration** (Manual)
   - Create app registration in Azure Portal
   - Configure redirect URIs: `https://your-site.powerappsportals.com/signin-oidc`
   - Grant API permissions for Dataverse
   - Copy Client ID and Client Secret to Power Pages

4. **User Mapping**
   - Configure how Entra ID users map to Contact records
   - Options: Email match, User Principal Name (UPN), Custom claim

### Entra ID User Invitation Flow

When using Entra ID, the onboarding process works as follows:

1. **Admin creates invitation** (via Power Automate or manually)
2. **Invitation email sent** to user's email address
3. **User clicks link** → Redirected to Entra ID consent screen
4. **User authenticates** → Entra ID validates credentials
5. **Power Pages receives token** → Creates/finds Contact record
6. **User redirected to portal** → Session established

---

## Contact System Architecture

### Contact as Portal User Identity

In Power Pages, **Contact** records serve as the identity for external portal users:

- **One Contact = One Portal User**
- Contact record stores user profile information
- Contact email (`emailaddress1`) is used for authentication
- Contact ID links to all related data (Pets, Appointments, etc.)

### Contact Record Structure

| Field | Purpose | Authentication Use |
|-------|---------|-------------------|
| `contactid` | Primary key (GUID) | Links to portal user session |
| `emailaddress1` | Email address | Login identifier, invitation target |
| `firstname` | First name | User profile display |
| `lastname` | Last name | User profile display |
| `telephone1` | Phone number | Contact information |
| `adx_identity_username` | Portal username | Internal portal identity |
| `adx_identity_logon_enabled` | Login enabled | Controls portal access |

### Contact Creation Scenarios

#### Scenario 1: User Self-Registration

1. User visits portal and clicks "Sign Up"
2. User fills registration form (Entity Form on Contact)
3. Contact record created with `adx_identity_logon_enabled = true`
4. User receives verification email
5. User clicks verification link → Account activated

#### Scenario 2: Admin Invitation (Entra ID)

1. Admin creates Contact record manually or via automation
2. Admin sends portal invitation email
3. User receives email with invitation link
4. User clicks link → Redirected to Entra ID
5. User authenticates → Contact linked to Entra ID account
6. User can now access portal

#### Scenario 3: Power Automate Onboarding (Our Use Case)

1. Anonymous user submits Booking Request form
2. Power Automate flow triggers on record creation
3. Flow checks if Contact exists (by email)
4. If not exists: Flow creates Contact record
5. Flow sends portal invitation email
6. Flow links Contact to Booking Request
7. User receives invitation → Registers → Can view booking status

---

## Web Roles and Permissions

### Web Roles

Web roles define groups of portal users with specific permissions:

- **Authenticated Users** - Default role for all logged-in users
- **Administrators** - Full access to portal management
- **Custom Roles** - Business-specific roles (e.g., "Veterinarian", "Pet Owner")

### Table Permissions

Table permissions control what data users can access:

| Scope | Description | Use Case |
|-------|-------------|----------|
| **Global** | All records in table | Public data (Services) |
| **Contact** | Records where Contact = current user | User's own Contact record |
| **Account** | Records where Account = user's account | Organization-level data |
| **Parent** | Records where parent Contact = current user | User's pets, appointments |
| **Self** | Only the user's own record | Contact self-service |

### Anonymous Access

For anonymous access (booking form), configure:

- **Table Permission**: Booking Request table
- **Scope**: Global
- **Privileges**: Create only
- **Web Role**: Anonymous Users

This allows unauthenticated users to submit booking requests without logging in.

---

## Contact System in PawsFirst Portal

### Our Implementation

In the PawsFirst Veterinary Portal, we use the Contact system as follows:

1. **Initial State**: User is anonymous (no Contact record)
2. **Booking Request**: User submits form anonymously
3. **Power Automate Flow**: 
   - Creates Contact record (if doesn't exist)
   - Sends portal invitation email
   - Links Contact to Booking Request
4. **User Registration**: User receives email, registers via Entra ID
5. **Authenticated Access**: User can now:
   - View their booking requests
   - Manage their pets
   - Book additional appointments
   - Upload documents

### Contact-to-Pet Relationship

```
Contact (Pet Owner)
    │
    ├─── Pet 1 (Max - Dog)
    │       ├─── Appointment 1
    │       ├─── Appointment 2
    │       └─── Document 1
    │
    └─── Pet 2 (Whiskers - Cat)
            ├─── Appointment 1
            └─── Document 1
```

**Table Permission Pattern**:
- **Pet Read**: `pa911_petowner` = current user's Contact ID
- **Appointment Read**: `pa911_pet.pa911_petowner` = current user's Contact ID
- **Document Read**: `pa911_pet.pa911_petowner` = current user's Contact ID

This ensures users only see data for their own pets.

---

## Best Practices

### Security

1. **Always use table permissions** - Never rely on UI hiding alone
2. **Scope appropriately** - Use Contact/Account scopes for user-specific data
3. **Anonymous access carefully** - Only allow create operations, never read/update
4. **Validate server-side** - Don't trust client-side validation

### User Experience

1. **Clear invitation emails** - Explain what the portal is and how to register
2. **Simple registration** - Minimize required fields
3. **Password reset** - Enable self-service password reset
4. **Profile management** - Allow users to update their Contact record

### Automation

1. **Use Power Automate** - Automate Contact creation and invitations
2. **Link records** - Always link Contact to related records (Booking Request, etc.)
3. **Status tracking** - Use status fields to track onboarding progress
4. **Error handling** - Handle duplicate emails, failed invitations gracefully

---

## Troubleshooting

### Common Issues

**Issue**: User cannot log in after invitation
- **Check**: `adx_identity_logon_enabled` = true on Contact record
- **Check**: Email address matches exactly (case-sensitive in some scenarios)
- **Check**: Entra ID app registration redirect URIs are correct
- **Check**: ExternalId Dataverse table has required information

**Issue**: User sees "Access Denied" on pages
- **Check**: Table permissions are configured correctly
- **Check**: User has appropriate web role assigned
- **Check**: Scope filters are correct (Contact ID matching)

**Issue**: Anonymous form submission fails
- **Check**: Table permission exists for Anonymous Users web role
- **Check**: Permission has Create privilege
- **Check**: Required fields are provided in form

---

## References

- [Power Pages Authentication Overview](https://learn.microsoft.com/en-us/power-pages/security/authentication/configure-site)
- [Microsoft Entra ID Integration](https://learn.microsoft.com/en-us/power-pages/security/authentication/azure-ad)
- [Table Permissions](https://learn.microsoft.com/en-us/power-pages/security/table-permissions)
- [Web Roles](https://learn.microsoft.com/en-us/power-pages/security/web-roles)
- [Contact Entity Documentation](https://learn.microsoft.com/en-us/dynamics365/customer-engagement/web-api/contact)

---

## Next Steps

- **[Booking Request Form](booking-request-form.md)** - Create anonymous Entity Form for booking requests
- **[Power Automate Integration](power-automate-integration.md)** - Build user onboarding automation flow


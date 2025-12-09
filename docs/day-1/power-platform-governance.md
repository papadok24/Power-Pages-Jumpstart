# Power Platform Governance Guide - PawsFirst Portal

## Overview

This guide provides an overview of Power Platform governance concepts and administrative practices relevant to managing Power Pages sites like the PawsFirst Veterinary Portal. Understanding governance helps ensure your portal remains secure, compliant, and well-maintained throughout its lifecycle.

**Why Governance Matters**: Effective governance balances innovation with security, ensuring that Power Pages sites are built responsibly, maintained properly, and aligned with organizational standards. For the PawsFirst portal, governance ensures that pet owner data is protected, appointments are managed securely, and the site remains available and performant.

---

## Understanding Power Platform Admin Roles

Before managing a Power Pages site, it's important to understand the different administrative roles and their responsibilities. Different tasks require different permission levels.

### Key Administrative Roles

| Role | Purpose | Common Tasks |
|------|---------|--------------|
| **System Administrator** | Full access to all administrative functions | Site provisioning, environment management, user management |
| **System Customizer** | Can customize the system but cannot manage security | Table configuration, form customization, workflow management |
| **Website Owner** | Can manage specific Power Pages site settings | Site configuration, content management, table permissions |
| **Power Platform Administrator** | Manages Power Platform environments and resources | Environment creation, DLP policies, capacity management |

### Roles Required for Website Administration

For the PawsFirst portal, you'll need appropriate roles to perform common administrative tasks:

- **Adding Custom Domain Names**: Requires System Administrator or Website Owner role
- **Updating Dynamics 365 Instance**: Requires System Administrator role
- **Managing Authentication Keys**: Requires System Administrator or Website Owner role
- **Configuring Table Permissions**: Requires System Customizer or Website Owner role
- **Managing Site Visibility**: Requires System Administrator or Website Owner role

**Reference**: [Roles required for website administration](https://learn.microsoft.com/en-us/power-pages/admin/admin-roles)

---

## Using the Power Platform Admin Center

The Power Platform Admin Center is your central hub for managing Power Pages sites and Power Platform resources. It provides administrators with various site configuration capabilities.

### Accessing the Admin Center

There are two ways to access the admin center:

**Method 1: From Design Studio**
1. In Power Pages Design Studio, select the **Set up** workspace
2. In the **Site Details** section, select **Open admin center**
3. The Power Platform Admin Center opens with your site details

**Method 2: Direct Access**
1. Go to [Power Platform Admin Center](https://admin.powerplatform.microsoft.com)
2. Under **Resources**, select **Power Pages sites**
3. Select the site you want to manage (e.g., PawsFirst)

### Key Admin Center Capabilities

The admin center provides access to several important administrative functions:

#### Site Actions

Common site management actions available from the **Site Actions** menu:

- **Restart site** - Restart the site (useful after configuration changes)
- **Shut down this site** - Temporarily turn off the site
- **Delete this site** - Permanently remove the site
- **Disable custom errors** - Show detailed error messages (development/testing only)
- **Enable diagnostic logs** - Enable logging for troubleshooting
- **Enable maintenance mode** - Put the site in maintenance mode for updates

**PawsFirst Example**: If you need to apply a critical security update to the PawsFirst portal, you might enable maintenance mode, apply the update, then restart the site.

#### Additional Site Actions

From the **...** menu next to Site Actions, you can access:

- **Manage Dynamics 365 Instance** - Update the Dataverse instance your site connects to
- **Update Dynamics 365 URL** - Update site URL if your environment URL changed
- **Metadata translations** - Import translated metadata for multi-language support
- **Install Field Service Extension** - Add Field Service capabilities (if needed)
- **Install Project Service Extension** - Add Project Service Automation (if needed)

#### Site Details

The **Site Details** section provides important information about your site:

- **Site Name** - The display name of your site (e.g., "PawsFirst")
- **Website Record** - Links the site to its Dataverse metadata
- **Site URL** - The public URL (e.g., `https://pawsfirst.powerappsportals.com`)
- **Application Type** - Indicates if the site is Trial or Production
- **Early Upgrade** - Indicates if the site is enabled for early code updates
- **Site Visibility** - Controls who can access the site
- **Site State** - Current running state (Running, Stopped, etc.)
- **Application Id** - Microsoft Entra application ID for the site
- **Org URL** - The Dataverse organization URL

**Editing Site Details**: Click **Edit** to update the site name, website record, or site URL. For the PawsFirst portal, you might update the site name if the clinic rebrands or change the URL if moving to a custom domain.

**Reference**: [Use the admin center](https://learn.microsoft.com/en-us/power-pages/admin/admin-overview)

---

## Managing Power Pages Sites

### Site Lifecycle Management

Understanding the site lifecycle helps you manage the PawsFirst portal effectively:

1. **Provisioning** - Initial site creation (covered in [Site Provisioning Guide](site-provisioning-guide.md))
2. **Configuration** - Setting up authentication, table permissions, and content
3. **Development** - Building pages, forms, and workflows
4. **Testing** - Validating functionality before production
5. **Production** - Live site serving customers
6. **Maintenance** - Ongoing updates and improvements
7. **Decommissioning** - Retiring the site when no longer needed

### Converting to Production

When the PawsFirst portal is ready for pet owners to use:

1. In the admin center, go to **Site Details**
2. Select **Convert to Production**
3. This changes the site from Trial to Production status
4. Production sites have different SLA and support levels

**Reference**: [Convert a site](https://learn.microsoft.com/en-us/power-pages/admin/convert-site)

### Custom Domain Configuration

For the PawsFirst portal, you might want to use a custom domain like `appointments.pawsfirstvet.com` instead of the default `pawsfirst.powerappsportals.com`:

1. In **Site Details**, select **Connect Custom Domain**
2. Follow the DNS configuration steps
3. Verify domain ownership
4. Update your site URL

**Reference**: [Add a custom domain name](https://learn.microsoft.com/en-us/power-pages/admin/add-custom-domain)

---

## Security & Compliance

### Site Visibility

Control who can access your Power Pages site:

- **Public** - Anyone can access (for anonymous booking requests)
- **Authenticated Users Only** - Requires login (for pet owner portal areas)
- **Restricted** - Only specific users/groups

For PawsFirst, you might configure:
- Public access for the booking request form
- Authenticated access for pet owner dashboard and appointment history

**Reference**: [Site visibility in Power Pages](https://learn.microsoft.com/en-us/power-pages/security/site-visibility)

### IP Restrictions

Restrict site access by IP address for additional security:

1. In admin center, go to **Security** > **IP Restrictions**
2. Configure allowed or blocked IP addresses
3. Useful for internal-only portals or specific geographic restrictions

**Reference**: [Restrict website access by IP address](https://learn.microsoft.com/en-us/power-pages/admin/ip-address-restrict)

### Custom Certificates

For custom domains, you may need to manage SSL certificates:

1. In admin center, go to **Security** > **Custom Certificates**
2. Upload your SSL certificate
3. Configure certificate bindings

**Reference**: [Manage custom certificates](https://learn.microsoft.com/en-us/power-pages/admin/manage-custom-certificates)

### Website Authentication Key

Manage the authentication key used for secure API communication:

1. In admin center, go to **Security** > **Website Authentication Key**
2. View or regenerate the authentication key
3. Use this key for Portals Web API calls

**Reference**: [Manage website authentication key](https://learn.microsoft.com/en-us/power-pages/admin/manage-auth-key)

---

## Site Health & Performance

### Site Checker

Run diagnostic checks on your Power Pages site:

1. In admin center, go to **Site Health** > **Site Checker**
2. Review recommendations and issues
3. Address any problems identified

**Reference**: [Run Site Checker](https://learn.microsoft.com/en-us/power-pages/admin/site-checker)

### Content Delivery Network (CDN)

Improve site performance with CDN:

1. In admin center, go to **Performance & Protection** > **Content Delivery Network**
2. Enable CDN for faster content delivery
3. Configure CDN settings

**Reference**: [Content Delivery Network](https://learn.microsoft.com/en-us/power-pages/configure/configure-cdn)

### Web Application Firewall

Protect your site from common web attacks:

1. In admin center, go to **Performance & Protection** > **Web Application Firewall**
2. Configure firewall rules
3. Monitor security events

---

## Microsoft Entra Application Ownership

To manage a Power Pages site that's already provisioned, you must be an owner of the Microsoft Entra application connected to your website.

### Adding Yourself as Owner

If you need to manage the PawsFirst site but aren't the original creator:

1. Go to Power Platform Admin Center
2. From **Site Details**, copy the **Application Id** value
3. Go to Microsoft Entra ID (Azure Portal)
4. Search for the app registration using the Application Id
5. Switch from **My apps** to **All apps** if needed
6. Add yourself (or your group) as an owner of the app registration
7. Reopen the site details page in Power Platform Admin Center

**Note**: The current application owner or a global administrator can perform this task.

---

## Governance Best Practices

### Environment Strategy

For the PawsFirst portal, consider using multiple environments:

- **Development** - For building and testing new features
- **Test/UAT** - For user acceptance testing before production
- **Production** - Live site serving pet owners

This separation helps prevent issues from affecting production users.

### Data Loss Prevention (DLP) Policies

Configure DLP policies to control which connectors can be used together:

- **Business Data Group** - Connectors for business data (Dataverse, SharePoint)
- **Non-Business Data Group** - Connectors for external services (social media, public APIs)

For PawsFirst, you might restrict Power Automate flows to prevent accidental data exposure.

### Regular Monitoring

Regularly monitor your Power Pages site:

- Review site usage and performance metrics
- Check diagnostic logs for errors
- Monitor authentication and access patterns
- Review table permission configurations

### Documentation

Maintain documentation for your Power Pages site:

- Site configuration details
- Custom domain setup
- Authentication configuration
- Table permissions matrix
- Custom web templates and components

---

## Quick-Start Governance Checklist

Use this checklist when setting up or managing the PawsFirst portal:

### Pre-Deployment

- [ ] Verify appropriate admin roles are assigned
- [ ] Configure site visibility settings
- [ ] Set up IP restrictions (if needed)
- [ ] Configure table permissions for all portal-facing tables
- [ ] Test authentication (Microsoft Entra ID or local)
- [ ] Review and configure security settings

### Post-Deployment

- [ ] Convert site to Production (if ready)
- [ ] Configure custom domain (if applicable)
- [ ] Enable diagnostic logging
- [ ] Run Site Checker and address issues
- [ ] Configure CDN for performance
- [ ] Set up monitoring and alerts
- [ ] Document site configuration

### Ongoing Maintenance

- [ ] Regularly review site health metrics
- [ ] Monitor authentication and access logs
- [ ] Review and update table permissions as needed
- [ ] Keep site documentation current
- [ ] Review and update DLP policies
- [ ] Test site functionality after updates
- [ ] Monitor site performance and capacity

---

## PawsFirst Portal Governance Example

Here's how governance applies to the PawsFirst Veterinary Portal:

### Site Configuration
- **Site Name**: PawsFirst Veterinary Portal
- **Site URL**: `pawsfirst.powerappsportals.com` (or custom domain)
- **Application Type**: Production (after initial testing)
- **Site Visibility**: Public for booking, Authenticated for dashboard

### Security Settings
- **IP Restrictions**: None (public-facing portal)
- **Authentication**: Microsoft Entra ID for pet owners
- **Table Permissions**: Configured for Contact, Pet, Appointment, Booking Request
- **Custom Domain**: Optional (e.g., `appointments.pawsfirstvet.com`)

### Administrative Tasks
- **Site Owner**: Assigned Website Owner role
- **System Admin**: Manages environment and Dataverse configuration
- **Content Manager**: Updates pages and content via Design Studio
- **Support Team**: Monitors site health and user issues

---

## References

- [Use the admin center](https://learn.microsoft.com/en-us/power-pages/admin/admin-overview)
- [Manage websites from the Power Platform admin center](https://learn.microsoft.com/en-us/power-pages/admin/power-platform-admin-center)
- [Roles required for website administration](https://learn.microsoft.com/en-us/power-pages/admin/admin-roles)
- [Power Pages Documentation](https://learn.microsoft.com/en-us/power-pages/)
- [Power Platform Admin Center](https://admin.powerplatform.microsoft.com)

---

## Next Steps

After understanding governance basics:

1. Review the [Site Provisioning Guide](site-provisioning-guide.md) for hands-on setup
2. Explore [Data Model Design](data-model.md) to understand table permissions
3. Learn about [Identity and Contacts](../day-2/identity-and-contacts.md) for authentication configuration



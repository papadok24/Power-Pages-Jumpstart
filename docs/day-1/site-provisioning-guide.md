# Site Provisioning Guide - PawsFirst Power Pages Site

## Overview

This guide provides step-by-step instructions for creating and configuring the PawsFirst Veterinary Portal Power Pages site with Microsoft Entra ID authentication. This setup is required before beginning Day 1 development activities.

---

## Prerequisites

Before starting, ensure you have:

- **Power Platform Environment** - Access to a Power Platform environment with Power Pages license enabled
- **Admin Access** - Administrator privileges in Power Platform Admin Center
- **Microsoft Entra ID Tenant** - Configured Entra ID tenant (formerly Azure Active Directory)
- **Solution Package** - Pre-built Dataverse solution containing Pet, Service, and Appointment table customizations
- **PAC CLI** (Optional) - Power Platform CLI installed for source control management

---

## Step 1: Create Power Pages Site

### 1.1 Navigate to Power Pages Maker Portal

1. Go to [make.powerpages.microsoft.com](https://make.powerpages.microsoft.com)
2. Sign in with your Power Platform administrator credentials
3. Click **"Create a site"** or **"New site"** button

### 1.2 Select Template

1. Choose **"Blank template"** (not Community or other templates)
2. Click **"Next"**

### 1.3 Configure Site Details

1. **Site Name**: Enter `PawsFirst` (or your preferred name)
2. **URL**: Choose a unique URL (e.g., `pawsfirst-{yourorg}`)
   - Note: URLs must be globally unique across all Power Pages sites
   - Format: `https://{your-site-name}.powerappsportals.com`
3. **Language**: Select your primary language
4. Click **"Create"**

### 1.4 Wait for Provisioning

- Site provisioning typically takes 5-10 minutes
- You'll receive a notification when the site is ready
- The site will open automatically in the Design Studio

---

## Step 2: Deploy Dataverse Solution

### 2.1 Import Solution Package

1. Navigate to [Power Platform Admin Center](https://admin.powerplatform.microsoft.com)
2. Select your environment
3. Go to **Solutions** > **Import**
4. Upload the pre-built solution package containing:
   - `pa911_pet` table (custom Pet entity)
   - `pa911_service` table (custom Service entity)
   - `pa911_document` table (custom Document entity)
   - Custom columns on `appointment` table
   - Relationships and table permissions

### 2.2 Verify Solution Import

1. Confirm all tables are visible in **Solutions** > **PawsFirst Solution**
2. Verify tables appear in **Tables** view:
   - `pa911_pet` (Pet)
   - `pa911_service` (Service)
   - `pa911_document` (Document)
3. Check that `appointment` table has custom columns:
   - `pa911_pet` (lookup to Pet)
   - `pa911_service` (lookup to Service)

---

## Step 3: Set Up Table Permissions

### 3.1 Navigate to Table Permissions

1. In Power Pages Design Studio, go to **Set up** > **Table permissions**
2. Click **"New table permission"**

### 3.2 Configure Contact Table Permissions

1. **Table**: Select `Contact`
2. **Name**: `Contact - Self Access`
3. **Access Type**: `Read`, `Write`
4. **Scope**: `Contact`
5. **Web Roles**: Assign to appropriate web role (e.g., "Authenticated Users")
6. **Conditions**: 
   - `contactid` equals `{{ user.id }}`
7. Click **"Save"**

### 3.3 Configure Pet Table Permissions

1. **Table**: Select `pa911_pet` (Pet)
2. **Name**: `Pet - Own Pets`
3. **Access Type**: `Read`, `Write`
4. **Scope**: `Contact`
5. **Web Roles**: Assign to authenticated users
6. **Conditions**:
   - `pa911_petowner` equals `{{ user.id }}`
7. Click **"Save"**

### 3.4 Configure Service Table Permissions

1. **Table**: Select `pa911_service` (Service)
2. **Name**: `Service - Public Read`
3. **Access Type**: `Read` only
4. **Scope**: `Global`
5. **Web Roles**: Assign to all users (including anonymous)
6. Click **"Save"**

### 3.5 Configure Appointment Table Permissions

1. **Table**: Select `appointment`
2. **Name**: `Appointment - Own Pets' Appointments`
3. **Access Type**: `Read`, `Write`
4. **Scope**: `Contact`
5. **Web Roles**: Assign to authenticated users
6. **Conditions**:
   - `pa911_pet.pa911_petowner` equals `{{ user.id }}`
7. Click **"Save"**

---

## Next Steps

After completing this guide:

1. Review the [Home Page Build Guide](home-page-build.md) to create your first page with Liquid
2. Work through [User Stories](user-stories.md) to learn Liquid syntax fundamentals
3. Reference [Data Model Design](data-model.md) for table structure details

---

## References

- [Power Pages Documentation](https://learn.microsoft.com/en-us/power-pages/)
- [Configure Authentication in Power Pages](https://learn.microsoft.com/en-us/power-pages/configure/authentication/providers/azure-ad)
- [Table Permissions Overview](https://learn.microsoft.com/en-us/power-pages/configure/table-permissions)
- [Power Platform CLI Documentation](https://learn.microsoft.com/en-us/power-platform/developer/cli/introduction)


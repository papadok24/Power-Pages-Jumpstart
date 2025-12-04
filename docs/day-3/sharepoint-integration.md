# SharePoint Integration Setup

## Overview

This guide covers setting up SharePoint document management for the Pet table in Power Pages. SharePoint integration allows pet owners to upload, view, and manage medical documents (vaccination records, lab results, prescriptions, etc.) associated with their pets.

**Prerequisites**:
- Complete [Data Model Design](../day-1/data-model.md) - Pet table created
- Power Platform environment with SharePoint integration enabled
- SharePoint site available in the same tenant
- Power Pages site provisioned and configured

---

## Why SharePoint for Document Management?

### SharePoint vs. Alternatives

**SharePoint (Recommended)**:
- ✅ Native integration with Power Pages
- ✅ Built-in security and permissions
- ✅ Scalable storage (no Dataverse file size limits)
- ✅ Version control and document history
- ✅ OOTB document management controls
- ✅ Customizable via reverse-engineered API

**Dataverse File Columns**:
- ❌ Limited file size (typically 32MB max)
- ❌ No version control
- ❌ Limited document management features
- ❌ Not optimized for large files or many documents

**Azure Blob Storage**:
- ❌ Requires custom development
- ❌ No OOTB Power Pages integration
- ❌ Additional infrastructure to manage
- ❌ More complex security configuration

**Conclusion**: SharePoint provides the best balance of features, integration, and ease of use for Power Pages document management.

---

## Step 1: Enable Server-Based SharePoint Integration

Before configuring document locations, you must enable server-based SharePoint integration in your Power Platform environment.

### Enable Integration in Power Platform Admin Center

1. Navigate to **Power Platform Admin Center**: https://admin.powerplatform.microsoft.com
2. Select your **Environment**
3. Go to **Settings** → **Product** → **Features**
4. Under **SharePoint Integration**, ensure **Server-based SharePoint integration** is enabled
5. If not enabled, click **Edit** and enable it
6. Click **Save**

**Note**: This may require environment administrator permissions. If you don't have access, contact your Power Platform administrator.

### Verify SharePoint Site Connection

1. In your Power Platform environment, navigate to **Settings** → **Document Management**
2. Verify that a SharePoint site is connected
3. If no site is connected, follow the prompts to connect a SharePoint site

---

## Step 2: Enable Document Management for Pet Table

Enable document management on the Pet custom table so that documents can be associated with Pet records.

### Enable in Dataverse

1. Navigate to **Power Apps** → **Dataverse** → **Tables**
2. Find and open the **Pet** table (`pa911_pet`)
3. Go to the **Properties** tab
4. Under **Document Management**, check **Enable document management**
5. Click **Save**

**Note**: This creates a SharePoint document location for the Pet table. Documents uploaded will be stored in SharePoint folders organized by Pet record.

---

## Step 3: Create SharePoint Document Location

After enabling document management, you need to create a document location that links the Pet table to SharePoint.

### Automatic Creation

When you enable document management on a table, Dataverse automatically:
- Creates a default document location
- Sets up folder structure in SharePoint
- Configures basic permissions

### Verify Document Location

1. Navigate to **Power Apps** → **Dataverse** → **Tables** → **Pet**
2. Go to **Document Management** tab
3. Verify that a document location exists
4. If needed, click **New Document Location** to create one manually

### Document Location Settings

| Setting | Value | Notes |
|---------|-------|-------|
| **Name** | Pet Documents | Descriptive name for the location |
| **Relative URL** | `/PetDocuments` | SharePoint folder path |
| **Parent Site or Location** | Your SharePoint site | The connected SharePoint site |
| **Regarding Entity** | Pet | Links documents to Pet records |

---

## Step 4: Configure Power Pages Document Management

Configure Power Pages to allow portal users to access and manage documents.

### Enable Document Management in Power Pages

1. Navigate to **Power Pages** → **Your Site** → **Settings** → **General**
2. Verify that document management features are available
3. Document management is typically enabled by default when SharePoint integration is configured

### Configure Table Permissions

Users need appropriate permissions to access documents. Since documents are associated with Pet records, configure Pet table permissions:

1. Navigate to **Power Pages** → **Your Site** → **Security** → **Table Permissions**
2. Verify or create permission for Pet table:
   - **Name**: Pet - User Read/Write Own
   - **Table**: Pet
   - **Web Role**: Authenticated Users
   - **Scope**: Contact
   - **Privileges**: Read, Write
   - **Contact Scope**: Current user's Contact

**Note**: Document access is controlled through the Pet table permissions. Users can only access documents for pets they own.

---

## Step 5: Test Document Management

### Test in Model-Driven App

1. Navigate to your model-driven app
2. Open a Pet record
3. Go to the **Documents** tab
4. Verify you can upload, view, and download documents
5. Check that documents appear in SharePoint

### Test in Power Pages

1. Navigate to your Power Pages site
2. Log in as a portal user
3. Navigate to a Pet record page
4. Verify document management controls are visible
5. Test uploading a document
6. Verify the document appears in SharePoint

---

## Document Storage Structure

SharePoint organizes documents in the following structure:

```
SharePoint Site/
└── PetDocuments/
    └── {Pet Record GUID}/
        ├── vaccination-record.pdf
        ├── lab-results-2025-01.pdf
        └── prescription.pdf
```

Each Pet record gets its own folder in SharePoint, identified by the Pet record's GUID. This ensures:
- Documents are organized by pet
- Easy to find documents for a specific pet
- Permissions can be managed at the folder level

---

## Troubleshooting

### Common Issues

**Issue**: Document management option not available in table properties
- **Solution**: Verify server-based SharePoint integration is enabled in Power Platform Admin Center
- **Solution**: Check that a SharePoint site is connected to the environment

**Issue**: Documents not appearing in Power Pages
- **Solution**: Verify table permissions are configured correctly for Pet table
- **Solution**: Check that the document location is created and active
- **Solution**: Verify user has appropriate web role assigned

**Issue**: Upload fails with permission error
- **Solution**: Check SharePoint site permissions
- **Solution**: Verify Power Pages service account has access to SharePoint
- **Solution**: Check table permissions allow Write access

**Issue**: Documents not accessible after upload
- **Solution**: Verify document location is correctly configured
- **Solution**: Check SharePoint folder permissions
- **Solution**: Verify Pet record relationship is correct

---

## Next Steps

- **[Pet Document Upload (OOTB)](pet-document-upload-ootb.md)** - Use out-of-the-box document management controls
- **[Pet Document Upload (Custom)](pet-document-upload-custom.md)** - Build custom document management using reverse-engineered SharePoint API

---

## References

- [Manage SharePoint documents in Power Pages](https://learn.microsoft.com/en-us/power-pages/configure/manage-sharepoint-documents)
- [Enable server-based SharePoint integration](https://learn.microsoft.com/en-us/power-platform/admin/set-up-sharepoint-integration)
- [Document Management in Dataverse](https://learn.microsoft.com/en-us/power-apps/developer/data-platform/document-management)


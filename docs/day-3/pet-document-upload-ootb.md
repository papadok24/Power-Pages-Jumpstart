# Pet Document Upload - OOTB Implementation

## Overview

This guide covers implementing document upload functionality for Pet records using Power Pages' out-of-the-box (OOTB) document management controls. This approach leverages built-in SharePoint integration without requiring custom code.

**Prerequisites**:
- Complete [SharePoint Integration Setup](sharepoint-integration.md) - Document management enabled for Pet table
- Pet table permissions configured for portal users
- Power Pages site with authenticated user access

---

## Step 1: Configure Pet Entity Form

Create or configure an Entity Form for the Pet table that includes document management.

### Create Pet Entity Form

1. Navigate to **Power Pages** → **Your Site** → **Content** → **Entity Forms**
2. Click **New** to create a new form
3. Configure basic settings:

| Setting | Value |
|---------|-------|
| **Name** | Pet Form with Documents |
| **Table** | Pet (pa911_pet) |
| **Mode** | Edit (or Insert for new pets) |
| **Type** | Web Form |

4. Click **Save**

### Add Form Fields

Add the standard Pet fields to the form:

| Field | Logical Name | Required |
|-------|--------------|----------|
| Name | `pa911_name` | Yes |
| Species | `pa911_species` | Yes |
| Breed | `pa911_breed` | No |
| Date of Birth | `pa911_dateofbirth` | No |
| Weight | `pa911_weight` | No |
| Owner | `pa911_petowner` | Yes |
| Medical Notes | `pa911_notes` | No |

---

## Step 2: Add Document Subgrid

The document subgrid displays documents associated with the Pet record and allows users to upload new documents.

### Configure Document Subgrid

1. In the Entity Form editor, go to **Subgrids** section
2. Click **Add Subgrid**
3. Configure the subgrid:

| Setting | Value |
|---------|-------|
| **Name** | Pet Documents |
| **Type** | Related Documents |
| **Data Source** | Pet (pa911_pet) |
| **Show Toolbar** | Yes |
| **Show Upload Button** | Yes |
| **Show Download Button** | Yes |
| **Show Delete Button** | Yes (optional) |

4. Click **Save**

### Subgrid Display Options

Configure how the subgrid appears:

| Setting | Value | Notes |
|---------|-------|-------|
| **Records Per Page** | 10 | Adjust based on expected document volume |
| **Show Search** | Yes | Allow users to search documents |
| **Show Filter** | Yes | Allow users to filter documents |
| **Enable Sorting** | Yes | Allow column sorting |

---

## Step 3: Configure Document Location in Power Pages

Ensure the document location is properly configured for Power Pages access.

### Verify Document Location

1. Navigate to **Power Apps** → **Dataverse** → **Tables** → **Pet**
2. Go to **Document Management** tab
3. Verify document location exists and is active
4. Note the **Relative URL** (e.g., `/PetDocuments`)

### Configure Power Pages Access

1. Navigate to **Power Pages** → **Your Site** → **Settings** → **General**
2. Verify document management is enabled
3. Document management should be automatically available when SharePoint integration is configured

---

## Step 4: Create Pet Detail Page

Create a web page where users can view and manage their pet's documents.

### Create Web Page

1. Navigate to **Power Pages** → **Your Site** → **Content** → **Web Pages**
2. Create a new page:
   - **Name**: Pet Details
   - **Partial URL**: `pet-details`
   - **Parent Page**: Home (or appropriate parent)

### Add Entity Form to Page

Add the Entity Form with document subgrid to the page:

```liquid
<div class="container mt-4">
    <h1>Pet Information</h1>
    
    {% entityform name:"Pet Form with Documents" %}
</div>
```

Or use Design Studio to drag the form component onto the page.

### Page Permissions

Configure page access:

1. Go to **Page Permissions** tab
2. Allow **Authenticated Users** to view
3. This ensures only logged-in users can access pet documents

---

## Step 5: Configure Table Permissions

Ensure users have appropriate permissions to access and manage documents.

### Pet Table Permissions

1. Navigate to **Power Pages** → **Your Site** → **Security** → **Table Permissions**
2. Verify or create permission:

| Setting | Value |
|---------|-------|
| **Name** | Pet - User Read/Write Own |
| **Table** | Pet (pa911_pet) |
| **Web Role** | Authenticated Users |
| **Scope** | Contact |
| **Privileges** | Read, Write |
| **Contact Scope** | Current user's Contact |

**Note**: Document access is controlled through Pet table permissions. Users can only access documents for pets they own.

---

## Step 6: Test Document Upload

### Testing Checklist

- [ ] User can access Pet Details page
- [ ] Entity Form displays with Pet information
- [ ] Document subgrid is visible
- [ ] Upload button appears in subgrid toolbar
- [ ] User can upload a document
- [ ] Uploaded document appears in subgrid
- [ ] User can download uploaded document
- [ ] User can view document in SharePoint
- [ ] Documents are organized by Pet record in SharePoint

### Test Scenarios

**Scenario 1: Upload Single Document**
1. Navigate to Pet Details page
2. Scroll to Documents subgrid
3. Click **Upload** button
4. Select a file (e.g., PDF, image)
5. Verify file uploads successfully
6. Verify document appears in subgrid

**Scenario 2: Upload Multiple Documents**
1. Upload first document
2. Upload second document
3. Verify both documents appear in subgrid
4. Verify both documents are accessible

**Scenario 3: Download Document**
1. Click on a document in the subgrid
2. Verify download starts
3. Verify downloaded file opens correctly

**Scenario 4: Document Organization**
1. Upload documents for different pets
2. Verify documents are stored in separate SharePoint folders
3. Verify each pet's documents are isolated

---

## Step 7: Customize Subgrid Appearance (Optional)

### Custom Styling

Add custom CSS to style the document subgrid:

```css
/* Custom styles for document subgrid */
.entitylist-table {
    border-collapse: collapse;
    width: 100%;
}

.entitylist-table th {
    background-color: #f8f9fa;
    font-weight: bold;
    padding: 12px;
}

.entitylist-table td {
    padding: 10px;
    border-bottom: 1px solid #dee2e6;
}
```

Add this CSS to your site's custom CSS file or in a content snippet.

### Custom JavaScript

Add JavaScript to enhance document management:

```javascript
// Example: Show file size in human-readable format
function formatFileSize(bytes) {
    if (!bytes || bytes === 0) return '0 B';
    const sizes = ['B', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(1024));
    return Math.round(bytes / Math.pow(1024, i) * 100) / 100 + ' ' + sizes[i];
}

// Example: Add custom upload validation
function validateFileUpload(file) {
    const maxSize = 10 * 1024 * 1024; // 10MB
    const allowedTypes = ['application/pdf', 'image/jpeg', 'image/png'];
    
    if (file.size > maxSize) {
        alert('File size exceeds 10MB limit');
        return false;
    }
    
    if (!allowedTypes.includes(file.type)) {
        alert('File type not allowed. Please upload PDF, JPEG, or PNG files.');
        return false;
    }
    
    return true;
}
```

---

## Advanced Configuration

### Filter Documents by Type

If you need to categorize documents, you can:

1. Create a custom choice field on the Pet table for document categories
2. Use SharePoint metadata to tag documents
3. Filter the document subgrid based on metadata

**Note**: Advanced filtering may require custom implementation. See [Pet Document Upload (Custom)](pet-document-upload-custom.md) for more advanced scenarios.

### Folder Organization

SharePoint automatically organizes documents by Pet record GUID. To customize folder structure:

1. Modify the document location's Relative URL
2. Use SharePoint folder metadata
3. Implement custom folder naming in custom implementation

---

## Troubleshooting

### Common Issues

**Issue**: Document subgrid not appearing
- **Solution**: Verify document management is enabled for Pet table
- **Solution**: Check that document location is created and active
- **Solution**: Verify Entity Form includes the subgrid

**Issue**: Upload button not visible
- **Solution**: Check subgrid settings - ensure "Show Upload Button" is enabled
- **Solution**: Verify user has Write permission on Pet table
- **Solution**: Check table permissions are configured correctly

**Issue**: Upload fails with error
- **Solution**: Verify SharePoint integration is enabled
- **Solution**: Check SharePoint site permissions
- **Solution**: Verify file size is within limits
- **Solution**: Check browser console for detailed error messages

**Issue**: Documents not accessible after upload
- **Solution**: Verify document location is correctly configured
- **Solution**: Check SharePoint folder permissions
- **Solution**: Verify Pet record relationship is correct

---

## Best Practices

### File Size Limits

- Set reasonable file size limits (e.g., 10MB per file)
- Inform users of file size restrictions
- Consider file type restrictions (PDF, images only)

### Security

- Always use table permissions to control document access
- Verify users can only access documents for their own pets
- Regularly audit document access permissions

### User Experience

- Provide clear instructions for document upload
- Show file size and type requirements
- Display upload progress for large files
- Provide feedback on successful uploads

### Performance

- Limit number of documents displayed per page
- Use pagination for large document lists
- Consider lazy loading for document thumbnails

---

## Next Steps

- **[Pet Document Upload (Custom)](pet-document-upload-custom.md)** - Build custom document management with advanced features
- **[Appointment History](appointment-history.md)** - Display appointment history for pets

---

## References

- [Entity Forms Documentation](https://learn.microsoft.com/en-us/power-pages/configure/entity-forms)
- [Manage SharePoint documents in Power Pages](https://learn.microsoft.com/en-us/power-pages/configure/manage-sharepoint-documents)
- [Table Permissions](https://learn.microsoft.com/en-us/power-pages/security/table-permissions)


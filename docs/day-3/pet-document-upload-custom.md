# Pet Document Upload - Custom Implementation

## Overview

This guide covers building a custom document management interface for Pet records using the reverse-engineered Power Pages SharePoint API. This approach provides full control over the user experience, including custom upload progress, file type filtering, folder navigation, and advanced document management features.

**Prerequisites**:
- Complete [SharePoint Integration Setup](sharepoint-integration.md) - Document management enabled
- Understanding of JavaScript and Fetch API
- Basic knowledge of HTML/CSS
- Power Pages site with authenticated user access

---

## Why Custom Implementation?

### OOTB vs. Custom

**OOTB Approach** (from [Pet Document Upload (OOTB)](pet-document-upload-ootb.md)):
- ✅ Quick to implement
- ✅ Built-in security
- ✅ Standard SharePoint integration
- ❌ Limited customization
- ❌ Fixed UI/UX
- ❌ No custom upload progress
- ❌ Limited file type filtering

**Custom Approach**:
- ✅ Full UI/UX control
- ✅ Custom upload progress indicators
- ✅ Advanced file type filtering
- ✅ Folder navigation
- ✅ Custom document organization
- ✅ Enhanced user experience
- ❌ Requires JavaScript development
- ❌ More maintenance overhead

---

## Power Pages SharePoint API Overview

Power Pages provides internal SharePoint endpoints that can be reverse-engineered for custom implementations. These endpoints are used by the OOTB document management controls.

### Key Endpoints

1. **Get Anti-forgery Token**: `GET /_portal/{WEBSITE_ID}/Layout/GetAntiForgeryToken`
2. **List Files**: `POST /_services/sharepoint-data.json/{WEBSITE_ID}`
3. **Upload Files**: `POST /_services/sharepoint-addfiles/{WEBSITE_ID}`

### Authentication Requirements

- All requests must include authentication cookies (`credentials: 'include'`)
- Anti-forgery token required for all POST requests
- Requests must be made within the same Power Pages session

---

## Step 1: Get Website ID

The website ID is required for all SharePoint API calls. Multiple strategies can be used:

### Strategy 1: HTML Data Attribute (Recommended)

Add the website ID to your page HTML:

```html
<div class="container wrapper-body" data-website-id="{{ website.id }}"></div>
```

### Strategy 2: JavaScript Detection

```javascript
const websiteId =
  document.body.dataset.websiteId ||
  document.querySelector("[data-website-id]")?.dataset.websiteId ||
  "{{ website.id }}"; // Liquid fallback
```

### Strategy 3: Liquid Template

```liquid
{% assign websiteId = website.id %}
<script>
  const WEBSITE_ID = "{{ website.id }}";
</script>
```

---

## Step 2: Get Anti-forgery Token

The anti-forgery token is required for all POST requests to prevent CSRF attacks.

### Implementation

```javascript
async function getAntiForgeryToken(websiteId) {
  const res = await fetch(
    `/_portal/${websiteId}/Layout/GetAntiForgeryToken?_=${Date.now()}`,
    {
      headers: { 
        Accept: "text/html", 
        "X-Requested-With": "XMLHttpRequest" 
      },
      credentials: "include",
    },
  );
  
  const html = await res.text();
  const tag = html.match(
    /<input[^>]*name=["']__RequestVerificationToken["'][^>]*>/i,
  );
  
  return tag ? tag[0].match(/value=["']([^"']+)["']/i)?.[1] || "" : "";
}
```

### Usage

```javascript
const token = await getAntiForgeryToken(websiteId);
if (!token) {
  throw new Error("Missing anti-forgery token");
}
```

---

## Step 3: List Files

List documents associated with a Pet record.

### Implementation

```javascript
async function listFiles({
  websiteId,
  regardingId,
  logicalName = "pa911_pet",
  page = 1,
  pageSize = 25,
  sortExpression = "Modified DESC",
  pagingInfo = "",
  folderPath = "",
}) {
  const token = await getAntiForgeryToken(websiteId);
  if (!token) throw new Error("Missing anti-forgery token");

  const body = {
    regarding: {
      Id: regardingId,
      LogicalName: logicalName,
      Name: null,
      KeyAttributes: [],
      RowVersion: null,
    },
    sortExpression,
    page,
    pageSize,
    pagingInfo,
    folderPath,
  };

  const res = await fetch(`/_services/sharepoint-data.json/${websiteId}`, {
    method: "POST",
    credentials: "include",
    headers: {
      __RequestVerificationToken: token,
      "Content-Type": "application/json",
      Accept: "application/json, text/javascript, */*; q=0.01",
      "X-Requested-With": "XMLHttpRequest",
    },
    body: JSON.stringify(body),
  });

  if (!res.ok) throw new Error(`List failed: ${res.status}`);

  const data = await res.json();
  return {
    items: Array.isArray(data.SharePointItems) ? data.SharePointItems : [],
    total: Number(data.TotalCount) || 0,
    pagingInfo: data.PagingInfo || "",
  };
}
```

### Pagination Support

```javascript
async function listAllFiles(opts) {
  let page = 1;
  let pagingInfo = "";
  const all = [];

  while (true) {
    const { items, pagingInfo: next } = await listFiles({
      ...opts,
      page,
      pagingInfo,
    });
    
    all.push(...items);
    
    if (!next || next.trim() === "") break;
    
    pagingInfo = next;
    page += 1;
  }

  return all;
}
```

---

## Step 4: Upload Files

Upload documents to SharePoint associated with a Pet record.

### Implementation with Progress Support

```javascript
function uploadFile({
  websiteId,
  regardingId,
  logicalName = "pa911_pet",
  file,
  overwrite = false,
  signal,
  onProgress,
}) {
  return new Promise(async (resolve, reject) => {
    try {
      const token = await getAntiForgeryToken(websiteId);
      if (!token) return reject(new Error("Missing anti-forgery token"));

      const fd = new FormData();
      fd.set("regardingEntityLogicalName", logicalName);
      fd.set("regardingEntityId", regardingId);
      fd.set("overwrite", String(Boolean(overwrite)));
      fd.set("__RequestVerificationToken", token);
      fd.append("files", file, file.name);

      const xhr = new XMLHttpRequest();
      xhr.open("POST", `/_services/sharepoint-addfiles/${websiteId}`, true);
      xhr.setRequestHeader("X-Requested-With", "XMLHttpRequest");
      xhr.withCredentials = true;

      if (onProgress) {
        xhr.upload.onprogress = (e) => {
          if (e.lengthComputable) {
            onProgress({ loaded: e.loaded, total: e.total });
          }
        };
      }

      xhr.onload = () => {
        if (xhr.status >= 200 && xhr.status < 300) {
          const text = xhr.responseText?.trim();
          if (!text) return resolve();

          try {
            const j = JSON.parse(text);
            if (j && j.Message) return reject(new Error(j.Message));
          } catch {}

          resolve();
        } else {
          let msg = "Upload failed";
          try {
            const j = JSON.parse(xhr.responseText || "{}");
            if (j.Message) msg = j.Message;
          } catch {}

          reject(new Error(msg));
        }
      };

      xhr.onerror = () => reject(new Error("Network error during upload"));
      xhr.onabort = () => reject(new Error("Upload canceled"));

      if (signal) {
        signal.addEventListener("abort", () => {
          try {
            xhr.abort();
          } catch {}
        });
      }

      xhr.send(fd);
    } catch (e) {
      reject(e);
    }
  });
}
```

### Upload Multiple Files

```javascript
async function uploadFilesBatch({
  websiteId,
  regardingId,
  logicalName,
  files,
  overwrite,
  onProgress,
}) {
  let uploadedBytes = 0;
  const total = [...files].reduce((s, f) => s + (f.size || 0), 0);

  for (const f of files) {
    await uploadFile({
      websiteId,
      regardingId,
      logicalName,
      file: f,
      overwrite,
      onProgress: ({ loaded }) => {
        uploadedBytes =
          uploadedBytes - (uploadedBytes % (f.size || 1)) + loaded;
        const pct = total ? Math.round((uploadedBytes / total) * 100) : 0;
        if (onProgress) onProgress({ loaded: uploadedBytes, total, percent: pct });
      },
    });
  }
}
```

---

## Step 5: Download Files

Download documents from SharePoint.

### Implementation

```javascript
async function downloadByBlob({ url, fileName = "download" }) {
  const resp = await fetch(url, { credentials: "include" });
  
  if (!resp.ok) throw new Error(`Download failed (${resp.status})`);

  const blob = await resp.blob();
  const a = document.createElement("a");
  a.href = URL.createObjectURL(blob);
  a.download = fileName;
  document.body.appendChild(a);
  a.click();
  document.body.removeChild(a);
  URL.revokeObjectURL(a.href);
}
```

---

## Step 6: Date and File Size Formatting

SharePoint returns dates and file sizes in formats that require special handling.

### Date Formatting

SharePoint returns dates in Microsoft's proprietary format: `/Date(1758829228000)/`

```javascript
function formatDate(dateString) {
  if (!dateString) return "";

  // Handle SharePoint date format: /Date(1758829228000)/
  const dateMatch = dateString.match(/\/Date\((\d+)\)\//);
  if (dateMatch) {
    const timestamp = parseInt(dateMatch[1]);
    const date = new Date(timestamp);
    return date.toLocaleDateString("en-US", {
      year: "numeric",
      month: "short",
      day: "numeric",
      hour: "2-digit",
      minute: "2-digit",
    });
  }

  // Handle other date formats
  try {
    const date = new Date(dateString);
    if (!isNaN(date.getTime())) {
      return date.toLocaleDateString("en-US", {
        year: "numeric",
        month: "short",
        day: "numeric",
        hour: "2-digit",
        minute: "2-digit",
      });
    }
  } catch (e) {
    // Fallback to original string if parsing fails
  }

  return dateString;
}
```

### File Size Formatting

SharePoint returns file sizes as raw bytes:

```javascript
function formatFileSize(bytes) {
  if (!bytes || bytes === 0) return "";

  const sizes = ["B", "KB", "MB", "GB"];
  const i = Math.floor(Math.log(bytes) / Math.log(1024));
  
  if (i === 0) return `${bytes} ${sizes[i]}`;
  
  return `${(bytes / Math.pow(1024, i)).toFixed(1)} ${sizes[i]}`;
}
```

---

## Step 7: Folder Navigation

Handle SharePoint folder paths for navigation.

### Breadcrumb Implementation

```javascript
function updateBreadcrumb(currentPath) {
  if (!currentPath) return;

  // Handle SharePoint folder path format (starts with "/")
  const cleanPath = currentPath.startsWith("/")
    ? currentPath.substring(1)
    : currentPath;

  const pathParts = cleanPath.split("/").filter((part) => part.trim());

  const breadcrumbHtml = pathParts
    .map((part, index) => {
      const isLast = index === pathParts.length - 1;
      // Reconstruct the full SharePoint path for navigation
      const pathToHere = "/" + pathParts.slice(0, index + 1).join("/");

      if (isLast) {
        return `<span class="cmp-breadcrumb-item active">${part}</span>`;
      } else {
        return `<span class="cmp-breadcrumb-item">
          <button class="cmp-breadcrumb-link" 
                  onclick="navigateToPath('${encodeURIComponent(pathToHere)}')" 
                  title="Go to ${part}">${part}</button>
        </span>`;
      }
    })
    .join("");

  // Update breadcrumb element
  const breadcrumbElement = document.getElementById("breadcrumb");
  if (breadcrumbElement) {
    breadcrumbElement.innerHTML = breadcrumbHtml;
  }
}

function navigateToPath(folderPath) {
  State.currentPath = decodeURIComponent(folderPath);
  State.currentPage = 1; // Reset pagination
  State.pagingInfo = ""; // Clear pagination token
  loadDocuments(); // Reload documents for new path
}
```

---

## Step 8: Complete Implementation Example

### HTML Structure

```html
<div class="container mt-4" data-website-id="{{ website.id }}">
  <h1>Pet Documents</h1>
  
  <!-- Breadcrumb -->
  <nav id="breadcrumb" class="mb-3"></nav>
  
  <!-- Upload Area -->
  <div class="upload-area mb-4">
    <input type="file" id="fileInput" multiple accept=".pdf,.jpg,.jpeg,.png">
    <button id="uploadBtn" class="btn btn-primary">Upload Files</button>
    <div id="uploadProgress" class="progress mt-2" style="display: none;">
      <div class="progress-bar" role="progressbar" style="width: 0%"></div>
    </div>
  </div>
  
  <!-- Document List -->
  <div id="documentList" class="document-list">
    <div id="loadingState" class="text-center">
      <div class="spinner-border" role="status">
        <span class="visually-hidden">Loading...</span>
      </div>
    </div>
    <div id="emptyState" class="text-center d-none">
      <p>No documents found.</p>
    </div>
    <div id="documentItems" class="row"></div>
  </div>
  
  <!-- Pagination -->
  <nav id="pagination" class="mt-4 d-none">
    <button id="prevBtn" class="btn btn-secondary">Previous</button>
    <span id="pageInfo" class="mx-3"></span>
    <button id="nextBtn" class="btn btn-secondary">Next</button>
  </nav>
</div>
```

### JavaScript State Management

```javascript
const State = {
  websiteId: document.querySelector("[data-website-id]")?.dataset.websiteId || "{{ website.id }}",
  petId: "{{ request.params['id'] }}", // Get from URL or Liquid
  currentPath: "",
  currentPage: 1,
  pagingInfo: "",
  totalCount: 0,
};

// Initialize
document.addEventListener("DOMContentLoaded", () => {
  loadDocuments();
  setupUploadHandler();
  setupPagination();
});
```

### Document Loading

```javascript
async function loadDocuments() {
  showLoading();
  
  try {
    const result = await listFiles({
      websiteId: State.websiteId,
      regardingId: State.petId,
      logicalName: "pa911_pet",
      page: State.currentPage,
      pageSize: 25,
      sortExpression: "Modified DESC",
      pagingInfo: State.pagingInfo,
      folderPath: State.currentPath,
    });
    
    State.totalCount = result.total;
    State.pagingInfo = result.pagingInfo;
    
    displayDocuments(result.items);
    updatePagination();
    hideLoading();
  } catch (error) {
    console.error("Error loading documents:", error);
    showError(error.message);
    hideLoading();
  }
}

function displayDocuments(items) {
  const container = document.getElementById("documentItems");
  
  if (items.length === 0) {
    document.getElementById("emptyState").classList.remove("d-none");
    container.innerHTML = "";
    return;
  }
  
  document.getElementById("emptyState").classList.add("d-none");
  
  container.innerHTML = items.map(item => `
    <div class="col-md-4 mb-3">
      <div class="card">
        <div class="card-body">
          <h5 class="card-title">
            <i class="${getFileIcon(item.Name)}"></i>
            ${item.Name}
          </h5>
          <p class="card-text">
            <small class="text-muted">
              ${formatFileSize(item.FileSize || item.File_x0020_Size)} • 
              ${formatDate(item.Modified || item.ModifiedOn)}
            </small>
          </p>
          <a href="${item.Url}" 
             class="btn btn-sm btn-primary" 
             target="_blank">Download</a>
        </div>
      </div>
    </div>
  `).join("");
}
```

### File Icon Mapping

```javascript
function getFileIcon(filename) {
  if (!filename) return "bi-file-earmark";
  
  const ext = filename.split(".").pop()?.toLowerCase();
  const iconMap = {
    pdf: "bi-file-earmark-pdf",
    doc: "bi-file-earmark-word",
    docx: "bi-file-earmark-word",
    xls: "bi-file-earmark-excel",
    xlsx: "bi-file-earmark-excel",
    ppt: "bi-file-earmark-ppt",
    pptx: "bi-file-earmark-ppt",
    txt: "bi-file-earmark-text",
    zip: "bi-file-earmark-zip",
    jpg: "bi-file-earmark-image",
    jpeg: "bi-file-earmark-image",
    png: "bi-file-earmark-image",
    gif: "bi-file-earmark-image",
    mp4: "bi-file-earmark-play",
    avi: "bi-file-earmark-play",
    mov: "bi-file-earmark-play",
  };
  
  return iconMap[ext] || "bi-file-earmark";
}
```

### Upload Handler

```javascript
function setupUploadHandler() {
  const fileInput = document.getElementById("fileInput");
  const uploadBtn = document.getElementById("uploadBtn");
  const progressBar = document.getElementById("uploadProgress");
  const progressBarFill = progressBar.querySelector(".progress-bar");
  
  uploadBtn.addEventListener("click", async () => {
    const files = fileInput.files;
    if (files.length === 0) {
      alert("Please select files to upload");
      return;
    }
    
    // Validate files
    for (const file of files) {
      if (!validateFile(file)) return;
    }
    
    progressBar.style.display = "block";
    progressBarFill.style.width = "0%";
    
    try {
      await uploadFilesBatch({
        websiteId: State.websiteId,
        regardingId: State.petId,
        logicalName: "pa911_pet",
        files: Array.from(files),
        overwrite: false,
        onProgress: ({ percent }) => {
          progressBarFill.style.width = `${percent}%`;
          progressBarFill.textContent = `${percent}%`;
        },
      });
      
      alert("Files uploaded successfully!");
      fileInput.value = "";
      progressBar.style.display = "none";
      loadDocuments(); // Reload document list
    } catch (error) {
      console.error("Upload error:", error);
      alert("Upload failed: " + error.message);
      progressBar.style.display = "none";
    }
  });
}

function validateFile(file) {
  const maxSize = 10 * 1024 * 1024; // 10MB
  const allowedTypes = [
    "application/pdf",
    "image/jpeg",
    "image/png",
    "image/jpg",
  ];
  
  if (file.size > maxSize) {
    alert(`File ${file.name} exceeds 10MB limit`);
    return false;
  }
  
  if (!allowedTypes.includes(file.type)) {
    alert(`File type not allowed for ${file.name}`);
    return false;
  }
  
  return true;
}
```

### Pagination

```javascript
function setupPagination() {
  const prevBtn = document.getElementById("prevBtn");
  const nextBtn = document.getElementById("nextBtn");
  
  prevBtn.addEventListener("click", () => {
    if (State.currentPage > 1) {
      State.currentPage--;
      State.pagingInfo = ""; // Reset for previous page
      loadDocuments();
    }
  });
  
  nextBtn.addEventListener("click", () => {
    if (State.pagingInfo && State.pagingInfo.trim() !== "") {
      State.currentPage++;
      loadDocuments();
    }
  });
}

function updatePagination() {
  const pagination = document.getElementById("pagination");
  const prevBtn = document.getElementById("prevBtn");
  const nextBtn = document.getElementById("nextBtn");
  const pageInfo = document.getElementById("pageInfo");
  
  const hasMore = State.pagingInfo && State.pagingInfo.trim() !== "";
  const hasPrev = State.currentPage > 1;
  
  if (hasMore || hasPrev) {
    pagination.classList.remove("d-none");
    prevBtn.disabled = !hasPrev;
    nextBtn.classList.toggle("d-none", !hasMore);
    
    const showing = State.currentPage * 25;
    pageInfo.textContent = `Page ${State.currentPage} (Showing ${Math.min(showing, State.totalCount)} of ${State.totalCount})`;
  } else {
    pagination.classList.add("d-none");
  }
}
```

---

## Field Mapping Reference

SharePoint API returns the following fields:

| Field | Description | Example |
|-------|-------------|---------|
| `Name` | File name | `vaccination-record.pdf` |
| `Url` | Direct download URL | `https://sharepoint.com/...` |
| `IsFolder` | Whether item is a folder | `true` or `false` |
| `Modified` or `ModifiedOn` | Last modified date | `/Date(1758829228000)/` |
| `ModifiedOnDisplay` | Formatted modified date | `"Jan 15, 2025"` |
| `FileSize` or `File_x0020_Size` | File size in bytes | `152467` |
| `FileSizeDisplay` | Formatted file size | `"149 KB"` |
| `FolderPath` | SharePoint folder path | `/PetDocuments` |

---

## Production Implementation Lessons Learned

### Error Handling

Always implement comprehensive error handling:

```javascript
try {
  const result = await listFiles({...});
} catch (error) {
  if (error.message.includes("anti-forgery")) {
    // Retry with new token
    await loadDocuments();
  } else {
    showError(error.message);
  }
}
```

### State Management

- Reset pagination when changing filters or paths
- Clear paging info when starting new searches
- Maintain current path for breadcrumb navigation

### Performance Considerations

1. **Debounced Operations**: Use debouncing for search/filter operations
2. **Loading States**: Always show loading indicators during API calls
3. **Error Recovery**: Provide retry mechanisms for failed operations
4. **Memory Management**: Clean up object URLs after downloads
5. **State Validation**: Check for required data before API calls

### Security Considerations

1. **URL Encoding**: Always encode user input in URLs
2. **XSS Prevention**: Sanitize data before rendering HTML
3. **CSRF Protection**: Always include anti-forgery tokens
4. **Credential Handling**: Use `credentials: "include"` for authenticated requests

---

## Troubleshooting

### Common Issues

**Issue**: Anti-forgery token not found
- **Solution**: Verify website ID is correct
- **Solution**: Check that user is authenticated
- **Solution**: Verify Power Pages session is active

**Issue**: Upload fails with 403 error
- **Solution**: Verify table permissions allow Write access
- **Solution**: Check SharePoint site permissions
- **Solution**: Verify anti-forgery token is included

**Issue**: Documents not appearing after upload
- **Solution**: Reload document list after upload
- **Solution**: Verify document location is correct
- **Solution**: Check SharePoint folder permissions

**Issue**: Date formatting errors
- **Solution**: Use the provided `formatDate()` function
- **Solution**: Handle both `/Date(...)/` format and ISO strings

---

## Next Steps

- **[Appointment History](appointment-history.md)** - Display appointment history for pets
- **[ALM Overview](alm-overview.md)** - Learn about deployment and lifecycle management

---

## References

- [Manage SharePoint documents in Power Pages](https://learn.microsoft.com/en-us/power-pages/configure/manage-sharepoint-documents)
- [Power Pages Web API](https://learn.microsoft.com/en-us/power-pages/configure/web-api-overview)
- [Fetch API Documentation](https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API)


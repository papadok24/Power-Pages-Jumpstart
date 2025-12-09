# Power Pages Jumpstart - Veterinary Appointment Booking Portal

## Project Overview

A 3-day (~12 hours total) Power Pages jumpstart class teaching external-facing, data-driven website development through a **Veterinary Appointment Booking Portal** demo.

**Core Value Proposition**: Power Pages solves the problem of exposing internal Dataverse data to external users in a secure, controlled manner with a low-code first approach.

---

## Demo Scenario: PawsFirst Veterinary Portal

A modern appointment booking portal for a veterinary clinic where pet owners can:

- Register/login to manage their profile
- View available appointment slots (Card Gallery)
- Book appointments for their pets
- Upload pet medical documents (SharePoint integration via Web API)
- View appointment history (modern list controls)

### Technical Focus Areas

1. **Custom Web Components** - Using Web Templates with `{% manifest %}` tags to create reusable, configurable components
2. **Portals Web API** - Performing CRUD operations without traditional forms for richer user experiences
3. **Enhanced File Uploads** - SharePoint integration for secure document storage
4. **New UX Components** - Leveraging Card Gallery, Flex Containers, and modern list controls
5. **Custom User Invitation System** - Streamlined onboarding for external users
6. **Liquid Syntax** - Server-side logic using Power Pages' subset of Liquid template language

---

## Portal Information Architecture

The PawsFirst portal is organized into two main zones: **public** (accessible to anonymous users) and **authenticated** (requires login). The portal focuses on three customer-facing data areas: **Pets**, **Booking Requests**, and **Appointments**.

### Public Zone

| Page | URL | Purpose | Access |
|------|-----|---------|--------|
| **Home** | `/` | Marketing/overview page | Anonymous & Authenticated |
| **Book Appointment** | `/book-appointment` | Anonymous booking request form | Anonymous & Authenticated |

### Authenticated Zone

| Page | URL | Purpose | Access |
|------|-----|---------|--------|
| **Dashboard** | `/dashboard` | **Default landing page for signed-in customers** - Summary view of Pets, Active Appointments, and Booking Requests | Authenticated Users |
| **My Pets** | `/my-pets` | Full list of user's pets with add/edit capability | Authenticated Users |
| **My Appointments** | `/my-appointments` | Full list of appointments (Active and History views) | Authenticated Users |
| **My Booking Requests** | `/my-booking-requests` | Full list of booking requests tied to the user's Contact | Authenticated Users |
| **Profile** | `/profile` | Manage contact details and profile information | Authenticated Users |

### Dashboard Architecture

The **Dashboard** is the primary teaching example for building a customer dashboard in Power Pages. It displays:

- **My Pets Summary**: Top 5 pets with "View All" link to `/my-pets`
- **Active Appointments Summary**: Top 5 active appointments with "View All" link to `/my-appointments`
- **Booking Requests Summary**: Top 5 booking requests with "View All" link to `/my-booking-requests`

Each summary section uses Entity Lists with `recordsperpage:5` to limit display, with full lists available on dedicated pages.

### Data Architecture

The portal exposes only three customer-facing tables through Entity Lists:
- **Pets** (`pa911_pet`) - Managed via My Pets page
- **Booking Requests** (`pa911_bookingrequest`) - Created from public form, viewed on Dashboard and My Booking Requests page
- **Appointments** (`appointment`) - Displayed as Active and History on Dashboard and My Appointments page

**Supporting tables** (Service, Appointment Slot) are used in booking workflows but are not exposed as customer-facing lists. See [Data Model Design](docs/day-1/data-model.md) for details.

### Navigation Flow

1. **Anonymous users** can access Home and Book Appointment pages
2. **After booking**, Power Automate creates Contact and sends invitation
3. **Authenticated users** land on Dashboard after login (configured via site settings/login redirect)
4. **Dashboard** provides quick access to all customer data with "View All" links to detail pages
5. **Detail pages** (My Pets, My Appointments, My Booking Requests) show full Entity Lists with search, sort, and pagination

---

## 3-Day Class Outline

### Day 1: Foundation (~4 hours)

| Time | Topic |
|------|-------|
| 0:00-0:45 | **What is Power Pages?** - Benefits, architecture, ideal use cases |
| 0:45-1:30 | **Environment Tour** - Design Studio, Dataverse, site settings |
| 1:30-2:15 | **Demo: Create PawsFirst Site** - Starting from blank template |
| 2:15-2:30 | **Break** |
| 2:30-3:15 | **Dataverse Modeling** - Pets, Appointments, Services tables |
| 3:15-4:00 | **Lists and Views** - OOTB Entity Lists for customer dashboard (Pets, Booking Requests, Appointments) |

### Day 2: Building Features (~4 hours)

| Time | Topic |
|------|-------|
| 0:00-0:30 | **Build: Anonymous Booking Form** - OOTB Entity Forms for public access |
| 0:30-1:00 | **Liquid Syntax Fundamentals** - Objects, tags, filters |
| 1:00-1:30 | **Power Automate Integration** - Cloud flows triggered from Power Pages |
| 1:30-2:00 | **Identity Providers Deep Dive** - Entra ID configuration, Contact system architecture |
| 2:00-2:15 | **Break** |
| 2:15-2:30 | **Build: User Onboarding Flow** - Review portal invitation automation flow |
| 2:30-3:00 | **Custom Web Templates** - Manifest structure, parameters (optional) |
| 3:00-3:30 | **Build: Customer Dashboard** - Create dashboard page with summary Entity Lists for Pets, Appointments, and Booking Requests |
| 3:30-4:00 | **Wrap-up** - Day 2 review, Q&A, preview Day 3 |

### Day 3: Advanced Features (~4 hours)

| Time | Topic |
|------|-------|
| 0:00-0:45 | **SharePoint Integration Setup** - Enable document management, configure locations |
| 0:45-1:30 | **Build: Pet Document Upload (OOTB)** - Subgrid and form-based document management |
| 1:30-2:15 | **Build: Pet Document Upload (Custom)** - Reverse-engineered SharePoint API implementation |
| 2:15-2:30 | **Break** |
| 2:30-3:00 | **View Appointment History** - OOTB Entity Lists and custom views |
| 3:00-3:30 | **ALM Overview** - Solutions, PAC CLI, Pipelines, GitHub Actions |
| 3:30-4:00 | **Wrap-up** - Deployment best practices, course review, Q&A |

---

## Technology Stack

- **Power Pages** - Low-code platform for data-driven websites
- **Microsoft Dataverse** - Data storage and management
- **Bootstrap 5.2.2** - Responsive design framework (built-in)
- **jQuery** - Client-side interactivity (built-in)
- **Liquid Template Language** - Server-side logic and templating
- **Portals Web API** - RESTful API for Dataverse operations
- **PAC CLI** - Power Platform CLI for site metadata management

---

## Key Concepts Covered

### Liquid Syntax in Power Pages

Power Pages supports a subset of Shopify's Liquid, with Power Pages-specific objects:

**Objects:**
- `page` - Current page information
- `request` - HTTP request details
- `user` - Current user context
- `sitemap` - Site navigation structure
- `entities` - Dataverse data access
- `params` - URL/query parameters
- `settings` - Site configuration settings

**Tags:**
- `if/else` - Conditional logic
- `for` - Loops
- `case` - Switch statements
- `assign` - Variable assignment
- `capture` - Content capture
- `include` - Template includes
- `fetchxml` - Dataverse queries
- `entitylist` - Display lists
- `entityform` - Display forms

**Filters:** Standard Liquid filters + Dataverse-specific filters

### Custom Web Components

Web templates can be created as reusable components using the `{% manifest %}` tag. This allows pro-developers to build advanced components that low-code makers can configure through the Design Studio.

**Key Features:**
- Parameter configuration in Design Studio
- Type definitions (Functional components)
- Table associations for data workspace navigation
- Reusable across multiple pages

**Reference:** [Web templates as components](https://learn.microsoft.com/en-us/power-pages/configure/web-templates-as-components)

### Portals Web API

The Portals Web API enables rich user experiences by performing CRUD operations directly from webpages without using forms.

**Capabilities:**
- Create, read, update, delete operations
- Works with all Dataverse tables
- Server-side caching for performance
- Requires Power Pages license

**Reference:** [Portals Web API overview](https://learn.microsoft.com/en-us/power-pages/configure/web-api-overview)

---

## Folder Structure

This project follows a mono-repo approach for managing Power Pages site metadata and Power Platform solution objects using PAC CLI.

```
Power-Pages-Jumpstart/
├── README.md                    # Project overview & class outline
├── docs/
│   ├── day-1/                   # Day 1 reference materials
│   ├── day-2/                   # Day 2 reference materials
│   └── day-3/                   # Day 3 reference materials
├── src/
│   ├── pawsfirst---pawsfirst-pa911/  # PAC CLI: Power Pages site metadata
│   │   ├── web-pages/           # Web page definitions (Home, Dashboard, My Pets, etc.)
│   │   ├── web-templates/       # Custom web template components
│   │   ├── content-snippets/    # Reusable content snippets
│   │   ├── web-files/           # Static files (CSS, JS, images)
│   │   └── basic-forms/        # Entity Forms (Booking Request, etc.)
│   └── PowerPagesJumpstartBase/  # PAC CLI: Power Platform solution
│       ├── Entities/            # Dataverse tables (Pets, Appointments, Services, etc.)
│       ├── WebResources/       # Custom JavaScript/CSS files
│       └── Other/              # Other solution components
├── scripts/                     # Helper scripts (PAC CLI commands, automation)
└── assets/                      # Images, diagrams, presentation materials
```

---

## Getting Started

### Prerequisites

- Power Pages environment access
- Power Platform CLI (PAC CLI) installed
- Basic understanding of Dataverse concepts
- Familiarity with HTML/CSS helpful but not required

### Environment Setup

1. Provision a Power Pages site in your Power Platform environment
2. Configure Dataverse tables (Pets, Appointments, Services)
3. Set up authentication (Microsoft Entra ID or local authentication)
4. Export site metadata using PAC CLI (see scripts folder)

### PAC CLI Commands

```bash
# Export Power Pages site metadata
pac pages download --path ./src/site

# Import Power Pages site metadata
pac pages upload --path ./src/site

# Export Power Platform solution
pac solution export --path ./src/solution
```

### Building Managed Solutions

To build managed solution packages from the `.cdsproj` files in the `src/` directory, use the build script:

```powershell
.\scripts\Build-Solutions.ps1 -Version "1.0.0.1"
```

**Parameters:**
- `-Version` (Required): Version number in format `Major.Minor.Patch.Build` (e.g., "1.0.0.1")
- `-OutputPath` (Optional): Output directory for built solutions (default: "build/solutions")
- `-Configuration` (Optional): MSBuild configuration (default: "Release")

**Example:**
```powershell
# Build all solutions with version 1.0.0.1
.\scripts\Build-Solutions.ps1 -Version "1.0.0.1"

# Build with custom output path
.\scripts\Build-Solutions.ps1 -Version "2.0.0.0" -OutputPath "dist"
```

The script will:
1. Find all `.cdsproj` files in the `src/` directory
2. Update each solution's `Solution.xml` with the specified version
3. Build managed solution packages using MSBuild
4. Output solution ZIP files to the specified output directory

**Prerequisites:**
- MSBuild (included with Visual Studio or Visual Studio Build Tools)
- .NET SDK (for NuGet package restore)
- PowerShell 5.1 or later

---

## Documentation

### Day 1: Foundation

- **[Site Provisioning Guide](docs/day-1/site-provisioning-guide.md)** - Step-by-step instructions for creating the Power Pages site with Microsoft Entra ID authentication
- **[Home Page Build](docs/day-1/home-page-build.md)** - Theme/brand setup and building the home page with Design Studio low-code builder
- **[Data Model Design](docs/day-1/data-model.md)** - Complete Dataverse entity schemas, relationships, and table permissions for Pets, Services, Appointments, and Documents
- **[Lists and Views](docs/day-2/lists-and-views.md)** - OOTB Entity Lists for customer dashboard (Pets, Booking Requests, Appointments) and Dataverse views

### Day 2: Building Features

- **[Booking Request Form](docs/day-2/booking-request-form.md)** - Step-by-step guide for creating anonymous OOTB Entity Forms
- **[User Stories](docs/day-1/user-stories.md)** - 8 Liquid-focused user stories covering Pets, Appointments, and Services interactions
- **[Identity and Contacts](docs/day-2/identity-and-contacts.md)** - Power Pages authentication architecture, Microsoft Entra ID integration, and Contact system
- **[Power Automate Integration](docs/day-2/power-automate-integration.md)** - Cloud flow setup for user onboarding automation
- **[Custom Web Templates](docs/day-2/custom-web-templates.md)** - Optional advanced topic on web template components with manifest

### Day 3: Advanced Features

- **[SharePoint Integration](docs/day-3/sharepoint-integration.md)** - Enable SharePoint document management for Pet records
- **[Pet Document Upload (OOTB)](docs/day-3/pet-document-upload-ootb.md)** - Out-of-the-box document management using subgrids
- **[Pet Document Upload (Custom)](docs/day-3/pet-document-upload-custom.md)** - Custom implementation using reverse-engineered SharePoint API
- **[Appointment History](docs/day-3/appointment-history.md)** - Display appointment history using OOTB Entity Lists and custom views
- **[ALM Overview](docs/day-3/alm-overview.md)** - Application Lifecycle Management: Solutions, PAC CLI, Pipelines, and GitHub Actions

---

## Key Resources

- [Web templates as components](https://learn.microsoft.com/en-us/power-pages/configure/web-templates-as-components)
- [Portals Web API overview](https://learn.microsoft.com/en-us/power-pages/configure/web-api-overview)
- [Power Pages Documentation](https://learn.microsoft.com/en-us/power-pages/)
- [Power Platform CLI Documentation](https://learn.microsoft.com/en-us/power-platform/developer/cli/introduction)

---

## Ideal Power Pages Use Cases

Power Pages is ideal when you need to:

- **Expose internal data externally** - Share Dataverse data with customers, partners, or vendors
- **Build data-driven websites** - Websites that require dynamic content from business systems
- **Enable self-service** - Allow external users to manage their own data (cases, accounts, documents)
- **Rapid development** - Build secure portals faster than custom web development
- **Leverage existing investments** - Extend Power Platform and Dataverse to external audiences

**Common Portal Types:**
- Customer self-service portals
- Partner/vendor portals
- Application/intake portals
- Event registration portals
- Community portals
- Appointment booking systems

---

## Class Delivery Notes

- **Format**: Instructor-led demo with optional follow-along
- **Pacing**: Approximately 4 hours per day with breaks
- **Hands-on**: Students encouraged to follow along but not required
- **Pre-work**: Environment setup instructions may be provided separately

---

## License

This project is for educational purposes as part of a Power Pages training class.


# Home Page Build - PawsFirst Portal

## Overview

This guide walks through building the initial home page for the PawsFirst Veterinary Portal using the Power Pages Design Studio low-code builder. We'll start by establishing the brand and theme, then build each section of the home page using the visual editor.

---

## Prerequisites

- Power Pages site provisioned (see [Site Provisioning Guide](site-provisioning-guide.md))
- Dataverse solution deployed with Pet, Service, and Appointment tables
- Access to Power Pages Design Studio

---

## Part 1: Theme and Brand Setup

Before building pages, establish your site's visual identity through the Design Studio styling tools.

### Step 1.1: Access Styling Settings

1. Open your Power Pages site in **Design Studio**
2. Click **Styling** in the left navigation panel
3. You'll see the theme customization workspace

### Step 1.2: Configure Brand Colors

In the **Color** section, set the PawsFirst brand palette:

| Color Role | Recommended Value | Purpose |
|------------|-------------------|---------|
| **Primary** | `#2E7D32` (Forest Green) | Main brand color, buttons, links |
| **Secondary** | `#1565C0` (Blue) | Secondary actions, accents |
| **Background** | `#FFFFFF` (White) | Page backgrounds |
| **Foreground** | `#212121` (Dark Gray) | Body text |
| **Header Background** | `#2E7D32` (Forest Green) | Site header |
| **Footer Background** | `#1B5E20` (Dark Green) | Site footer |

**To set colors:**
1. Click on each color swatch
2. Enter the hex value or use the color picker
3. Preview changes in real-time on the right panel

### Step 1.3: Configure Typography

In the **Font** section, configure text styles:

**Recommended Font Settings:**

| Element | Font Family | Size | Weight |
|---------|-------------|------|--------|
| **Headings** | Poppins or Montserrat | Various | Semi-Bold (600) |
| **Body Text** | Open Sans or Roboto | 16px | Regular (400) |
| **Navigation** | Same as Headings | 14px | Medium (500) |

**To configure fonts:**
1. Select a font family from the dropdown (Google Fonts available)
2. Adjust base font size for body text
3. Preview how text appears across the site

### Step 1.4: Configure Button Styles

In the **Button** section, style your call-to-action buttons:

**Primary Button:**
- Background: Primary color (`#2E7D32`)
- Text: White (`#FFFFFF`)
- Border Radius: 8px (rounded corners)
- Padding: 12px 24px

**Secondary Button:**
- Background: Transparent
- Text: Primary color
- Border: 2px solid Primary color
- Border Radius: 8px

### Step 1.5: Upload Logo

1. In **Styling** > **Logo**, click **Upload logo**
2. Upload your PawsFirst logo image (recommended: PNG with transparent background)
3. Adjust logo size:
   - **Header Logo Width**: 150-200px
   - Maintain aspect ratio

### Step 1.6: Set Favicon

1. In **Styling** > **Favicon**, upload a square icon (32x32 or 64x64 pixels)
2. This appears in browser tabs

### Step 1.7: Save and Preview

1. Click **Save** to apply theme changes
2. Click **Preview** to see the theme across your site
3. Verify colors, fonts, and logo appear correctly

---

## Part 2: Home Page Structure

The PawsFirst home page will include these sections built with the Design Studio components:

| Section | Purpose | Component Type |
|---------|---------|----------------|
| **Hero Banner** | Welcome message and primary CTA | Section with Text + Button |
| **Services Overview** | Showcase available services | Card Gallery or Flex Container |
| **Why Choose Us** | Trust builders and benefits | Multi-column layout |
| **Quick Actions** | Navigation to key features | Button group |
| **Contact Info** | Location and hours | Text + Spacer |

---

## Part 3: Build the Home Page

### Step 3.1: Navigate to Pages

1. In Design Studio, click **Pages** in the left navigation
2. Select the **Home** page (created by default)
3. The page opens in the visual editor

### Step 3.2: Build Hero Banner Section

**Add a Section:**
1. Click **+ Add a section** on the canvas
2. Choose **1 column layout**
3. Click on the section to select it

**Configure Section Background:**
1. With the section selected, click the **Style** tab in the right panel
2. Set **Background**: 
   - Option A: Solid color using your Primary color with 10% opacity
   - Option B: Upload a hero image of a veterinary clinic or pets
3. Set **Padding**: Top 80px, Bottom 80px
4. Set **Text Alignment**: Center

**Add Hero Content:**
1. Click **+ Add a component** inside the section
2. Add a **Text** component
3. Configure the text:
   - **Heading (H1)**: "Welcome to PawsFirst Veterinary Portal"
   - **Subheading**: "Your trusted partner in pet care. Book appointments, manage your pet's health records, and access our services online."
4. Style the heading:
   - Font Size: 48px (or use H1 preset)
   - Color: Primary color or white (if using dark background image)
   - Font Weight: Bold

**Add Call-to-Action Button:**
1. Click **+ Add a component**
2. Add a **Button** component
3. Configure:
   - **Text**: "Book an Appointment"
   - **Link**: `/book-appointment`
   - **Style**: Primary button
   - **Size**: Large

**Add Secondary Button (Optional):**
1. Add another **Button** component
2. Configure:
   - **Text**: "View Our Services"
   - **Link**: `/services`
   - **Style**: Secondary/Outline button

### Step 3.3: Build Services Overview Section

**Add Section:**
1. Click **+ Add a section** below the hero
2. Choose **1 column layout** for the header, then add content below

**Add Section Header:**
1. Add a **Text** component
2. Configure:
   - **Heading (H2)**: "Our Services"
   - **Subtext**: "Comprehensive care for your furry, feathered, and scaly friends"
3. Center align the text
4. Add padding below: 40px

**Option A: Use List Component (Data-Driven)**

1. Click **+ Add a component**
2. Select **List** from the Data components
3. Configure the list:
   - **Table**: Select `pa911_service` (Service)
   - **View**: Create a new view or use default
   - **Columns to display**: Name, Description, Duration, Price
4. Set **Layout**: Cards (if available) or Table
5. Configure **Filters**: Show only Active records (`statecode = 0`)

**Option B: Use Flex Container with Cards (Manual)**

1. Click **+ Add a component**
2. Select **Flex Container**
3. Configure:
   - **Direction**: Row
   - **Wrap**: Wrap
   - **Gap**: 24px
   - **Justify Content**: Center

4. Inside the Flex Container, add **Card** components for each service:

**Service Card 1 - Annual Checkup:**
- Add **Card** component
- **Title**: "Annual Checkup"
- **Description**: "Comprehensive health examination for your pet including vaccinations review."
- **Footer**: "$75 | 30 minutes"
- Card width: 300px or 33% of container

**Service Card 2 - Vaccinations:**
- **Title**: "Vaccinations"
- **Description**: "Keep your pet protected with our complete vaccination services."
- **Footer**: "$45 | 15 minutes"

**Service Card 3 - Surgery:**
- **Title**: "Surgery"
- **Description**: "Professional Surgery services to keep your pet looking and feeling great."
- **Footer**: "$50 | 60 minutes"

### Step 3.4: Build Why Choose Us Section

**Add Section:**
1. Click **+ Add a section**
2. Choose **3 column layout**
3. Set section background: Light gray (`#F5F5F5`)
4. Set padding: Top 60px, Bottom 60px

**Add Section Title:**
1. Above the columns, add a **Text** component spanning full width
2. **Heading (H2)**: "Why Choose PawsFirst?"
3. Center align, add bottom margin: 40px

**Column 1 - Experienced Staff:**
1. In the first column, add an **Icon** component (if available) or **Image**
2. Add **Text** component:
   - **Heading (H4)**: "Experienced Veterinarians"
   - **Body**: "Our team of certified veterinarians brings decades of combined experience in pet care."

**Column 2 - Modern Facility:**
1. Add **Icon** or **Image**
2. Add **Text** component:
   - **Heading (H4)**: "Modern Facilities"
   - **Body**: "State-of-the-art equipment and comfortable environment for your pet's visit."

**Column 3 - Convenient Booking:**
1. Add **Icon** or **Image**
2. Add **Text** component:
   - **Heading (H4)**: "Easy Online Booking"
   - **Body**: "Book appointments 24/7 through our convenient online portal."

### Step 3.5: Build Quick Actions Section

**Add Section:**
1. Click **+ Add a section**
2. Choose **1 column layout**
3. Set padding: Top 60px, Bottom 60px
4. Center content alignment

**Add Section Header:**
1. Add **Text** component
2. **Heading (H2)**: "Get Started Today"
3. **Subtext**: "Access all your pet care needs in one place"

**Add Button Group:**
1. Add a **Flex Container**
2. Configure:
   - **Direction**: Row
   - **Justify Content**: Center
   - **Gap**: 16px
   - **Wrap**: Wrap

3. Add **Button** components inside:

| Button Text | Link | Style |
|-------------|------|-------|
| "My Pets" | `/my-pets` | Primary |
| "Book Appointment" | `/book-appointment` | Primary |
| "My Appointments" | `/appointments` | Secondary |
| "Contact Us" | `/contact` | Secondary |

### Step 3.6: Build Contact Information Section

**Add Section:**
1. Click **+ Add a section**
2. Choose **2 column layout**
3. Set background: Primary color with 5% opacity or light green tint
4. Set padding: Top 60px, Bottom 60px

**Column 1 - Contact Details:**
1. Add **Text** component:
   - **Heading (H3)**: "Visit Us"
   - **Body**:
     ```
     PawsFirst Veterinary Clinic
     123 Pet Care Avenue
     City, State 12345
     
     Phone: (555) 123-4567
     Email: info@pawsfirst.com
     ```

**Column 2 - Hours:**
1. Add **Text** component:
   - **Heading (H3)**: "Hours of Operation"
   - **Body**:
     ```
     Monday - Friday: 8:00 AM - 6:00 PM
     Saturday: 9:00 AM - 4:00 PM
     Sunday: Emergency Only
     ```

---

## Part 4: Configure Page Settings

### Step 4.1: Set Page Metadata

1. With the Home page open, click **Page settings** (gear icon)
2. Configure:
   - **Page Title**: "Home | PawsFirst Veterinary Portal"
   - **Meta Description**: "Book veterinary appointments online at PawsFirst. Manage your pet's health records, view our services, and access care 24/7."
   - **URL**: `/` (root)

### Step 4.2: Configure Visibility

1. In Page settings, set **Who can see this page**:
   - Select **Everyone** (public page for both anonymous and authenticated users)
2. This allows visitors to see the home page before signing in

---

## Part 5: Save and Publish

### Step 5.1: Save Changes

1. Click **Save** in the top toolbar
2. Verify no validation errors appear

### Step 5.2: Preview the Page

1. Click **Preview** to open the page in a new tab
2. Test responsiveness:
   - Desktop view
   - Tablet view
   - Mobile view
3. Verify all sections display correctly

### Step 5.3: Publish

1. Click **Publish** (or **Sync**) to make changes live
2. Wait for publishing to complete
3. Visit your live site URL to verify

---

## Part 6: Mobile Responsiveness Tips

The Design Studio components are responsive by default, but consider these adjustments:

### Hero Section
- On mobile, reduce heading font size
- Stack buttons vertically
- Reduce padding

### Services Cards
- Cards should stack in single column on mobile
- Ensure touch targets (buttons) are at least 44px

### Multi-Column Layouts
- 3-column layouts collapse to single column on mobile
- Verify content reads well in linear flow

### Navigation
- Header automatically converts to hamburger menu on mobile
- Test mobile navigation flow

---

## Part 7: Adding Liquid for Dynamic Content (Optional Enhancement)

After building the base layout with Design Studio, you can enhance sections with Liquid for dynamic content.

### Dynamic Welcome Message

To personalize the hero for logged-in users, edit the hero Text component and add Liquid:

```liquid
{% if user %}
  Welcome back, {{ user.firstname | default: 'there' }}!
{% else %}
  Welcome to PawsFirst Veterinary Portal
{% endif %}
```

### Dynamic Services from Dataverse

If you want to pull services dynamically instead of using static cards, create a custom component using the **Code Editor**:

```liquid
{% fetchxml services %}
<fetch top="6">
  <entity name="pa911_service">
    <attribute name="pa911_name" />
    <attribute name="pa911_description" />
    <attribute name="pa911_price" />
    <filter>
      <condition attribute="statecode" operator="eq" value="0" />
    </filter>
    <order attribute="pa911_name" />
  </entity>
</fetch>
{% endfetchxml %}

<div class="row">
  {% for service in services.results.entities %}
    <div class="col-md-4 mb-4">
      <div class="card h-100">
        <div class="card-body">
          <h5>{{ service.pa911_name }}</h5>
          <p>{{ service.pa911_description | truncate: 100 }}</p>
        </div>
      </div>
    </div>
  {% endfor %}
</div>
```

---

## Testing Checklist

After building the home page, verify:

- [ ] Theme colors appear consistently across all sections
- [ ] Logo displays correctly in header
- [ ] All buttons link to correct pages
- [ ] Services section shows content (static or dynamic)
- [ ] Page displays correctly on desktop, tablet, and mobile
- [ ] Page loads for anonymous users (not signed in)
- [ ] Page loads for authenticated users
- [ ] Meta title and description are set for SEO

---

## Next Steps

After completing the home page:

1. Work through [User Stories](user-stories.md) to add Liquid-powered dynamic features
2. Create additional pages (My Pets, Book Appointment, Services)
3. Reference [Data Model Design](data-model.md) for table structure details

---

## References

- [Power Pages Design Studio Overview](https://learn.microsoft.com/en-us/power-pages/getting-started/use-design-studio)
- [Styling and Themes](https://learn.microsoft.com/en-us/power-pages/getting-started/style-site)
- [Add Sections and Components](https://learn.microsoft.com/en-us/power-pages/getting-started/add-text)
- [Power Pages Liquid Objects](https://learn.microsoft.com/en-us/power-pages/configure/liquid/liquid-objects)

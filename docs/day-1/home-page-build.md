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

**Service Card 3 - Emergency Care:**
- **Title**: "Emergency Care"
- **Description**: "Support available around the clock to ensure your peace of mind at all times."
- **Footer**: "24/7"

### Step 3.4: Build Why Choose Us Section

This section uses a **1:3 Left Variant** layout for visual interest, with a flex container to organize benefit cards in the larger column.

---

#### Option A: 1:3 Left Variant with Benefit Cards (Recommended)

**Add Section:**
1. Click **+ Add a section**
2. Choose **1:3 Left Variant** layout
3. Set section background: Light gray (`#F5F5F5`) or a subtle gradient
4. Set padding: Top 80px, Bottom 80px

**Left Column (1/4 width) - Section Intro:**
1. Add a **Text** component with:
   - **Eyebrow Text (small, uppercase)**: "WHY PAWSFIRST"
   - **Heading (H2)**: "Care That Goes Beyond the Checkup"
   - **Body**: "We treat every pet like family—because to you, they are."
2. Style the text:
   - Eyebrow: Font size 12px, Letter spacing 2px, Primary color
   - Heading: Font size 36px, Bold, Dark text
   - Body: Font size 18px, Secondary gray text
3. Set vertical alignment: Center
4. Add a **Button** component:
   - **Text**: "Meet Our Team"
   - **Link**: `/about`
   - **Style**: Secondary/Outline

**Right Column (3/4 width) - Benefit Cards:**
1. Add a **Flex Container**
2. Configure the flex container:
   - **Direction**: Row
   - **Wrap**: Wrap
   - **Gap**: 20px
   - **Justify Content**: Space Between

3. Add **4 Card components** inside the flex container:

| Card | Icon | Title | Description |
|------|------|-------|-------------|
| **Card 1** | Stethoscope/Heart | "Compassionate Experts" | "Our veterinarians combine 50+ years of experience with genuine care for every patient who walks through our doors." |
| **Card 2** | Clock/Calendar | "Your Schedule, Your Way" | "Book, reschedule, or cancel appointments online anytime. No phone tag, no waiting on hold." |
| **Card 3** | Shield/Badge | "Trusted by 5,000+ Families" | "From routine checkups to complex surgeries, local pet parents trust us with their companions' health." |
| **Card 4** | Hospital/Building | "Modern, Stress-Free Clinic" | "Separate waiting areas for cats and dogs, calming music, and fear-free certified staff." |

**Card Styling:**
- Background: White (`#FFFFFF`)
- Border Radius: 12px
- Padding: 24px
- Box Shadow: Subtle (0 2px 8px rgba(0,0,0,0.08))
- Width: 48% (allows 2 cards per row with gap)
- Icon/Image: 48px, Primary color

---

#### Option B: 1:3 Right Variant with Feature Image

**Add Section:**
1. Click **+ Add a section**
2. Choose **1:3 Right Variant** layout
3. Set section background: White
4. Set padding: Top 80px, Bottom 80px

**Left Column (3/4 width) - Benefits List:**
1. Add a **Text** component:
   - **Eyebrow**: "THE PAWSFIRST DIFFERENCE"
   - **Heading (H2)**: "Why Pet Parents Choose Us"
2. Add a **Flex Container** with:
   - **Direction**: Column
   - **Gap**: 24px

3. Inside the flex container, add **Text components** for each benefit:

**Benefit 1:**
- **Heading (H4)**: "Same-Day Sick Visits"
- **Body**: "When your pet isn't feeling well, waiting days for an appointment isn't an option. We reserve slots every day for urgent care needs."

**Benefit 2:**
- **Heading (H4)**: "Transparent Pricing"
- **Body**: "No surprise bills. See service costs upfront when you book, and receive detailed estimates before any procedure."

**Benefit 3:**
- **Heading (H4)**: "Digital Health Records"
- **Body**: "Access vaccination history, lab results, and visit notes anytime through your secure online portal."

**Benefit 4:**
- **Heading (H4)**: "Extended Evening Hours"
- **Body**: "Open until 8 PM on weekdays so you don't have to choose between work and your pet's health."

**Right Column (1/4 width) - Visual:**
1. Add an **Image** component
2. Upload a warm, authentic photo of:
   - A veterinarian with a happy pet
   - Or a pet in a comfortable clinic setting
3. Set image border radius: 16px
4. Consider adding a decorative element or accent color block behind the image

---

#### Option C: 3-Column Enhanced with Stats Banner

**Add Stats Banner Section First:**
1. Click **+ Add a section**
2. Choose **1 column layout**
3. Set background: Primary color (`#2E7D32`)
4. Set padding: Top 40px, Bottom 40px

5. Add a **Flex Container**:
   - **Direction**: Row
   - **Justify Content**: Space Around
   - **Align Items**: Center

6. Add **3 Text components** for stats (white text):

| Stat | Label |
|------|-------|
| "15+" | "Years Serving Our Community" |
| "5,000+" | "Happy Pet Families" |
| "24/7" | "Emergency Support" |

**Add Main Why Choose Us Section Below:**
1. Click **+ Add a section**
2. Choose **3 column layout**
3. Set background: White
4. Set padding: Top 60px, Bottom 60px

**Section Header (spans full width above columns):**
1. Add **Text** component:
   - **Heading (H2)**: "Built Around Your Pet's Comfort"
   - **Subtext**: "Every detail of our practice is designed with your companion's wellbeing in mind."
2. Center align, bottom margin: 48px

**Column 1:**
- **Icon**: Paw print or heart
- **Heading (H4)**: "Fear-Free Certified"
- **Body**: "Our entire team is trained in low-stress handling techniques. We go slow, use treats, and never force—because trust matters."

**Column 2:**
- **Icon**: Medical cross or clipboard
- **Heading (H4)**: "Comprehensive Care"
- **Body**: "From wellness exams and dental cleanings to surgery and rehabilitation—everything your pet needs under one roof."

**Column 3:**
- **Icon**: Chat bubble or phone
- **Heading (H4)**: "Always Here For You"
- **Body**: "Questions between visits? Our care team responds to portal messages within 24 hours, and our emergency line is always open."

### Step 3.5: Build Quick Actions Section

This section helps users quickly navigate to key portal features. Choose from these design approaches based on your site's needs.

---

#### Option A: Action Cards Grid (Recommended)

**Add Section:**
1. Click **+ Add a section**
2. Choose **1 column layout**
3. Set section background: Primary color (`#2E7D32`) or a gradient from Primary to darker shade
4. Set padding: Top 80px, Bottom 80px

**Add Section Header:**
1. Add **Text** component:
   - **Eyebrow (small, uppercase)**: "YOUR PET PORTAL"
   - **Heading (H2)**: "Everything You Need, One Click Away"
   - **Subtext**: "Manage appointments, track health records, and connect with our team—all from your dashboard."
2. Style text in white for contrast against dark background
3. Center align, bottom margin: 48px

**Add Action Cards Container:**
1. Add a **Flex Container**
2. Configure:
   - **Direction**: Row
   - **Wrap**: Wrap
   - **Gap**: 24px
   - **Justify Content**: Center

3. Add **4 Card components** styled as action tiles:

| Card | Icon | Title | Description | Link |
|------|------|-------|-------------|------|
| **Card 1** | Paw Print | "My Pets" | "View profiles, health history, and upcoming care reminders for all your companions." | `/my-pets` |
| **Card 2** | Calendar | "Book Appointment" | "Schedule wellness visits, vaccinations, or sick appointments in just a few taps." | `/book-appointment` |
| **Card 3** | Clipboard/List | "My Appointments" | "Check upcoming visits, reschedule, or review past appointment notes." | `/appointments` |
| **Card 4** | Chat/Envelope | "Contact Us" | "Have a question? Send us a message or find our clinic hours and location." | `/contact` |

**Card Styling:**
- Background: White (`#FFFFFF`)
- Border Radius: 16px
- Padding: 32px 24px
- Width: 280px (or 23% for 4 cards with gap)
- Text Alignment: Center
- Icon: 56px, Primary color, centered above title
- Title: H4, Bold, Dark text
- Description: 14px, Gray text (`#666666`)
- Hover Effect: Subtle lift/shadow (if supported)

**Make Cards Clickable:**
- Wrap each card in a link to its destination
- Or add a subtle "Learn more →" link at the bottom of each card

---

#### Option B: 2-Column Split Layout

**Add Section:**
1. Click **+ Add a section**
2. Choose **2 column layout**
3. Set background: Light gray (`#F8F9FA`)
4. Set padding: Top 80px, Bottom 80px

**Left Column - For Pet Owners:**
1. Add **Text** component:
   - **Heading (H3)**: "For Pet Parents"
   - **Body**: "Access your pet's complete care history and manage appointments."
2. Add a **Flex Container**:
   - **Direction**: Column
   - **Gap**: 12px

3. Add styled **Button** components:

| Button | Icon | Text | Link | Style |
|--------|------|------|------|-------|
| **Button 1** | Paw | "View My Pets" | `/my-pets` | Primary, Full Width |
| **Button 2** | Calendar+ | "Book an Appointment" | `/book-appointment` | Primary, Full Width |
| **Button 3** | List | "Upcoming Appointments" | `/appointments` | Secondary/Outline, Full Width |

**Right Column - Need Help?:**
1. Add **Text** component:
   - **Heading (H3)**: "Need Assistance?"
   - **Body**: "Our team is here to help with any questions about your pet's care."
2. Add a **Flex Container**:
   - **Direction**: Column
   - **Gap**: 12px

3. Add styled **Button** components:

| Button | Icon | Text | Link | Style |
|--------|------|------|------|-------|
| **Button 1** | Phone | "Call Us: (555) 123-4567" | `tel:5551234567` | Secondary, Full Width |
| **Button 2** | Envelope | "Send a Message" | `/contact` | Secondary, Full Width |
| **Button 3** | Question | "FAQs" | `/faq` | Text/Link style, Full Width |

---

#### Option C: 1:3 Right Variant with CTA Focus

**Add Section:**
1. Click **+ Add a section**
2. Choose **1:3 Right Variant** layout
3. Set background: White with a subtle decorative element (pattern or accent shape)
4. Set padding: Top 80px, Bottom 80px

**Left Column (3/4 width) - Action Grid:**
1. Add a **Flex Container**:
   - **Direction**: Row
   - **Wrap**: Wrap
   - **Gap**: 16px

2. Add **4 Action Tiles** using Card components:

**Tile Style:**
- Background: Light tint of primary color (`#E8F5E9`)
- Border: 2px solid Primary on hover
- Border Radius: 12px
- Padding: 24px
- Width: 48% (2 tiles per row)

| Tile | Icon | Title | Subtitle |
|------|------|-------|----------|
| **Tile 1** | Paw | "My Pets" | "Profiles & health records" |
| **Tile 2** | Calendar | "Book Visit" | "Schedule in seconds" |
| **Tile 3** | Clock | "Appointments" | "View & manage" |
| **Tile 4** | Message | "Get Help" | "We're here for you" |

**Right Column (1/4 width) - Highlight CTA:**
1. Add a **Card** component styled as a promotional block:
   - Background: Primary color (`#2E7D32`)
   - Border Radius: 16px
   - Padding: 32px
   - Text: White

2. Card Content:
   - **Icon**: Calendar with checkmark (white)
   - **Heading (H3)**: "New Patient?"
   - **Body**: "Register your pet and book your first wellness visit today."
   - **Button**: 
     - Text: "Get Started"
     - Link: `/register`
     - Style: White background, Primary text

---

#### Option D: Minimal Quick Links Bar

For a simpler approach that takes less vertical space:

**Add Section:**
1. Click **+ Add a section**
2. Choose **1 column layout**
3. Set background: White with top border (4px solid Primary)
4. Set padding: Top 40px, Bottom 40px

**Add Quick Links:**
1. Add a **Flex Container**:
   - **Direction**: Row
   - **Justify Content**: Space Evenly
   - **Align Items**: Center
   - **Gap**: 32px

2. Add **4 Link Groups** (each is a small flex container with icon + text):

| Icon | Link Text | URL |
|------|-----------|-----|
| Paw | "My Pets" | `/my-pets` |
| Calendar | "Book Now" | `/book-appointment` |
| List | "Appointments" | `/appointments` |
| Phone | "Contact" | `/contact` |

**Link Styling:**
- Icon: 24px, Primary color
- Text: 16px, Semi-bold, Primary color
- Hover: Underline or color shift
- Flex direction: Row with 8px gap (icon left of text)

**Optional Enhancement:**
Add a centered heading above: **"Quick Links"** (H4, uppercase, letter-spacing)

### Step 3.6: Build Contact Information Section

This section provides essential contact details and builds trust by showing accessibility. Choose a layout that fits your page flow.

---

#### Option A: 3-Column with Icon Headers (Recommended)

**Add Section:**
1. Click **+ Add a section**
2. Choose **3 column layout**
3. Set background: Light primary tint (`#E8F5E9`) or subtle gradient
4. Set padding: Top 80px, Bottom 80px

**Section Header (full width above columns):**
1. Add **Text** component:
   - **Heading (H2)**: "We're Here When You Need Us"
   - **Subtext**: "Questions? Concerns? Just want to say hi? We'd love to hear from you."
2. Center align, bottom margin: 48px

**Column 1 - Location:**
1. Add **Icon** or **Image** (Map pin icon, 48px, Primary color)
2. Add **Text** component:
   - **Heading (H4)**: "Find Us"
   - **Body**:
     ```
     PawsFirst Veterinary Clinic
     123 Pet Care Avenue
     Greenville, State 12345
     ```
3. Add **Button** component:
   - **Text**: "Get Directions"
   - **Link**: Google Maps URL or `/directions`
   - **Style**: Secondary/Outline, Small

**Column 2 - Contact:**
1. Add **Icon** (Phone icon, 48px, Primary color)
2. Add **Text** component:
   - **Heading (H4)**: "Get in Touch"
   - **Body** (use flex or line breaks with icons if possible):
     ```
     Phone: (555) 123-4567
     Text: (555) 123-4568
     Email: hello@pawsfirst.com
     ```
3. Add **Button** component:
   - **Text**: "Send a Message"
   - **Link**: `/contact`
   - **Style**: Secondary/Outline, Small

**Column 3 - Hours:**
1. Add **Icon** (Clock icon, 48px, Primary color)
2. Add **Text** component:
   - **Heading (H4)**: "Clinic Hours"
   - **Body**:
     ```
     Mon – Fri: 8:00 AM – 7:00 PM
     Saturday: 9:00 AM – 4:00 PM
     Sunday: Closed
     ```
3. Add **Text** component (styled as alert/note):
   - **Body**: "🚨 **Emergency?** Call our 24/7 line: (555) 911-PETS"
   - Style: Bold, slightly smaller text, or add a colored background

---

#### Option B: 1:3 Left Variant with Map Placeholder

**Add Section:**
1. Click **+ Add a section**
2. Choose **1:3 Left Variant** layout
3. Set background: White
4. Set padding: Top 80px, Bottom 80px

**Left Column (1/4 width) - Quick Contact Card:**
1. Add a **Card** component:
   - Background: Primary color (`#2E7D32`)
   - Border Radius: 16px
   - Padding: 32px
   - Text: White

2. Card Content:
   - **Heading (H3)**: "Contact Us"
   - **Body**: "We typically respond within 2 hours during business hours."
   - Add contact details with icons:
     ```
     📞 (555) 123-4567
     ✉️ hello@pawsfirst.com
     ```
   - **Button**:
     - Text: "Book a Visit"
     - Link: `/book-appointment`
     - Style: White background, Primary text

**Right Column (3/4 width) - Location & Hours:**
1. Add a **Flex Container**:
   - **Direction**: Row
   - **Gap**: 32px
   - **Wrap**: Wrap

2. **Left Content Block (60%):**
   - Add **Text** component:
     - **Heading (H3)**: "Visit Our Clinic"
     - **Body**:
       ```
       PawsFirst Veterinary Clinic
       123 Pet Care Avenue
       Greenville, State 12345
       
       Conveniently located in downtown Greenville with 
       free parking available behind the building.
       ```
   - Add **Image** component:
     - Upload a map screenshot or embed placeholder
     - Alt text: "Map showing PawsFirst clinic location"
     - Border Radius: 12px
     - Or add text: "📍 **Get Directions** →" as a link

3. **Right Content Block (40%):**
   - Add **Text** component:
     - **Heading (H4)**: "Hours"
   - Add styled hours using a **Flex Container** (Column direction):
   
   | Day | Hours |
   |-----|-------|
   | Monday – Friday | 8:00 AM – 7:00 PM |
   | Saturday | 9:00 AM – 4:00 PM |
   | Sunday | Closed |
   
   - Add **Emergency Callout** below:
     - Background: Red tint (`#FFEBEE`) or amber
     - Border-left: 4px solid red
     - Padding: 16px
     - **Text**: "**24/7 Emergency Line**<br>(555) 911-PETS"

---

#### Option C: 2-Column Enhanced with Visual Hierarchy

**Add Section:**
1. Click **+ Add a section**
2. Choose **2 column layout**
3. Set background: Light gray (`#F5F5F5`)
4. Set padding: Top 80px, Bottom 80px

**Column 1 - Contact & Location:**
1. Add **Text** component:
   - **Eyebrow**: "VISIT US"
   - **Heading (H2)**: "Your Neighborhood Vet"
   - **Body**: "We're proud to serve the Greenville community and surrounding areas."

2. Add a **Flex Container** with **Direction**: Column, **Gap**: 24px

3. Add **3 Contact Items** (each a small flex row with icon + text):

**Item 1 - Address:**
- Icon: Map Pin (24px)
- **Text**: 
  ```
  123 Pet Care Avenue
  Greenville, State 12345
  ```
- Add small link: "Get Directions →"

**Item 2 - Phone:**
- Icon: Phone (24px)
- **Text**: "(555) 123-4567"
- Add small text: "Call or text us anytime"

**Item 3 - Email:**
- Icon: Envelope (24px)
- **Text**: "hello@pawsfirst.com"
- Add small text: "We respond within 24 hours"

**Column 2 - Hours & Emergency:**
1. Add a **Card** component for hours:
   - Background: White
   - Border Radius: 12px
   - Padding: 24px
   - Box Shadow: Subtle

2. Card Content:
   - **Heading (H4)**: "Clinic Hours"
   - Add hours table/list:
   
   | Day | Hours | Status |
   |-----|-------|--------|
   | Mon – Thu | 8:00 AM – 7:00 PM | |
   | Friday | 8:00 AM – 6:00 PM | |
   | Saturday | 9:00 AM – 4:00 PM | |
   | Sunday | Closed | |
   
   - Add visual indicator for "Open Now" if desired

3. Add **Emergency Card** below:
   - Background: Primary color (`#2E7D32`)
   - Border Radius: 12px
   - Padding: 20px
   - Text: White
   - **Icon**: Phone with pulse/alert
   - **Heading (H4)**: "After-Hours Emergency"
   - **Body**: "For urgent pet emergencies outside clinic hours:"
   - **Phone**: "(555) 911-PETS"
   - Style phone number large and bold

---

#### Option D: Full-Width Banner Style

For a more compact footer-like contact section:

**Add Section:**
1. Click **+ Add a section**
2. Choose **1 column layout**
3. Set background: Dark shade of Primary (`#1B5E20`)
4. Set padding: Top 60px, Bottom 60px

**Add Content Container:**
1. Add a **Flex Container**:
   - **Direction**: Row
   - **Justify Content**: Space Between
   - **Align Items**: Center
   - **Wrap**: Wrap
   - **Gap**: 40px

2. Add **4 Content Blocks** (all white text):

**Block 1 - Branding:**
- Add **Image** (Logo - white version if available)
- **Text**: "Caring for pets since 2010"

**Block 2 - Location:**
- **Heading (H5)**: "Location"
- **Body**:
  ```
  123 Pet Care Avenue
  Greenville, State 12345
  ```

**Block 3 - Contact:**
- **Heading (H5)**: "Contact"
- **Body**:
  ```
  (555) 123-4567
  hello@pawsfirst.com
  ```

**Block 4 - Hours:**
- **Heading (H5)**: "Hours"
- **Body**:
  ```
  Mon–Fri: 8AM–7PM
  Sat: 9AM–4PM
  ```

**Emergency Banner (Optional):**
1. Below the flex container, add a **Text** component:
   - Center aligned
   - **Text**: "🚨 **Pet Emergency?** Call our 24/7 line: **(555) 911-PETS**"
   - Style: Slightly larger, yellow or white text with emphasis

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

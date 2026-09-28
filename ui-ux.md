# UI/UX Specification: WristReply AI

**Senior Mobile Product & Design System Guide**

---

### Design System Foundations

The design architecture employs an **OLED Dark Utility** aesthetic. Because this app interfaces with ambient watch faces, glanceable notification trays, and rapid foreground switching, the interface avoids bright saturated panels in favor of deep structural blacks, high-contrast typography, and purposeful luminescent accents.

```
Surface Depth & Layering:

┌────────────────────────────────────────────────────────┐
│ Background: #0B0E14 (Obsidian Canvas)                 │
│  ┌──────────────────────────────────────────────────┐  │
│  │ Surface Card: #131823 (Elevated 1dp)             │  │
│  │  ┌────────────────────────────────────────────┐  │  │
│  │  │ Interactive Pill: #1C2333 (Stroke: #2A364F)│  │  │
│  │  │ Active Accent: #38EF7D (Signal Mint Neon)  │  │  │
│  │  └────────────────────────────────────────────┘  │  │
│  └──────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────┘

```

#### Color Palette

| Token Name | Hex Code | Visual Target | Intended Role |
| --- | --- | --- | --- |
| `surface-canvas` | `#0B0E14` | Pitch Obsidian | Low-power OLED canvas, root scaffold background |
| `surface-raised` | `#131823` | Deep Slate | Card containers, list tiles, bottom sheets |
| `surface-interactive` | `#1C2333` | Gunmetal Tint | Default clickable pill containers, input fields |
| `border-subtle` | `#222B3D` | Faint Indigo Grey | 1px clean separators and structural borders |
| `border-accent` | `#2D3A54` | Crisp Muted Slate | Highlighting hover, active states, focus outlines |
| `accent-primary` | `#00F2FE` | Electric Cyan | Key status indicators, active toggles, icons |
| `accent-mint` | `#38EF7D` | Signal Mint | Successful message dispatch, live engine pulse |
| `accent-warning` | `#FFB020` | Cyber Amber | Missing permissions, disconnected Bluetooth nodes |
| `text-primary` | `#F1F5F9` | Frosted White | Primary titles, active reply pill text |
| `text-secondary` | `#94A3B8` | Cool Silver Grey | Context descriptions, timestamps, subheaders |
| `text-tertiary` | `#475569` | Muted Charcoal | Inactive states, metadata indicators |

#### Typography Architecture

* **Display Font Family:** `Space Grotesk` (Numeric readouts, primary headers, pill titles for tech precision).
* **Body Font Family:** `Inter` (Micro-copy, body text, switch labels, system dialogs).

```
Type Hierarchy Scale:
- Hero Metrics:     32px | Bold (700)      | Tracking: -0.02em | Space Grotesk
- Section Title:    18px | SemiBold (600)  | Tracking: -0.01em | Space Grotesk
- Body Regular:     14px | Regular (400)   | Tracking: 0.00em  | Inter
- Micro Badge:      11px | Medium (500)    | Tracking: +0.04em | Inter (Caps)
- Pill Interactive: 13px | SemiBold (600)  | Tracking: +0.01em | Inter

```

---

### Core Screen Architectural Flows

```
[Screen 1: Zero-Friction Handshake]
             │
             ▼
[Screen 2: Real-time Cockpit / Console] ────► [Modal: Quick Sandbox Test]
             │
             ▼
[Screen 3: Persona & Pill Tailoring]
             │
             ▼
[Screen 4: Ambient Wear OS Micro-HUD]

```

---

### Screen 1: Zero-Friction Permissions Handshake

Apps requesting `NotificationListenerService` or Battery Exemption often scare users off. The onboarding handles this with transparent, visual explanations before showing the system prompt.

#### Layout Blueprint

```
┌────────────────────────────────────────────────────────┐
│  [Logo / Lockup]                     [Step 1 of 2]    │
│                                                        │
│  WristReply AI                                         │
│  Zero-Cloud Setup                                      │
│                                                        │
│  ┌──────────────────────────────────────────────────┐  │
│  │  Shield Vector Asset with Glowing Mint Padlock   │  │
│  │                                                  │  │
│  │  "100% On-Device Isolation"                      │  │
│  │  Your incoming chats never touch external        │  │
│  │  servers. All intelligence runs locally via      │  │
│  │  Google ML Kit.                                  │  │
│  └──────────────────────────────────────────────────┘  │
│                                                        │
│  CORE ACCESS REQUIRED                                  │
│                                                        │
│  ┌──────────────────────────────────────────────────┐  │
│  │ (●) Notification Bridge                           │  │
│  │     Required to read incoming context and inject  │  │
│  │     quick-reply actions.                          │  │
│  │                                 [ GRANT ACCESS ]  │  │
│  └──────────────────────────────────────────────────┘  │
│                                                        │
│  ┌──────────────────────────────────────────────────┐  │
│  │ (○) Background Keep-Alive                         │  │
│  │     Prevents OEM battery killers from stopping    │  │
│  │     instant wrist syncing.      [ WHITELIST ME ]  │  │
│  └──────────────────────────────────────────────────┘  │
│                                                        │
│  [  LAUNCH CONSOLE (Active when Step 1 Granted)  ]     │
└────────────────────────────────────────────────────────┘

```

#### Micro-Interactions & Transitions

* As soon as the user returns from system settings with permission granted, the empty radio circle `(○)` morphs into a vibrant Signal Mint checkmark badge `(✓)` with a celebratory haptic pulse (`HapticFeedbackType.mediumImpact`).
* The **Launch Console** button glides up using a spring curve (`cubic-bezier(0.34, 1.56, 0.64, 1)`).

---

### Screen 2: Real-Time Cockpit / Console (Home)

The dashboard surfaces the health of the background daemon, active paired endpoints, and a live testing sandbox.

#### Visual Hierarchy & Components

```
┌────────────────────────────────────────────────────────┐
│ ⚡ WRISTREPLY CONSOLE                       [ ● LIVE ] │
│                                                        │
│ ┌────────────────────────────────────────────────────┐ │
│ │ HARDWARE & ENGINE STATUS                           │ │
│ │                                                    │ │
│ │  Engine Daemon: Active (18ms inference)            │ │
│ │  Wearable Node: Connected (Amazfit / Zepp BLE)     │ │
│ │  Protected RAM: 18.4 MB (OLED Minimal Mode)        │ │
│ └────────────────────────────────────────────────────┘ │
│                                                        │
│ PERFORMANCE SNAPSHOT                                   │
│ ┌──────────────────────────┐ ┌───────────────────────┐ │
│ │  482                     │ │  142 ms               │ │
│ │  Replies Dispatched      │ │  Avg Round-Trip BLE   │ │
│ └──────────────────────────┘ └───────────────────────┘ │
│                                                        │
│ LIVE TEST SANDBOX                                      │
│ "Simulate incoming WhatsApp message below"             │
│ ┌────────────────────────────────────────────────────┐ │
│ │ "Hey, are you free for a quick call right now?"    │ │
│ └────────────────────────────────────────────────────┘ │
│                                                        │
│ GENERATED ACTION PILLS (TAP TO SIMULATE DISPATCH):     │
│ ┌──────────────────┐ ┌─────────────────┐ ┌───────────┐ │
│ │ Free now, call!  │ │ Busy, text me   │ │ 10 min pls│ │
│ └──────────────────┘ └─────────────────┘ └───────────┘ │
│                                                        │
│ MONITORED PLATFORMS                                    │
│ [X] WhatsApp     [X] Telegram     [ ] Google Messages  │
└────────────────────────────────────────────────────────┘

```

#### Key UX Patterns

* **Live Sandbox:** Users can type or select pre-filled test prompts directly on the home screen. Tapping a generated pill triggers a simulated local broadcast, confirming that the notification dispatch pipeline is working without needing a second phone.
* **Engine Status Header:** Uses a pulsing mint dot (1.5-second opacity sine wave) to give immediate visual feedback that the background service is running.

---

### Screen 3: Persona & Pill Tailoring (Settings)

Controls how suggestions sound and adjusts fallback logic when messages aren't in standard English.

```
┌────────────────────────────────────────────────────────┐
│ <  REPLY PERSONALITY & RULES                           │
│                                                        │
│ CONVERSATION TONE                                      │
│ ┌───────────────┐ ┌────────────────┐ ┌───────────────┐ │
│ │ Casual (⚡)   │ │ Professional   │ │ Benglish Mix  │ │
│ │ "Astechi 5m"  │ │ "Understood"   │ │ "Koi tumi?"   │ │
│ └───────────────┘ └────────────────┘ └───────────────┘ │
│                                                        │
│ PERSISTENT FALLBACK PILLS                              │
│ When on-device AI cannot detect context, show these:   │
│                                                        │
│ 1. [ On my way right now!                ] [ ✕ ]       │
│ 2. [ In a meeting, will ping you shortly ] [ ✕ ]       │
│ 3. [ Call you in 10 minutes              ] [ ✕ ]       │
│                                                        │
│ [ + ADD CUSTOM FALLBACK TEMPLATE ]                     │
│                                                        │
│ DYNAMIC SMART INJECTIONS                               │
│ [✓] Auto-append Location Pin when queried "Where?"     │
│ [✓] Suppress duplicate chimes on notification clone    │
│ [ ] Enable floating assistive bubble over keyboard     │
└────────────────────────────────────────────────────────┘

```

---

### Screen 4: Wear OS & Smartwatch Glanceable HUD

Smartwatch layouts demand extreme economy of space: low cognitive load, large hit targets, and pure black canvases to eliminate screen edge borders.

```
                  Wear OS 40mm / 44mm Dial Layout
                           ┌───────────┐
                        .-'             '-.
                      .'    [WhatsApp]     '.
                     /   Mohammad Farhan     \
                    │    "Where are you?"     │
                    │   ─────────────────     │
                    │  ┌───────────────────┐  │
                     \ │ 1. wait 5 min  │ /
                      '.└───────────────────┘.'
                        '-.┌───────────────┐-'
                           │ 2. In Traffic jam │
                           └───────────────┘

```

#### Smartwatch UX Rules

1. **Vertical Pill Stack:** Pills use 100% component width with a minimum touch target height of **44dp**.
2. **High-Contrast Typography:** Pill labels are rendered in frosted white (`#F1F5F9`) against raised slate cards (`#1C2333`), with 8dp rounded corners for quick finger landing.
3. **Immediate Haptic Dispatch:** When a pill is tapped, the watch issues an immediate confirmation vibration (`VibrationEffect.createPredefined(EFFECT_CLICK)`), displays a brief checkmark animation, and dismisses the notification in **under 100ms**.

---

### Motion & Micro-Interaction Specifications

Smooth transitions keep the interface responsive without feeling sluggish.

```
Transition Orchestration:

Pill Press Down State:
Scale: 1.00 ────────► 0.96 (Duration: 90ms | Curve: easeOutQuad)
Haptic: Light Impact

Pill Release / Dispatch Trigger:
Scale: 0.96 ────────► 1.02 ────────► 1.00 (Duration: 180ms | Curve: elasticOut)
Border Tint: #222B3D ──────► #00F2FE ──────► #38EF7D (Signal Mint confirmation)
Toast/Snackbar: 0 UI clutter — Status indicated by a 2px top progress bar flash.

```

* **Zero Full-Page Loading Screens:** Because all inference and preference lookups happen locally in memory, screen transitions should never display spinning loading indicators. Use instant layout renders with subtle shimmer loading cards if reading from slower disks.
* **Overscroll Behavior:** Native Android physics stretch curves overscroll subtly, reinforcing the interface's tactile, mechanical feel.

---

### Accessibility & Contrast Compliance

* **WCAG 2.1 AAA Contrast:** Contrast between `#0B0E14` (Background) and `#F1F5F9` (Primary Body) measures **16.2:1**, far exceeding the 7:1 accessibility standard.
* **Large Touch Targets:** Every interactive chip and pill has a minimum bounding box of **48dp × 48dp** on mobile devices and **44dp × 44dp** on Wear OS, preventing accidental touches while walking or driving.
* **Screen Reader Semantic Roles:** Every action chip exposes an accessibility action descriptor:
* `AccessibilityNodeInfo.ACTION_CLICK` with the custom label: *"Tap to immediately send this quick reply via WhatsApp."*
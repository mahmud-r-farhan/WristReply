# Security Policy — WristReply AI

## Zero-Cloud Guarantee

WristReply AI is **architecturally incapable** of exfiltrating notification data because the production
manifest does **not** declare the `android.permission.INTERNET` permission. Every line of NLP inference
runs through on-device libraries (Google ML Kit Smart Reply is a 100% on-device model).

- **No telemetry, no analytics, no crash uploaders** are linked into the engine.
- All preferences are written to Android `SharedPreferences` and never leave the device sandbox.
- `android:allowBackup="false"` plus a `data_extraction_rules.xml` that excludes every preference file
  from cloud backup and device transfer.
- The Flutter UI is only instantiated when the user opens the app — it has no background access to
  notifications.
- The static `playground/` page runs the engine in the browser; it sends no request that contains
  message content.

If you discover a violation of this guarantee (for example a manifest diff that adds `INTERNET`), please
file a private security advisory and we will treat it as a P0 bug.

## Supported Versions

| Version | Supported |
| --- | --- |
| `0.2.x` | ✅ Active |
| `0.1.x` | ⚠️ Security fixes only |
| `< 0.1.0` | ❌ Not supported |

## Reporting a Vulnerability

**Please do not file a public GitHub issue for security bugs.**

- Email: **security@wristreply.app** (PGP key available on request)
- GitHub: open a draft advisory at
  <https://github.com/mahmud-r-farhan/WristReply/security/advisories/new>

We aim to acknowledge within 48 hours and patch critical bugs within 7 days.

## Out-of-Scope / Acceptable Risks

- Apps installed via sideloading that bypass the missing `INTERNET` permission (the user already has root
  at that point — out of our threat model).
- Attacks originating from a malicious OEM-modified system image.
- Any third-party smart-reply model that a downstream packager adds on top of the standalone AAR.

## Hall of Fame

We thank the following security researchers for responsible disclosures:

- *Your name here — be the first.*

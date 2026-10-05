# Why On-Device?

WristReply AI runs 100% on your Android phone.

- 🔒 No cloud calls. No analytics. No crash uploaders.
- 🧠 Google ML Kit Smart Reply is a 100% on-device model — it ships with the OS.
- 🪫 15–25 MB resident RAM, 0% idle CPU: the Flutter runtime is never booted in the background.
- 🛡️ The production manifest declares **no** `INTERNET` permission, so exfiltration is impossible by
  construction.
- 🚫 `android:allowBackup="false"`, and the data extraction rules exclude every preference file from
  cloud backup and device transfer.
- ⏱️ Inference is ephemeral: the ML Kit client is created per call, closed in a `finally` block, and
  bounded by a 2.5 s timeout.

See [engineering.md](../../engineering.md) for the full architecture and
[SECURITY.md](../../SECURITY.md) for the disclosure policy.

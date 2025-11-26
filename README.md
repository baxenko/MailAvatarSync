# 🧙‍♂️ MailAvatarSync: Auto Contact Images for macOS Mail

> Say goodbye to generic gray initials. Automatically fetch sender avatars and company logos for Apple Mail.

![Platform](https://img.shields.io/badge/platform-macOS-black?style=flat-square&logo=apple)
![Language](https://img.shields.io/badge/language-AppleScript-orange?style=flat-square)
![License](https://img.shields.io/badge/license-MIT-blue?style=flat-square)

**MailAvatarSync** is a native AppleScript rule for the macOS Mail app. It analyzes incoming emails, finds the sender's photo or company logo online, and automatically updates your Contacts app.

✨ **Killer Feature:** It intelligently detects automated emails from services (banks, newsletters, SaaS) and creates a **Business Contact** with the company logo and the "Company" flag checked.

---

## 🖼 Before & After

| ❌ Default Mail.app | ✅ With MailAvatarSync |
<img width="1650" height="153" alt="screenshot_2025-11-26 at 16 06 22@2x" src="https://github.com/user-attachments/assets/1923a272-a21e-4d3e-9b77-cc632363e149" />


---

## 🚀 Features

*   🔍 **Smart Fetching:** Scours Gravatar, Clearbit, and FaviconKit to find the best image.
*   🏢 **Business Mode:** Automatically creates a new "Company" contact if an organization emails you (e.g., GitHub, Slack, Your Bank) but isn't in your address book.
*   🔒 **Privacy Focused:** Runs locally on your Mac. No third-party apps required.
*   🎨 **Auto-Normalization:** Converts various image formats (WebP, ICO) into Contacts-friendly PNGs automatically.
*   🛡 **Safe:** Never overwrites existing contact photos.

---

## 📦 Installation

### Step 1. Download
Download the `MailAvatarSync` file from this repository.

### Step 2. Move to Mail Scripts Folder
Open Finder, press `Cmd + Shift + G`, and paste this path:

```bash
~/Library/Application Scripts/com.apple.mail<img width="2758" height="3404" alt="screenshot_2025-11-26 at 16 00 29@2x" src="https://github.com/user-attachments/assets/6ee6ff0a-e72a-4d67-b3d7-45d61d1744c2" />

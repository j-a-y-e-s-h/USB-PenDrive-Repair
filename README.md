# 🔧 USB PenDrive Low-Level Repair Toolkit

A complete diagnostic and repair toolkit for corrupted USB flash drives using **Alcor Micro** controllers. Includes factory-level Mass Production (MP) tools, automated recovery scripts, and detailed documentation of the entire troubleshooting process.

> **Final Verdict:** This particular drive (Samsung K9GDGD8U0D 16GB MLC) was diagnosed with irreparable hardware failure after 6 exhaustive repair attempts. The documentation serves as a reference guide for anyone attempting similar repairs.

---

## 📋 Table of Contents

- [Hardware Profile](#hardware-profile)
- [Error Code Reference](#error-code-reference)
- [Settings Matrix](#settings-matrix)
- [Tools Included](#tools-included)
- [Scripts](#scripts)
- [How to Use](#how-to-use)
- [Folder Structure](#folder-structure)
- [License](#license)

---

## 🖥️ Hardware Profile

| Property | Value |
|----------|-------|
| **Controller** | Alcor Micro AU6989SN-GTC [F500] - F/W FA01 |
| **NAND Flash** | Samsung K9GDGD8U0D (MLC-16K) - 1CE/Single Channel |
| **Capacity** | 16 GB (1348 blocks) |
| **VID:PID (broken)** | `058F:1234` (bootloader recovery mode) |
| **VID:PID (restored)** | `058F:9380` (operational mode) |
| **Flash ID** | `EC3A94C3A4CA` |

---

## ❌ Error Code Reference

| Code | Name | Meaning | Root Cause |
|------|------|---------|------------|
| `92100` | Load config error | Firmware write failed after LLF | ECC too low or power insufficient |
| `E0020000` | Timeout/Disconnect | USB controller dropped off bus | Power draw exceeded port limit |
| `E0010000` | Device remove | Physical USB disconnect | Same as above, thermal degradation |
| `50400` | Too many bad blocks | All blocks flagged bad | Fast Scan read corrupted BBT |
| `91F00` | Create file system error | Filesystem write failed | FAT16 invalid for >4GB partition |

---

## 📊 Settings Matrix (All Attempts)

| # | Power | Scan Mode | Scan Level | ECC | FS | Duration | Result |
|---|-------|-----------|------------|-----|----|----------|--------|
| 1 | 200mA | Low Level | Full Scan2 | 8 | FAT16 | ~30min | `92100` config error |
| 2 | 200mA | Low Level | Full Scan1 | Auto | FAT16 | 13min | `E0020000` disconnect |
| 3 | 500mA | Low Level | Fast Scan1 | Auto | FAT16 | <1min | `50400` all blocks bad |
| 4 | 500mA | Low Level | Full Scan1 | Auto | FAT16 | 33min | `91F00` FS error *(LLF succeeded!)* |
| 5 | 900mA | High Level | New | 0 | FAT32 | 7sec | `92100` 579 bad blocks |
| **6** | **900mA** | **Low Level** | **Full Scan1** | **Auto** | **FAT32** | **11min** | **`E0020000` disconnect** |

> **Key Finding:** Connection stability decreased over time (33min → 13min → 11min), indicating progressive hardware degradation regardless of power settings.

## 🛠️ Tools Included

Both diagnostic and repair tools are available directly in this repository as password-protected `.rar` archives (extract with password: `usbdev.ru`).

### ChipGenius v4.21.0701
USB controller and flash memory identification tool. Reads VID/PID, controller model, NAND flash type, and firmware version directly from the hardware.

*   🔗 **Download from this repository:** [ChipGenius_v4_21_0701.rar](./ChipGenius_v4_21_0701.rar) (or via [GitHub Direct Link](https://github.com/j-a-y-e-s-h/USB-PenDrive-Repair/raw/main/ChipGenius_v4_21_0701.rar))
*   🔗 **Official Mirror:** [ChipGenius v4.21.0701 — chipgenius.en.lo4d.com](https://chipgenius.en.lo4d.com/windows)

### AlcorMP v20.09.16.00
Alcor Micro Mass Production tool for factory-level firmware flashing, bad block mapping, and partition formatting of USB drives using Alcor controllers.

*   🔗 **Download from this repository:** [ALCOR_U2_MP_v20.09.16.00.rar](./ALCOR_U2_MP_v20.09.16.00.rar) (or via [GitHub Direct Link](https://github.com/j-a-y-e-s-h/USB-PenDrive-Repair/raw/main/ALCOR_U2_MP_v20.09.16.00.rar))
*   🔗 **Official Mirror:** [AlcorMP v20.09.16.00 — usbdev.ru](https://www.usbdev.ru/files/alcor/alcormp/)

> **Note:** All tool archives are password-protected. Extract with password: `usbdev.ru`

---

## 📜 Scripts

### `Restore_USB_Drive.ps1`
PowerShell script (self-elevating to Admin) that:
- Auto-detects USB drives by hardware type
- Kills Windows Explorer to release file locks
- Zeros out the MBR (first 1MB) via raw disk I/O
- Re-initializes the disk with a clean MBR partition table
- Creates and formats a new FAT32 volume
- Restarts Explorer

### `Restore_USB_Drive.bat`
Launcher for the PowerShell script with proper execution policy bypass.

### `Format_USB_Drive.bat`
Quick format script using `format /X` (force dismount) for drives that are accessible but need reformatting.

---

## 🚀 How to Use

### For Alcor Micro Controller Drives:
1. Run `ChipGenius` to identify your controller model and NAND flash type
2. Open `AlcorMP.exe` as Administrator
3. Configure Settings (`Setup` → adjust based on your hardware):
   - **Flash Type Tab:** `Scan Level` = `Full Scan1`, check `Auto ECC`
   - **Bad Block Tab:** `File System` = `FAT32`
   - **Other Tab:** `AdjustPower` = `500MA` (or `900MA` for USB 3.0 ports)
4. Click `Start(A)` and wait for the process to complete
5. If successful (green), eject and re-plug the drive

### For MBR/Partition Recovery:
1. Run `Restore_USB_Drive.bat` as Administrator
2. The script auto-detects, wipes, and repartitions the drive

---

## 📁 Folder Structure

```
USB-PenDrive-Repair/
├── README.md                       # This file
├── LICENSE                         # MIT License
├── .gitignore                      # Excludes raw executables/binaries
├── ALCOR_U2_MP_v20.09.16.00.rar   # Tool archive (tracked in Git)
├── ChipGenius_v4_21_0701.rar      # Tool archive (tracked in Git)
│
├── docs/
│   ├── USB_Repair_Summary.md       # Detailed technical documentation
│   └── walkthrough.md              # Chronological history of all attempts
│
├── scripts/
│   ├── Restore_USB_Drive.ps1       # PowerShell MBR recovery script
│   ├── Restore_USB_Drive.bat       # Launcher for PS1 script
│   └── Format_USB_Drive.bat        # Quick format script
│
└── screenshots/                    # Visual evidence of all repair attempts
    └── *.png
```

> **Note:** Extracted tool folders (containing `.exe` and `.dll` binaries) are excluded from git via `.gitignore`. You can extract the tracked `.rar` files in the repository root directory to use the tools.

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

The diagnostic tools (ChipGenius, AlcorMP) are third-party software and are **not** covered by this license.

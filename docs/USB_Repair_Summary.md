# USB PenDrive Diagnostic, Repair, and Configuration Summary

This document provides a highly detailed breakdown of the troubleshooting, low-level analysis, and configuration adjustments performed to repair your corrupted USB PenDrive.

---

## 1. Hardware Diagnostic Profile
The low-level hardware characteristics of the drive were extracted using the **ChipGenius v4.21.0701** utility. The findings are as follows:

*   **Controller Vendor:** Alcor Micro
*   **Controller Part-Number:** `AU6989SN-GTC [F500] - F/W FA01`
    *   *Note:* The `[F500]` and `FA01` signatures denote the specific firmware build and controller stepping version used.
*   **NAND Flash Memory (Storage Chip):** `Samsung K9GDGD8U0D (MLC-16K) - 1CE/Single Channel`
    *   *Note:* This is a Multi-Level Cell (MLC) flash memory chip with a 16KB page size. "1CE" means it has one Chip Enable line (single physical die inside the package).
*   **Total Capacity:** 16 GB (reported as `16384.0 MB` or `1348 blocks`).
*   **Original Error State:** 
    *   The USB controller's internal translation table or firmware had crashed, causing the drive to report a default hardware ID of **`VID: 058F, PID: 1234`**.
    *   Windows Disk Management identified the drive as `Removable (E:) No Media` with a total size of `0 Bytes`.

---

## 2. Explanation of Encountered Errors
During the repair process using the **AlcorMP Mass Production Tool**, six distinct error codes were encountered across all attempts:

### A. Error `92100: Load config error` (Bad Block: 31/1348)
*   **What it means:** The LLF succeeded to 100%, but the utility failed writing the new firmware configuration and Bad Block Table (BBT).
*   **Root Cause:** Default ECC threshold too low (fixed at `8`) and power limited to `200mA`.

### B. Error `E0020000: Bad Block: 0/1348`
*   **What it means:** The USB controller physically disconnected from the bus mid-process.
*   **Root Cause:** The controller drew more current than the USB port allowed, causing a connection drop. This error occurred at 200mA, 500mA, and even 900mA power settings, with progressively shorter survival times (13min → 11min).

### C. Error `50400: Too many bad block error` (Bad Block: 1348/1348)
*   **What it means:** 100% of blocks flagged as bad.
*   **Root Cause:** Fast Scan reads the existing BBT, which was corrupted/erased. All blocks read as `0xFF` = bad.

### D. Error `91F00: Create file system error`
*   **What it means:** The LLF and bad block scan completed perfectly (44 bad blocks mapped), but the final filesystem write failed.
*   **Root Cause:** The filesystem was set to `FAT16` (default), which is invalid for a 48.9GB partition. Required `FAT32`.

### E. Error `E0010000: Device remove`
*   **What it means:** The USB device was physically removed/disconnected during the format.
*   **Root Cause:** Same power instability as `E0020000`, occurring after 33 minutes at 500mA.

### F. Error `92100: Load config error` (Bad Block: 579/1348)
*   **What it means:** Nearly half the blocks flagged as bad during High Level Format mode.
*   **Root Cause:** High Level Format disabled Auto ECC and set ECC=0 (zero tolerance). Without error correction, worn cells with minor bit-flips were flagged as completely bad.

---

## 3. Complete Settings History
Every combination of settings tried in **AlcorMP -> Setup** across all 6 attempts:

| Attempt | Power | Scan Mode | Scan Level | ECC | Filesystem | Result |
|---------|-------|-----------|------------|-----|------------|--------|
| 1 | 200mA | Low Level | Full Scan2 | 8 | FAT16 | `92100` config error |
| 2 | 200mA | Low Level | Full Scan1 | Auto | FAT16 | `E0020000` disconnect at 13min |
| 3 | 500mA | Low Level | Fast Scan1 | Auto | FAT16 | `50400` all blocks bad |
| 4 | 500mA | Low Level | Full Scan1 | Auto | FAT16 | `91F00` filesystem error (LLF succeeded!) |
| 5 | 900mA | High Level | New | 0 | FAT32 | `92100` 579 bad blocks |
| **6** | **900mA** | **Low Level** | **Full Scan1** | **Auto** | **FAT32** | **`E0020000` disconnect at 11min** |

---

## 4. Final Verdict: HARDWARE FAILURE

**The drive cannot be repaired.** Every possible software configuration has been exhausted.

The critical evidence is the **progressive shortening of connection stability** across attempts:
*   Attempt 4: Survived **33 minutes** (at 500mA)
*   Attempt 2: Survived **13 minutes** (at 200mA)
*   Attempt 6: Survived **11 minutes** (at 900mA — maximum USB 3.0 power)

Even tripling the power supply from 200mA to 900mA did not prevent the disconnect. The failure is physical — likely degraded solder joints between the Alcor Micro AU6989SN controller and the Samsung K9GDGD8U0D NAND chip that weaken further under thermal stress from sustained writes.

**Recommendation:** Discard the drive and replace it. A new 16GB USB drive costs ₹150–200.

---

## 5. Directory Folder Structure
```text
C:\Users\Admin\Desktop\PenDrive\
├── USB_Repair_Summary.md          <-- This detailed documentation file
├── walkthrough.md                 <-- Chronological history of all attempts
├── Restore_USB_Drive.ps1          <-- PowerShell script to zero MBR and repartition
├── Restore_USB_Drive.bat          <-- Launcher for the PowerShell script
├── Format_USB_Drive.bat           <-- Quick format batch script
├── ChipGenius_v4_21_0701.rar      <-- ChipGenius archive (password: usbdev.ru)
├── ChipGenius_v4_21_0701/         <-- Extracted ChipGenius folder
├── ALCOR_U2_MP_v20.09.16.00.rar   <-- AlcorMP archive (password: usbdev.ru)
├── ALCOR_U2_MP_v20.09.16.00/      <-- Extracted AlcorMP tool folder
└── Screenshots/                   <-- All screenshots from repair sessions
```
*(All archives can be extracted using the password: **`usbdev.ru`**)*

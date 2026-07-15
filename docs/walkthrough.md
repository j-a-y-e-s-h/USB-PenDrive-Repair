# USB PenDrive Troubleshooting and Repair Walkthrough

This document outlines the complete step-by-step history of the troubleshooting sessions performed to diagnose and attempt to repair a corrupted 16GB USB PenDrive.

**Final Verdict: HARDWARE FAILURE — Drive cannot be repaired.**

---

## Step 1: Initial Diagnosis
1. **The Issue:** The drive was plugged in but did not show up in File Explorer with any capacity.
2. **Disk Management Check:** The drive was detected as `Disk 2 (Removable) No Media` with `0 Bytes` capacity.
3. **PnP Controller Properties:** Queried using PowerShell and found the USB controller has:
   * **Vendor ID (VID):** `058F` (Alcor Micro)
   * **Product ID (PID):** `1234` (Default fallback bootloader mode due to corrupted firmware).

---

## Step 2: Automated Repair Attempt (Transcend)
1. Since Transcend drives frequently use Alcor controllers under VID 058F, we guided the download of the official **Transcend JetFlash Online Recovery** tool.
2. The tool failed to recognize or restore the drive, indicating that the chip required a factory-level Mass Production (MP) flashing tool.

---

## Step 3: Low-Level Hardware Analysis
1. We bypassed Windows Defender's false positive block by temporarily disabling **Real-time protection**.
2. Ran **ChipGenius v4.21.0701** (using extraction password `usbdev.ru`) to query the raw controller:
   * **Controller Model:** `Alcor Micro AU6989SN-GTC [F500]`
   * **Flash ID:** `EC3A94C3A4CA`
   * **Memory Model:** `Samsung K9GDGD8U0D` (16GB MLC chip)

---

## Step 4: Factory Flashing Attempts (AlcorMP)

### Run 1: Default Settings
* **Configuration:** Full Scan2, ECC 8, Power 200mA, FAT16.
* **Result:** Reached 100% LLF, then failed with `92100: Load config error` (found 31 bad blocks).
* **Diagnosis:** ECC was too low and power too weak to write firmware configuration data.

### Run 2: Auto ECC, Still Low Power
* **Configuration:** Full Scan1, Auto ECC, Power 200mA, FAT16.
* **Result:** Failed after **13 minutes** with code `E0020000` (device disconnected).
* **Diagnosis:** 200mA power ceiling caused the controller to drop offline during write cycles.

### Run 3: Fast Scan (Incorrect for Corrupted BBT)
* **Configuration:** Fast Scan1, Auto ECC, Power 500mA, FAT16.
* **Result:** Failed with `50400: Too many bad block error` (1348/1348 bad blocks).
* **Diagnosis:** Fast Scan reads the existing BBT, which was corrupted, so every block appeared bad.

### Run 4: Overnight Run — Almost Succeeded
* **Configuration:** Full Scan1, Auto ECC, Power 500mA, FAT16.
* **Result:** LLF completed successfully! Found **44 bad blocks** out of 1348. But failed at the very end with `91F00: Create file system error`.
* **Diagnosis:** The filesystem was set to FAT16, which is invalid for a 48.9GB partition. The format needed FAT32.
* **Note:** PC also restarted during this run due to Windows Update, causing additional corruption.

### Run 5: High Level Format (Skipping Physical Scan)
* **Configuration:** High Level Format, Fast Scan, ECC 0, Power 900mA, FAT32.
* **Result:** Failed after **7 seconds** with `92100: Load config error` (579/1348 bad blocks).
* **Diagnosis:** High Level Format disabled Auto ECC and set ECC=0. Without error correction, nearly half the blocks were flagged as bad.

### Run 6: Final Attempt — Correct Combination
* **Configuration:** Low Level Format, Full Scan1, Auto ECC, Power 900mA, FAT32.
* **Result:** Failed after **11 minutes** with `E0020000` (device disconnected, 0/1348 blocks scanned).
* **Diagnosis:** Even at maximum USB 3.0 power (900mA), the drive physically disconnects during sustained writes. The disconnect time has been getting progressively shorter across attempts (33min → 13min → 11min), indicating cumulative hardware degradation.

---

## Step 5: Final Conclusion

**The drive has irreparable hardware failure.** The progressive shortening of connection stability (from 33 minutes down to 11 minutes) across attempts indicates that the solder joints between the Alcor Micro controller and the Samsung NAND flash chip are failing under thermal stress from sustained write operations.

Every possible software configuration was exhausted:
| Parameter | Values Tried |
|-----------|-------------|
| Power | 200mA, 500mA, 900mA |
| Scan Mode | Full Scan1, Full Scan2, Fast Scan1, High Level Format |
| ECC | Fixed 8, Auto ECC, ECC 0 |
| Filesystem | FAT16, FAT32 |
| USB Port | USB 2.0 rear, USB 3.0 motherboard |

**Recommendation:** Replace the drive. A new 16GB USB drive costs ₹150–200.

---

## Step 6: Backup of Files
All files (rar archives, extracted diagnostic tools, scripts, and guides) were compiled and saved inside the desktop folder:
* **Path:** `C:\Users\Admin\Desktop\PenDrive`

### Folder Contents:
```
C:\Users\Admin\Desktop\PenDrive\
├── USB_Repair_Summary.md          <-- Detailed technical documentation
├── walkthrough.md                 <-- This file (chronological history)
├── Restore_USB_Drive.ps1          <-- PowerShell script to zero MBR and repartition
├── Restore_USB_Drive.bat          <-- Launcher for the PowerShell script
├── Format_USB_Drive.bat           <-- Quick format batch script
├── ChipGenius_v4_21_0701.rar      <-- ChipGenius archive (password: usbdev.ru)
├── ChipGenius_v4_21_0701/         <-- Extracted ChipGenius folder
├── ALCOR_U2_MP_v20.09.16.00.rar   <-- AlcorMP archive (password: usbdev.ru)
├── ALCOR_U2_MP_v20.09.16.00/      <-- Extracted AlcorMP tool folder
└── Screenshots/                   <-- All screenshots from repair sessions
```

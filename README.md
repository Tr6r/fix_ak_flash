# Firmware Flashing Instability over UART (PC to MCU)

## 1. Summary

This document describes an instability issue encountered during firmware
flashing over UART using `ak-flash`. The problem caused intermittent failures
when flashing firmware multiple times consecutively.

After improving the UART reset mechanism, synchronization, and recovery
strategy, the flashing process is now stable and supports continuous
firmware updates.

---

## 2. Observed Issues

- UART device (`/dev/ttyUSBx`) cannot connect after flashing
- Bootloader parser state corruption after interrupted flashing
- Handshake failure when the MCU remains in a previous bootloader state

---

## 3. Root Causes

- `ak-flash` closes the UART device before transmit buffers are fully drained,
  leaving the UART in an unstable state for the next flashing attempt
- USB-UART device requires time to be detected again by the operating system
  after MCU reset, causing the UART port to be temporarily unavailable
- MCU bootloader parser may remain in an incorrect state and does not accept
  new handshake requests

---

## 4. Implemented Fixes

- Add `tcdrain()`, `tcflush()`, and a short delay before closing the UART device
- Retry UART connection when the device cannot be opened
- On handshake failure:
  - Send a special MCU reset command using a magic sequence
  - Restart `ak-flash` using `execv()` to ensure a clean process state

The MCU detects the reset command using a **3-byte sliding window magic
sequence detector**, allowing the reset command to be recognized even when
the bootloader parser is out of sync.

---

## 5. Flash Sequence Overview

The following sequence provides a high-level view of the UART flashing and
recovery mechanism. Implementation details are intentionally omitted for
clarity.

<img width="625" height="622" alt="flow1" src="https://github.com/user-attachments/assets/e7536a0c-64ff-4f2a-b28f-0c285770bdb4" />
<img width="626" height="723" alt="flow2" src="https://github.com/user-attachments/assets/ac740fc6-9aba-4d3b-b79e-4ca591eff8aa" />

---

## 6. Result

- Stable and reliable continuous firmware flashing over UART
- Automatic retry when UART device is temporarily unavailable
- Robust recovery when the MCU remains in an incorrect bootloader state

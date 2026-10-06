import subprocess
import time
import os
import sys

DEVICE_ID = "ZD222NPNWD"
BRAIN_DIR = r"C:\Users\sazee\.gemini\antigravity-ide\brain\2b4d1886-be71-48f5-914e-634b2633d7ee"

def run_cmd(cmd, cwd=None):
    print(f"--> Executing: {cmd}")
    res = subprocess.run(cmd, shell=True, capture_output=True, text=True, cwd=cwd)
    if res.stdout:
        print(res.stdout.strip())
    if res.stderr:
        print(f"STDERR: {res.stderr.strip()}", file=sys.stderr)
    return res

def capture_screenshot(filename):
    local_path = os.path.join(BRAIN_DIR, filename)
    print(f"[CAPTURING SCREENSHOT]: {filename}")
    run_cmd(f"adb -s {DEVICE_ID} shell screencap -p /sdcard/temp_screen.png")
    run_cmd(f"adb -s {DEVICE_ID} pull /sdcard/temp_screen.png \"{local_path}\"")
    run_cmd(f"adb -s {DEVICE_ID} shell rm /sdcard/temp_screen.png")
    if os.path.exists(local_path):
        size = os.path.getsize(local_path)
        print(f"[SUCCESS] Saved {filename} ({size} bytes)")
    else:
        print(f"[FAILED] Failed to save {filename}")

def main():
    print("==================================================")
    print("FRESKA TACTILE SYSTEM - PHYSICAL DEVICE VERIFICATION")
    print(f"Device: {DEVICE_ID} (Motorola Edge 50 Neo, Android 16)")
    print("==================================================")

    # 1. Port Forwarding
    run_cmd(f"adb -s {DEVICE_ID} reverse tcp:8088 tcp:8088")

    # 2. Wake device & dismiss keyguard
    run_cmd(f"adb -s {DEVICE_ID} shell input keyevent 224") # Wakeup
    time.sleep(1)
    run_cmd(f"adb -s {DEVICE_ID} shell input keyevent 82") # Menu / unlock
    time.sleep(1)

    # 3. VERIFY CUSTOMER APP
    print("\n--- [1/3] VERIFYING FRESKA CUSTOMER ---")
    run_cmd(f"adb -s {DEVICE_ID} shell am force-stop com.freska.customer.freska_customer")
    run_cmd(f"adb -s {DEVICE_ID} shell monkey -p com.freska.customer.freska_customer -c android.intent.category.LAUNCHER 1")
    time.sleep(7) # Wait for initial data load via port 8088

    capture_screenshot("tactile_customer_home.png")

    # Tap on first store card (center: x=610, y=1450)
    run_cmd(f"adb -s {DEVICE_ID} shell input tap 610 1450")
    time.sleep(4)
    capture_screenshot("tactile_customer_store_menu.png")

    # Tap +ADD button on first item (Organic A2 Farm Milk)
    run_cmd(f"adb -s {DEVICE_ID} shell input tap 1050 780")
    time.sleep(2)
    capture_screenshot("tactile_customer_item_added.png")

    # Tap floating cart bar (x=610, y=2450)
    run_cmd(f"adb -s {DEVICE_ID} shell input tap 610 2450")
    time.sleep(3)
    capture_screenshot("tactile_customer_cart_view.png")

    # 4. VERIFY VENDOR APP
    print("\n--- [2/3] VERIFYING FRESKA VENDOR ---")
    run_cmd(f"adb -s {DEVICE_ID} shell am force-stop com.freska.vendor.freska_vendor")
    run_cmd(f"adb -s {DEVICE_ID} shell monkey -p com.freska.vendor.freska_vendor -c android.intent.category.LAUNCHER 1")
    time.sleep(5)

    capture_screenshot("tactile_vendor_initial.png")

    # Dismiss any active voice sheet if open
    run_cmd(f"adb -s {DEVICE_ID} shell input tap 610 300")
    time.sleep(1)

    # Orders tab (x=360, y=2500)
    run_cmd(f"adb -s {DEVICE_ID} shell input tap 360 2500")
    time.sleep(2)
    capture_screenshot("tactile_vendor_orders_queue.png")

    # Menu tab (x=610, y=2500)
    run_cmd(f"adb -s {DEVICE_ID} shell input tap 610 2500")
    time.sleep(2)
    capture_screenshot("tactile_vendor_menu_catalog.png")

    # Earnings tab (x=850, y=2500)
    run_cmd(f"adb -s {DEVICE_ID} shell input tap 850 2500")
    time.sleep(2)
    capture_screenshot("tactile_vendor_earnings_view.png")

    # 5. VERIFY RIDER APP
    print("\n--- [3/3] VERIFYING FRESKA RIDER ---")
    run_cmd(f"adb -s {DEVICE_ID} shell am force-stop com.example.freska_rider")
    run_cmd(f"adb -s {DEVICE_ID} shell monkey -p com.example.freska_rider -c android.intent.category.LAUNCHER 1")
    time.sleep(6)

    capture_screenshot("tactile_rider_dashboard.png")

    # Toggle Duty switch (x=1050, y=220)
    run_cmd(f"adb -s {DEVICE_ID} shell input tap 1050 220")
    time.sleep(2)
    capture_screenshot("tactile_rider_duty_toggled.png")

    print("\n==================================================")
    print("PHYSICAL DEVICE VERIFICATION RUN COMPLETE")
    print("==================================================")

if __name__ == "__main__":
    main()

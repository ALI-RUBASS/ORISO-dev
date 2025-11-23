#!/usr/bin/env python3
"""
Browser-based test for group chat functionality.
This script uses Selenium to actually click on a group chat and capture errors.
"""

import time
import json
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.options import Options
from selenium.common.exceptions import TimeoutException, NoSuchElementException

class BrowserGroupChatTester:
    def __init__(self):
        self.base_url = "https://app.oriso.site"
        self.username = "orisoconsultant1"
        self.password = "@Consultant12345"
        self.driver = None
        
    def setup_browser(self):
        """Setup Chrome browser with options"""
        print("🔧 Setting up browser...")
        
        chrome_options = Options()
        chrome_options.add_argument('--headless')
        chrome_options.add_argument('--no-sandbox')
        chrome_options.add_argument('--disable-dev-shm-usage')
        chrome_options.add_argument('--disable-gpu')
        chrome_options.add_argument('--window-size=1920,1080')
        chrome_options.add_argument('--ignore-certificate-errors')
        chrome_options.add_argument('--allow-insecure-localhost')
        chrome_options.add_argument('--disable-blink-features=AutomationControlled')
        
        # Enable browser logging
        chrome_options.set_capability('goog:loggingPrefs', {'browser': 'ALL'})
        
        self.driver = webdriver.Chrome(options=chrome_options)
        self.driver.implicitly_wait(10)
        
        print("✅ Browser ready!")
        
    def login(self):
        """Login to the application"""
        print(f"\n🔐 Logging in as {self.username}...")
        
        try:
            self.driver.get(f"{self.base_url}/login")
            print(f"📍 Loaded URL: {self.driver.current_url}")
            time.sleep(5)
            
            # Save screenshot of login page
            screenshot_path = f"/home/caritas/Desktop/online-beratung/screenshot_login_page_{int(time.time())}.png"
            self.driver.save_screenshot(screenshot_path)
            print(f"📸 Login page screenshot: {screenshot_path}")
            
            # Print page source to debug
            print(f"📄 Page title: {self.driver.title}")
            
            # Wait for username field
            wait = WebDriverWait(self.driver, 20)
            username_field = wait.until(EC.presence_of_element_located((By.ID, "username")))
            username_field.clear()
            username_field.send_keys(self.username)
            print(f"✅ Entered username: {self.username}")
            
            time.sleep(1)
            
            # Wait for password field
            password_field = wait.until(EC.presence_of_element_located((By.ID, "password")))
            password_field.clear()
            password_field.send_keys(self.password)
            print(f"✅ Entered password")
            
            time.sleep(1)
            
            login_button = wait.until(EC.element_to_be_clickable((By.XPATH, "//button[contains(text(), 'Log') or contains(text(), 'Sign') or contains(text(), 'Anmelden')]")))
            print(f"✅ Found login button")
            login_button.click()
            print(f"✅ Clicked login button")
            
            print("⏳ Waiting for redirect...")
            time.sleep(5)
            
            # Navigate to messages view
            messages_url = f"{self.base_url}/sessions/consultant/sessionView"
            print(f"📍 Navigating to messages view: {messages_url}")
            self.driver.get(messages_url)
            
            print("⏳ Waiting for page to load...")
            time.sleep(8)
            
            print(f"✅ Successfully logged in! Current URL: {self.driver.current_url}")
            
            # Take screenshot of the messages list
            screenshot_path = f"/home/caritas/Desktop/online-beratung/screenshot_messages_list_{int(time.time())}.png"
            self.driver.save_screenshot(screenshot_path)
            print(f"📸 Screenshot saved: {screenshot_path}")
            
            return True
            
        except Exception as e:
            print(f"❌ Login failed: {e}")
            screenshot_path = f"/home/caritas/Desktop/online-beratung/screenshot_login_failed_{int(time.time())}.png"
            self.driver.save_screenshot(screenshot_path)
            print(f"📸 Screenshot saved: {screenshot_path}")
            return False
    
    def get_console_logs(self):
        """Get browser console logs"""
        try:
            logs = self.driver.get_log('browser')
            return logs
        except Exception as e:
            print(f"⚠️ Could not get console logs: {e}")
            return []
    
    def print_console_logs(self, title="Console logs"):
        """Print formatted console logs"""
        logs = self.get_console_logs()
        
        if not logs:
            print(f"\n📋 {title}: (empty)")
            return
        
        print(f"\n📋 {title}:\n")
        
        errors = [log for log in logs if log['level'] == 'SEVERE']
        warnings = [log for log in logs if log['level'] == 'WARNING']
        infos = [log for log in logs if log['level'] == 'INFO']
        
        if errors:
            print(f"  🔴 ERRORS ({len(errors)}):")
            for i, log in enumerate(errors[:10], 1):
                print(f"    {i}. {log['source']} {log['message'][:200]}")
        
        if warnings:
            print(f"\n  ⚠️  WARNINGS ({len(warnings)}):")
            for i, log in enumerate(warnings[:5], 1):
                print(f"    {i}. {log['source']} {log['message'][:200]}")
        
        if infos:
            print(f"\n  ℹ️  INFO ({len(infos)} total, showing last 10):")
            for i, log in enumerate(infos[-10:], 1):
                print(f"    {i}. {log['source']} {log['message'][:200]}")
    
    def click_group_chat(self, group_name="Group 10"):
        """Find and click on a specific group chat"""
        print(f"\n🔍 Looking for group chat: {group_name}...")
        
        try:
            # Wait a bit more for the list to load
            time.sleep(5)
            
            # Take screenshot before clicking
            screenshot_path = f"/home/caritas/Desktop/online-beratung/screenshot_before_click_{int(time.time())}.png"
            self.driver.save_screenshot(screenshot_path)
            print(f"📸 Screenshot saved: {screenshot_path}")
            
            # Print console logs before clicking
            self.print_console_logs("Console logs BEFORE clicking")
            
            # Try to find the group by text content
            # Look for elements containing the group name
            possible_selectors = [
                f"//div[contains(text(), '{group_name}')]",
                f"//span[contains(text(), '{group_name}')]",
                f"//p[contains(text(), '{group_name}')]",
                f"//a[contains(text(), '{group_name}')]",
                f"//*[contains(text(), '{group_name}')]"
            ]
            
            group_element = None
            for selector in possible_selectors:
                try:
                    elements = self.driver.find_elements(By.XPATH, selector)
                    if elements:
                        print(f"✅ Found {len(elements)} elements with text '{group_name}' using: {selector}")
                        # Find the clickable parent (usually a div or a)
                        for elem in elements:
                            # Try to find a clickable parent
                            parent = elem
                            for _ in range(5):  # Go up max 5 levels
                                try:
                                    parent = parent.find_element(By.XPATH, "..")
                                    # Check if this parent has a click handler or is a link
                                    tag = parent.tag_name.lower()
                                    classes = parent.get_attribute("class") or ""
                                    if "session" in classes.lower() or "chat" in classes.lower() or "item" in classes.lower():
                                        group_element = parent
                                        print(f"✅ Found clickable parent: {tag} with classes: {classes}")
                                        break
                                except:
                                    break
                            if group_element:
                                break
                        if group_element:
                            break
                except Exception as e:
                    continue
            
            if not group_element:
                print(f"❌ Could not find group chat: {group_name}")
                print("\n📄 Available elements on page:")
                # Print all text content to help debug
                body = self.driver.find_element(By.TAG_NAME, "body")
                text_content = body.text
                print(text_content[:2000])  # Print first 2000 chars
                
                screenshot_path = f"/home/caritas/Desktop/online-beratung/screenshot_group_not_found_{int(time.time())}.png"
                self.driver.save_screenshot(screenshot_path)
                print(f"📸 Screenshot saved: {screenshot_path}")
                return False
            
            print(f"🖱️  Clicking on group chat: {group_name}")
            
            # Scroll element into view
            self.driver.execute_script("arguments[0].scrollIntoView(true);", group_element)
            time.sleep(1)
            
            # Click the element
            group_element.click()
            print(f"✅ Clicked on group chat!")
            
            # Wait for the chat to load
            print("⏳ Waiting for chat to load...")
            time.sleep(5)
            
            # Take screenshot after clicking
            screenshot_path = f"/home/caritas/Desktop/online-beratung/screenshot_after_click_{int(time.time())}.png"
            self.driver.save_screenshot(screenshot_path)
            print(f"📸 Screenshot saved: {screenshot_path}")
            
            # Print console logs after clicking
            self.print_console_logs("Console logs AFTER clicking")
            
            # Check current URL
            print(f"\n🌐 Current URL: {self.driver.current_url}")
            
            # Wait a bit more to see if errors appear
            print("⏳ Waiting to observe any errors...")
            time.sleep(10)
            
            # Take final screenshot
            screenshot_path = f"/home/caritas/Desktop/online-beratung/screenshot_final_{int(time.time())}.png"
            self.driver.save_screenshot(screenshot_path)
            print(f"📸 Final screenshot saved: {screenshot_path}")
            
            # Print final console logs
            self.print_console_logs("Console logs FINAL")
            
            # Check if page is white (error state)
            body = self.driver.find_element(By.TAG_NAME, "body")
            body_text = body.text
            if len(body_text.strip()) < 50:
                print("\n⚠️  WARNING: Page appears to be mostly empty (possible white screen)")
            
            return True
            
        except Exception as e:
            print(f"❌ Error clicking group chat: {e}")
            screenshot_path = f"/home/caritas/Desktop/online-beratung/screenshot_click_error_{int(time.time())}.png"
            self.driver.save_screenshot(screenshot_path)
            print(f"📸 Screenshot saved: {screenshot_path}")
            return False
    
    def cleanup(self):
        """Close browser"""
        if self.driver:
            print("\n🧹 Closing browser...")
            self.driver.quit()
            print("✅ Browser closed!")

def main():
    print("=" * 80)
    print("🚀 STARTING BROWSER-BASED GROUP CHAT TEST")
    print("=" * 80)
    
    tester = BrowserGroupChatTester()
    
    try:
        # Setup browser
        tester.setup_browser()
        
        # Login
        if not tester.login():
            print("\n❌ Login failed, stopping test")
            return
        
        # Click on Group 10
        if not tester.click_group_chat("Group 10"):
            print("\n❌ Could not click group chat")
            return
        
        print("\n" + "=" * 80)
        print("✅ TEST COMPLETED!")
        print("=" * 80)
        
    except Exception as e:
        print(f"\n❌ Test failed with error: {e}")
        import traceback
        traceback.print_exc()
        
    finally:
        tester.cleanup()

if __name__ == "__main__":
    main()

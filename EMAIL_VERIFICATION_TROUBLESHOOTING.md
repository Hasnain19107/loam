# Email Verification Not Sending - Troubleshooting Guide

## Problem
Verification emails are not being sent after user signup.

## Common Causes & Solutions

### 1. ✅ Firebase Email/Password Authentication Not Enabled

**Check:**
1. Go to Firebase Console: https://console.firebase.google.com/
2. Select your project
3. Navigate to **Authentication** → **Sign-in method**
4. Look for **Email/Password** provider

**Fix:**
- Click on **Email/Password**
- Toggle **Enable** to ON
- Click **Save**

---

### 2. ✅ Email Template Not Configured

**Check:**
1. Firebase Console → **Authentication** → **Templates** tab
2. Select **Email address verification**

**Fix:**
- Ensure template is properly configured
- Default template should work fine
- Customize if needed:
  ```
  Subject: Verify your email for %APP_NAME%
  
  Body:
  Hello,
  
  Follow this link to verify your email address.
  
  %LINK%
  
  If you didn't ask to verify this address, you can ignore this email.
  
  Thanks,
  Your %APP_NAME% team
  ```

---

### 3. ✅ Emails Going to Spam Folder

**Check:**
- Look in your spam/junk folder
- Check "Promotions" tab in Gmail
- Check "Updates" tab in Gmail

**Fix:**
- Mark Firebase emails as "Not Spam"
- Add `noreply@your-project.firebaseapp.com` to contacts
- For production: Configure custom SMTP (see below)

---

### 4. ✅ Rate Limiting (Too Many Requests)

**Check:**
- Console shows error: `[firebase_auth/too-many-requests]`

**Fix:**
- Wait 5-10 minutes before trying again
- Our cooldown mechanism prevents this (60 seconds between resends)
- During testing, use different email addresses

---

### 5. ✅ Network/Connectivity Issues

**Check:**
- Device has internet connection
- Firebase is reachable
- No firewall blocking Firebase

**Fix:**
- Check internet connection
- Try on different network
- Disable VPN if using one

---

### 6. ✅ Email Provider Blocking Firebase

**Check:**
- Some email providers block automated emails
- Corporate email servers may block Firebase

**Fix:**
- Try with Gmail, Outlook, or Yahoo
- Avoid using temporary email services
- Check with IT if using corporate email

---

### 7. ✅ Firebase Project Configuration

**Check:**
- `google-services.json` is up to date
- Project ID matches Firebase console

**Fix:**
1. Download fresh `google-services.json` from Firebase Console
2. Replace in `android/app/google-services.json`
3. Rebuild the app

---

### 8. ✅ Code Issues

**Check our implementation:**

```dart
// In FirebaseService.signUp()
Future<void> signUp(String email, String password) async {
  final userCredential = await _auth.createUserWithEmailAndPassword(
    email: email,
    password: password,
  );
  
  // Send email verification immediately after signup
  await userCredential.user?.sendEmailVerification();
}
```

**Potential Issues:**
- `userCredential.user` might be null
- Email sending might fail silently

**Enhanced Version with Error Handling:**

```dart
Future<void> signUp(String email, String password) async {
  try {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    if (userCredential.user != null) {
      print('User created: ${userCredential.user!.uid}');
      print('Sending verification email to: ${userCredential.user!.email}');
      
      await userCredential.user!.sendEmailVerification();
      
      print('Verification email sent successfully');
    } else {
      print('ERROR: User is null after signup');
    }
  } catch (e) {
    print('ERROR in signUp: $e');
    rethrow;
  }
}
```

---

## Testing Steps

### Step 1: Check Firebase Console
1. Go to Firebase Console → Authentication → Users
2. Sign up with a new email
3. Check if user appears in the list
4. Check if "Email verified" column shows false

### Step 2: Check Logs
Add debug logging to see what's happening:

```dart
// In AuthController.signUp()
try {
  _isLoading.value = true;
  print('DEBUG: Starting signup for ${email}');
  
  await _firebaseService.signUp(email, password);
  
  print('DEBUG: Signup completed, reloading user');
  await reloadUser();
  
  print('DEBUG: User reloaded, email verified: ${isEmailVerified}');
  
  _emailVerificationSent.value = true;
  
  Get.snackbar(
    'Verification Email Sent',
    'Please check your email and click the verification link',
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: Get.theme.colorScheme.primary,
    colorText: Colors.white,
    duration: const Duration(seconds: 4),
  );
} catch (e) {
  print('DEBUG: Error in signup: $e');
  // ... error handling
}
```

### Step 3: Test with Different Emails
Try these email providers:
- ✅ Gmail (best for testing)
- ✅ Outlook/Hotmail
- ✅ Yahoo
- ❌ Avoid temporary email services (they often block Firebase)

### Step 4: Check Email Delivery Time
- Firebase emails can take 1-5 minutes to arrive
- Check spam folder after 5 minutes
- Try resending after waiting

---

## Quick Fix: Add Better Error Handling

Update `firebase_service.dart`:

```dart
Future<void> signUp(String email, String password) async {
  try {
    print('🔵 Creating user account for: $email');
    
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    if (userCredential.user == null) {
      throw Exception('User creation failed: user is null');
    }
    
    print('✅ User created successfully: ${userCredential.user!.uid}');
    print('📧 Sending verification email...');
    
    await userCredential.user!.sendEmailVerification();
    
    print('✅ Verification email sent to: ${userCredential.user!.email}');
    
  } catch (e) {
    print('❌ Error in signUp: $e');
    rethrow;
  }
}
```

---

## Firebase Console Checklist

Go to Firebase Console and verify:

- [ ] **Authentication** is enabled for your project
- [ ] **Email/Password** sign-in method is enabled
- [ ] **Email templates** are configured (Templates tab)
- [ ] **Authorized domains** include your domain (Settings → Authorized domains)
- [ ] **Users** appear in the Users tab after signup
- [ ] **Quota** is not exceeded (check Usage tab)

---

## Production Setup (Optional)

For production apps, consider:

### Custom Email Domain
1. Firebase Console → Authentication → Templates
2. Click "Customize action URL"
3. Set your custom domain
4. Configure DNS records

### Custom SMTP (Firebase Extensions)
1. Install "Trigger Email" extension
2. Configure SendGrid, Mailgun, or AWS SES
3. Better deliverability and customization

### Email Allowlist (Testing)
1. Firebase Console → Authentication → Settings
2. Add test emails to allowlist
3. These bypass rate limits

---

## Still Not Working?

### Check Firebase Status
- Visit: https://status.firebase.google.com/
- Ensure Email/Password Auth is operational

### Check Firebase Logs
1. Firebase Console → Functions (if using)
2. Check for any errors

### Contact Firebase Support
- Firebase Console → Support
- Provide:
  - Project ID
  - User email (test account)
  - Timestamp of signup attempt
  - Error messages from console

---

## Expected Behavior

### Successful Flow:
1. User enters email and password
2. Clicks "Continue"
3. Account created in Firebase
4. Verification email sent immediately
5. Email arrives within 1-5 minutes
6. User clicks link in email
7. Email gets verified
8. User can proceed with "Check Verification"

### Email Content:
```
From: noreply@your-project.firebaseapp.com
Subject: Verify your email for LOAM

Hello,

Follow this link to verify your email address.

[Verify Email Button/Link]

If you didn't ask to verify this address, you can ignore this email.

Thanks,
Your LOAM team
```

---

## Debug Commands

Run these in your terminal to check configuration:

```bash
# Check if google-services.json exists
ls android/app/google-services.json

# View Firebase project ID
cat android/app/google-services.json | grep project_id

# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

---

## Common Mistakes

❌ **Email/Password auth not enabled in Firebase**
✅ Enable in Firebase Console → Authentication → Sign-in method

❌ **Using wrong Firebase project**
✅ Check project ID in google-services.json matches console

❌ **Checking wrong email account**
✅ Make sure you're checking the email you signed up with

❌ **Not waiting long enough**
✅ Wait 5 minutes and check spam folder

❌ **Rate limited from testing**
✅ Wait 10 minutes or use different email

❌ **Old google-services.json**
✅ Download fresh copy from Firebase Console

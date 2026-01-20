# Firebase Rate Limiting Fix - Email Verification

## Problem
Firebase was blocking resend email requests with the error:
```
[firebase_auth/too-many-requests] We have blocked all requests from this device due to unusual activity. Try again later.
```

## Root Cause
Firebase implements rate limiting to prevent abuse. When you send too many verification emails in a short period (especially during testing), Firebase temporarily blocks the device.

## Solution Implemented

### 1. **60-Second Cooldown Timer**
- Added `_resendCooldown` reactive variable to track cooldown seconds
- Added `_lastResendTime` to track when the last email was sent
- Prevents users from clicking "Resend" multiple times rapidly

### 2. **Visual Feedback**
- Button shows "Resend in X seconds" during cooldown
- Button is disabled during cooldown period
- Button text changes to "Resend verification email" when ready

### 3. **Enhanced Error Handling**
The `resendVerificationEmail()` method now handles:

#### **Too Many Requests Error**
```dart
if (errorMessage.contains('too-many-requests')) {
  // Shows user-friendly message explaining Firebase blocked the request
  // Advises to wait a few minutes
}
```

#### **Network Error**
```dart
if (errorMessage.contains('network')) {
  // Shows network connectivity message
}
```

#### **Generic Errors**
```dart
else {
  // Shows generic error with advice to try later
}
```

### 4. **Automatic Cooldown Management**
```dart
_resendCooldown.value = 60;
Future.doWhile(() async {
  await Future.delayed(const Duration(seconds: 1));
  if (_resendCooldown.value > 0) {
    _resendCooldown.value--;
    return true;
  }
  return false;
});
```

## Files Modified

### `auth_controller.dart`
- Added `_resendCooldown` and `_lastResendTime` state variables
- Added `resendCooldown` getter
- Enhanced `resendVerificationEmail()` with:
  - Cooldown check before sending
  - Automatic cooldown timer
  - Specific error handling for rate limiting

### `signup_page.dart`
- Updated resend button to use `Obx()` for reactive updates
- Shows cooldown timer in button text
- Disables button during cooldown

## How It Works

### First Resend
1. User clicks "Resend verification email"
2. Email is sent successfully
3. `_lastResendTime` is set to current time
4. Cooldown timer starts at 60 seconds
5. Button shows "Resend in 60 seconds" and is disabled

### During Cooldown
1. Button is disabled
2. Text shows remaining seconds
3. Countdown updates every second
4. User cannot click the button

### After Cooldown
1. Timer reaches 0
2. Button becomes enabled
3. Text changes back to "Resend verification email"
4. User can resend again

### If Rate Limited by Firebase
1. Shows specific error message
2. Advises user to wait a few minutes
3. Cooldown still applies to prevent further attempts

## Benefits

✅ **Prevents Rate Limiting**: 60-second cooldown prevents rapid requests
✅ **Better UX**: Visual feedback shows when user can resend
✅ **Clear Error Messages**: Users understand what's happening
✅ **Automatic Recovery**: Timer resets automatically
✅ **Prevents Frustration**: Users know exactly when they can try again

## Testing Notes

### Normal Flow
- First resend: Works immediately
- Second resend: Must wait 60 seconds
- After cooldown: Can resend again

### Rate Limited Flow
- If Firebase blocks: Shows specific error message
- Cooldown still applies
- User should wait several minutes before trying again

### Edge Cases Handled
- Network disconnection during resend
- Multiple rapid clicks (prevented by cooldown)
- App restart (cooldown resets, which is acceptable)

## Recommendations for Production

1. **Increase Cooldown**: Consider 90-120 seconds for production
2. **Persist Cooldown**: Save to local storage to survive app restarts
3. **Max Attempts**: Track total resend attempts per session
4. **Alternative Contact**: Provide support email if user can't receive emails

## Firebase Rate Limits (Reference)

Firebase typically allows:
- **Email Verification**: ~5-10 emails per hour per device
- **Password Reset**: Similar limits
- **SMS OTP**: More restrictive limits

When limits are exceeded, Firebase blocks for:
- **First offense**: 1-5 minutes
- **Repeated offenses**: Up to several hours
- **Severe abuse**: Can be permanent

## Code Example

```dart
// In AuthController
Future<void> resendVerificationEmail() async {
  // Check cooldown
  if (_lastResendTime != null) {
    final timeSinceLastResend = DateTime.now().difference(_lastResendTime!);
    if (timeSinceLastResend < Duration(seconds: 60)) {
      // Show "please wait" message
      return;
    }
  }

  try {
    await _firebaseService.sendEmailVerification();
    _lastResendTime = DateTime.now();
    _resendCooldown.value = 60;
    // Start countdown timer
  } catch (e) {
    // Handle specific errors
  }
}
```

```dart
// In SignupPage
Obx(() {
  final cooldown = authController.resendCooldown;
  return OutlinedButton(
    onPressed: cooldown > 0 ? null : () => authController.resendVerificationEmail(),
    child: Text(
      cooldown > 0 
        ? 'Resend in $cooldown seconds'
        : 'Resend verification email'
    ),
  );
})
```

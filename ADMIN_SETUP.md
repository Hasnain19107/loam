# Admin Setup Guide

This guide explains how to set up admin users for the Loam admin panel.

## Important: Firestore Collections

**Note**: Firestore collections are created automatically when you first write to them. If you don't see the `user_roles` collection, it will be created when you add the first document.

## Method 1: Using Firebase Console (Recommended for First Admin)

### Step 1: Create User Account
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Navigate to **Authentication** > **Users**
4. Click **Add user** to create a new user, or use an existing user
5. Note the **User UID** (it looks like: `abc123def456...`)
6. **Important**: Make sure the user has a profile in the `profiles` collection
   - If not, create one with the same ID as the user's UID

### Step 2: Create User Profile (if doesn't exist)
1. In Firebase Console, go to **Firestore Database**
2. Check if `profiles` collection exists
3. If the user doesn't have a profile, create one:
   - Collection: `profiles`
   - Document ID: Use the User UID from Step 1
   - Add fields:
     - `email` (string): User's email
     - `first_name` (string): User's name (optional)
     - `created_at` (timestamp): Current timestamp
     - `updated_at` (timestamp): Current timestamp

### Step 3: Add Admin Role in Firestore
1. In Firebase Console, go to **Firestore Database**
2. If `user_roles` collection doesn't exist, it will be created automatically
3. Click **Start collection** (if collection doesn't exist) or **Add document**
4. **Document ID**: Leave as auto-generated (or create your own)
5. Add the following fields:
   - `user_id` (string): The User UID from Step 1
   - `role` (string): `super_admin` or `event_host`
     - `super_admin`: Full admin access
     - `event_host`: Can manage events only
   - `created_at` (timestamp): Click the timestamp icon to set current time

### Example Document Structure:
```json
{
  "user_id": "abc123def456...",
  "role": "super_admin",
  "created_at": "January 1, 2024 at 12:00:00 AM UTC+0"
}
```

### Visual Guide:
1. **Firestore Database** → Click **Start collection** (if first time)
2. Collection ID: `user_roles`
3. Document ID: Auto-generate (or custom)
4. Add fields:
   - Field: `user_id`, Type: `string`, Value: `[your-user-uid]`
   - Field: `role`, Type: `string`, Value: `super_admin`
   - Field: `created_at`, Type: `timestamp`, Value: `[current time]`
5. Click **Save**

## Method 2: Initialize Collections First (Optional)

If you want to ensure collections exist before adding data:

```dart
// Run: flutter run lib/utils/initialize_firestore_collections.dart
```

This will create the `user_roles` collection structure.

## Method 3: Using Flutter Code (For Development)

### Option A: Using AdminSetupHelper (Recommended)

**Note**: This requires the user to already exist in Firebase Authentication and have a profile in Firestore.

Create a temporary setup script:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:loam/utils/admin_setup_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  final helper = AdminSetupHelper();
  
  // Set admin by email
  await helper.setSuperAdminByEmail('admin@example.com');
  
  // Or set by user ID
  // await helper.setSuperAdminByUserId('user-uid-here');
}
```

### Option B: Using FirebaseService

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:loam/data/network/remote/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  final firebaseService = FirebaseService();
  
  // Get user ID first (you need to know the user's email or UID)
  final userId = 'user-uid-here';
  
  // Assign super admin role
  await firebaseService.setSuperAdmin(userId);
  
  // Or assign event host role
  // await firebaseService.setEventHost(userId);
}
```

## Method 3: Using Firebase CLI

If you have Firebase CLI installed:

```bash
# Install Firebase CLI if not already installed
npm install -g firebase-tools

# Login to Firebase
firebase login

# Use Firestore emulator or direct access
# Add role document manually through CLI or use a script
```

## Roles Explained

### `super_admin`
- Full access to all admin features
- Can manage users, events, settings
- Can assign/remove admin roles
- Can manage quiz builder and responses

### `event_host`
- Can manage events (create, edit, delete)
- Can approve/reject event participants
- Cannot manage users or settings
- Cannot access quiz builder

### `user` (default)
- Regular user role
- Cannot access admin panel
- Can only use the regular app features

## Verification

After setting up admin role:

1. **Check in Firestore**: Verify the document exists in `user_roles` collection
2. **Test Login**: Try logging in with the admin account at `/admin/login`
3. **Check Access**: You should be redirected to `/admin` dashboard after login

## Troubleshooting

### User can't access admin panel
- Verify the `user_roles` document exists
- Check that `user_id` matches exactly (case-sensitive)
- Ensure `role` is exactly `super_admin` or `event_host` (not `super admin` or `Super Admin`)
- Check that user profile exists in `profiles` collection

### Multiple roles
- A user can have multiple roles
- If a user has `super_admin`, they automatically have admin access
- If a user only has `event_host`, they have limited admin access

## Security Notes

⚠️ **Important**: 
- Only assign `super_admin` role to trusted users
- Keep admin credentials secure
- Regularly audit admin users in Firestore
- Consider implementing admin invite system (see Admin Settings page)

## Next Steps

After setting up your first admin:
1. Log in to admin panel
2. Go to **Settings** > **Admin & Team**
3. Use the invite system to add more admins securely


# Admin Events Page - Signup Count Display Fix

## Problem
The admin events page was showing "0 signups" for all events with a TODO comment, instead of displaying the actual number of approved participants.

## Solution

### 1. Updated AdminEventsController
**File**: `lib/features/admin/events/controllers/admin_events_controller.dart`

**Changes**:
- Added `_eventSignupCounts` map to store signup counts for each event
- Added `getSignupCount(String eventId)` method to retrieve counts
- Updated `loadEvents()` to fetch approved participant counts for each event
- Updated `deleteEvent()` to clean up signup count when event is deleted

**Code**:
```dart
final RxMap<String, int> _eventSignupCounts = <String, int>{}.obs;

int getSignupCount(String eventId) => _eventSignupCounts[eventId] ?? 0;

// In loadEvents():
for (final event in eventsList) {
  try {
    final approvedCount = await _firebaseService.getEventApprovedCount(event.id);
    _eventSignupCounts[event.id] = approvedCount;
  } catch (e) {
    _eventSignupCounts[event.id] = 0;
  }
}
```

### 2. Updated AdminEventsPage View
**File**: `lib/features/admin/events/view/admin_events_page.dart`

**Changes**:
- Replaced hardcoded `'0 signups'` with dynamic count from controller
- Wrapped in `Obx()` to make it reactive
- Displays actual approved participant count

**Before**:
```dart
Text(
  '0 signups', // TODO: Get actual signup count
  style: TextStyle(...),
),
```

**After**:
```dart
Obx(
  () => Row(
    children: [
      Icon(Icons.people, ...),
      Text(
        '${controller.getSignupCount(event.id)} signups',
        style: TextStyle(...),
      ),
      if (!event.isUnlimitedCapacity && event.capacity != null)
        Text(' / ${event.capacity}', ...),
    ],
  ),
),
```

## How It Works

1. **On Page Load**:
   - Controller fetches all events
   - For each event, fetches approved participant count using `getEventApprovedCount()`
   - Stores counts in `_eventSignupCounts` map

2. **Display**:
   - Event card calls `controller.getSignupCount(event.id)`
   - Shows format: "X signups" or "X signups / Y" (if limited capacity)
   - Reactive via `Obx()` - updates when data changes

3. **On Refresh**:
   - Pull-to-refresh reloads events and signup counts
   - UI automatically updates with new counts

## Examples

**Unlimited Capacity Event**:
- Display: "5 signups"

**Limited Capacity Event (10 spots)**:
- Display: "7 signups / 10"

**Event with No Signups**:
- Display: "0 signups"

**Event at Full Capacity (5/5)**:
- Display: "5 signups / 5"

## Performance Notes

- Uses existing `getEventApprovedCount()` method (efficient count query)
- Loads counts in parallel for all events during page load
- Cached in controller, no repeated queries for same event
- Refreshes when user pulls to refresh

## Related Features

This fix complements the capacity management system:
- Shows accurate approved participant counts
- Helps admins monitor event capacity
- Updates in real-time when events are refreshed

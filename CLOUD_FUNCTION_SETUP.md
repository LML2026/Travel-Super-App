# Cloud Function Setup Guide

## ✅ What Was Done

The CORS error you saw was because **browsers block direct requests to external APIs**. I've fixed this by:

1. ✅ Created Cloud Function (`functions/index.js`) that calls Duffel API from the backend
2. ✅ Updated Flight Service to call the Cloud Function instead of Duffel directly
3. ✅ Removed API key from frontend (now uses Firebase Auth token)

## 🚀 Deployment Steps

### Step 1: Find Your Firebase Project ID

Run in terminal:
```powershell
firebase projects:list
```

Look for your project ID (e.g., `travel-super-app-abc123`)

### Step 2: Create `.firebaserc` file

In project root (`c:\Projects\TravelSuperApp\`), create `.firebaserc`:

```json
{
  "projects": {
    "default": "YOUR_PROJECT_ID_HERE"
  }
}
```

Replace `YOUR_PROJECT_ID_HERE` with the ID from Step 1.

### Step 3: Install Function Dependencies

```powershell
cd functions
npm install
cd ..
```

### Step 4: Set Duffel API Key as Secret

```powershell
firebase functions:secrets:set DUFFEL_API_KEY
```

When prompted, enter your Duffel API key (for example: `YOUR_DUFFEL_API_KEY`).

### Step 5: Deploy Cloud Function

```powershell
firebase deploy --only functions
```

Wait for deployment to complete. You'll see:
```
✔  Deploy complete!

Function URL: https://us-central1-YOUR_PROJECT_ID.cloudfunctions.net/searchFlights
```

### Step 6: Update App Code

In `lib/features/flights/services/flight_service.dart`, line 9:

Replace:
```dart
static const String cloudFunctionUrl =
    'https://us-central1-YOUR_PROJECT_ID.cloudfunctions.net/searchFlights';
```

With your actual URL from Step 5 deployment output.

### Step 7: Reload App

In terminal: `r` (hot reload)

## ✅ Testing

1. Make sure you're logged in (required for auth token)
2. Go to Flights tab
3. Fill form:
   - From: `LHR`
   - To: `CDG`
   - Date: Any future date
   - Cabin: `Economy`
4. Tap **Search Flights**

Check browser console (F12) for logs showing:
- 🔍 "Searching flights..."
- 📤 Request to Cloud Function
- 📥 Response received
- ✈️ Flights found

## 🎯 Architecture After Fix

```
Flutter Web App
    ↓ (Firebase Auth token)
Cloud Function (searchFlights)
    ↓ (Bearer token from backend)
Duffel API
    ↓
Return flights
```

**Benefits:**
- ✅ No CORS errors
- ✅ API key hidden from browser
- ✅ Secure auth-gated API
- ✅ Can log/monitor on backend
- ✅ Easy to add features (caching, rate limiting, etc.)

## Troubleshooting

### Function deployment fails
- Check: `firebase login` → `firebase projects:list`
- Ensure you have Firebase CLI installed: `npm install -g firebase-tools`

### Still getting CORS error
- Ensure deployment completed (check Cloud Console)
- Clear browser cache (Ctrl+Shift+Delete)
- Check Cloud Function URL is correct in flight_service.dart

### Getting "User not authenticated" error
- Make sure you're logged in to the app first
- Check Firebase Auth is enabled in your project

### Still no results after auth check
- Check Cloud Function logs: `firebase functions:log`
- Look for Duffel API response in logs

## Questions?

Run `firebase functions:log` to see real-time function logs and debug any issues!

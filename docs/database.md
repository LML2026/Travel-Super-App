# Database

## Platform
- Firebase Firestore

## Current Collections
- users/{uid}/trips/{tripId}
- users/{uid}/savedFlights/{flightId}
- users/{uid}/savedHotels/{hotelId}

## Trip Document Baseline
- destination
- departureDate
- returnDate
- budget
- currency
- travellers
- notes
- selectedFlightId (optional)
- selectedHotelId (optional)
- weatherSnapshot (optional)
- createdAt
- updatedAt

## Planned Additions
- users/{uid}/trips/{tripId}/itinerary/{itemId}
- users/{uid}/trips/{tripId}/documents/{docId}
- users/{uid}/wallet/{currencyCode}
- users/{uid}/expenses/{expenseId}

## Data Rules
- Keep user data scoped by uid.
- Use server timestamps for create/update.
- Keep schema evolution backward-compatible.

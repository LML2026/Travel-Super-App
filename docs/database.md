# Database

## Platform
- Firebase Firestore

## Current Collections
- users/{uid}/trips/{tripId}
- users/{uid}/savedFlights/{flightId}
- users/{uid}/savedHotels/{hotelId}
- users/{uid}/trips/{tripId}/transport/{rideId}
- users/{uid}/trips/{tripId}/expenses/{expenseId}
- users/{uid}/trips/{tripId}/documents/{documentId}
- users/{uid}/trips/{tripId}/activities/{activityId}

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

## Firestore Paths
- users/{uid}/trips/{tripId}
- users/{uid}/saved_flights/{saveId}
- users/{uid}/saved_hotels/{saveId}
- users/{uid}/trips/{tripId}/transport/{rideId}
- users/{uid}/trips/{tripId}/expenses/{expenseId}
- users/{uid}/trips/{tripId}/documents/{documentId}
- users/{uid}/trips/{tripId}/activities/{activityId}

## Planned Additions
- users/{uid}/trips/{tripId}/itinerary/{itemId}
- users/{uid}/wallet/{currencyCode}
- users/{uid}/expenses/{expenseId} (legacy global path, optional)

## Data Rules
- Keep user data scoped by uid.
- Use server timestamps for create/update.
- Keep schema evolution backward-compatible.

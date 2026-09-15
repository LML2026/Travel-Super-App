// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appName => 'ITAREVO Travel';

  @override
  String get home => 'Strona główna';

  @override
  String get trips => 'Podróże';

  @override
  String get discover => 'Odkrywaj';

  @override
  String get aiAssistant => 'Asystent AI';

  @override
  String get wallet => 'Portfel';

  @override
  String get maps => 'Mapy';

  @override
  String get nearbyEssentials => 'Usługi w pobliżu';

  @override
  String get translator => 'Tłumacz';

  @override
  String get profile => 'Profil';

  @override
  String get settings => 'Ustawienia';

  @override
  String get search => 'Szukaj';

  @override
  String get save => 'Zapisz';

  @override
  String get cancel => 'Anuluj';

  @override
  String get back => 'Wstecz';

  @override
  String get done => 'Gotowe';

  @override
  String get addToTrip => 'Dodaj do podróży';

  @override
  String get openMap => 'Otwórz mapę';

  @override
  String get mapAndRoute => 'Mapa i trasa';

  @override
  String get liveGooglePlaces => 'Google Places na żywo';

  @override
  String get toilets => 'Toalety';

  @override
  String get supermarkets => 'Supermarkety';

  @override
  String get restaurants => 'Restauracje';

  @override
  String get cafes => 'Kawiarnie';

  @override
  String get pharmacies => 'Apteki';

  @override
  String get hospitals => 'Szpitale';

  @override
  String get atms => 'Bankomaty';

  @override
  String get parking => 'Parking';

  @override
  String get fuel => 'Paliwo';

  @override
  String get trainStations => 'Stacje kolejowe';

  @override
  String get busStations => 'Dworce autobusowe';

  @override
  String get airports => 'Lotniska';

  @override
  String get evCharging => 'Ładowanie EV';

  @override
  String get taxi => 'Taksówka';

  @override
  String get publicTransport => 'Transport publiczny';

  @override
  String get dashboardUnavailable => 'Panel niedostępny';

  @override
  String get preparingYourDashboard => 'Przygotowywanie panelu...';

  @override
  String get dashboardLoadFailed =>
      'Nie udało się wczytać podsumowania podróży.';

  @override
  String get noUpcomingTrip => 'Brak nadchodzącej podróży';

  @override
  String get profileSubtitle =>
      'Ustawienia konta, wylogowanie i usunięcie konta.';

  @override
  String get myBookings => 'Moje rezerwacje';

  @override
  String get myBookingsSubtitle =>
      'Loty, pobyty i transport we wszystkich podróżach.';

  @override
  String get travelDiscovery => 'Odkrywanie podróży';

  @override
  String get travelDiscoverySubtitle =>
      'Wyszukuj loty, hotele, przejazdy, aktywności i restauracje i dodawaj je do podróży.';

  @override
  String get savedItems => 'Zapisane elementy';

  @override
  String get savedItemsSubtitle =>
      'Loty, hotele, przejazdy, restauracje i miejsca, które chcesz zapamiętać.';

  @override
  String get quickBooking => 'Szybka rezerwacja';

  @override
  String get flights => 'Loty';

  @override
  String get hotels => 'Hotele';

  @override
  String get trains => 'Pociągi';

  @override
  String get buses => 'Autobusy';

  @override
  String get carRental => 'Wynajem samochodu';

  @override
  String get aiAssistantSubtitle => 'Jak mogę dziś pomóc?';

  @override
  String get translatorSubtitle => 'Tekst, tryb rozmowy i zwroty podróżne.';

  @override
  String get liveTrip => 'Podróż na żywo';

  @override
  String get dashboard => 'Panel';

  @override
  String get noUpcomingTripSubtitle =>
      'Zapisz podróż, aby zobaczyć tutaj loty, hotele, pogodę i budżet.';

  @override
  String get signOut => 'Wyloguj się';

  @override
  String get account => 'Konto';

  @override
  String get traveler => 'Podróżnik';

  @override
  String get noEmailAvailable => 'Brak dostępnego adresu e-mail';

  @override
  String get profileHomeShortcutsHint =>
      'Hotele, Pogoda, Portfel i Tłumacz pozostają dostępne ze skrótów na stronie głównej.';

  @override
  String get deleteAccount => 'Usuń konto';

  @override
  String get deleteAccountFailed =>
      'Nie udało się usunąć konta. Spróbuj ponownie.';

  @override
  String get deleteAccountQuestion => 'Usunąć konto?';

  @override
  String get deleteAccountWarning =>
      'Spowoduje to trwałe usunięcie profilu ITAREVO i danych należących do tego konta. Tej operacji nie można cofnąć.';

  @override
  String get currentPassword => 'Aktualne hasło';

  @override
  String get reauthenticateWithProvider =>
      'Zostaniesz poproszony o uwierzytelnienie u dostawcy logowania.';

  @override
  String get deletePermanently => 'Usuń trwale';

  @override
  String get openSavedPlaces => 'Otwórz zapisane miejsca';

  @override
  String get exploreAroundTrip => 'Odkrywaj okolice podróży';

  @override
  String get searchNearby => 'Szukaj w pobliżu';

  @override
  String get whatAreYouLookingFor => 'Czego szukasz?';

  @override
  String get openNow => 'Otwarte teraz';

  @override
  String get topRated => 'Najwyżej oceniane';

  @override
  String ratingOutOfFive(String rating) {
    return 'Ocena $rating / 5';
  }

  @override
  String get noTripsYetSearchDestination =>
      'Brak podróży. Wyszukaj powyżej dowolny cel.';

  @override
  String searchForNearby(String service) {
    return 'Szukaj $service w pobliżu';
  }

  @override
  String get searchDestination => 'Szukaj celu podróży';

  @override
  String placesNear(String location) {
    return 'Miejsca w pobliżu $location';
  }

  @override
  String get details => 'Szczegóły';

  @override
  String uiText(String key) {
    String _temp0 = intl.Intl.selectLogic(
      key,
      {
        'k_acceptAndAdd': 'Accept and add',
        'k_acceptTermsPrivacy': 'I accept Terms and Privacy Policy',
        'k_acceptTermsToContinue': 'Please accept terms to continue.',
        'k_accessibilityAware': 'Accessibility-aware',
        'k_accuracy': 'Accuracy',
        'k_activityStatusHint': 'Planned, booked, optional',
        'k_add': 'Add',
        'k_addActivity': 'Add Activity',
        'k_addBookingsToTrip': 'Add bookings to trip',
        'k_addCurrency': 'Add currency',
        'k_addExpense': 'Add Expense',
        'k_addItineraryItem': 'Add itinerary item',
        'k_addItineraryLocationsRoute':
            'Add itinerary locations to build a route.',
        'k_addReminder': 'Add reminder',
        'k_addTasksPrepareTrip':
            'Add suggested or custom tasks to prepare this trip.',
        'k_addToTrip': 'Dodaj do podróży',
        'k_addTransport': 'Add transport',
        'k_added': 'Added',
        'k_addedToTripItinerary': 'Added to trip itinerary.',
        'k_addedToTripSuffix': 'added to trip.',
        'k_aiAssistant': 'Asystent AI',
        'k_aiTranslatorComingNext': 'AI translator module coming next.',
        'k_aiTravelPlanner': 'AI Travel Planner',
        'k_all': 'All',
        'k_allCurrenciesAdded': 'All supported currencies are already added.',
        'k_allTrips': 'All trips',
        'k_alreadyHaveAccountSignIn': 'Already have an account? Sign in',
        'k_amenities': 'Amenities',
        'k_amount': 'Amount',
        'k_amountGbp': 'Amount (£)',
        'k_askAi': 'Ask AI',
        'k_atLeastSixCharacters': 'At least 6 characters',
        'k_attachFile': 'Attach File',
        'k_backToLogin': 'Back to Login',
        'k_backToTrip': 'Back to Trip',
        'k_balanced': 'Balanced',
        'k_baseCurrency': 'Base currency',
        'k_beds': 'Beds',
        'k_bookReturnRide': 'Book Return Ride',
        'k_bookTaxi': 'Book Taxi',
        'k_booking': 'Booking',
        'k_bookingStatus': 'Booking Status',
        'k_bookingsUnavailable':
            'Bookings are unavailable right now. Please try again.',
        'k_budget': 'Budget',
        'k_buildingTripAwareItinerary': 'Building a trip-aware itinerary...',
        'k_business': 'Business',
        'k_cabin': 'Cabin',
        'k_cabinClass': 'Cabin Class',
        'k_calculatingLiveWalkingRoute': 'Calculating live walking route...',
        'k_cancel': 'Anuluj',
        'k_casual': 'Casual',
        'k_category': 'Category',
        'k_categoryMustBeSelected': 'Category must be selected.',
        'k_cheapest': 'Cheapest',
        'k_checkInboxResetInstructions':
            'Check your inbox for reset instructions.',
        'k_checklist': 'Checklist',
        'k_checkoutAfterCheckin': 'Check-out must be after check-in.',
        'k_clear': 'Clear',
        'k_clearRecents': 'Clear recents',
        'k_collaboratorEmail': 'Collaborator email',
        'k_collaboratorInvited': 'Collaborator invited.',
        'k_collaboratorUserIdOptional': 'Collaborator user ID (optional)',
        'k_compareRideOptions': 'Compare estimated ride options',
        'k_compareSelectedOptions': 'Compare selected options',
        'k_complete': 'complete',
        'k_confirmPassword': 'Confirm Password',
        'k_confirmationPdfPath': '/path/to/confirmation.pdf',
        'k_confirmedBookings': 'Confirmed Bookings',
        'k_continueWithApple': 'Continue with Apple',
        'k_continueWithGoogle': 'Continue with Google',
        'k_convert': 'Convert',
        'k_convertCurrency': 'Convert Currency',
        'k_coordinates': 'Coordinates',
        'k_copy': 'Copy',
        'k_cost': 'Cost',
        'k_couldNotOpenMapPreview': 'Could not open map preview.',
        'k_createAccount': 'Create Account',
        'k_createAccountLower': 'Create an account',
        'k_createChecklist': 'Create checklist',
        'k_createTrip': 'Create Trip',
        'k_createTripBeforeLinkingFlight':
            'Create a trip before linking a flight.',
        'k_createTripBeforeLinkingHotel':
            'Create a trip before linking a hotel.',
        'k_createTripFirstSaveTaxi': 'Create a trip first to save taxi rides.',
        'k_createTripToAddBookings':
            'Create a trip to add bookings and itinerary items.',
        'k_culture': 'Culture',
        'k_currency': 'Currency',
        'k_currencyConversionUnavailable': 'Currency conversion unavailable.',
        'k_current': 'Current',
        'k_date': 'Date',
        'k_dateRequired': 'Date is required.',
        'k_dateTime': 'Date and time',
        'k_day': 'Day',
        'k_delete': 'Delete',
        'k_deleteExpenseQuestion': 'Delete expense?',
        'k_deleteTrip': 'Delete Trip',
        'k_departureDate': 'Departure Date',
        'k_description': 'Description',
        'k_destination': 'Destination',
        'k_destinationOrMapLocation': 'Destination or map location',
        'k_destinationWalletId': 'Destination wallet ID',
        'k_details': 'Szczegóły',
        'k_directOnly': 'Direct only',
        'k_discoveryFailed': 'Discovery failed',
        'k_dismiss': 'Dismiss',
        'k_documentTypeHint': 'Ticket, confirmation, passport, visa',
        'k_dueToday': 'due today',
        'k_duplicate': 'Duplicate',
        'k_duration': 'Duration',
        'k_economy': 'Economy',
        'k_edit': 'Edit',
        'k_editTrip': 'Edit Trip',
        'k_editor': 'Editor',
        'k_email': 'Email',
        'k_emailNotVerifiedYet': 'Email is not verified yet.',
        'k_enableCurrencyWallet': 'Enable a new currency wallet balance.',
        'k_enterDestination': 'Enter a destination.',
        'k_enterPassword': 'Enter your password',
        'k_enterValidCost': 'Enter a valid cost.',
        'k_enterValidIataCodes':
            'Enter valid 3-letter IATA codes, e.g. LHR and CDG.',
        'k_error': 'Error',
        'k_estimatedAbbrev': 'est.',
        'k_eventsToday': 'events today',
        'k_exampleCdg': 'e.g., CDG',
        'k_exampleLhr': 'e.g., LHR',
        'k_exampleLisbonCityCentre': 'e.g. Lisbon city centre',
        'k_expense': 'Expense',
        'k_expenseAutoLoggingInfo': 'Expense auto-logging info',
        'k_expenseName': 'Expense Name',
        'k_failedLoadSavedHotels': 'Failed to load saved hotels',
        'k_failedLoadSearches': 'Failed to load searches',
        'k_family': 'Family',
        'k_familyFriendly': 'Family-friendly',
        'k_fastest': 'Fastest',
        'k_favourite': 'Favourite',
        'k_fetchingRate': 'Fetching rate...',
        'k_fillFlightSearchFields':
            'Please fill in From, To and Departure Date.',
        'k_findNearby': 'Find nearby',
        'k_fintechWallet': 'Fintech Wallet',
        'k_first': 'First',
        'k_firstClass': 'First Class',
        'k_flightDetails': 'Flight Details',
        'k_flightSaved': 'Flight saved',
        'k_flights': 'Loty',
        'k_food': 'Food',
        'k_forgotPasswordQuestion': 'Forgot password?',
        'k_from': 'From',
        'k_fromIataCode': 'From (IATA Code)',
        'k_fromThisTripQuestion': 'from this trip?',
        'k_generatePlan': 'Generate Plan',
        'k_goBack': 'Go Back',
        'k_hotelDetails': 'Hotel Details',
        'k_hotelNotificationComingNext':
            'Hotel notification workflow coming next.',
        'k_iVerifiedEmail': 'I have verified my email',
        'k_interest': 'Interest',
        'k_invalidDateFormat': 'Invalid date format. Use yyyy-mm-dd hh:mm',
        'k_inviteCollaborator': 'Invite collaborator',
        'k_language': 'Language',
        'k_linkFlight': 'Link Flight',
        'k_linkHotel': 'Link Hotel',
        'k_liveBookingUnavailable': 'Live Booking Unavailable',
        'k_liveTrip': 'Podróż na żywo',
        'k_loading': 'Loading...',
        'k_loadingActivities': 'Loading activities...',
        'k_loadingBudget': 'Loading budget...',
        'k_loadingFlight': 'Loading flight...',
        'k_loadingHotel': 'Loading hotel...',
        'k_loadingTotals': 'Loading totals...',
        'k_loadingTransportRides': 'Loading transport rides...',
        'k_loadingWeather': 'Loading weather...',
        'k_local': 'Local',
        'k_localFilePath': 'Local file path',
        'k_location': 'Location',
        'k_locationHint': 'Location hint',
        'k_luggage': 'Luggage',
        'k_makeEditor': 'Make editor',
        'k_makeViewer': 'Make viewer',
        'k_manageExpenses': 'Manage expenses',
        'k_manageReadiness': 'Manage readiness',
        'k_mapIntegrationComingNext': 'Map integration coming next.',
        'k_mapUnavailable': 'Map unavailable',
        'k_maps': 'Mapy',
        'k_minWalking': 'min walking',
        'k_mirrorSharedTripAccess': 'Used to mirror shared trip access',
        'k_myBookings': 'Moje rezerwacje',
        'k_myTrips': 'My Trips',
        'k_name': 'Name',
        'k_navigate': 'Navigate',
        'k_nearby': 'Nearby',
        'k_nearbyDemoFallback':
            'Nearby results with a clear demo fallback when live search is unavailable.',
        'k_nearbyEssentials': 'Usługi w pobliżu',
        'k_nearbyPlacesUnavailable': 'Nearby places are unavailable right now.',
        'k_next': 'Next',
        'k_nights': 'Nights',
        'k_noActivitiesPlanned': 'No activities planned yet.',
        'k_noActivitiesYet': 'No activities yet. Add your first trip plan.',
        'k_noBookingInProgress': 'No booking in progress',
        'k_noCollaboratorsYet': 'No collaborators invited yet.',
        'k_noExpensesYet': 'No expenses yet. Tap Add Expense to start.',
        'k_noFlightAdded': 'No flight added yet.',
        'k_noFlightsFound': 'No flights found',
        'k_noHotelLinkedTap': 'No hotel linked yet. Tap to add one.',
        'k_noLinkedFlight': 'No linked flight yet.',
        'k_noLinkedHotel': 'No linked hotel yet.',
        'k_noPlacesFoundFor': 'No places found for',
        'k_noProvidersAvailable': 'No providers are currently available.',
        'k_noReadinessReminders':
            'No readiness reminders for the next few hours.',
        'k_noRelevantDocuments':
            'No relevant documents found for the next event.',
        'k_noRemindersYet': 'No reminders yet.',
        'k_noSavedFlightsAvailable': 'No saved flights available.',
        'k_noSavedHotelsAvailable': 'No saved hotels available.',
        'k_noSavedRidesForSelectedTrip':
            'No saved rides for the selected trip.',
        'k_noSavedTransportRides': 'No saved transport rides yet.',
        'k_noSpendingActivity': 'No spending activity yet.',
        'k_noTodayBookingsActivities':
            'No saved bookings or activities for today.',
        'k_noTransactions': 'No transactions yet.',
        'k_notes': 'Notes',
        'k_notifyHotel': 'Notify Hotel',
        'k_open': 'Open',
        'k_openAiPlanner': 'Open AI Planner',
        'k_openFlights': 'Open Flights',
        'k_openHotels': 'Open Hotels',
        'k_openMap': 'Otwórz mapę',
        'k_openReadiness': 'Open readiness',
        'k_openTrips': 'Open Trips',
        'k_origin': 'Origin',
        'k_overdue': 'overdue',
        'k_owner': 'Owner',
        'k_packed': 'Packed',
        'k_passengers': 'Passengers',
        'k_passwordResetEmailSent':
            'Password reset email sent. Check your inbox.',
        'k_pending': 'pending',
        'k_phrasebook': 'Phrasebook',
        'k_pickup': 'Pickup',
        'k_pickupDateTime': 'Pickup date and time',
        'k_plannedNextMilestoneSuffix': 'is planned in the next milestone.',
        'k_plannedRideDetails': 'Planned ride details',
        'k_plannerFailed': 'Planner failed',
        'k_playTranslation': 'Play translation',
        'k_premiumEconomy': 'Premium Economy',
        'k_proceedToBooking': 'Proceed to booking',
        'k_profile': 'Profil',
        'k_provider': 'Provider',
        'k_rainyDayPlan': 'Rainy-day plan',
        'k_rateUnavailable': 'Rate unavailable',
        'k_readiness': 'Readiness',
        'k_receiptCaptureQueued':
            'Receipt capture assistant is queued for next step.',
        'k_receive': 'Receive',
        'k_receiveFunds': 'Receive Funds',
        'k_recentSearches': 'Recent Searches',
        'k_reenterPassword': 'Re-enter your password',
        'k_referenceUrlCode': 'Reference / URL / Code',
        'k_refresh': 'Refresh',
        'k_registrationSuccessful': 'Registration successful!',
        'k_reject': 'Reject',
        'k_relaxation': 'Relaxation',
        'k_relaxed': 'Relaxed',
        'k_remaining': 'Remaining',
        'k_rememberMe': 'Remember me',
        'k_reminderAddedFor': 'Reminder added for',
        'k_reminders': 'Reminders',
        'k_remove': 'Remove',
        'k_removeDocumentQuestion': 'Remove document?',
        'k_removedFromSavedHotelsSuffix': 'removed from saved hotels',
        'k_replace': 'Replace',
        'k_replan': 'Replan',
        'k_resendVerificationEmail': 'Resend verification email',
        'k_resetPassword': 'Reset Password',
        'k_restaurantCuisine': 'Restaurant cuisine',
        'k_restore': 'Restore',
        'k_retry': 'Retry',
        'k_returnDateOptional': 'Return Date (Optional)',
        'k_reviewPlannedRide': 'Review planned ride',
        'k_rideOptions': 'Ride options',
        'k_room': 'Room',
        'k_save': 'Zapisz',
        'k_saveChanges': 'Save Changes',
        'k_saveExpense': 'Save Expense',
        'k_saveFlight': 'Save flight',
        'k_saveFlightPlan': 'Save Flight Plan',
        'k_saveReceipt': 'Save Receipt',
        'k_saveRideToItinerary': 'Save ride to itinerary',
        'k_saveTask': 'Save Task',
        'k_saveUnavailable': 'Save unavailable',
        'k_saved': 'Saved',
        'k_savedDiscovery': 'Saved discovery',
        'k_savedFlightDetails': 'Saved Flight Details',
        'k_savedFlights': 'Saved Flights',
        'k_savedHotelDetails': 'Saved Hotel Details',
        'k_savedHotels': 'Saved Hotels',
        'k_savedItems': 'Zapisane elementy',
        'k_savedRides': 'Saved rides',
        'k_savedTransport': 'Saved transport',
        'k_seafood': 'Seafood',
        'k_search': 'Szukaj',
        'k_searchDeleted': 'Search deleted',
        'k_searchEverything': 'Search Everything',
        'k_searchFlights': 'Search Flights',
        'k_searchHotels': 'Search Hotels',
        'k_searchInApp': 'Search in app',
        'k_searchPlaceStationVenue': 'Search a place, station, or venue',
        'k_searchingDemoTravelProviders': 'Searching demo travel providers...',
        'k_selectBothDates': 'Please select both dates.',
        'k_selectTrip': 'Select trip',
        'k_selectedTrip': 'Selected trip',
        'k_send': 'Send',
        'k_sendFunds': 'Send Funds',
        'k_signIn': 'Sign In',
        'k_signInAddBookings': 'Sign in to add bookings to a trip.',
        'k_signInAddSavedItems': 'Sign in to add saved items to trips.',
        'k_signInSaveFlights': 'Please sign in to save flights.',
        'k_signInViewRecentSearches': 'Please sign in to view recent searches.',
        'k_signInViewSavedFlights': 'Please sign in to view saved flights.',
        'k_signOut': 'Wyloguj się',
        'k_source': 'Source',
        'k_spent': 'Spent',
        'k_status': 'Status',
        'k_stayDetails': 'Stay Details',
        'k_suggestedPreparation': 'Suggested preparation',
        'k_suggestedSearch': 'Suggested search',
        'k_suggestedTime': 'Suggested time',
        'k_swapLanguages': 'Swap languages',
        'k_tapAttachFlight': 'Tap to attach a flight.',
        'k_task': 'Task',
        'k_tasksRemaining': 'tasks remaining',
        'k_taxiHub': 'Taxi Hub',
        'k_textToTranslate': 'Text to translate',
        'k_ticket': 'Ticket',
        'k_title': 'Title',
        'k_titleAndTypeRequired': 'Title and type are required.',
        'k_titleRequired': 'Title is required.',
        'k_to': 'To',
        'k_toIataCode': 'To (IATA Code)',
        'k_translate': 'Translate',
        'k_translateCard': 'Translate Card',
        'k_translateDestination': 'Translate Destination',
        'k_translationCopied': 'Translation copied.',
        'k_translator': 'Tłumacz',
        'k_translatorCardSubtitle': 'Text, conversation mode and phrasebook.',
        'k_transportHub': 'Transport Hub',
        'k_travelDiscovery': 'Odkrywanie podróży',
        'k_travelDocumentsComingNext': 'Travel documents module coming next.',
        'k_travelTranslator': 'Travel Translator',
        'k_travelWallet': 'Travel Wallet',
        'k_travellers': 'Travellers',
        'k_trip': 'Trip',
        'k_tripActivities': 'Trip Activities',
        'k_tripAiAssistantComingNext': 'Trip AI assistant coming next.',
        'k_tripBudget': 'Trip Budget',
        'k_tripChangedUpdatePlan': 'Your trip changed - update your plan?',
        'k_tripContext': 'Trip context',
        'k_tripContextUnavailableSearch':
            'Trip context unavailable. Enter a location to search.',
        'k_tripCreatedSuccessfully': 'Trip created successfully.',
        'k_tripDashboard': 'Trip Dashboard',
        'k_tripDocumentRemoved': 'Trip document removed.',
        'k_tripDocuments': 'Trip Documents',
        'k_tripExpenses': 'Trip Expenses',
        'k_tripForSavedTransportActions':
            'Trip for saved transport and add-to-trip actions',
        'k_tripNotFound': 'Trip not found',
        'k_tripNotFoundPeriod': 'Trip not found.',
        'k_tripNotes': 'Trip Notes',
        'k_tripNotesHint': 'Add trip notes, ideas, reminders, and links...',
        'k_tripNotesSaved': 'Trip notes saved.',
        'k_tripOwner': 'Trip owner',
        'k_tripReadiness': 'Trip Readiness',
        'k_tryAgain': 'Try again',
        'k_type': 'Type',
        'k_typeMessage': 'Type message...',
        'k_unableCalculateTotals': 'Unable to calculate totals',
        'k_unableLoadBudget': 'Unable to load budget',
        'k_unableLoadFlight': 'Unable to load flight',
        'k_unableLoadHotel': 'Unable to load hotel',
        'k_unableToOpenMapLink': 'Unable to open map link.',
        'k_unlink': 'Unlink',
        'k_upcoming': 'upcoming',
        'k_update': 'Update',
        'k_useInRoute': 'Use in route',
        'k_useSamplePickup': 'Use sample pickup',
        'k_vegetarian': 'Vegetarian',
        'k_verificationEmailSentAgain': 'Verification email sent again.',
        'k_verifyEmail': 'Verify Email',
        'k_viewDetails': 'View Details',
        'k_viewRouteOnMap': 'View route on map',
        'k_viewer': 'Viewer',
        'k_waitConfirmProvider':
            'Please wait while we confirm with the provider.',
        'k_weather': 'Weather',
        'k_weatherAwarePlan': 'Weather-aware plan',
        'k_weatherCurrentlyUnavailable': 'Weather currently unavailable',
        'k_weatherUnavailable': 'Weather unavailable.',
        'k_weatherUnavailableNow': 'Weather is currently unavailable.',
        'k_youExampleEmail': 'you@example.com',
        'k_yourEmailExample': 'your@email.com',
        'other': '$key',
      },
    );
    return '$_temp0';
  }
}

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Romanian Moldavian Moldovan (`ro`).
class AppLocalizationsRo extends AppLocalizations {
  AppLocalizationsRo([String locale = 'ro']) : super(locale);

  @override
  String get appName => 'ITAREVO Travel';

  @override
  String get home => 'Acasă';

  @override
  String get trips => 'Călătorii';

  @override
  String get discover => 'Descoperă';

  @override
  String get aiAssistant => 'Asistent AI';

  @override
  String get wallet => 'Portofel';

  @override
  String get maps => 'Hărți';

  @override
  String get nearbyEssentials => 'Servicii din apropiere';

  @override
  String get translator => 'Traducător';

  @override
  String get profile => 'Profil';

  @override
  String get settings => 'Setări';

  @override
  String get search => 'Caută';

  @override
  String get save => 'Salvează';

  @override
  String get cancel => 'Anulează';

  @override
  String get back => 'Înapoi';

  @override
  String get done => 'Gata';

  @override
  String get addToTrip => 'Adaugă la călătorie';

  @override
  String get openMap => 'Deschide harta';

  @override
  String get mapAndRoute => 'Hartă și traseu';

  @override
  String get liveGooglePlaces => 'Google Places live';

  @override
  String get toilets => 'Toalete';

  @override
  String get supermarkets => 'Supermarketuri';

  @override
  String get restaurants => 'Restaurante';

  @override
  String get cafes => 'Cafenele';

  @override
  String get pharmacies => 'Farmacii';

  @override
  String get hospitals => 'Spitale';

  @override
  String get atms => 'Bancomate';

  @override
  String get parking => 'Parcare';

  @override
  String get fuel => 'Combustibil';

  @override
  String get trainStations => 'Gări';

  @override
  String get busStations => 'Autogări';

  @override
  String get airports => 'Aeroporturi';

  @override
  String get evCharging => 'Încărcare EV';

  @override
  String get taxi => 'Taxi';

  @override
  String get publicTransport => 'Transport public';

  @override
  String get dashboardUnavailable => 'Tabloul de bord nu este disponibil';

  @override
  String get preparingYourDashboard => 'Îți pregătim tabloul de bord...';

  @override
  String get dashboardLoadFailed => 'Nu am putut încărca rezumatul călătoriei.';

  @override
  String get noUpcomingTrip => 'Nicio călătorie viitoare';

  @override
  String get profileSubtitle => 'Setări cont, deconectare și ștergere cont.';

  @override
  String get myBookings => 'Rezervările mele';

  @override
  String get myBookingsSubtitle =>
      'Zboruri, sejururi și transport pentru călătoriile tale.';

  @override
  String get travelDiscovery => 'Descoperire de călătorii';

  @override
  String get travelDiscoverySubtitle =>
      'Caută zboruri, hoteluri, curse, activități și restaurante și adaugă-le la o călătorie.';

  @override
  String get savedItems => 'Elemente salvate';

  @override
  String get savedItemsSubtitle =>
      'Zboruri, hoteluri, curse, restaurante și locuri pe care vrei să le păstrezi.';

  @override
  String get quickBooking => 'Rezervare rapidă';

  @override
  String get flights => 'Zboruri';

  @override
  String get hotels => 'Hoteluri';

  @override
  String get trains => 'Trenuri';

  @override
  String get buses => 'Autobuze';

  @override
  String get carRental => 'Închirieri auto';

  @override
  String get aiAssistantSubtitle => 'Cum te pot ajuta astăzi?';

  @override
  String get translatorSubtitle =>
      'Text, mod conversație și expresii de călătorie.';

  @override
  String get liveTrip => 'Călătorie live';

  @override
  String get dashboard => 'Tablou de bord';

  @override
  String get noUpcomingTripSubtitle =>
      'Salvează o călătorie pentru a vedea aici zborurile, hotelurile, vremea și bugetul.';

  @override
  String get signOut => 'Deconectare';

  @override
  String get account => 'Cont';

  @override
  String get traveler => 'Călător';

  @override
  String get noEmailAvailable => 'Niciun e-mail disponibil';

  @override
  String get profileHomeShortcutsHint =>
      'Hoteluri, Vreme, Portofel și Traducător rămân disponibile din comenzile rapide de pe pagina principală.';

  @override
  String get deleteAccount => 'Șterge contul';

  @override
  String get deleteAccountFailed =>
      'Nu am putut șterge contul. Încearcă din nou.';

  @override
  String get deleteAccountQuestion => 'Ștergi contul?';

  @override
  String get deleteAccountWarning =>
      'Aceasta elimină definitiv profilul ITAREVO și datele acestui cont. Acțiunea nu poate fi anulată.';

  @override
  String get currentPassword => 'Parola actuală';

  @override
  String get reauthenticateWithProvider =>
      'Ți se va cere să te autentifici folosind furnizorul de conectare.';

  @override
  String get deletePermanently => 'Șterge definitiv';

  @override
  String get openSavedPlaces => 'Deschide locurile salvate';

  @override
  String get exploreAroundTrip => 'Explorează în jurul călătoriei';

  @override
  String get searchNearby => 'Caută în apropiere';

  @override
  String get whatAreYouLookingFor => 'Ce cauți?';

  @override
  String get openNow => 'Deschis acum';

  @override
  String get topRated => 'Cel mai bine evaluate';

  @override
  String ratingOutOfFive(String rating) {
    return 'Evaluare $rating / 5';
  }

  @override
  String get noTripsYetSearchDestination =>
      'Nu există încă călătorii. Caută o destinație mai sus.';

  @override
  String searchForNearby(String service) {
    return 'Caută $service în apropiere';
  }

  @override
  String get searchDestination => 'Caută destinația';

  @override
  String placesNear(String location) {
    return 'Locuri lângă $location';
  }

  @override
  String get details => 'Detalii';

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
        'k_addToTrip': 'Adaugă la călătorie',
        'k_addTransport': 'Add transport',
        'k_added': 'Added',
        'k_addedToTripItinerary': 'Added to trip itinerary.',
        'k_addedToTripSuffix': 'added to trip.',
        'k_aiAssistant': 'Asistent AI',
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
        'k_cancel': 'Anulează',
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
        'k_details': 'Detalii',
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
        'k_flights': 'Zboruri',
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
        'k_liveTrip': 'Călătorie live',
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
        'k_maps': 'Hărți',
        'k_minWalking': 'min walking',
        'k_mirrorSharedTripAccess': 'Used to mirror shared trip access',
        'k_myBookings': 'Rezervările mele',
        'k_myTrips': 'My Trips',
        'k_name': 'Name',
        'k_navigate': 'Navigate',
        'k_nearby': 'Nearby',
        'k_nearbyDemoFallback':
            'Nearby results with a clear demo fallback when live search is unavailable.',
        'k_nearbyEssentials': 'Servicii din apropiere',
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
        'k_openMap': 'Deschide harta',
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
        'k_save': 'Salvează',
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
        'k_savedItems': 'Elemente salvate',
        'k_savedRides': 'Saved rides',
        'k_savedTransport': 'Saved transport',
        'k_seafood': 'Seafood',
        'k_search': 'Caută',
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
        'k_signOut': 'Deconectare',
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
        'k_translator': 'Traducător',
        'k_translatorCardSubtitle': 'Text, conversation mode and phrasebook.',
        'k_transportHub': 'Transport Hub',
        'k_travelDiscovery': 'Descoperire de călătorii',
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

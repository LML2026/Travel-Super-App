import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_bg.dart';
import 'app_localizations_cs.dart';
import 'app_localizations_da.dart';
import 'app_localizations_de.dart';
import 'app_localizations_el.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ro.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_sv.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('bg'),
    Locale('cs'),
    Locale('da'),
    Locale('de'),
    Locale('el'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('ja'),
    Locale('nl'),
    Locale('pl'),
    Locale('pt'),
    Locale('ro'),
    Locale('ru'),
    Locale('sv'),
    Locale('tr'),
    Locale('zh')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'ITAREVO Travel'**
  String get appName;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @trips.
  ///
  /// In en, this message translates to:
  /// **'Trips'**
  String get trips;

  /// No description provided for @discover.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get discover;

  /// No description provided for @aiAssistant.
  ///
  /// In en, this message translates to:
  /// **'AI Assistant'**
  String get aiAssistant;

  /// No description provided for @wallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get wallet;

  /// No description provided for @maps.
  ///
  /// In en, this message translates to:
  /// **'Maps'**
  String get maps;

  /// No description provided for @nearbyEssentials.
  ///
  /// In en, this message translates to:
  /// **'Nearby Essentials'**
  String get nearbyEssentials;

  /// No description provided for @translator.
  ///
  /// In en, this message translates to:
  /// **'Translator'**
  String get translator;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @addToTrip.
  ///
  /// In en, this message translates to:
  /// **'Add to trip'**
  String get addToTrip;

  /// No description provided for @openMap.
  ///
  /// In en, this message translates to:
  /// **'Open Map'**
  String get openMap;

  /// No description provided for @mapAndRoute.
  ///
  /// In en, this message translates to:
  /// **'Map & route'**
  String get mapAndRoute;

  /// No description provided for @liveGooglePlaces.
  ///
  /// In en, this message translates to:
  /// **'Live Google Places'**
  String get liveGooglePlaces;

  /// No description provided for @toilets.
  ///
  /// In en, this message translates to:
  /// **'Toilets'**
  String get toilets;

  /// No description provided for @supermarkets.
  ///
  /// In en, this message translates to:
  /// **'Supermarkets'**
  String get supermarkets;

  /// No description provided for @restaurants.
  ///
  /// In en, this message translates to:
  /// **'Restaurants'**
  String get restaurants;

  /// No description provided for @cafes.
  ///
  /// In en, this message translates to:
  /// **'Cafes'**
  String get cafes;

  /// No description provided for @pharmacies.
  ///
  /// In en, this message translates to:
  /// **'Pharmacies'**
  String get pharmacies;

  /// No description provided for @hospitals.
  ///
  /// In en, this message translates to:
  /// **'Hospitals'**
  String get hospitals;

  /// No description provided for @atms.
  ///
  /// In en, this message translates to:
  /// **'ATMs'**
  String get atms;

  /// No description provided for @parking.
  ///
  /// In en, this message translates to:
  /// **'Parking'**
  String get parking;

  /// No description provided for @fuel.
  ///
  /// In en, this message translates to:
  /// **'Fuel'**
  String get fuel;

  /// No description provided for @trainStations.
  ///
  /// In en, this message translates to:
  /// **'Train stations'**
  String get trainStations;

  /// No description provided for @busStations.
  ///
  /// In en, this message translates to:
  /// **'Bus stations'**
  String get busStations;

  /// No description provided for @airports.
  ///
  /// In en, this message translates to:
  /// **'Airports'**
  String get airports;

  /// No description provided for @evCharging.
  ///
  /// In en, this message translates to:
  /// **'EV charging'**
  String get evCharging;

  /// No description provided for @taxi.
  ///
  /// In en, this message translates to:
  /// **'Taxi'**
  String get taxi;

  /// No description provided for @publicTransport.
  ///
  /// In en, this message translates to:
  /// **'Public transport'**
  String get publicTransport;

  /// No description provided for @dashboardUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Dashboard unavailable'**
  String get dashboardUnavailable;

  /// No description provided for @preparingYourDashboard.
  ///
  /// In en, this message translates to:
  /// **'Preparing your dashboard...'**
  String get preparingYourDashboard;

  /// No description provided for @dashboardLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'We could not load your travel summary.'**
  String get dashboardLoadFailed;

  /// No description provided for @noUpcomingTrip.
  ///
  /// In en, this message translates to:
  /// **'No upcoming trip'**
  String get noUpcomingTrip;

  /// No description provided for @profileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Account settings, sign out and delete account.'**
  String get profileSubtitle;

  /// No description provided for @myBookings.
  ///
  /// In en, this message translates to:
  /// **'My Bookings'**
  String get myBookings;

  /// No description provided for @myBookingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Flights, stays and transport across your trips.'**
  String get myBookingsSubtitle;

  /// No description provided for @travelDiscovery.
  ///
  /// In en, this message translates to:
  /// **'Travel Discovery'**
  String get travelDiscovery;

  /// No description provided for @travelDiscoverySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Search flights, hotels, rides, activities and restaurants, then add them to a trip.'**
  String get travelDiscoverySubtitle;

  /// No description provided for @savedItems.
  ///
  /// In en, this message translates to:
  /// **'Saved Items'**
  String get savedItems;

  /// No description provided for @savedItemsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Flights, hotels, rides, restaurants and places you want to remember.'**
  String get savedItemsSubtitle;

  /// No description provided for @quickBooking.
  ///
  /// In en, this message translates to:
  /// **'Quick Booking'**
  String get quickBooking;

  /// No description provided for @flights.
  ///
  /// In en, this message translates to:
  /// **'Flights'**
  String get flights;

  /// No description provided for @hotels.
  ///
  /// In en, this message translates to:
  /// **'Hotels'**
  String get hotels;

  /// No description provided for @trains.
  ///
  /// In en, this message translates to:
  /// **'Trains'**
  String get trains;

  /// No description provided for @buses.
  ///
  /// In en, this message translates to:
  /// **'Buses'**
  String get buses;

  /// No description provided for @carRental.
  ///
  /// In en, this message translates to:
  /// **'Car Rental'**
  String get carRental;

  /// No description provided for @aiAssistantSubtitle.
  ///
  /// In en, this message translates to:
  /// **'How can I help today?'**
  String get aiAssistantSubtitle;

  /// No description provided for @translatorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Text, conversation mode and travel phrases.'**
  String get translatorSubtitle;

  /// No description provided for @liveTrip.
  ///
  /// In en, this message translates to:
  /// **'Live Trip'**
  String get liveTrip;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @noUpcomingTripSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save a trip to see flights, hotels, weather, and budget here.'**
  String get noUpcomingTripSubtitle;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @traveler.
  ///
  /// In en, this message translates to:
  /// **'Traveler'**
  String get traveler;

  /// No description provided for @noEmailAvailable.
  ///
  /// In en, this message translates to:
  /// **'No email available'**
  String get noEmailAvailable;

  /// No description provided for @profileHomeShortcutsHint.
  ///
  /// In en, this message translates to:
  /// **'Hotels, Weather, Wallet, and Translator remain available from the Home dashboard shortcuts.'**
  String get profileHomeShortcutsHint;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountFailed.
  ///
  /// In en, this message translates to:
  /// **'We could not delete your account. Please try again.'**
  String get deleteAccountFailed;

  /// No description provided for @deleteAccountQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete account?'**
  String get deleteAccountQuestion;

  /// No description provided for @deleteAccountWarning.
  ///
  /// In en, this message translates to:
  /// **'This permanently removes your ITAREVO profile and data owned by this account. This action cannot be undone.'**
  String get deleteAccountWarning;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPassword;

  /// No description provided for @reauthenticateWithProvider.
  ///
  /// In en, this message translates to:
  /// **'You will be asked to authenticate with your sign-in provider.'**
  String get reauthenticateWithProvider;

  /// No description provided for @deletePermanently.
  ///
  /// In en, this message translates to:
  /// **'Delete permanently'**
  String get deletePermanently;

  /// No description provided for @openSavedPlaces.
  ///
  /// In en, this message translates to:
  /// **'Open saved places'**
  String get openSavedPlaces;

  /// No description provided for @exploreAroundTrip.
  ///
  /// In en, this message translates to:
  /// **'Explore around your trip'**
  String get exploreAroundTrip;

  /// No description provided for @searchNearby.
  ///
  /// In en, this message translates to:
  /// **'Search nearby'**
  String get searchNearby;

  /// No description provided for @whatAreYouLookingFor.
  ///
  /// In en, this message translates to:
  /// **'What are you looking for?'**
  String get whatAreYouLookingFor;

  /// No description provided for @openNow.
  ///
  /// In en, this message translates to:
  /// **'Open now'**
  String get openNow;

  /// No description provided for @topRated.
  ///
  /// In en, this message translates to:
  /// **'Top rated'**
  String get topRated;

  /// No description provided for @ratingOutOfFive.
  ///
  /// In en, this message translates to:
  /// **'Rating {rating} / 5'**
  String ratingOutOfFive(String rating);

  /// No description provided for @noTripsYetSearchDestination.
  ///
  /// In en, this message translates to:
  /// **'No trips yet. Search any destination above.'**
  String get noTripsYetSearchDestination;

  /// No description provided for @searchForNearby.
  ///
  /// In en, this message translates to:
  /// **'Search for {service} nearby'**
  String searchForNearby(String service);

  /// No description provided for @searchDestination.
  ///
  /// In en, this message translates to:
  /// **'Search destination'**
  String get searchDestination;

  /// No description provided for @placesNear.
  ///
  /// In en, this message translates to:
  /// **'Places near {location}'**
  String placesNear(String location);

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @uiText.
  ///
  /// In en, this message translates to:
  /// **'{key, select, k_acceptAndAdd{Accept and add} k_acceptTermsPrivacy{I accept Terms and Privacy Policy} k_acceptTermsToContinue{Please accept terms to continue.} k_accessibilityAware{Accessibility-aware} k_accuracy{Accuracy} k_activityStatusHint{Planned, booked, optional} k_add{Add} k_addActivity{Add Activity} k_addBookingsToTrip{Add bookings to trip} k_addCurrency{Add currency} k_addExpense{Add Expense} k_addItineraryItem{Add itinerary item} k_addItineraryLocationsRoute{Add itinerary locations to build a route.} k_addReminder{Add reminder} k_addTasksPrepareTrip{Add suggested or custom tasks to prepare this trip.} k_addToTrip{Add to trip} k_addTransport{Add transport} k_added{Added} k_addedToTripItinerary{Added to trip itinerary.} k_addedToTripSuffix{added to trip.} k_aiAssistant{AI Assistant} k_aiTranslatorComingNext{AI translator module coming next.} k_aiTravelPlanner{AI Travel Planner} k_all{All} k_allCurrenciesAdded{All supported currencies are already added.} k_allTrips{All trips} k_alreadyHaveAccountSignIn{Already have an account? Sign in} k_amenities{Amenities} k_amount{Amount} k_amountGbp{Amount (£)} k_askAi{Ask AI} k_atLeastSixCharacters{At least 6 characters} k_attachFile{Attach File} k_backToLogin{Back to Login} k_backToTrip{Back to Trip} k_balanced{Balanced} k_baseCurrency{Base currency} k_beds{Beds} k_bookReturnRide{Book Return Ride} k_bookTaxi{Book Taxi} k_booking{Booking} k_bookingStatus{Booking Status} k_bookingsUnavailable{Bookings are unavailable right now. Please try again.} k_budget{Budget} k_buildingTripAwareItinerary{Building a trip-aware itinerary...} k_business{Business} k_cabin{Cabin} k_cabinClass{Cabin Class} k_calculatingLiveWalkingRoute{Calculating live walking route...} k_cancel{Cancel} k_casual{Casual} k_category{Category} k_categoryMustBeSelected{Category must be selected.} k_cheapest{Cheapest} k_checkInboxResetInstructions{Check your inbox for reset instructions.} k_checklist{Checklist} k_checkoutAfterCheckin{Check-out must be after check-in.} k_clear{Clear} k_clearRecents{Clear recents} k_collaboratorEmail{Collaborator email} k_collaboratorInvited{Collaborator invited.} k_collaboratorUserIdOptional{Collaborator user ID (optional)} k_compareRideOptions{Compare estimated ride options} k_compareSelectedOptions{Compare selected options} k_complete{complete} k_confirmPassword{Confirm Password} k_confirmationPdfPath{/path/to/confirmation.pdf} k_confirmedBookings{Confirmed Bookings} k_continueWithApple{Continue with Apple} k_continueWithGoogle{Continue with Google} k_convert{Convert} k_convertCurrency{Convert Currency} k_coordinates{Coordinates} k_copy{Copy} k_cost{Cost} k_couldNotOpenMapPreview{Could not open map preview.} k_createAccount{Create Account} k_createAccountLower{Create an account} k_createChecklist{Create checklist} k_createTrip{Create Trip} k_createTripBeforeLinkingFlight{Create a trip before linking a flight.} k_createTripBeforeLinkingHotel{Create a trip before linking a hotel.} k_createTripFirstSaveTaxi{Create a trip first to save taxi rides.} k_createTripToAddBookings{Create a trip to add bookings and itinerary items.} k_culture{Culture} k_currency{Currency} k_currencyConversionUnavailable{Currency conversion unavailable.} k_current{Current} k_date{Date} k_dateRequired{Date is required.} k_dateTime{Date and time} k_day{Day} k_delete{Delete} k_deleteExpenseQuestion{Delete expense?} k_deleteTrip{Delete Trip} k_departureDate{Departure Date} k_description{Description} k_destination{Destination} k_destinationOrMapLocation{Destination or map location} k_destinationWalletId{Destination wallet ID} k_details{Details} k_directOnly{Direct only} k_discoveryFailed{Discovery failed} k_dismiss{Dismiss} k_documentTypeHint{Ticket, confirmation, passport, visa} k_dueToday{due today} k_duplicate{Duplicate} k_duration{Duration} k_economy{Economy} k_edit{Edit} k_editTrip{Edit Trip} k_editor{Editor} k_email{Email} k_emailNotVerifiedYet{Email is not verified yet.} k_enableCurrencyWallet{Enable a new currency wallet balance.} k_enterDestination{Enter a destination.} k_enterPassword{Enter your password} k_enterValidCost{Enter a valid cost.} k_enterValidIataCodes{Enter valid 3-letter IATA codes, e.g. LHR and CDG.} k_error{Error} k_estimatedAbbrev{est.} k_eventsToday{events today} k_exampleCdg{e.g., CDG} k_exampleLhr{e.g., LHR} k_exampleLisbonCityCentre{e.g. Lisbon city centre} k_expense{Expense} k_expenseAutoLoggingInfo{Expense auto-logging info} k_expenseName{Expense Name} k_failedLoadSavedHotels{Failed to load saved hotels} k_failedLoadSearches{Failed to load searches} k_family{Family} k_familyFriendly{Family-friendly} k_fastest{Fastest} k_favourite{Favourite} k_fetchingRate{Fetching rate...} k_fillFlightSearchFields{Please fill in From, To and Departure Date.} k_findNearby{Find nearby} k_fintechWallet{Fintech Wallet} k_first{First} k_firstClass{First Class} k_flightDetails{Flight Details} k_flightSaved{Flight saved} k_flights{Flights} k_food{Food} k_forgotPasswordQuestion{Forgot password?} k_from{From} k_fromIataCode{From (IATA Code)} k_fromThisTripQuestion{from this trip?} k_generatePlan{Generate Plan} k_goBack{Go Back} k_hotelDetails{Hotel Details} k_hotelNotificationComingNext{Hotel notification workflow coming next.} k_iVerifiedEmail{I have verified my email} k_interest{Interest} k_invalidDateFormat{Invalid date format. Use yyyy-mm-dd hh:mm} k_inviteCollaborator{Invite collaborator} k_language{Language} k_linkFlight{Link Flight} k_linkHotel{Link Hotel} k_liveBookingUnavailable{Live Booking Unavailable} k_liveTrip{Live Trip} k_loading{Loading...} k_loadingActivities{Loading activities...} k_loadingBudget{Loading budget...} k_loadingFlight{Loading flight...} k_loadingHotel{Loading hotel...} k_loadingTotals{Loading totals...} k_loadingTransportRides{Loading transport rides...} k_loadingWeather{Loading weather...} k_local{Local} k_localFilePath{Local file path} k_location{Location} k_locationHint{Location hint} k_luggage{Luggage} k_makeEditor{Make editor} k_makeViewer{Make viewer} k_manageExpenses{Manage expenses} k_manageReadiness{Manage readiness} k_mapIntegrationComingNext{Map integration coming next.} k_mapUnavailable{Map unavailable} k_maps{Maps} k_minWalking{min walking} k_mirrorSharedTripAccess{Used to mirror shared trip access} k_myBookings{My Bookings} k_myTrips{My Trips} k_name{Name} k_navigate{Navigate} k_nearby{Nearby} k_nearbyDemoFallback{Nearby results with a clear demo fallback when live search is unavailable.} k_nearbyEssentials{Nearby Essentials} k_nearbyPlacesUnavailable{Nearby places are unavailable right now.} k_next{Next} k_nights{Nights} k_noActivitiesPlanned{No activities planned yet.} k_noActivitiesYet{No activities yet. Add your first trip plan.} k_noBookingInProgress{No booking in progress} k_noCollaboratorsYet{No collaborators invited yet.} k_noExpensesYet{No expenses yet. Tap Add Expense to start.} k_noFlightAdded{No flight added yet.} k_noFlightsFound{No flights found} k_noHotelLinkedTap{No hotel linked yet. Tap to add one.} k_noLinkedFlight{No linked flight yet.} k_noLinkedHotel{No linked hotel yet.} k_noPlacesFoundFor{No places found for} k_noProvidersAvailable{No providers are currently available.} k_noReadinessReminders{No readiness reminders for the next few hours.} k_noRelevantDocuments{No relevant documents found for the next event.} k_noRemindersYet{No reminders yet.} k_noSavedFlightsAvailable{No saved flights available.} k_noSavedHotelsAvailable{No saved hotels available.} k_noSavedRidesForSelectedTrip{No saved rides for the selected trip.} k_noSavedTransportRides{No saved transport rides yet.} k_noSpendingActivity{No spending activity yet.} k_noTodayBookingsActivities{No saved bookings or activities for today.} k_noTransactions{No transactions yet.} k_notes{Notes} k_notifyHotel{Notify Hotel} k_open{Open} k_openAiPlanner{Open AI Planner} k_openFlights{Open Flights} k_openHotels{Open Hotels} k_openMap{Open Map} k_openReadiness{Open readiness} k_openTrips{Open Trips} k_origin{Origin} k_overdue{overdue} k_owner{Owner} k_packed{Packed} k_passengers{Passengers} k_passwordResetEmailSent{Password reset email sent. Check your inbox.} k_pending{pending} k_phrasebook{Phrasebook} k_pickup{Pickup} k_pickupDateTime{Pickup date and time} k_plannedNextMilestoneSuffix{is planned in the next milestone.} k_plannedRideDetails{Planned ride details} k_plannerFailed{Planner failed} k_playTranslation{Play translation} k_premiumEconomy{Premium Economy} k_proceedToBooking{Proceed to booking} k_profile{Profile} k_provider{Provider} k_rainyDayPlan{Rainy-day plan} k_rateUnavailable{Rate unavailable} k_readiness{Readiness} k_receiptCaptureQueued{Receipt capture assistant is queued for next step.} k_receive{Receive} k_receiveFunds{Receive Funds} k_recentSearches{Recent Searches} k_reenterPassword{Re-enter your password} k_referenceUrlCode{Reference / URL / Code} k_refresh{Refresh} k_registrationSuccessful{Registration successful!} k_reject{Reject} k_relaxation{Relaxation} k_relaxed{Relaxed} k_remaining{Remaining} k_rememberMe{Remember me} k_reminderAddedFor{Reminder added for} k_reminders{Reminders} k_remove{Remove} k_removeDocumentQuestion{Remove document?} k_removedFromSavedHotelsSuffix{removed from saved hotels} k_replace{Replace} k_replan{Replan} k_resendVerificationEmail{Resend verification email} k_resetPassword{Reset Password} k_restaurantCuisine{Restaurant cuisine} k_restore{Restore} k_retry{Retry} k_returnDateOptional{Return Date (Optional)} k_reviewPlannedRide{Review planned ride} k_rideOptions{Ride options} k_room{Room} k_save{Save} k_saveChanges{Save Changes} k_saveExpense{Save Expense} k_saveFlight{Save flight} k_saveFlightPlan{Save Flight Plan} k_saveReceipt{Save Receipt} k_saveRideToItinerary{Save ride to itinerary} k_saveTask{Save Task} k_saveUnavailable{Save unavailable} k_saved{Saved} k_savedDiscovery{Saved discovery} k_savedFlightDetails{Saved Flight Details} k_savedFlights{Saved Flights} k_savedHotelDetails{Saved Hotel Details} k_savedHotels{Saved Hotels} k_savedItems{Saved Items} k_savedRides{Saved rides} k_savedTransport{Saved transport} k_seafood{Seafood} k_search{Search} k_searchDeleted{Search deleted} k_searchEverything{Search Everything} k_searchFlights{Search Flights} k_searchHotels{Search Hotels} k_searchInApp{Search in app} k_searchPlaceStationVenue{Search a place, station, or venue} k_searchingDemoTravelProviders{Searching demo travel providers...} k_selectBothDates{Please select both dates.} k_selectTrip{Select trip} k_selectedTrip{Selected trip} k_send{Send} k_sendFunds{Send Funds} k_signIn{Sign In} k_signInAddBookings{Sign in to add bookings to a trip.} k_signInAddSavedItems{Sign in to add saved items to trips.} k_signInSaveFlights{Please sign in to save flights.} k_signInViewRecentSearches{Please sign in to view recent searches.} k_signInViewSavedFlights{Please sign in to view saved flights.} k_signOut{Sign out} k_source{Source} k_spent{Spent} k_status{Status} k_stayDetails{Stay Details} k_suggestedPreparation{Suggested preparation} k_suggestedSearch{Suggested search} k_suggestedTime{Suggested time} k_swapLanguages{Swap languages} k_tapAttachFlight{Tap to attach a flight.} k_task{Task} k_tasksRemaining{tasks remaining} k_taxiHub{Taxi Hub} k_textToTranslate{Text to translate} k_ticket{Ticket} k_title{Title} k_titleAndTypeRequired{Title and type are required.} k_titleRequired{Title is required.} k_to{To} k_toIataCode{To (IATA Code)} k_translate{Translate} k_translateCard{Translate Card} k_translateDestination{Translate Destination} k_translationCopied{Translation copied.} k_translator{Translator} k_translatorCardSubtitle{Text, conversation mode and phrasebook.} k_transportHub{Transport Hub} k_travelDiscovery{Travel Discovery} k_travelDocumentsComingNext{Travel documents module coming next.} k_travelTranslator{Travel Translator} k_travelWallet{Travel Wallet} k_travellers{Travellers} k_trip{Trip} k_tripActivities{Trip Activities} k_tripAiAssistantComingNext{Trip AI assistant coming next.} k_tripBudget{Trip Budget} k_tripChangedUpdatePlan{Your trip changed - update your plan?} k_tripContext{Trip context} k_tripContextUnavailableSearch{Trip context unavailable. Enter a location to search.} k_tripCreatedSuccessfully{Trip created successfully.} k_tripDashboard{Trip Dashboard} k_tripDocumentRemoved{Trip document removed.} k_tripDocuments{Trip Documents} k_tripExpenses{Trip Expenses} k_tripForSavedTransportActions{Trip for saved transport and add-to-trip actions} k_tripNotFound{Trip not found} k_tripNotFoundPeriod{Trip not found.} k_tripNotes{Trip Notes} k_tripNotesHint{Add trip notes, ideas, reminders, and links...} k_tripNotesSaved{Trip notes saved.} k_tripOwner{Trip owner} k_tripReadiness{Trip Readiness} k_tryAgain{Try again} k_type{Type} k_typeMessage{Type message...} k_unableCalculateTotals{Unable to calculate totals} k_unableLoadBudget{Unable to load budget} k_unableLoadFlight{Unable to load flight} k_unableLoadHotel{Unable to load hotel} k_unableToOpenMapLink{Unable to open map link.} k_unlink{Unlink} k_upcoming{upcoming} k_update{Update} k_useInRoute{Use in route} k_useSamplePickup{Use sample pickup} k_vegetarian{Vegetarian} k_verificationEmailSentAgain{Verification email sent again.} k_verifyEmail{Verify Email} k_viewDetails{View Details} k_viewRouteOnMap{View route on map} k_viewer{Viewer} k_waitConfirmProvider{Please wait while we confirm with the provider.} k_weather{Weather} k_weatherAwarePlan{Weather-aware plan} k_weatherCurrentlyUnavailable{Weather currently unavailable} k_weatherUnavailable{Weather unavailable.} k_weatherUnavailableNow{Weather is currently unavailable.} k_youExampleEmail{you@example.com} k_yourEmailExample{your@email.com} other{{key}}}'**
  String uiText(String key);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'ar',
        'bg',
        'cs',
        'da',
        'de',
        'el',
        'en',
        'es',
        'fr',
        'it',
        'ja',
        'nl',
        'pl',
        'pt',
        'ro',
        'ru',
        'sv',
        'tr',
        'zh'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'bg':
      return AppLocalizationsBg();
    case 'cs':
      return AppLocalizationsCs();
    case 'da':
      return AppLocalizationsDa();
    case 'de':
      return AppLocalizationsDe();
    case 'el':
      return AppLocalizationsEl();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'nl':
      return AppLocalizationsNl();
    case 'pl':
      return AppLocalizationsPl();
    case 'pt':
      return AppLocalizationsPt();
    case 'ro':
      return AppLocalizationsRo();
    case 'ru':
      return AppLocalizationsRu();
    case 'sv':
      return AppLocalizationsSv();
    case 'tr':
      return AppLocalizationsTr();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}

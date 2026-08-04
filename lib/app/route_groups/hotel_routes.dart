import 'package:go_router/go_router.dart';

import '../../features/hotels/models/hotel.dart';
import '../../features/hotels/models/saved_hotel.dart';
import '../../features/hotels/pages/hotel_details_page.dart';
import '../../features/hotels/screens/hotel_search_page.dart';
import '../../features/hotels/screens/recent_hotel_searches_page.dart';
import '../../features/hotels/screens/saved_hotel_details_page.dart';
import '../../features/hotels/screens/saved_hotels_page.dart';
import '../app_routes.dart';
import '../route_error_page.dart';

List<RouteBase> buildHotelRoutes() {
  return [
    GoRoute(
      name: AppRoute.hotels.routeName,
      path: AppRoute.hotels.path,
      builder: (context, state) => const HotelSearchPage(),
    ),
    GoRoute(
      name: AppRoute.hotelRecent.routeName,
      path: AppRoute.hotelRecent.path,
      builder: (context, state) => const RecentHotelSearchesPage(),
    ),
    GoRoute(
      name: AppRoute.hotelSaved.routeName,
      path: AppRoute.hotelSaved.path,
      builder: (context, state) => const SavedHotelsPage(),
    ),
    GoRoute(
      name: AppRoute.hotelDetails.routeName,
      path: AppRoute.hotelDetails.path,
      builder: (context, state) {
        final extra = state.extra;
        if (extra is! Hotel) {
          return const RouteErrorPage(
            message: 'Hotel details route requires a Hotel extra payload.',
          );
        }
        return HotelDetailsPage(hotel: extra);
      },
    ),
    GoRoute(
      name: AppRoute.savedHotelDetails.routeName,
      path: AppRoute.savedHotelDetails.path,
      builder: (context, state) {
        final extra = state.extra;
        if (extra is! SavedHotel) {
          return const RouteErrorPage(
            message: 'Saved hotel details route requires a SavedHotel extra payload.',
          );
        }
        return SavedHotelDetailsPage(hotel: extra);
      },
    ),
  ];
}

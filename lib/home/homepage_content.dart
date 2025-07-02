import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pitstop/home/bloc/user_bloc.dart';
import 'package:pitstop/home/bloc/user_state.dart';
import 'package:pitstop/data/api/customer/customer_service.dart';

import 'package:pitstop/data/model/booking/booking_model.dart';
import 'package:pitstop/data/model/service/service_model.dart';
import 'package:pitstop/data/model/mechanic/mechanic_model.dart';
import 'package:pitstop/data/model/customer/customer_model.dart';
import 'package:pitstop/utils/profile_utils.dart';
import 'package:intl/intl.dart';
import 'package:pitstop/data/utils/admin_utils.dart';

class HomepageContent extends StatefulWidget {
  final ValueChanged<String>? onSearchSubmitted;
  final VoidCallback? onNavigateToBooking;
  final VoidCallback? onProfileIncomplete;
  final List<BookingModel>? bookings;
  final Map<String, List<ServiceModel>>? servicesByGroup;
  final List<MechanicModel>? mechanics;

  const HomepageContent({
    Key? key,
    this.onSearchSubmitted,
    this.onNavigateToBooking,
    this.onProfileIncomplete,
    this.bookings,
    this.servicesByGroup,
    this.mechanics,
  }) : super(key: key);

  @override
  State<HomepageContent> createState() => _HomepageContentState();
}

class _HomepageContentState extends State<HomepageContent> {
  final AdminUtils _adminUtils = AdminUtils();

  List<BookingModel> _bookingsToday = [];
  List<CustomerModel> _customers = [];
  List<MechanicModel> _mechanics = [];
  Map<String, ServiceModel> _servicesMap = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkProfileCompleteness();
    _fetchDataForToday();
  }

  Future<void> _fetchDataForToday() async {
    setState(() {
      _isLoading = true;
    });

    final userState = context.read<UserBloc>().state;
    String? userId;
    if (userState is UserLoadSuccess) {
      userId = userState.userId;
    }

    try {
      final data = await _adminUtils.fetchDataForToday();

      // Filter bookings for logged-in user only
      final allBookingsTodayDynamic = data['bookingsToday'] as List<dynamic>;
      final allBookingsToday = allBookingsTodayDynamic.cast<BookingModel>();
      final filteredBookingsToday = userId == null
          ? <BookingModel>[]
          : allBookingsToday.where((b) => b.usersId == userId).toList();

      setState(() {
        _bookingsToday = filteredBookingsToday;
        _customers = data['customers'] as List<CustomerModel>;
        _mechanics = data['mechanics'] as List<MechanicModel>;
        _servicesMap = data['servicesMap'] as Map<String, ServiceModel>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching data for today: $e');
    }
  }

  void _checkProfileCompleteness() async {
    final isIncomplete = await checkProfileCompleteness(context);
    if (isIncomplete && mounted) {
      showProfileIncompleteDialog(context, () {
        if (widget.onProfileIncomplete != null) {
          widget.onProfileIncomplete!();
        }
      });
    }
  }

  // Helper method to build a section header (e.g., "Categories" with "View All").
  Widget _buildSectionHeader(BuildContext context, String title, VoidCallback onViewAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black, // Changed to black
          ),
        ),
        TextButton(
          onPressed: onViewAll,
          child: Text(
            'View All',
            style: TextStyle(color: Colors.amber.shade700, fontWeight: FontWeight.w600), // Amber
          ),
        ),
      ],
    );
  }

  // Helper method to build a single category item.
  Widget _buildCategoryItem(BuildContext context, IconData iconData, String label, Color iconBgColor, Color iconColor, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap ?? () {
        print('$label category tapped');
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: iconBgColor,
            child: Icon(iconData, size: 28, color: iconColor),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500), // Changed to black87
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ScrollController _scrollController = ScrollController();
    // Define the colors for consistency.
    final Color primaryTextColor = Colors.black;
    final Color secondaryTextColor = Colors.black87; // Adjusted to a darker grey, close to black
    final Color accentColor = Colors.amber.shade700; // Main accent color (amber)
    final Color lightAmberBg = Colors.amber.shade50; // Light background for category icons

    return Container(
      color: Colors.white, // Ensures the entire background is white
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Header Section ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            BlocBuilder<UserBloc, UserState>(
                              builder: (context, state) {
                                String username = 'User';
                                if (state is UserLoadSuccess) {
                                  username = state.username ?? 'User';
                                }
                                return Text(
                                  'Hello, $username 👋',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: primaryTextColor,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 4),
                            InkWell(
                              onTap: () {
                                // TODO: Implement action when location is tapped
                                print('Location tapped!');
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.location_on_outlined, color: accentColor, size: 16),
                                  const SizedBox(width: 4),
                                  FutureBuilder(
                                    future: () async {
                                      final userState = context.read<UserBloc>().state;
                                      if (userState is UserLoadSuccess) {
                                        final userId = userState.userId;
                                        if (userId != null) {
                                          final customerService = CustomerService();
                                          final customer = await customerService.getCustomerByUserId(userId);
                                          return customer?.address ?? '';
                                        }
                                      }
                                      return '';
                                    }(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return Text('Loading...', style: TextStyle(fontSize: 14, color: secondaryTextColor));
                                      } else if (snapshot.hasError) {
                                        return Text('Error', style: TextStyle(fontSize: 14, color: secondaryTextColor));
                                      } else {
                                        return Text(snapshot.data ?? '', style: TextStyle(fontSize: 14, color: secondaryTextColor));
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // --- Search Bar ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search here',
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      prefixIcon: Icon(Icons.search, color: Colors.black54), // Changed to black54 for softer look
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 20.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide(color: accentColor, width: 1.5), // Amber border when focused
                      ),
                    ),
                    onSubmitted: (value) {
                      if (widget.onSearchSubmitted != null) {
                        widget.onSearchSubmitted!(value);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // --- Special Offer Banner ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    clipBehavior: Clip.antiAlias,
                    elevation: 4,
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        // Placeholder for the background image
                        // If you have an image, replace this Container with Image.asset or NetworkImage
                        Container(
                          height: 160,
                          decoration: BoxDecoration(
                            color: Colors.amber.shade200, // A lighter amber as a placeholder background
                            borderRadius: BorderRadius.circular(16),
                          ),
                          // Example of how to add an image
                          // child: Image.network(
                          //   'YOUR_IMAGE_URL_HERE',
                          //   fit: BoxFit.cover,
                          //   width: double.infinity,
                          // ),
                        ),
                        // Gradient Overlay
                        Container(
                          height: 160,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.black.withOpacity(0.6), Colors.transparent, Colors.transparent],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              stops: const [0.0, 0.7, 1.0],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        // Text and Button Content
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Get special offer',
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Up to 25%',
                                style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () {
                                  // TODO: Implement action when "Explore Now" button is pressed
                                  print('Explore Now banner tapped!');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black, // Button background black
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                                  textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text('Explore Now', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // --- Categories Section ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildSectionHeader(context, "Categories", () {
                    // TODO: Implement navigation to "View All Categories"
                    print('View All Categories tapped');
                  }),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildCategoryItem(
                        context,
                        Icons.settings_outlined,
                        'Booking',
                        lightAmberBg, // Light amber background for icon
                        accentColor, // Amber icon color
                        onTap: () {
                          if (widget.onNavigateToBooking != null) {
                            widget.onNavigateToBooking!();
                          }
                        },
                      ),
                  
                    ],
                  ),
                ),

                // Booking view status code here:

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildSectionHeader(context, "Booking for Today", () {
                    // TODO: Implement navigation to "View All Categories"
                    print('View All Categories tapped');
                  }),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    DateFormat('EEEE, MMM d, yyyy').format(DateTime.now()),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: Colors.black87,
                    ),
                  ),
                ),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SizedBox(
                        height: 250,
                        child: Scrollbar(
                          thumbVisibility: true,
                          radius: const Radius.circular(8),
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            children: [
                              FutureBuilder<Map<String, List<ServiceModel>>>(
                                future: _adminUtils.fetchServicesForBookings(_bookingsToday, _servicesMap),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const Center(child: CircularProgressIndicator());
                                  } else if (snapshot.hasError) {
                                    return Center(
                                      child: Text(
                                        'Error: ${snapshot.error}',
                                        style: const TextStyle(color: Colors.red),
                                      ),
                                    );
                                  } else {
                                    final servicesByBookingId = snapshot.data ?? {};
                                    return _adminUtils.buildGroupedBookingListForDate(
                                      _bookingsToday,
                                      _customers,
                                      _mechanics,
                                      _servicesMap,
                                      servicesByBookingId,
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
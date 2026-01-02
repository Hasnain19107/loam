import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';

import '../../../core/widgets/loam_card.dart';
import '../../../data/models/event_model.dart';
import '../../../data/network/remote/firebase_service.dart';
import '../../auth/controller/auth_controller.dart';

class MyEventsPage extends StatefulWidget {
  const MyEventsPage({super.key});

  @override
  State<MyEventsPage> createState() => _MyEventsPageState();
}

class _MyEventsPageState extends State<MyEventsPage>
    with SingleTickerProviderStateMixin {
  final _authController = Get.find<AuthController>();
  final _firebaseService = FirebaseService();

  List<EventModel> _approvedEvents = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadMyEvents();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMyEvents() async {
    if (_authController.user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final events = await _firebaseService.getUserEvents(
        _authController.user!.uid,
      );
      setState(() {
        _approvedEvents = events;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading events: $e');
      setState(() => _isLoading = false);
    }
  }

  List<EventModel> get _upcomingEvents {
    final now = DateTime.now();
    return _approvedEvents.where((event) {
      final eventEnd = event.endDate ?? event.startDate;
      return !eventEnd.isBefore(now);
    }).toList();
  }

  List<EventModel> get _pastEvents {
    final now = DateTime.now();
    return _approvedEvents.where((event) {
      final eventEnd = event.endDate ?? event.startDate;
      return eventEnd.isBefore(now);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              child: Text(
                'My Events',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Tabs Container
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _isLoading
                    ? Center(
                        child: Text(
                          'Loading...',
                          style: TextStyle(color: AppColors.mutedForeground),
                        ),
                      )
                    : Column(
                        children: [
                          // Tabs
                          Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.all(4),
                            child: TabBar(
                              controller: _tabController,
                              labelColor: AppColors.foreground,
                              unselectedLabelColor: AppColors.mutedForeground,
                              indicator: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              indicatorSize: TabBarIndicatorSize.tab,
                              dividerColor: Colors.transparent,
                              labelStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              unselectedLabelStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              tabs: const [
                                Tab(text: 'Upcoming'),
                                Tab(text: 'Past'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Content
                          Expanded(
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                _buildEventsList(_upcomingEvents, 'upcoming'),
                                _buildEventsList(_pastEvents, 'past'),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsList(List<EventModel> events, String type) {
    if (events.isEmpty) {
      return _buildEmptyState(type);
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        final isPast = type == 'past';
        return Padding(
          padding: EdgeInsets.only(bottom: index < events.length - 1 ? 16 : 0),
          child: _EventCard(
            event: event,
            isPast: isPast,
            onTap: () => Get.toNamed(
              AppRoutes.eventDetail.replaceAll(':id', event.id),
              parameters: {'source': 'my-gatherings'},
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String type) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.calendar_today,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No ${type} events',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              type == 'upcoming'
                  ? "You don't have any upcoming events yet."
                  : "You don't have any past events yet.",
              style: TextStyle(color: AppColors.mutedForeground),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final EventModel event;
  final bool isPast;
  final VoidCallback onTap;

  const _EventCard({
    required this.event,
    required this.isPast,
    required this.onTap,
  });

  String _formatDate(DateTime date) {
    return DateFormat('EEE, MMM d').format(date);
  }

  String _formatTime(DateTime date) {
    return DateFormat('h:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isPast ? 0.6 : 1.0,
      child: LoamCard(
        padding: const EdgeInsets.all(16),
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          event.name,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isPast
                              ? AppColors.muted
                              : Colors.green.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isPast ? 'Past' : 'Confirmed',
                          style: TextStyle(
                            fontSize: 12,
                            color: isPast
                                ? AppColors.mutedForeground
                                : Colors.green.shade800,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(event.startDate),
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.mutedForeground,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatTime(event.startDate),
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                  if (event.location != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location!,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.mutedForeground,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.chevron_right,
              color: AppColors.mutedForeground,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/user_profile_model.dart';
import '../../../data/models/event_model.dart';
import '../../../data/network/remote/firebase_service.dart';

class EventParticipantsPage extends StatefulWidget {
  const EventParticipantsPage({super.key});

  @override
  State<EventParticipantsPage> createState() => _EventParticipantsPageState();
}

class _EventParticipantsPageState extends State<EventParticipantsPage> {
  final _firebaseService = FirebaseService();
  String get _eventId => Get.parameters['id'] ?? Get.arguments as String? ?? '';

  EventModel? _event;
  List<UserProfileModel> _participants = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (_eventId.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final event = await _firebaseService.getEvent(_eventId);
      final participants = await _firebaseService.getEventParticipants(_eventId);

      setState(() {
        _event = event;
        _participants = participants;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading participants: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Who's going"),
            if (_event != null)
              Text(
                _event!.name,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.mutedForeground,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _participants.isEmpty
              ? Center(
                  child: Text(
                    'No participants yet',
                    style: TextStyle(color: AppColors.mutedForeground),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _participants.length,
                  itemBuilder: (context, index) {
                    final participant = _participants[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.popover,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              shape: BoxShape.circle,
                            ),
                            child: participant.photo != null
                                ? ClipOval(
                                    child: Image.network(
                                      participant.photo!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Center(
                                    child: Text(
                                      participant.firstName
                                              ?.substring(0, 1)
                                              .toUpperCase() ??
                                          '?',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            participant.firstName ?? 'Guest',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}

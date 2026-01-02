import 'models/event_model.dart';



/// Mock events data matching the React version
/// These events can be used for development and testing
List<EventModel> get mockEvents {
  final now = DateTime.now();
  
  return [
    // Event 1: Coffee & Conversations - Sat, Jan 18, 10:00 AM
    EventModel(
      id: '1',
      name: 'Coffee & Conversations',
      description: 'Join us for a warm morning of meaningful conversations over freshly brewed coffee. This intimate gathering brings together 6-8 people who share a love for deep discussions and genuine connection. We\'ll explore topics ranging from faith and purpose to everyday joys and challenges.',
      coverImageUrl: '/events/coffee.jpg',
      location: 'The Good Cup, Marina Bay',
      startDate: DateTime(now.year, 1, 18, 10, 0),
      capacity: 8,
      isUnlimitedCapacity: false,
      requiresApproval: false,
      showParticipants: true,
      visibility: 'public',
      status: 'published',
      createdAt: DateTime(now.year, 1, 1),
      updatedAt: DateTime(now.year, 1, 1),
    ),
    
    // Event 2: Sunset Walk & Prayer - Sun, Jan 19, 6:00 PM
    EventModel(
      id: '2',
      name: 'Sunset Walk & Prayer',
      description: 'Experience the beauty of golden hour as we walk along the waterfront together. This peaceful evening combines gentle exercise with moments of reflection and prayer. Perfect for those seeking both physical activity and spiritual nourishment.',
      coverImageUrl: '/events/sunset.jpg',
      location: 'East Coast Park',
      startDate: DateTime(now.year, 1, 19, 18, 0),
      capacity: 10,
      isUnlimitedCapacity: false,
      requiresApproval: false,
      showParticipants: true,
      visibility: 'public',
      status: 'published',
      createdAt: DateTime(now.year, 1, 1),
      updatedAt: DateTime(now.year, 1, 1),
    ),
    
    // Event 3: Dinner Fellowship - Fri, Jan 24, 7:30 PM
    EventModel(
      id: '3',
      name: 'Dinner Fellowship',
      description: 'A carefully curated dinner experience at one of Singapore\'s finest restaurants. Break bread with fellow believers in an atmosphere of warmth and hospitality. The evening includes guided conversation starters to help foster meaningful connections.',
      coverImageUrl: '/events/dinner.jpg',
      location: 'Botanico, Singapore Botanic Gardens',
      startDate: DateTime(now.year, 1, 24, 19, 30),
      capacity: 8,
      isUnlimitedCapacity: false,
      requiresApproval: false,
      showParticipants: true,
      visibility: 'public',
      status: 'published',
      createdAt: DateTime(now.year, 1, 1),
      updatedAt: DateTime(now.year, 1, 1),
    ),
    
    // Event 4: Book Club: Sacred Rhythms - Sat, Feb 1, 3:00 PM
    EventModel(
      id: '4',
      name: 'Book Club: Sacred Rhythms',
      description: 'Dive deep into Ruth Haley Barton\'s "Sacred Rhythms" with a group of curious minds. Whether you\'ve read it before or this is your first time, come ready to share insights and learn from others\' perspectives.',
      coverImageUrl: '/events/book.jpg',
      location: 'City Hall Library',
      startDate: DateTime(now.year, 2, 1, 15, 0),
      capacity: 15,
      isUnlimitedCapacity: false,
      requiresApproval: false,
      showParticipants: true,
      visibility: 'public',
      status: 'published',
      createdAt: DateTime(now.year, 1, 1),
      updatedAt: DateTime(now.year, 1, 1),
    ),
    
    // Event 5: Worship Night - Sat, Feb 8, 8:00 PM
    EventModel(
      id: '5',
      name: 'Worship Night',
      description: 'An evening of heartfelt worship in an intimate setting. Bring your voice, your heart, and an openness to encounter God\'s presence with others. All are welcome, regardless of musical ability.',
      coverImageUrl: '/events/worship.jpg',
      location: 'Hope Community Center',
      startDate: DateTime(now.year, 2, 8, 20, 0),
      capacity: 20,
      isUnlimitedCapacity: false,
      requiresApproval: false,
      showParticipants: true,
      visibility: 'public',
      status: 'published',
      createdAt: DateTime(now.year, 1, 1),
      updatedAt: DateTime(now.year, 1, 1),
    ),
    
    // Event 6: Hiking & Devotions - Sun, Feb 16, 7:00 AM (Past event)
    EventModel(
      id: '6',
      name: 'Hiking & Devotions',
      description: 'Start your Sunday with an invigorating hike through MacRitchie Reservoir. We\'ll pause at scenic points for short devotionals and prayer, combining the beauty of nature with spiritual reflection.',
      coverImageUrl: '/events/hike.jpg',
      location: 'MacRitchie Reservoir Park',
      startDate: DateTime(now.year - 1, 2, 16, 7, 0), // Set to past year to make it a past event
      capacity: 12,
      isUnlimitedCapacity: false,
      requiresApproval: false,
      showParticipants: true,
      visibility: 'public',
      status: 'past',
      createdAt: DateTime(now.year - 1, 1, 1),
      updatedAt: DateTime(now.year - 1, 2, 16),
    ),
  ];
}


class AppConstants {
  // App Info
  static const String appName = 'Loam';
  static const String appTagline = 'Genuine People, In Real Life';
  static const String appDescription =
      'Curated experiences for Christians to connect through meaningful events. Meet genuine people in your city.';

  // Age Restriction
  static const int minimumAge = 21;

  // Default Values
  static const String defaultCity = 'Singapore';
  static const String defaultLanguage = 'English';
  static const String defaultCountryCode = '+65';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String profilesCollection = 'profiles';
  static const String eventsCollection = 'events';
  static const String eventParticipantsCollection = 'event_participants';
  static const String surveysCollection = 'surveys';
  static const String surveyQuestionsCollection = 'survey_questions';
  static const String surveyResponsesCollection = 'survey_responses';
  static const String matchmakerSetsCollection = 'matchmaker_sets';
  static const String matchmakerQuestionsCollection = 'matchmaker_questions';
  static const String matchmakerSessionsCollection = 'matchmaker_sessions';
  static const String matchmakerAnswersCollection = 'matchmaker_answers';
  static const String matchesCollection = 'matches';
  static const String userRolesCollection = 'user_roles';
  static const String appSettingsCollection = 'app_settings';
  static const String adminInvitesCollection = 'admin_invites';
  static const String eventReportsCollection = 'event_reports';

  // Storage Paths
  static const String avatarsStoragePath = 'avatars';
  static const String eventImagesStoragePath = 'events';

  // Routes
  static const String routeLanding = '/';
  static const String routeQuiz = '/quiz';
  static const String routeAuthChoice = '/auth-choice';
  static const String routeLogin = '/login';
  static const String routeSignup = '/signup';
  static const String routeOnboarding = '/onboarding';
  static const String routeHome = '/home';
  static const String routeChat = '/chat';
  static const String routeMyEvents = '/my-events';
  static const String routeProfile = '/profile';
  static const String routeEditProfile = '/edit-profile';
  static const String routeEventDetail = '/event/:id';
  static const String routeEventParticipants = '/event/:id/participants';
  static const String routeMatchmake = '/matchmake';
  static const String routeMatchmakeChat = '/matchmake/chat';
  static const String routeSettingsNotifications = '/settings/notifications';
  static const String routeSettingsLanguage = '/settings/language';
  static const String routeSettingsCity = '/settings/city';
  static const String routeBlocked = '/blocked';
  static const String routeNotFound = '/not-found';

  // Admin Routes
  static const String routeAdminLogin = '/admin/login';
  static const String routeAdminDashboard = '/admin';
  static const String routeAdminUsers = '/admin/users';
  static const String routeAdminEvents = '/admin/events';
  static const String routeAdminEventCreate = '/admin/events/new';
  static const String routeAdminEventDetail = '/admin/events/:id';
  static const String routeAdminEventEdit = '/admin/events/:id/edit';
  static const String routeAdminRequests = '/admin/requests';
  static const String routeAdminEventRequests = '/admin/events/:id/requests';
  static const String routeAdminSettings = '/admin/settings';
  static const String routeAdminQuizBuilder = '/admin/quiz-builder';
  static const String routeAdminQuizQuestions = '/admin/quiz-builder/:quizId';
  static const String routeAdminQuizResponses = '/admin/quiz-responses';
  static const String routeAdminMatchmakerBuilder = '/admin/matchmaker-builder';
  static const String routeAdminMatchmakerQuestions = '/admin/matchmaker-builder/:setId';
  static const String routeAdminMatchmakerResponses = '/admin/matchmaker-responses';
  static const String routeAdminMatchmaking = '/admin/matchmaking';
  static const String routeAdminMatchmakingDetail = '/admin/matchmaking/:userId';

  // User Roles
  static const String roleSuperAdmin = 'super_admin';
  static const String roleEventHost = 'event_host';
  static const String roleUser = 'user';

  // Event Status
  static const String eventStatusDraft = 'draft';
  static const String eventStatusPublished = 'published';
  static const String eventStatusPast = 'past';

  // Event Visibility
  static const String eventVisibilityPublic = 'public';
  static const String eventVisibilityHidden = 'hidden';

  // Participation Status
  static const String participationStatusPending = 'pending';
  static const String participationStatusApproved = 'approved';
  static const String participationStatusRejected = 'rejected';

  // Match Status
  static const String matchStatusActive = 'active';
  static const String matchStatusInactive = 'inactive';

  // Survey/Matchmaker Status
  static const String statusActive = 'active';
  static const String statusInactive = 'inactive';

  // Session Status
  static const String sessionStatusInProgress = 'in_progress';
  static const String sessionStatusSubmitted = 'submitted';
  static const String sessionStatusCompleted = 'completed';

  // Question Types
  static const String questionTypeMultipleChoice = 'multiple_choice';
  static const String questionTypeScale = 'scale_1_10';
  static const String questionTypeFreeText = 'free_text';

  // Animation Durations
  static const Duration animationDurationFast = Duration(milliseconds: 200);
  static const Duration animationDurationNormal = Duration(milliseconds: 300);
  static const Duration animationDurationSlow = Duration(milliseconds: 500);

  // OTP
  static const int otpLength = 6;
  static const int otpResendCooldownSeconds = 30;
}


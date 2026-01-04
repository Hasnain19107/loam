class AppRoutes {
  // Public Routes
  static const String landing = '/';
  static const String quiz = '/quiz';
  static const String authChoice = '/auth-choice';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String onboarding = '/onboarding';

  // Protected Routes
  static const String main = '/main';
  static const String home = '/home';
  static const String chat = '/chat';
  static const String myEvents = '/my-events';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String eventDetail = '/event/:id';
  static const String eventParticipants = '/event/:id/participants';
  static const String matchmake = '/matchmake';
  static const String matchmakeChat = '/matchmake/chat';
  static const String settingsNotifications = '/settings/notifications';
  static const String settingsLanguage = '/settings/language';
  static const String settingsCity = '/settings/city';
  static const String blocked = '/blocked';

  // Admin Routes
  static const String adminLogin = '/admin/login';
  static const String adminDashboard = '/admin';
  static const String adminUsers = '/admin/users';
  static const String adminEvents = '/admin/events';
  static const String adminEventCreate = '/admin/events/new';
  static const String adminEventDetail = '/admin/events/:id';
  static const String adminEventEdit = '/admin/events/:id/edit';
  static const String adminRequests = '/admin/requests';
  static const String adminEventRequests = '/admin/events/:id/requests';
  static const String adminSettings = '/admin/settings';
  static const String adminQuizBuilder = '/admin/quiz-builder';
  static const String adminQuizQuestions = '/admin/quiz-builder/:quizId';
  static const String adminQuizResponses = '/admin/quiz-responses';
  static const String adminMatchmakerBuilder = '/admin/matchmaker-builder';
  static const String adminMatchmakerQuestions =
      '/admin/matchmaker-builder/:setId';
  static const String adminMatchmakerResponses = '/admin/matchmaker-responses';
  static const String adminMatchmaking = '/admin/matchmaking';
  static const String adminMatchmakingDetail = '/admin/matchmaking/:userId';

  // Fallback
  static const String notFound = '/not-found';
}

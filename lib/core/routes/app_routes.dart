class AppRoutes {
  // Public Routes
  static const String landing = '/';
  static const String quiz = '/quiz';
  static const String authChoice = '/auth-choice';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String emailVerification = '/email-verification';
  static const String forgotPassword = '/forgot-password';
  static const String accessCode = '/access-code';
  static const String onboarding = '/onboarding';
  static const String terms = '/terms';
  static const String privacy = '/privacy';
  static const String communityGuidelines = '/community-guidelines';
  static const String communityAgreement = '/community-agreement';

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

  // Fallback
  static const String notFound = '/not-found';
}

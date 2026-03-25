import 'package:get/get.dart';
import 'package:loam/features/user/chat/controller/chat_controller.dart';
import 'package:loam/features/user/chat/view/chat_page.dart';
import '../../features/auth/view/landing_page.dart';
import '../../features/user/bottom_navigation/view/main_navigation.dart';
import '../../features/user/bottom_navigation/controller/main_navigation_controller.dart';
import '../../features/auth/view/signup/quiz_page.dart';
import '../../features/auth/view/signup/auth_choice_page.dart';
import '../../features/auth/view/login_page.dart';
import '../../features/auth/view/forgot_password_page.dart';
import '../../features/auth/view/signup/signup_page.dart';
import '../../features/auth/view/email_verification_page.dart';
import '../../features/auth/view/signup/profile_setup_page.dart';
import '../../features/auth/view/signup/access_code_page.dart';
import '../../features/auth/view/legal_document_page.dart';
import '../../features/auth/view/community_agreement_page.dart';
import '../../features/user/home/view/home_page.dart';
import '../../features/user/home/controller/home_controller.dart';
import '../../features/user/events/view/my_events_page.dart';
import '../../features/user/profile/view/profile_page.dart';
import '../../features/user/profile/controller/profile_controller.dart';
import '../../features/user/profile/view/edit_profile_page.dart';
import '../../features/user/events/view/event_detail_page.dart';
import '../../features/user/events/controller/event_detail_controller.dart';
import '../../features/user/events/view/event_participants_page.dart';
import '../../features/user/events/controller/events_controller.dart';
import '../../features/user/matchmake/view/matchmake_page.dart';
import '../../features/user/matchmake/controller/matchmake_controller.dart';
import '../../features/user/matchmake/view/matchmake_chat_page.dart';
import '../../features/user/settings/view/notification_settings_page.dart';
import '../../features/user/settings/controller/settings_controller.dart';
import '../../features/user/settings/view/language_settings_page.dart';
import '../../features/user/settings/view/city_settings_page.dart';
import '../../features/auth/view/blocked_screen_page.dart';
import '../../features/user/common/view/not_found_page.dart';

import 'app_routes.dart';

class AppPages {
  static const initial = AppRoutes.landing;

  static final routes = [
    // Public Routes
    GetPage(name: AppRoutes.landing, page: () => const LandingPage()),
    GetPage(name: AppRoutes.quiz, page: () => const QuizPage()),
    GetPage(name: AppRoutes.authChoice, page: () => const AuthChoicePage()),
    GetPage(name: AppRoutes.login, page: () => const LoginPage()),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordPage(),
    ),
    GetPage(name: AppRoutes.signup, page: () => const SignupPage()),
    GetPage(
      name: AppRoutes.emailVerification,
      page: () => const EmailVerificationPage(),
    ),
    GetPage(name: AppRoutes.accessCode, page: () => const AccessCodePage()),
    GetPage(name: AppRoutes.onboarding, page: () => const ProfileSetupPage()),
    GetPage(
      name: AppRoutes.terms,
      page: () => const LegalDocumentPage(type: 'terms'),
    ),
    GetPage(
      name: AppRoutes.privacy,
      page: () => const LegalDocumentPage(type: 'privacy'),
    ),
    GetPage(
      name: AppRoutes.communityGuidelines,
      page: () => const LegalDocumentPage(type: 'guidelines'),
    ),
    GetPage(
      name: AppRoutes.communityAgreement,
      page: () => const CommunityAgreementPage(),
    ),

    // Protected Routes
    GetPage(
      name: AppRoutes.main,
      page: () => const MainNavigationScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<MainNavigationController>(() => MainNavigationController());
        Get.lazyPut<HomeController>(() => HomeController());
        Get.lazyPut<EventsController>(() => EventsController());
        Get.lazyPut<MatchmakeController>(() => MatchmakeController());
        Get.lazyPut<ChatController>(() => ChatController());
        Get.lazyPut<ProfileController>(() => ProfileController());
      }),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomePage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<HomeController>(() => HomeController());
      }),
    ),
    GetPage(
      name: AppRoutes.chat,
      page: () => const ChatPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ChatController>(() => ChatController());
      }),
    ),
    GetPage(
      name: AppRoutes.myEvents,
      page: () => const MyEventsPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<EventsController>(() => EventsController());
      }),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfilePage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ProfileController>(() => ProfileController());
      }),
    ),
    GetPage(
      name: AppRoutes.editProfile,
      page: () => const EditProfilePage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ProfileController>(() => ProfileController());
      }),
    ),
    GetPage(
      name: AppRoutes.eventDetail,
      page: () => const EventDetailPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<EventDetailController>(() => EventDetailController());
      }),
    ),
    GetPage(
      name: AppRoutes.eventParticipants,
      page: () => const EventParticipantsPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<EventsController>(() => EventsController());
      }),
    ),
    GetPage(
      name: AppRoutes.matchmake,
      page: () => const MatchmakePage(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<MatchmakeController>()) {
          Get.put(MatchmakeController());
        }
      }),
    ),
    GetPage(
      name: AppRoutes.matchmakeChat,
      page: () => const MatchmakeChatPage(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<MatchmakeController>()) {
          Get.put(MatchmakeController());
        }
      }),
    ),
    GetPage(
      name: AppRoutes.settingsNotifications,
      page: () => const NotificationSettingsPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SettingsController>(() => SettingsController());
      }),
    ),
    GetPage(
      name: AppRoutes.settingsLanguage,
      page: () => const LanguageSettingsPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SettingsController>(() => SettingsController());
      }),
    ),
    GetPage(
      name: AppRoutes.settingsCity,
      page: () => const CitySettingsPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SettingsController>(() => SettingsController());
      }),
    ),
    GetPage(name: AppRoutes.blocked, page: () => const BlockedScreenPage()),

    // Fallback
    GetPage(name: AppRoutes.notFound, page: () => const NotFoundPage()),
  ];
}

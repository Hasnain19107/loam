import 'package:get/get.dart';
import '../../auth/controller/auth_controller.dart';
import '../../events/controller/events_controller.dart';

class HomeController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  final EventsController _eventsController = Get.put(EventsController());

  // Getters
  AuthController get authController => _authController;
  EventsController get eventsController => _eventsController;

  String get greeting {
    final firstName = _authController.userProfile?.firstName?.trim() ?? 'there';
    return firstName != 'there' ? 'Hey $firstName' : 'Hey there';
  }

  @override
  void onInit() {
    super.onInit();
    _eventsController.loadEvents();
  }
}


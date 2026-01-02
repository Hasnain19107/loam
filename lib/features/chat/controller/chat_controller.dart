import 'package:get/get.dart';
import '../../auth/controller/auth_controller.dart';

class ChatController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();

  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  String? get error => _error.value.isEmpty ? null : _error.value;

  @override
  void onInit() {
    super.onInit();
    // Initialize chat functionality
  }

  // Placeholder for future chat implementation
  Future<void> loadChats() async {
    // TODO: Implement chat loading
  }
}


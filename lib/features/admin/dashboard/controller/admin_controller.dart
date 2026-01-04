import 'package:get/get.dart';
import '../../../../data/network/remote/firebase_service.dart';
import '../../../auth/controller/auth_controller.dart';

class AdminController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();
  final AuthController _authController = Get.find<AuthController>();

  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;

  // Dashboard stats
  final RxInt _totalUsers = 0.obs;
  final RxInt _activeUsers = 0.obs;
  final RxInt _upcomingEvents = 0.obs;
  final RxInt _pendingApprovals = 0.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  String? get error => _error.value.isEmpty ? null : _error.value;
  int get totalUsers => _totalUsers.value;
  int get activeUsers => _activeUsers.value;
  int get upcomingEvents => _upcomingEvents.value;
  int get pendingApprovals => _pendingApprovals.value;

  @override
  void onInit() {
    super.onInit();
    // Assuming if this controller is active, the user is authorized
    loadDashboardStats();
  }

  Future<void> loadDashboardStats() async {
    try {
      _isLoading.value = true;
      _error.value = '';

      _totalUsers.value = await _firebaseService.getTotalUsersCount();
      _activeUsers.value = await _firebaseService.getActiveUsersCount();
      _upcomingEvents.value = await _firebaseService.getUpcomingEventsCount();
      _pendingApprovals.value = await _firebaseService
          .getPendingApprovalsCount();

      _isLoading.value = false;
    } catch (e) {
      _error.value = e.toString();
      _isLoading.value = false;
    }
  }
}

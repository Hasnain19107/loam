import 'package:get/get.dart';
import '../../../../data/network/remote/firebase_service.dart';
import '../../../../data/models/user_profile_model.dart';

class AdminUsersController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();

  final RxBool _isLoading = false.obs;
  final RxList<UserProfileModel> _users = <UserProfileModel>[].obs;
  final RxString _searchQuery = ''.obs;

  bool get isLoading => _isLoading.value;
  List<UserProfileModel> get users => _users;
  String get searchQuery => _searchQuery.value;

  List<UserProfileModel> get filteredUsers {
    if (_searchQuery.value.isEmpty) {
      return _users;
    }
    final query = _searchQuery.value.toLowerCase();
    return _users.where((user) {
      return user.firstName?.toLowerCase().contains(query) == true ||
          user.email?.toLowerCase().contains(query) == true ||
          user.phone?.contains(query) == true;
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadUsers();
  }

  Future<void> loadUsers() async {
    try {
      _isLoading.value = true;
      final usersList = await _firebaseService.getAllUsers();
      _users.value = usersList;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load users: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  void setSearchQuery(String query) {
    _searchQuery.value = query;
  }

  Future<void> toggleShadowBlock(String userId, bool currentStatus) async {
    try {
      await _firebaseService.updateUserShadowBlock(userId, !currentStatus);
      final index = _users.indexWhere((u) => u.id == userId);
      if (index != -1) {
        _users[index] = _users[index].copyWith(isShadowBlocked: !currentStatus);
      }
      Get.snackbar(
        'Success',
        currentStatus ? 'User unblocked' : 'User shadow blocked',
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to update user: ${e.toString()}');
    }
  }

  Future<void> updateAdminNotes(String userId, String notes) async {
    try {
      await _firebaseService.updateUserAdminNotes(userId, notes);
      final index = _users.indexWhere((u) => u.id == userId);
      if (index != -1) {
        _users[index] = _users[index].copyWith(adminNotes: notes);
      }
      Get.snackbar('Success', 'Notes saved');
    } catch (e) {
      Get.snackbar('Error', 'Failed to save notes: ${e.toString()}');
    }
  }
}

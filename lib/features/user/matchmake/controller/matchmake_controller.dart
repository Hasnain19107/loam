import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../data/network/remote/firebase_service.dart';
import '../../../../data/models/user_profile_model.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../auth/controller/auth_controller.dart';

enum MatchmakeState { notStarted, submitted, matched }

class MatchmakeQuestion {
  final String id;
  final String questionText;
  final String questionType;
  final List<String>? options;
  final String? scaleLabelLow;
  final String? scaleLabelHigh;
  final int displayOrder;

  MatchmakeQuestion({
    required this.id,
    required this.questionText,
    required this.questionType,
    this.options,
    this.scaleLabelLow,
    this.scaleLabelHigh,
    required this.displayOrder,
  });

  factory MatchmakeQuestion.fromJson(Map<String, dynamic> json) {
    List<String>? parsedOptions;

    if (json['options'] != null) {
      if (json['options'] is List) {
        parsedOptions = List<String>.from(json['options']);
      } else if (json['options'] is String) {
        parsedOptions = List<String>.from(
          (jsonDecode(json['options']) as List).map((e) => e.toString()),
        );
      }
    }

    return MatchmakeQuestion(
      id: json['id'],
      questionText: json['question_text'],
      questionType: json['question_type'],
      options: parsedOptions,
      scaleLabelLow: json['scale_label_low'],
      scaleLabelHigh: json['scale_label_high'],
      displayOrder: json['display_order'] ?? 0,
    );
  }
}

class MatchmakeAnswer {
  final String questionId;
  final String value;

  MatchmakeAnswer({required this.questionId, required this.value});
}

class MatchmakeController extends GetxController {
  final _firebaseService = FirebaseService();
  final _authController = Get.find<AuthController>();
  final _firestore = FirebaseFirestore.instance;

  final _isLoading = false.obs;
  final _error = ''.obs;
  final _state = MatchmakeState.notStarted.obs;
  final _matchedUser = Rx<UserProfileModel?>(null);

  final _questions = <MatchmakeQuestion>[].obs;
  final _answers = <MatchmakeAnswer>[].obs;
  final _currentQuestionIndex = 0.obs;

  final _sessionId = RxnString();
  final _setId = RxnString();
  final _isCompleted = false.obs;
  final _freeTextInput = ''.obs;

  bool _chatInitialized = false;

  late final ScrollController scrollController;
  late final TextEditingController textEditingController;

  // ===== GETTERS =====
  bool get isLoading => _isLoading.value;
  String? get error => _error.value.isEmpty ? null : _error.value;
  MatchmakeState get state => _state.value;
  UserProfileModel? get matchedUser => _matchedUser.value;

  List<MatchmakeQuestion> get questions => _questions.toList();
  List<MatchmakeAnswer> get answers => _answers.toList();

  int get currentQuestionIndex => _currentQuestionIndex.value;
  bool get isCompleted => _isCompleted.value;
  String get freeTextInput => _freeTextInput.value;
  String? get sessionId => _sessionId.value;

  MatchmakeQuestion? get currentQuestion {
    if (_questions.isEmpty ||
        _currentQuestionIndex.value >= _questions.length) {
      return null;
    }
    return _questions[_currentQuestionIndex.value];
  }

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController();
    textEditingController = TextEditingController();

    textEditingController.addListener(() {
      _freeTextInput.value = textEditingController.text;
    });

    checkMatchmakeStatus();
  }

  @override
  void onClose() {
    scrollController.dispose();
    textEditingController.dispose();
    super.onClose();
  }

  // ===== MATCH STATUS =====
  Future<void> checkMatchmakeStatus() async {
    final user = _authController.user;
    if (user == null) return;

    try {
      _isLoading.value = true;

      // Check match as user_1
      final match1 = await _firestore
          .collection(AppConstants.matchesCollection)
          .where('status', isEqualTo: AppConstants.matchStatusActive)
          .where('user_1_id', isEqualTo: user.uid)
          .limit(1)
          .get();

      // Check match as user_2
      final match2 = await _firestore
          .collection(AppConstants.matchesCollection)
          .where('status', isEqualTo: AppConstants.matchStatusActive)
          .where('user_2_id', isEqualTo: user.uid)
          .limit(1)
          .get();

      final doc = match1.docs.isNotEmpty
          ? match1.docs.first
          : match2.docs.firstOrNull;

      if (doc != null) {
        final data = doc.data();
        final otherUserId = data['user_1_id'] == user.uid
            ? data['user_2_id']
            : data['user_1_id'];

        final profile = await _firebaseService.getUserProfile(otherUserId);
        if (profile != null) {
          _matchedUser.value = profile;
          _state.value = MatchmakeState.matched;
          return;
        }
      }

      _state.value = MatchmakeState.notStarted;
    } catch (e) {
      _error.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  // ===== CHAT INIT =====
  // ===== CHAT INIT =====
  Future<void> initializeChat() async {
    // Ensure we don't re-initialize unnecessarily
    if (_chatInitialized) return;
    _chatInitialized = true;

    _isLoading.value = true;

    try {
      // Simulate network delay for better UX
      await Future.delayed(const Duration(milliseconds: 500));

      bool hasBackendData = false;

      // Try to load from backend if user is logged in
      if (_authController.user != null) {
        try {
          final setSnap = await _firestore
              .collection(AppConstants.matchmakerSetsCollection)
              .where('status', isEqualTo: AppConstants.statusActive)
              .limit(1)
              .get();

          if (setSnap.docs.isNotEmpty) {
            final setDoc = setSnap.docs.first;
            _setId.value = setDoc.id;

            final questionsSnap = await _firestore
                .collection(AppConstants.matchmakerQuestionsCollection)
                .where('set_id', isEqualTo: setDoc.id)
                .where('is_active', isEqualTo: true)
                .orderBy('display_order')
                .get();

            if (questionsSnap.docs.isNotEmpty) {
              _questions.assignAll(
                questionsSnap.docs.map((d) {
                  return MatchmakeQuestion.fromJson({'id': d.id, ...d.data()});
                }),
              );
              hasBackendData = true;
              await _loadSession(setDoc.id);
            }
          }
        } catch (e) {
          print('Error fetching matchmaker data: $e');
        }
      }

      // Always fallback to mock data if no backend data found (or user not logged in)
      if (!hasBackendData) {
        _loadMockData();
      }
    } finally {
      _isLoading.value = false;
      // Ensure we scroll to bottom after layout
      WidgetsBinding.instance.addPostFrameCallback((_) => scrollToBottom());
    }
  }

  Future<void> _loadSession(String setId) async {
    final userId = _authController.user!.uid;
    final sessionSnap = await _firestore
        .collection(AppConstants.matchmakerSessionsCollection)
        .where('user_id', isEqualTo: userId)
        .where('set_id', isEqualTo: setId)
        .limit(1)
        .get();

    if (sessionSnap.docs.isEmpty) {
      final session = await _firestore
          .collection(AppConstants.matchmakerSessionsCollection)
          .add({
            'user_id': userId,
            'set_id': setId,
            'status': 'in_progress',
            'created_at': FieldValue.serverTimestamp(),
          });
      _sessionId.value = session.id;
    } else {
      _sessionId.value = sessionSnap.docs.first.id;
      // TODO: Load existing answers
    }
  }

  void _loadMockData() {
    _questions.assignAll([
      MatchmakeQuestion(
        id: '1',
        questionText: 'What type of gatherings do you prefer?',
        questionType: 'multiple_choice',
        options: [
          'Small & Intimate',
          'Large & Social',
          'Professional',
          'Casual',
        ],
        displayOrder: 1,
      ),
      MatchmakeQuestion(
        id: '2',
        questionText: 'How would you describe your social battery?',
        questionType: 'scale',
        scaleLabelLow: 'Low',
        scaleLabelHigh: 'High',
        displayOrder: 2,
      ),
      MatchmakeQuestion(
        id: '3',
        questionText: 'What are you looking for in a community?',
        questionType: 'free_text',
        displayOrder: 3,
      ),
    ]);
    _sessionId.value = 'mock_session';
  }

  // ===== ANSWERS =====
  Future<void> handleAnswer(String value) async {
    final q = currentQuestion;
    if (q == null) return;

    _answers.add(MatchmakeAnswer(questionId: q.id, value: value));

    await _firestore
        .collection(AppConstants.matchmakerAnswersCollection)
        .doc('${_sessionId.value}_${q.id}')
        .set({
          'session_id': _sessionId.value,
          'question_id': q.id,
          'answer_value': value,
          'created_at': FieldValue.serverTimestamp(),
        });

    if (_currentQuestionIndex.value < _questions.length - 1) {
      _currentQuestionIndex.value++;
      textEditingController.clear();
    } else {
      _isCompleted.value = true;
    }

    scrollToBottom();
  }

  void handleFreeTextSubmit() {
    if (_freeTextInput.value.trim().isNotEmpty) {
      handleAnswer(_freeTextInput.value.trim());
    }
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}

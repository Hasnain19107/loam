import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/loam_button.dart';
import '../../controller/auth_controller.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final _authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  Future<void> _loadQuiz() async {
    // TODO: Load quiz from Firebase
    // For now, using mock questions
    _authController.setQuizLoading(true);

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    final questions = [
      {
        'id': '1',
        'question_text': 'Do you consider yourself more of a',
        'question_type': 'multiple_choice',
        'options': ['Smart person', 'Funny person'],
      },
      {
        'id': '2',
        'question_text': 'I enjoy going out with friends',
        'question_type': 'scale_1_10',
        'scale_label_low': 'Rarely',
        'scale_label_high': 'Very often',
      },
      {
        'id': '3',
        'question_text': 'Are you a woman or a man?',
        'question_type': 'multiple_choice',
        'options': ['Woman', 'Man'],
      },
    ];

    _authController.assignQuizQuestions(questions);
    _authController.setQuizLoading(false);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_authController.isQuizLoading) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: const Center(child: CircularProgressIndicator()),
        );
      }

      if (_authController.quizQuestions.isEmpty) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'No survey available',
                      style: TextStyle(color: AppColors.mutedForeground),
                    ),
                    const SizedBox(height: 24),
                    LoamButton(
                      text: 'Continue',
                      onPressed: () => Get.toNamed(AppRoutes.authChoice),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }

      final question = _authController.quizQuestions[_authController.quizStep];
      final questionType = question['question_type'] as String;

      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0),
            child: Column(
              children: [
                // Back button
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: _authController.handleQuizBack,
                  ),
                ),
                SizedBox(height: 24),
                // Progress indicator
                Row(
                  children: List.generate(
                    _authController.quizQuestions.length,
                    (index) => Expanded(
                      child: Container(
                        height: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: index <= _authController.quizStep
                              ? AppColors.primary
                              : AppColors.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                // Question
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        question['question_text'],
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),

                      // Answer options
                      if (questionType == 'multiple_choice')
                        ...(question['options'] as List<String>).map((option) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () =>
                                    _authController.handleQuizAnswer(option),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppColors.foreground,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(option),
                              ),
                            ),
                          );
                        }),

                      if (questionType == 'scale_1_10') ...[
                        Text(
                          '${question['scale_label_low'] ?? '1'} - ${question['scale_label_high'] ?? '10'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.mutedForeground,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: List.generate(10, (index) {
                            final value = index + 1;
                            final isSelected =
                                _authController.quizScaleValue == value;
                            return GestureDetector(
                              onTap: () =>
                                  _authController.setQuizScaleValue(value),
                              child: Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.secondary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    value.toString(),
                                    style: TextStyle(
                                      color: isSelected
                                          ? AppColors.primaryForeground
                                          : AppColors.foreground,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 24),
                        LoamButton(
                          text: 'Continue',
                          variant: LoamButtonVariant.primary,
                          onPressed: _authController.quizScaleValue != null
                              ? () => _authController.handleQuizAnswer(
                                  _authController.quizScaleValue.toString(),
                                )
                              : null,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

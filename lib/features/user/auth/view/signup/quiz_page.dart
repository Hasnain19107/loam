import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/routes/app_routes.dart';
import '../../../../../core/widgets/loam_button.dart';
import '../../controller/quiz_controller.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final _quizController = Get.put(QuizController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_quizController.isLoading) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: const Center(child: CircularProgressIndicator()),
        );
      }

      if (_quizController.questions.isEmpty) {
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

      final question = _quizController.questions[_quizController.currentStep];
      final questionType = question.questionType;

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
                    onPressed: _quizController.handleBack,
                  ),
                ),
                SizedBox(height: 24),
                // Progress indicator
                Row(
                  children: List.generate(
                    _quizController.questions.length,
                    (index) => Expanded(
                      child: Container(
                        height: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: index <= _quizController.currentStep
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
                        question.questionText,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),

                      // Answer options
                      if (questionType == 'multiple_choice' &&
                          question.options != null)
                        ...(question.options!).map((option) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () =>
                                    _quizController.handleAnswer(option),
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
                          '${question.scaleLabelLow ?? '1'} - ${question.scaleLabelHigh ?? '10'}',
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
                                _quizController.scaleValue == value;
                            return GestureDetector(
                              onTap: () => _quizController.setScaleValue(value),
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
                          onPressed: _quizController.scaleValue != null
                              ? () => _quizController.handleAnswer(
                                  _quizController.scaleValue.toString(),
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

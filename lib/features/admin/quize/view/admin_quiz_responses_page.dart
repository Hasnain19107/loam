import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/survey_model.dart';
import '../controller/admin_quiz_responses_controller.dart';
import '../../widgets/admin_layout.dart';

class AdminQuizResponsesPage extends StatelessWidget {
  const AdminQuizResponsesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminQuizResponsesController());

    return AdminLayout(
      title: 'Quiz Responses',
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Download quiz responses as CSV or Excel',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.mutedForeground,
                ),
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.surveys.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.help_outline,
                          size: 48,
                          color: AppColors.mutedForeground,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No quizzes yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.foreground,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.refresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: controller.surveys.length,
                    itemBuilder: (context, index) {
                      final quiz = controller.surveys[index];
                      final responseCount =
                          controller.responseCounts[quiz.id] ?? 0;
                      return _QuizResponseCard(
                        quiz: quiz,
                        responseCount: responseCount,
                        controller: controller,
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuizResponseCard extends StatelessWidget {
  final SurveyModel quiz;
  final int responseCount;
  final AdminQuizResponsesController controller;

  const _QuizResponseCard({
    required this.quiz,
    required this.responseCount,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  quiz.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.foreground,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _StatusBadge(status: quiz.status),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.people_outline,
                size: 16,
                color: AppColors.mutedForeground,
              ),
              const SizedBox(width: 4),
              Text(
                '$responseCount response${responseCount != 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.mutedForeground,
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: AppColors.mutedForeground,
              ),
              const SizedBox(width: 4),
              Text(
                DateFormat('MMM d, yyyy').format(quiz.createdAt),
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.mutedForeground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: Obx(
              () => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton.icon(
                    onPressed:
                        controller.isDownloading(quiz.id) || responseCount == 0
                        ? null
                        : () => controller.downloadCSV(quiz),
                    icon: controller.isDownloading(quiz.id)
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.description_outlined, size: 18),
                    label: const Text('CSV'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.foreground,
                      side: BorderSide(color: AppColors.border),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed:
                        controller.isDownloading(quiz.id) || responseCount == 0
                        ? null
                        : () => controller.downloadExcel(quiz),
                    icon: controller.isDownloading(quiz.id)
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Icon(Icons.table_chart_outlined, size: 18),
                    label: const Text('Excel'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    String label;

    switch (status) {
      case 'active':
        backgroundColor = Colors.green.shade600;
        textColor = Colors.white;
        label = 'Active';
        break;
      case 'draft':
        backgroundColor = AppColors.secondary;
        textColor = AppColors.foreground;
        label = 'Draft';
        break;
      case 'archived':
        backgroundColor = Colors.transparent;
        textColor = AppColors.mutedForeground;
        label = 'Archived';
        break;
      default:
        backgroundColor = AppColors.secondary;
        textColor = AppColors.foreground;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: status == 'archived'
            ? Border.all(color: AppColors.border)
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }
}

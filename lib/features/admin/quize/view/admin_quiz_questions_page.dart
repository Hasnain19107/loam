import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/survey_question_model.dart';
import '../controller/admin_quiz_questions_controller.dart';
import '../../widgets/admin_layout.dart';

class AdminQuizQuestionsPage extends StatelessWidget {
  const AdminQuizQuestionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Extract quizId from route parameters or path (similar to AdminEventDetailPage)
    String quizId = Get.parameters['quizId'] ?? '';

    // If param is empty or just the placeholder ':quizId', try to get from query params
    if (quizId.isEmpty || quizId == ':quizId') {
      final uri = Uri.parse(Get.currentRoute);
      if (uri.queryParameters.containsKey('quizId')) {
        quizId = uri.queryParameters['quizId']!;
      }
    }

    // Fallback to regex from path if still empty or placeholder
    if (quizId.isEmpty || quizId == ':quizId') {
      final currentRoute = Get.currentRoute;
      final match = RegExp(
        r'/admin/quiz-builder/([^/?]+)',
      ).firstMatch(currentRoute);
      if (match != null) {
        final captured = match.group(1);
        if (captured != null && captured != ':quizId') {
          quizId = captured;
        }
      }
    }

    // Validate quizId
    if (quizId.isEmpty || quizId == ':quizId') {
      return AdminLayout(
        title: 'Quiz Questions',
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: AppColors.mutedForeground,
                ),
                const SizedBox(height: 16),
                Text(
                  'Invalid Quiz ID',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.mutedForeground,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Route: ${Get.currentRoute}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.mutedForeground,
                  ),
                ),
                Text(
                  'Parameters: ${Get.parameters}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Get or create controller for this quizId
    final controller = Get.put(AdminQuizQuestionsController(), tag: quizId);

    // Load survey and questions if not already loaded or loading
    if (controller.survey == null && !controller.isLoading) {
      // Start loading immediately (synchronously)
      controller.startLoading();
      // Then load data asynchronously
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.loadSurveyAndQuestions(quizId);
      });
    }

    return AdminLayout(
      title: controller.survey?.title ?? 'Quiz Questions',
      child: SafeArea(
        child: Obx(() {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.survey == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: AppColors.mutedForeground,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Quiz not found',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Quiz ID: $quizId',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton(
                    onPressed: () => Get.back(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }
          return Column(
            children: [
              // Header Actions (Mobile Safe)
              Padding(
                padding: const EdgeInsets.all(16),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 600;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${controller.questions.length} Question${controller.questions.length != 1 ? 's' : ''}',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.mutedForeground,
                              ),
                            ),

                            _StatusBadge(status: controller.survey!.status),
                          ],
                        ),

                        const SizedBox(height: 12),

                        if (!controller.showForm)
                          SizedBox(
                            width: isMobile ? double.infinity : null,
                            child: ElevatedButton.icon(
                              onPressed: () => controller.setShowForm(true),
                              icon: const Icon(Icons.add, size: 20),
                              label: const Text('Add Question'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.primaryForeground,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),

              // Content Section
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (controller.showForm) ...[
                        _QuestionForm(controller: controller, quizId: quizId),
                        const SizedBox(height: 24),
                      ],

                      if (controller.questions.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(48),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.card,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Icon(
                                    Icons.help_outline,
                                    size: 48,
                                    color: AppColors.mutedForeground,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'No questions yet',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.foreground,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Add your first question to get started',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.mutedForeground,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ...controller.questions.map(
                          (question) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _QuestionCard(
                              question: question,
                              controller: controller,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _QuestionForm extends StatelessWidget {
  final AdminQuizQuestionsController controller;
  final String quizId;

  const _QuestionForm({required this.controller, required this.quizId});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                controller.editingQuestion != null
                    ? 'Edit Question'
                    : 'Add New Question',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.foreground,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 24),
                onPressed: controller.resetForm,
                color: AppColors.mutedForeground,
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            decoration: InputDecoration(
              labelText: 'Question Text',
              hintText: 'Enter your question...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: AppColors.background,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            controller: TextEditingController(text: controller.questionText)
              ..selection = TextSelection.collapsed(
                offset: controller.questionText.length,
              ),
            onChanged: controller.setQuestionText,
            maxLines: 3,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          Obx(
            () => Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Question Type',
                  labelStyle: const TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                value: controller.questionType,
                dropdownColor: AppColors.card,
                items: const [
                  DropdownMenuItem(
                    value: 'multiple_choice',
                    child: Text(
                      'Multiple Choice',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'scale_1_10',
                    child: Text(
                      'Scale 1–10',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) controller.setQuestionType(value);
                },
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Obx(
            () => controller.questionType == 'multiple_choice'
                ? _MultipleChoiceOptions(controller: controller)
                : _ScaleLabels(controller: controller),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: controller.handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.primaryForeground,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    controller.editingQuestion != null
                        ? 'Update Question'
                        : 'Save Question',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: controller.resetForm,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Cancel', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MultipleChoiceOptions extends StatelessWidget {
  final AdminQuizQuestionsController controller;

  const _MultipleChoiceOptions({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Options (minimum 2)',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: AppColors.foreground,
          ),
        ),
        const SizedBox(height: 12),
        Obx(
          () => Column(
            children: List.generate(
              controller.options.length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Option ${index + 1}',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: AppColors.background,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        controller:
                            TextEditingController(
                                text: controller.options[index],
                              )
                              ..selection = TextSelection.collapsed(
                                offset: controller.options[index].length,
                              ),
                        onChanged: (value) =>
                            controller.updateOption(index, value),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    if (controller.options.length > 2) ...[
                      const SizedBox(width: 8),
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        child: IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            size: 24,
                            color: AppColors.destructive,
                          ),
                          onPressed: () => controller.removeOption(index),
                          tooltip: 'Remove option',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: controller.addOption,
          icon: const Icon(Icons.add, size: 20),
          label: const Text('Add Option'),
          style: OutlinedButton.styleFrom(
            backgroundColor: AppColors.secondary.withOpacity(0.3),
            foregroundColor: AppColors.foreground,
            side: BorderSide(color: AppColors.border),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}

class _ScaleLabels extends StatelessWidget {
  final AdminQuizQuestionsController controller;

  const _ScaleLabels({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Scale Labels',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: AppColors.foreground,
          ),
        ),
        const SizedBox(height: 12),

        TextField(
          decoration: InputDecoration(
            labelText: 'Label for 1 (above)',
            hintText: 'e.g., Rarely',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: AppColors.background,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          controller: TextEditingController(text: controller.scaleLabelLow)
            ..selection = TextSelection.collapsed(
              offset: controller.scaleLabelLow.length,
            ),
          onChanged: controller.setScaleLabelLow,
          style: const TextStyle(fontSize: 16),
        ),

        const SizedBox(height: 12),
        TextField(
          decoration: InputDecoration(
            labelText: 'Label for 10 (below)',
            hintText: 'e.g., Very often',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: AppColors.background,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          controller: TextEditingController(text: controller.scaleLabelHigh)
            ..selection = TextSelection.collapsed(
              offset: controller.scaleLabelHigh.length,
            ),
          onChanged: controller.setScaleLabelHigh,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final SurveyQuestionModel question;
  final AdminQuizQuestionsController controller;

  const _QuestionCard({required this.question, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  question.questionType == 'multiple_choice'
                      ? Icons.list_alt_rounded
                      : Icons.linear_scale_rounded,
                  size: 24,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            question.questionText,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.foreground,
                              height: 1.4,
                            ),
                          ),
                        ),
                        // Actions Menu
                        PopupMenuButton<String>(
                          icon: Icon(
                            Icons.more_vert,
                            color: AppColors.mutedForeground,
                          ),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          onSelected: (value) {
                            switch (value) {
                              case 'edit':
                                controller.handleEdit(question);
                                break;
                              case 'delete':
                                _showDeleteDialog(context);
                                break;
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit_outlined, size: 18),
                                  SizedBox(width: 12),
                                  Text('Edit Question'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete_outline,
                                    size: 18,
                                    color: AppColors.destructive,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Delete',
                                    style: TextStyle(
                                      color: AppColors.destructive,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        question.questionType == 'multiple_choice'
                            ? 'Multiple Choice • ${(question.options ?? []).length} Options'
                            : 'Scale 1–10 • ${question.scaleLabelLow ?? 'Low'} → ${question.scaleLabelHigh ?? 'High'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.mutedForeground,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (question.questionType == 'multiple_choice' &&
                        (question.options?.isNotEmpty ?? false)) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: question.options!.take(4).map((option) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.border.withOpacity(0.6),
                              ),
                            ),
                            child: Text(
                              option,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.mutedForeground,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      if (question.options!.length > 4)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '+ ${question.options!.length - 4} more options',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.mutedForeground,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete question?'),
        content: const Text('Are you sure you want to delete this question?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.handleDelete(question.id);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.destructive,
              foregroundColor: AppColors.destructiveForeground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Delete'),
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
    Color color;
    Color backgroundColor;
    String label;
    IconData? icon;

    switch (status) {
      case 'active':
        color = Colors.green.shade700;
        backgroundColor = Colors.green.shade50;
        label = 'Active';
        icon = Icons.check_circle;
        break;
      case 'draft':
        color = Colors.orange.shade800;
        backgroundColor = Colors.orange.shade50;
        label = 'Draft';
        icon = Icons.edit;
        break;
      case 'archived':
        color = Colors.grey.shade700;
        backgroundColor = Colors.grey.shade100;
        label = 'Archived';
        icon = Icons.archive;
        break;
      default:
        color = Colors.blue.shade700;
        backgroundColor = Colors.blue.shade50;
        label = status;
        icon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

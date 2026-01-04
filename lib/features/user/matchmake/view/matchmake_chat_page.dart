import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/loam_button.dart';
import '../../../../core/widgets/loam_card.dart';
import '../controller/matchmake_controller.dart';

class MatchmakeChatPage extends StatefulWidget {
  const MatchmakeChatPage({super.key});

  @override
  State<MatchmakeChatPage> createState() => _MatchmakeChatPageState();
}

class _MatchmakeChatPageState extends State<MatchmakeChatPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<MatchmakeController>().initializeChat();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MatchmakeController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading) {
            return Center(
              child: Text(
                'Loading...',
                style: TextStyle(color: AppColors.mutedForeground),
              ),
            );
          }

          if (controller.isCompleted) {
            return _buildCompletedView(context);
          }

          return Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.border, width: 1),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Get.back(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    Text(
                      '${controller.currentQuestionIndex + 1} of ${controller.questions.length}',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.mutedForeground,
                      ),
                    ),
                    const SizedBox(width: 36),
                  ],
                ),
              ),

              // Chat messages
              Expanded(
                child: ListView(
                  controller: controller.scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    ..._buildPreviousMessages(context, controller),
                    if (controller.currentQuestion != null)
                      _buildCurrentQuestion(
                        context,
                        controller.currentQuestion!,
                      ),
                    SizedBox(
                      height: controller.currentQuestion != null ? 16 : 0,
                    ),
                    // Scroll anchor - triggers rebuild and scroll when index/answers change
                    // Spacer for bottom content
                    SizedBox(height: 100),
                  ],
                ),
              ),

              // Answer input area
              if (controller.currentQuestion != null)
                _buildAnswerInput(
                  context,
                  controller.currentQuestion!,
                  controller,
                ),
            ],
          );
        }),
      ),
    );
  }

  List<Widget> _buildPreviousMessages(
    BuildContext context,
    MatchmakeController controller,
  ) {
    final widgets = <Widget>[];

    for (int i = 0; i < controller.answers.length; i++) {
      final answer = controller.answers[i];
      final question = i < controller.questions.length
          ? controller.questions[i]
          : null;

      if (question != null) {
        widgets.addAll([
          _buildQuestionBubble(context, question.questionText),
          const SizedBox(height: 12),
          _buildAnswerBubble(context, answer.value),
          const SizedBox(height: 12),
        ]);
      }
    }

    return widgets;
  }

  Widget _buildQuestionBubble(BuildContext context, String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(
            16,
          ).copyWith(topLeft: const Radius.circular(4)),
        ),
        child: Text(
          text,
          style: const TextStyle(color: AppColors.foreground, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildAnswerBubble(BuildContext context, String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(
            16,
          ).copyWith(topRight: const Radius.circular(4)),
        ),
        child: Text(
          text,
          style: TextStyle(color: AppColors.primaryForeground, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildCurrentQuestion(
    BuildContext context,
    MatchmakeQuestion question,
  ) {
    return _buildQuestionBubble(context, question.questionText);
  }

  Widget _buildAnswerInput(
    BuildContext context,
    MatchmakeQuestion question,
    MatchmakeController controller,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Column(
        children: [
          if (question.questionType == 'multiple_choice' &&
              question.options != null)
            _buildMultipleChoiceInput(question, controller),
          if (question.questionType == 'scale' ||
              question.questionType == 'scale_1_10')
            _buildScaleInput(question, controller),
          if (question.questionType == 'free_text')
            _buildFreeTextInput(controller),
        ],
      ),
    );
  }

  Widget _buildMultipleChoiceInput(
    MatchmakeQuestion question,
    MatchmakeController controller,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: (question.options ?? []).map((option) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              controller.handleAnswer(option);
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                option,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildScaleInput(
    MatchmakeQuestion question,
    MatchmakeController controller,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              question.scaleLabelLow ?? '1',
              style: TextStyle(fontSize: 12, color: AppColors.mutedForeground),
            ),
            Text(
              question.scaleLabelHigh ?? '10',
              style: TextStyle(fontSize: 12, color: AppColors.mutedForeground),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // First row: 1-5
        Row(
          children: [1, 2, 3, 4, 5].asMap().entries.map((entry) {
            final num = entry.value;
            final isLast = entry.key == 4;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: isLast ? 0 : 8),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        controller.handleAnswer(num.toString());
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            num.toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        // Second row: 6-10
        Row(
          children: [6, 7, 8, 9, 10].asMap().entries.map((entry) {
            final num = entry.value;
            final isLast = entry.key == 4;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: isLast ? 0 : 8),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        controller.handleAnswer(num.toString());
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            num.toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFreeTextInput(MatchmakeController controller) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller.textEditingController,
            decoration: InputDecoration(
              hintText: 'Type your answer...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            maxLines: null,
            textInputAction: TextInputAction.send,
            onSubmitted: (value) {
              controller.handleFreeTextSubmit();
            },
          ),
        ),
        const SizedBox(width: 8),
        Obx(
          () => IconButton(
            icon: Icon(Icons.send),
            onPressed: controller.freeTextInput.trim().isNotEmpty
                ? () {
                    controller.handleFreeTextSubmit();
                  }
                : null,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.primaryForeground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletedView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: LoamCard(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.access_time,
                  size: 28,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Thanks for your input',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Give us 48 hours to review, and we\'ll pass you a match.',
                style: TextStyle(color: AppColors.mutedForeground),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              LoamButton(
                text: 'Done',
                onPressed: () => Get.offAllNamed(AppRoutes.home),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

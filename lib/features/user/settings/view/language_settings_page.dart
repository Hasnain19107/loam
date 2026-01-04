import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../controller/settings_controller.dart';

class LanguageSettingsPage extends StatelessWidget {
  const LanguageSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final _settingsController = Get.find<SettingsController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const Text('App language'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Obx(() {
          final languages = _settingsController.languages;
          final currentLanguage = _settingsController.currentLanguage;
          
          return Container(
            decoration: BoxDecoration(
              color: AppColors.popover,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [AppColors.loamCardShadow],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: languages.map((language) {
                final isSelected = currentLanguage == language;
                return InkWell(
                  onTap: () => _settingsController.handleLanguageSelect(language),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: language != languages.last
                          ? Border(
                              bottom: BorderSide(color: AppColors.border),
                            )
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          language,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        if (isSelected)
                          Icon(Icons.check, color: AppColors.primary),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }),
      ),
    );
  }
}

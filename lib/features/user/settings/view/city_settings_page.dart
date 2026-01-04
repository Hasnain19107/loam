import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../controller/settings_controller.dart';

class CitySettingsPage extends StatelessWidget {
  const CitySettingsPage({super.key});

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
        title: const Text('City'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Obx(() {
          final cities = _settingsController.cities;
          final currentCity = _settingsController.currentCity;
          
          return Container(
            decoration: BoxDecoration(
              color: AppColors.popover,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [AppColors.loamCardShadow],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: cities.map((city) {
                final isSelected = currentCity == city;
                return InkWell(
                  onTap: () => _settingsController.handleCitySelect(city),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: city != cities.last
                          ? Border(
                              bottom: BorderSide(color: AppColors.border),
                            )
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          city,
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

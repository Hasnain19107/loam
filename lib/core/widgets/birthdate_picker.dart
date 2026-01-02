import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class BirthdatePicker extends StatefulWidget {
  final DateTime? value;
  final ValueChanged<DateTime> onChange;

  const BirthdatePicker({
    super.key,
    this.value,
    required this.onChange,
  });

  @override
  State<BirthdatePicker> createState() => _BirthdatePickerState();
}

class _BirthdatePickerState extends State<BirthdatePicker> {
  static const List<String> months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  late FixedExtentScrollController _dayController;
  late FixedExtentScrollController _monthController;
  late FixedExtentScrollController _yearController;

  List<int> get days => List.generate(31, (i) => i + 1);
  List<int> get years {
    final currentYear = DateTime.now().year;
    return List.generate(100, (i) => currentYear - i);
  }

  int get selectedDay => widget.value?.day ?? 15;
  int get selectedMonth => widget.value?.month ?? 6;
  int get selectedYear => widget.value?.year ?? 2005;

  @override
  void initState() {
    super.initState();
    final dayIndex = widget.value != null 
        ? widget.value!.day - 1 
        : 14; // Default to day 15
    final monthIndex = widget.value != null 
        ? widget.value!.month - 1 
        : 5; // Default to June
    final yearIndex = widget.value != null 
        ? (years.indexOf(widget.value!.year) >= 0 
            ? years.indexOf(widget.value!.year) 
            : 21)
        : 21; // Default to 2005
    
    _dayController = FixedExtentScrollController(initialItem: dayIndex);
    _monthController = FixedExtentScrollController(initialItem: monthIndex);
    _yearController = FixedExtentScrollController(initialItem: yearIndex);
    
    // Set initial value if provided
    if (widget.value != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _onDateChanged();
      });
    }
  }

  @override
  void dispose() {
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  void _onDateChanged() {
    final month = _monthController.selectedItem + 1;
    final year = years[_yearController.selectedItem];
    
    // Get the last valid day for the selected month/year
    final lastDayOfMonth = DateTime(year, month + 1, 0).day;
    final selectedDayIndex = _dayController.selectedItem;
    final day = days[selectedDayIndex];
    
    // If selected day exceeds last day of month, adjust it
    if (day > lastDayOfMonth) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _dayController.animateToItem(
          lastDayOfMonth - 1,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      });
      return;
    }
    
    // Create and validate the date
    try {
      final date = DateTime(year, month, day);
      widget.onChange(date);
    } catch (e) {
      // Fallback to last valid day
      final validDay = DateTime(year, month + 1, 0).day;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _dayController.animateToItem(
          validDay - 1,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: _WheelColumn(
            label: 'Day',
            items: days.map((d) => d.toString()).toList(),
            controller: _dayController,
            onChanged: _onDateChanged,
            initialIndex: widget.value != null ? widget.value!.day - 1 : 14,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _WheelColumn(
            label: 'Month',
            items: months,
            controller: _monthController,
            onChanged: _onDateChanged,
            initialIndex: widget.value != null ? widget.value!.month - 1 : 5,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _WheelColumn(
            label: 'Year',
            items: years.map((y) => y.toString()).toList(),
            controller: _yearController,
            onChanged: _onDateChanged,
            initialIndex: widget.value != null 
                ? (years.indexOf(widget.value!.year) >= 0 
                    ? years.indexOf(widget.value!.year) 
                    : 21)
                : 21,
          ),
        ),
      ],
    );
  }
}

class _WheelColumn extends StatefulWidget {
  final String label;
  final List<String> items;
  final FixedExtentScrollController controller;
  final VoidCallback onChanged;
  final int initialIndex;

  const _WheelColumn({
    required this.label,
    required this.items,
    required this.controller,
    required this.onChanged,
    required this.initialIndex,
  });

  @override
  State<_WheelColumn> createState() => _WheelColumnState();
}

class _WheelColumnState extends State<_WheelColumn> {
  int _selectedIndex = 0;

  static const double itemHeight = 44.0;
  static const int visibleItems = 5;

  @override
  void initState() {
    super.initState();
    // Initialize with the passed initialIndex
    _selectedIndex = widget.initialIndex;
    widget.controller.addListener(_updateSelectedIndex);
    
    // Update selected index after the first frame when scroll view is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.controller.hasClients) {
        setState(() {
          _selectedIndex = widget.controller.selectedItem;
        });
      }
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateSelectedIndex);
    super.dispose();
  }

  void _updateSelectedIndex() {
    if (mounted && widget.controller.hasClients) {
      final newIndex = widget.controller.selectedItem;
      if (_selectedIndex != newIndex) {
        setState(() {
          _selectedIndex = newIndex;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.mutedForeground,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        // Wheel picker
        SizedBox(
          height: itemHeight * visibleItems,
          child: Stack(
            children: [
              // Selection indicator
              Positioned(
                top: itemHeight * 2,
                left: 0,
                right: 0,
                child: Container(
                  height: itemHeight,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.border,
                      width: 1,
                    ),
                  ),
                ),
              ),
              // Fade gradients
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: itemHeight * 2,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.background,
                          AppColors.background.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: itemHeight * 2,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          AppColors.background,
                          AppColors.background.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // List wheel
              ListWheelScrollView.useDelegate(
                controller: widget.controller,
                itemExtent: itemHeight,
                diameterRatio: 1000000, // Very high value to make it flat (no perspective/size changes)
                physics: const FixedExtentScrollPhysics(),
                onSelectedItemChanged: (index) {
                  _updateSelectedIndex();
                  widget.onChanged();
                },
                childDelegate: ListWheelChildBuilderDelegate(
                  builder: (context, index) {
                    if (index < 0 || index >= widget.items.length) {
                      return const SizedBox.shrink();
                    }
                    
                    final isSelected = index == _selectedIndex;
                    final item = widget.items[index];
                    
                    // Calculate distance from selected item
                    final distance = (index - _selectedIndex).abs();
                    
                    // Apply progressive opacity based on distance
                    // Selected: 1.0, Adjacent: 0.6, 2nd: 0.4, 3rd+: 0.2
                    double opacity;
                    if (isSelected) {
                      opacity = 1.0;
                    } else if (distance == 1) {
                      opacity = 0.6; // First previous/forward
                    } else if (distance == 2) {
                      opacity = 0.4; // Second previous/forward
                    } else {
                      opacity = 0.2; // Further items - very low opacity
                    }
                    
                    return Container(
                      height: itemHeight,
                      alignment: Alignment.center,
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 150),
                        style: TextStyle(
                          fontSize: 18, // Same size for all items - no shrinking
                          fontWeight: isSelected 
                              ? FontWeight.w600 
                              : FontWeight.normal,
                          color: isSelected
                              ? AppColors.foreground
                              : AppColors.mutedForeground.withOpacity(opacity),
                        ),
                        child: Text(item),
                      ),
                    );
                  },
                  childCount: widget.items.length,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

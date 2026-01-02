import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/country_codes.dart';

class CountryCodeSelect extends StatefulWidget {
  final CountryCode value;
  final ValueChanged<CountryCode> onChange;

  const CountryCodeSelect({
    super.key,
    required this.value,
    required this.onChange,
  });

  @override
  State<CountryCodeSelect> createState() => _CountryCodeSelectState();
}

class _CountryCodeSelectState extends State<CountryCodeSelect> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlay;
  String _search = '';

  void _openDropdown() {
    if (_overlay != null) return;

    _overlay = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            /// Outside tap
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _closeDropdown,
                child: const SizedBox(),
              ),
            ),

            /// Dropdown
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: const Offset(0, 60),
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 300,
                  height: 320,
                  decoration: BoxDecoration(
                    color: AppColors.popover,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: TextField(
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: 'Search country',
                            prefixIcon:
                                const Icon(Icons.search, size: 18),
                            filled: true,
                            fillColor:
                                AppColors.secondary.withOpacity(0.4),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            isDense: true,
                          ),
                          onChanged: (v) {
                            _search = v;
                            _overlay?.markNeedsBuild();
                          },
                        ),
                      ),

                      Expanded(
                        child: ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          itemCount: _filteredCountries.length,
                          separatorBuilder: (_, __) => Divider(
                            height: 1,
                            color: AppColors.border,
                          ),
                          itemBuilder: (context, index) {
                            final country = _filteredCountries[index];
                            final isSelected =
                                country.code == widget.value.code;

                            return InkWell(
                              onTap: () {
                                widget.onChange(country);
                                _closeDropdown();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                color: isSelected
                                    ? AppColors.secondary
                                    : Colors.transparent,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        country.name,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      country.code,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color:
                                            AppColors.mutedForeground,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_overlay!);
  }

  void _closeDropdown() {
    _overlay?.remove();
    _overlay = null;
    _search = '';
  }

  List<CountryCode> get _filteredCountries {
    if (_search.isEmpty) return countryCodes;
    final q = _search.toLowerCase();
    return countryCodes.where((c) {
      return c.name.toLowerCase().contains(q) ||
          c.code.contains(_search);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _openDropdown,
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.popover,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border, width: 2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.value.code,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.keyboard_arrow_down, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _closeDropdown();
    super.dispose();
  }
}

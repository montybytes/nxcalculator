import "package:flutter/material.dart";
import "package:nxcalculator/repositories/settings.dart";
import "package:nxcalculator/theme/constants.dart";
import "package:provider/provider.dart";

class MultiSettingTile<T> extends StatelessWidget {
  const MultiSettingTile({
    required this.selected,
    required this.selectables,
    this.onSelectionChanged,
    super.key,
  });

  final T selected;
  final List<MultiSetting<T>> selectables;
  final Function(T selection)? onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsRepository>(
      builder: (context, settings, child) {
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: largeBorderRadius.borderRadius,
            border: Border.all(color: Colors.grey.withAlpha(80)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < selectables.length; i++)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(1),
                    child: Material(
                      color: selected == selectables[i].data
                          ? Colors.grey.withAlpha(80)
                          : Colors.transparent,
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(i == 0 ? 12 - 1 : 0),
                        right: Radius.circular(
                          i == selectables.length - 1 ? 12 - 1 : 0,
                        ),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.horizontal(
                          left: Radius.circular(i == 0 ? 12 - 1 : 0),
                          right: Radius.circular(
                            i == selectables.length - 1 ? 12 - 1 : 0,
                          ),
                        ),
                        onTap: () {
                          onSelectionChanged?.call(selectables[i].data);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (selectables[i].icon != null)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: SizedBox.square(
                                    dimension: 32,
                                    child: selectables[i].icon,
                                  ),
                                ),
                              Text(selectables[i].label),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class MultiSetting<T> {
  final String label;
  final Widget? icon;
  final T data;

  const MultiSetting({required this.label, required this.data, this.icon});
}

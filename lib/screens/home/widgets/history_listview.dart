import "package:flutter/material.dart" hide Dismissible;
import "package:nxcalculator/models/history_item.dart";
import "package:nxcalculator/registries/settings.dart";
import "package:nxcalculator/repositories/calculator.dart";
import "package:nxcalculator/repositories/settings.dart";
import "package:nxcalculator/utils/strings.dart";
import "package:nxdesign/colors.dart";
import "package:nxdesign/fonts.dart";
import "package:nxdesign/metrics.dart";
import "package:nxdesign/widgets.dart";
import "package:provider/provider.dart";

class HistoryListview extends StatefulWidget {
  const HistoryListview({
    required this.repo,
    this.onDelete,
    this.onTapItem,
    super.key,
  });

  final void Function(int index)? onDelete;
  final void Function(HistoryItem item)? onTapItem;
  final CalculatorRepository repo;

  @override
  State<HistoryListview> createState() => _HistoryListviewState();
}

class _HistoryListviewState extends State<HistoryListview> {
  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  CalculatorRepository get _calculator => context.read<CalculatorRepository>();
  SettingsRepository get _settings => context.read<SettingsRepository>();

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 16,
      children: [
        _buildHeader(),
        Expanded(
          child: (widget.repo.history.isEmpty)
              ? const SafeArea(
                  child: Center(
                    child: Text(
                      "No items to display",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CustomScrollView(
                    slivers: [
                      SliverList.separated(
                        itemCount: widget.repo.history.length,
                        itemBuilder: (context, index) {
                          final item = widget.repo.history[index];
                          return _buildDismissible(item, index);
                        },
                        separatorBuilder: (context, index) {
                          return const SizedBox(height: 8);
                        },
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 124)),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Dismissible _buildDismissible(HistoryItem item, int index) {
    return Dismissible(
      key: ValueKey("${item.result}-${item.equation.join()}"),
      background: Container(
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.only(left: 4),
        padding: const EdgeInsets.only(right: 24, top: 32, bottom: 32),
        decoration: const BoxDecoration(
          color: NxColors.nothingRed,
          borderRadius: NxMetrics.cardBorderRadius,
        ),
        child: const NxIcon(
          path: NxIcon.deleteSwipe,
          color: NxColors.darkThemeText,
        ),
      ),
      confirmDismiss: () async => true,
      onDismissed: () => widget.onDelete?.call(index),
      child: Card(
        color: _isDark
            ? NxColors.darkThemeListItem
            : NxColors.lightThemeListItem,
        child: InkWell(
          onTap: () => widget.onTapItem?.call(item),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  getFormattedToken(
                    widget.repo.history[index].result,
                    settings: _settings,
                  ),
                  maxLines: 1,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 28,
                    fontFamily: _settings.get(equationResultFont),
                  ),
                  strutStyle: const StrutStyle(
                    forceStrutHeight: true,
                    fontSize: 28,
                  ),
                ),
                Text(
                  widget.repo.history[index].equation.map((token) {
                    return getFormattedToken(token, settings: _settings);
                  }).join(),
                  maxLines: 1,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontFamily: _settings.get(equationResultFont),
                    fontSize: 20,
                    color: _isDark
                        ? NxColors.darkInactive
                        : NxColors.lightInactive,
                  ),
                  strutStyle: const StrutStyle(
                    forceStrutHeight: true,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const SizedBox.square(dimension: 48),
          const Expanded(
            child: Text(
              "History",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontFamily: NxFonts.fontNType),
              strutStyle: StrutStyle(fontSize: 24, forceStrutHeight: true),
            ),
          ),
          if (widget.repo.history.isEmpty)
            const SizedBox.square(dimension: 48)
          else
            IconButton(
              tooltip: "Delete History",
              onPressed: () async {
                final shouldClear = await showDialog<bool>(
                  context: context,
                  builder: (context) => const ConfirmActionDialog(
                    titleText: "Clear History",
                    infoText: "Are you sure you want to clear all history?",
                    isWarning: true,
                  ),
                );

                if (shouldClear ?? false) {
                  await _calculator.clearHistory();
                }
              },
              icon: const SizedBox.square(
                dimension: 24,
                child: NxIcon(path: NxIcon.delete),
              ),
            ),
        ],
      ),
    );
  }
}

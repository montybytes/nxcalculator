import "package:flutter/material.dart";
import "package:nxcalculator/models/history_item.dart";
import "package:nxcalculator/theme/constants.dart";
import "package:nxcalculator/utils/ui.dart";

class HistoryBottomSheet extends StatefulWidget {
  const HistoryBottomSheet({required this.history, this.onDelete, super.key});

  final List<HistoryItem> history;
  final void Function(int index)? onDelete;

  @override
  State<HistoryBottomSheet> createState() => _HistoryBottomSheetState();
}

class _HistoryBottomSheetState extends State<HistoryBottomSheet> {
  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Column(
      children: [
        const Text(
          "History",
          style: TextStyle(fontSize: 24, fontFamily: "Ntype-82"),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: widget.history.isEmpty
              ? const Center(
                  child: Text(
                    "No items to display",
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : ListView.separated(
                  itemCount: widget.history.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 2),
                  itemBuilder: (context, index) {
                    final item = widget.history[index];
                    return Padding(
                      padding: index == widget.history.length - 1
                          ? const EdgeInsetsGeometry.only(bottom: 124)
                          : EdgeInsetsGeometry.zero,
                      child: Row(
                        children: [
                          Expanded(
                            child: Dismissible(
                              key: ValueKey(
                                "${item.result}-${item.equation.join()}",
                              ),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(
                                  right: 24,
                                  top: 32,
                                  bottom: 32,
                                ),
                                decoration: BoxDecoration(
                                  color: nothingRed,
                                  borderRadius: buildListTileBorder(
                                    index,
                                    widget.history.length,
                                  ).borderRadius,
                                ),
                                child: Image.asset("assets/icons/delete.png"),
                              ),
                              onDismissed: (direction) {
                                widget.onDelete?.call(index);
                                setState(() {});
                              },
                              child: Card(
                                shape: buildListTileBorder(
                                  index,
                                  widget.history.length,
                                ),
                                color: isDark
                                    ? darkThemeListItem
                                    : lightThemeListItem,

                                child: InkWell(
                                  onTap: () => Navigator.of(context).pop(item),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Text(
                                          widget.history[index].result,
                                          textAlign: TextAlign.end,
                                          maxLines: 1,
                                          style: const TextStyle(
                                            fontSize: 32,
                                            fontFamily: "LetteraMono",
                                            letterSpacing: -4,
                                          ),
                                          strutStyle: const StrutStyle(
                                            forceStrutHeight: true,
                                            fontSize: 32,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text.rich(
                                          maxLines: 1,
                                          textAlign: TextAlign.end,
                                          strutStyle: const StrutStyle(
                                            forceStrutHeight: true,
                                            fontSize: 20,
                                          ),

                                          TextSpan(
                                            style: const TextStyle(
                                              fontFamily: "LetteraMono",
                                              letterSpacing: -2,
                                              fontSize: 20,
                                              color: Colors.grey,
                                            ),
                                            children: widget
                                                .history[index]
                                                .equation
                                                .map((text) {
                                                  return getEquationText(
                                                    text,
                                                    fontSize: 16,
                                                    verticalOffset: -8,
                                                  );
                                                })
                                                .toList(),
                                          ),
                                        ),
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
                ),
        ),
      ],
    );
  }
}

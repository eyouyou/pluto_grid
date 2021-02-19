import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

/// Open the context menu on the right side of the column.
Future<PlutoGridColumnMenuItem> showColumnMenu({
  BuildContext context,
  Offset position,
  PlutoGridStateManager stateManager,
  PlutoColumn column,
}) {
  if (position == null) {
    return null;
  }

  final RenderBox overlay = Overlay.of(context).context.findRenderObject();

  final Color textColor = stateManager.configuration.cellTextStyle.color;

  final Color backgroundColor = stateManager.configuration.menuBackgroundColor;

  final buildTextItem = (
    String text, {
    bool enabled = true,
  }) {
    return Text(
      text,
      style: TextStyle(
        color: enabled ? textColor : textColor.withOpacity(0.5),
        fontSize: 13,
      ),
    );
  };

  final buildMenuItem = <PlutoGridColumnMenuItem>({
    PlutoGridColumnMenuItem value,
    Widget child,
    bool enabled = true,
  }) {
    return PopupMenuItem<PlutoGridColumnMenuItem>(
      value: value,
      child: child,
      height: 36,
      enabled: enabled,
    );
  };

  final localeText = stateManager.localeText;

  return showMenu<PlutoGridColumnMenuItem>(
    context: context,
    color: backgroundColor,
    position: RelativeRect.fromRect(
        position & const Size(40, 40), Offset.zero & overlay.size),
    items: [
      if (column.frozen.isFrozen == true)
        buildMenuItem(
          value: PlutoGridColumnMenuItem.unfreeze,
          child: buildTextItem(localeText.unfreezeColumn),
        ),
      if (column.frozen.isFrozen != true) ...[
        buildMenuItem(
          value: PlutoGridColumnMenuItem.freezeToLeft,
          child: buildTextItem(localeText.freezeColumnToLeft),
        ),
        buildMenuItem(
          value: PlutoGridColumnMenuItem.freezeToRight,
          child: buildTextItem(localeText.freezeColumnToRight),
        ),
      ],
      const PopupMenuDivider(),
      buildMenuItem(
        value: PlutoGridColumnMenuItem.autoFit,
        child: buildTextItem(localeText.autoFitColumn),
      ),
    ],
  );
}

/// Items in the context menu on the right side of the column
enum PlutoGridColumnMenuItem {
  unfreeze,
  freezeToLeft,
  freezeToRight,
  hideColumn,
  setColumns,
  autoFit,
  setFilter,
  resetFilter,
}

import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

class PlutoGridCellGestureEvent extends PlutoGridEvent {
  final PlutoGridGestureType gestureType;
  final Offset offset;
  final PlutoCell cell;
  final PlutoColumn column;
  final int rowIdx;

  PlutoGridCellGestureEvent({
    this.gestureType,
    this.offset,
    this.cell,
    this.column,
    this.rowIdx,
  });

  @override
  void handler(PlutoGridController stateManager) {
    if (gestureType == null ||
        offset == null ||
        cell == null ||
        column == null ||
        rowIdx == null) {
      return;
    }

    if (gestureType.isOnTapUp) {
      _onTapUp(stateManager);
    } else if (gestureType.isOnLongPressStart) {
      _onLongPressStart(stateManager);
    } else if (gestureType.isOnLongPressMoveUpdate) {
      _onLongPressMoveUpdate(stateManager);
    } else if (gestureType.isOnLongPressEnd) {
      _onLongPressEnd(stateManager);
    }
  }

  void _onTapUp(PlutoGridController stateManager) {
    if (_setKeepFocusAndCurrentCell(stateManager)) {
      return;
    } else if (stateManager.isSelectingInteraction()) {
      _selecting(stateManager);
      return;
    } else if (stateManager.mode.isSelect) {
      _selectMode(stateManager);
      return;
    }

    if (stateManager.isCurrentCell(cell) && stateManager.isEditing != true) {
      stateManager.setEditing(true);
    } else {
      stateManager.setCurrentCell(cell, rowIdx);
    }
  }

  void _onLongPressStart(PlutoGridController stateManager) {
    _setCurrentCell(stateManager, cell, rowIdx);

    stateManager.setSelecting(true);

    if (stateManager.selectingMode.isRow) {
      stateManager.toggleSelectingRow(rowIdx);
    }
  }

  void _onLongPressMoveUpdate(PlutoGridController stateManager) {
    _setCurrentCell(stateManager, cell, rowIdx);

    stateManager.setCurrentSelectingPositionWithOffset(offset);

    stateManager.eventManager.addEvent(PlutoGridMoveUpdateEvent(
      offset: offset,
    ));
  }

  void _onLongPressEnd(PlutoGridController stateManager) {
    _setCurrentCell(stateManager, cell, rowIdx);

    stateManager.setSelecting(false);
  }

  bool _setKeepFocusAndCurrentCell(PlutoGridController stateManager) {
    if (stateManager.hasFocus) {
      return false;
    }

    stateManager.setKeepFocus(true);

    return stateManager.isCurrentCell(cell);
  }

  void _selecting(PlutoGridController stateManager) {
    if (stateManager.keyPressed.shift) {
      final int columnIdx = stateManager.columnIndex(column);

      stateManager.setCurrentSelectingPosition(
        cellPosition: PlutoGridCellPosition(
          columnIdx: columnIdx,
          rowIdx: rowIdx,
        ),
      );
    } else if (stateManager.keyPressed.ctrl) {
      stateManager.toggleSelectingRow(rowIdx);
    }
  }

  void _selectMode(PlutoGridController stateManager) {
    if (stateManager.isCurrentCell(cell)) {
      stateManager.handleOnSelected();
    } else {
      stateManager.setCurrentCell(cell, rowIdx);
    }
  }

  void _setCurrentCell(
    PlutoGridController stateManager,
    PlutoCell cell,
    int rowIdx,
  ) {
    if (stateManager.isCurrentCell(cell) != true) {
      stateManager.setCurrentCell(cell, rowIdx, notify: false);
    }
  }
}

enum PlutoGridGestureType {
  onTapUp,
  onLongPressStart,
  onLongPressMoveUpdate,
  onLongPressEnd,
}

extension PlutoGridGestureTypeExtension on PlutoGridGestureType {
  bool get isOnTapUp => this == PlutoGridGestureType.onTapUp;

  bool get isOnLongPressStart => this == PlutoGridGestureType.onLongPressStart;

  bool get isOnLongPressMoveUpdate =>
      this == PlutoGridGestureType.onLongPressMoveUpdate;

  bool get isOnLongPressEnd => this == PlutoGridGestureType.onLongPressEnd;
}

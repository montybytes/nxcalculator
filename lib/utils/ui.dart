import "package:flutter/material.dart";
import "package:nxdesign/metrics.dart";

BorderRadius getListTileBorder(int index, int listLength) {
  if (listLength == 1) {
    return NxMetrics.largeBorderRadius;
  }
  if (index == 0) {
    return NxMetrics.startBorderRadius;
  }
  if (index == listLength - 1) {
    return NxMetrics.endBorderRadius;
  }
  return NxMetrics.defaultBorderRadius;
}

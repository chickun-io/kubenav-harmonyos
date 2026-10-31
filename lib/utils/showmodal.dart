import 'package:flutter/material.dart';

import 'package:kubenav/utils/constants.dart';
import 'package:kubenav/utils/l10n.dart';
import 'package:kubenav/utils/themes.dart';

void showModal(BuildContext context, Widget widget, {bool fullScreen = false}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(Constants.spacingMiddle),
      ),
    ),
    clipBehavior: Clip.antiAliasWithSaveLayer,
    constraints: fullScreen == false
        ? null
        : BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
    builder: (BuildContext context) {
      return widget;
    },
  );
}

void showActions(BuildContext context, Widget widget) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    useSafeArea: true,
    elevation: 0,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return widget;
    },
  );
}

void showSnackbar(BuildContext context, String title, String message) {
  final localizedTitle = t(context, title);
  final exactMessage = t(context, message);
  final localizedMessage = exactMessage == message
      ? message.replaceAll(
          'An unknown error occured',
          t(context, 'An unknown error occured'),
        )
      : exactMessage;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
      backgroundColor: Theme.of(context).extension<CustomColors>()!.message,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Constants.sizeBorderRadius),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizedTitle,
            style: TextStyle(
              color: Theme.of(context).extension<CustomColors>()!.onMessage,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            localizedMessage,
            style: TextStyle(
              color: Theme.of(context).extension<CustomColors>()!.onMessage,
            ),
            maxLines: 5,
          ),
        ],
      ),
    ),
  );
}

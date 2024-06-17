import 'package:why_taxi_user/utils/Session.dart';
import 'package:why_taxi_user/utils/new_utils/ui.dart';
import 'package:flutter/material.dart';
import 'package:why_taxi_user/Locale/strings_enum.dart';
import 'package:why_taxi_user/Locale/locale.dart';

class RowItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;

  RowItem(this.title, this.subtitle, this.icon);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          getTranslated(context, title) != null
              ? getTranslated(context, title)!
              : title,
          style: theme.textTheme.headline6!
              .copyWith(color: theme.hintColor, fontSize: 12),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Icon(
              icon,
              color: theme.primaryColor,
              size: 16,
            ),
            SizedBox(width: 12),
            Text(
              subtitle!,
              style: theme.textTheme.headline6!.copyWith(fontSize: 12),
            ),
          ],
        )
      ],
    );
  }
}

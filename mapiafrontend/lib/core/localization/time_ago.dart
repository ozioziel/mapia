import 'package:flutter/widgets.dart';
import 'package:mapiafrontend/core/localization/l10n_extension.dart';

String localizedTimeAgo(BuildContext context, DateTime date) {
  final difference = DateTime.now().difference(date);
  final l10n = context.l10n;

  if (difference.inMinutes < 1) return l10n.timeAgoNow;
  if (difference.inMinutes < 60) {
    return l10n.timeAgoMinutes(difference.inMinutes);
  }
  if (difference.inHours < 24) return l10n.timeAgoHours(difference.inHours);
  return l10n.timeAgoDays(difference.inDays);
}

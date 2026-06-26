import 'package:flutter/widgets.dart';
import 'package:mapiafrontend/core/localization/l10n_extension.dart';
import 'package:mapiafrontend/features/posts/domain/entities/post_entity.dart';

extension LocalizedPostType on PostType {
  String label(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      PostType.news => l10n.news,
      PostType.novelty => l10n.novelty,
      PostType.party => l10n.party,
      PostType.foodDeal => l10n.foodDeal,
      PostType.sale => l10n.sale,
      PostType.traffic => l10n.traffic,
      PostType.blockade => l10n.blockade,
      PostType.accident => l10n.accident,
      PostType.serviceCut => l10n.serviceCut,
      PostType.security => l10n.security,
      PostType.lostFound => l10n.lostFound,
      PostType.other => l10n.other,
    };
  }

  String pluralLabel(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      PostType.news => l10n.newsPlural,
      PostType.novelty => l10n.noveltyPlural,
      PostType.party => l10n.partyPlural,
      PostType.foodDeal => l10n.foodDealPlural,
      PostType.sale => l10n.salePlural,
      PostType.traffic => l10n.trafficPlural,
      PostType.blockade => l10n.blockadePlural,
      PostType.accident => l10n.accidentPlural,
      PostType.serviceCut => l10n.serviceCutPlural,
      PostType.security => l10n.security,
      PostType.lostFound => l10n.lostFoundPlural,
      PostType.other => l10n.otherPlural,
    };
  }

  String description(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      PostType.news => l10n.newsDescription,
      PostType.novelty => l10n.noveltyDescription,
      PostType.party => l10n.partyDescription,
      PostType.foodDeal => l10n.foodDealDescription,
      PostType.sale => l10n.saleDescription,
      PostType.traffic => l10n.trafficDescription,
      PostType.blockade => l10n.blockadeDescription,
      PostType.accident => l10n.accidentDescription,
      PostType.serviceCut => l10n.serviceCutDescription,
      PostType.security => l10n.securityDescription,
      PostType.lostFound => l10n.lostFoundDescription,
      PostType.other => l10n.otherDescription,
    };
  }
}

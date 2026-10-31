import 'package:flutter/material.dart';

import 'package:kubenav/models/kubernetes/schema.models.swagger.dart';
import 'package:kubenav/utils/l10n.dart';
import 'package:kubenav/utils/resources.dart';
import 'package:kubenav/widgets/resources/helpers/details_item.dart';

/// The [DetailsItemMetadata] widget is used to show the metadata of a
/// Kubernetes resource.
class DetailsItemMetadata extends StatelessWidget {
  const DetailsItemMetadata({
    super.key,
    required this.kind,
    required this.metadata,
  });

  final String? kind;
  final IoK8sApimachineryPkgApisMetaV1ObjectMeta? metadata;

  @override
  Widget build(BuildContext context) {
    final ownerReferences = metadata?.ownerReferences
        ?.map(
          (ownerReference) => '${ownerReference.kind} (${ownerReference.name})',
        )
        .toList();

    return DetailsItem(
      title: t(context, 'Metadata'),
      details: [
        DetailsItemModel(name: t(context, 'Kind'), values: kind),
        DetailsItemModel(name: t(context, 'Name'), values: metadata?.name),
        DetailsItemModel(
          name: t(context, 'Namespace'),
          values: metadata?.namespace,
        ),
        DetailsItemModel(
          name: t(context, 'Age'),
          values: getAge(metadata?.creationTimestamp),
        ),
        DetailsItemModel(
          name: t(context, 'Labels'),
          values: metadata?.labels?.entries
              .map((e) => '${e.key}: ${e.value}')
              .toList(),
        ),
        DetailsItemModel(
          name: t(context, 'Annotations'),
          values: metadata?.annotations?.entries
              .map((e) => '${e.key}: ${e.value}')
              .toList(),
        ),
        DetailsItemModel(
          name: t(context, 'Owner References'),
          values: ownerReferences,
          onTap: (int index) {
            goToReference(
              context,
              metadata?.ownerReferences?[index],
              metadata?.namespace,
            );
          },
        ),
      ],
    );
  }
}

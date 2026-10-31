import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:kubenav/models/kubernetes/schema.models.swagger.dart';
import 'package:kubenav/utils/constants.dart';
import 'package:kubenav/utils/l10n.dart';
import 'package:kubenav/utils/navigate.dart';
import 'package:kubenav/utils/resources.dart';
import 'package:kubenav/widgets/plugins/argo/resources/plugin_argo_resources.dart';
import 'package:kubenav/widgets/resources/helpers/details_item.dart';
import 'package:kubenav/widgets/resources/helpers/details_item_metadata.dart';
import 'package:kubenav/widgets/resources/helpers/details_resources_preview.dart';
import 'package:kubenav/widgets/resources/resources/resources.dart';
import 'package:kubenav/widgets/resources/resources/resources_events.dart';
import 'package:kubenav/widgets/resources/resources_details.dart';
import 'package:kubenav/widgets/resources/resources_list.dart';

final Resource argoResourceApplication = Resource(
  category: ArgoResourceCategories.resources,
  plural: 'Applications',
  singular: 'Application',
  description: 'A group of Kubernetes resources as defined by a manifest.',
  path: '/apis/argoproj.io/v1alpha1',
  resource: 'applications',
  scope: ResourceScope.namespaced,
  additionalPrinterColumns: [],
  icon: 'argo',
  template: resourceDefaultTemplate,
  decodeListData: (ResourcesListData data) {
    final parsed = json.decode(data.list);
    final items = IoArgoprojV1alpha1ApplicationList.fromJson(parsed).items;

    return items.map((e) {
      final status = e.status?.health?.status ?? 'Unknown';

      return ResourceItem(
        item: e,
        metrics: null,
        status: status == 'Healthy'
            ? ResourceStatus.success
            : status == 'Degraded'
            ? ResourceStatus.danger
            : ResourceStatus.warning,
      );
    }).toList();
  },
  decodeList: (String data) {
    final parsed = json.decode(data);
    return IoArgoprojV1alpha1ApplicationList.fromJson(parsed).items;
  },
  getName: (dynamic item) {
    return (item as IoArgoprojV1alpha1Application).metadata.name ?? '';
  },
  getNamespace: (dynamic item) {
    return (item as IoArgoprojV1alpha1Application).metadata.namespace;
  },
  decodeItem: (String data) {
    final parsed = json.decode(data);
    return IoArgoprojV1alpha1Application.fromJson(parsed);
  },
  encodeItem: (dynamic item) {
    JsonEncoder encoder = const JsonEncoder.withIndent('  ');
    return encoder.convert(item);
  },
  toJson: (dynamic item) {
    return json.decode(json.encode(item));
  },
  listItemBuilder:
      (BuildContext context, Resource resource, ResourceItem listItem) {
        final item = listItem.item as IoArgoprojV1alpha1Application;
        final status = listItem.status;

        return ResourcesListItem(
          name: item.metadata.name ?? '',
          namespace: item.metadata.namespace ?? '',
          resource: resource,
          item: item,
          status: status,
          details: [
            tFmt(context, 'Namespace: {0}', [item.metadata.namespace ?? '-']),
            tFmt(context, 'App Health: {0}', [
              item.status?.health?.status ?? '-',
            ]),
            tFmt(context, 'Sync Status: {0}', [
              item.status?.$sync?.status ?? '-',
            ]),
            tFmt(context, 'Created At: {0}', [
              getAge(item.metadata.creationTimestamp),
            ]),
            tFmt(context, 'Last Sync: {0}', [
              getAge(item.status?.operationState?.finishedAt),
            ]),
          ],
        );
      },
  previewItemBuilder: (BuildContext context, dynamic listItem) {
    final item = listItem as IoArgoprojV1alpha1Application;

    return [
      tFmt(context, 'Namespace: {0}', [item.metadata.namespace ?? '-']),
      tFmt(context, 'App Health: {0}', [item.status?.health?.status ?? '-']),
      tFmt(context, 'Sync Status: {0}', [item.status?.$sync?.status ?? '-']),
      tFmt(context, 'Created At: {0}', [
        getAge(item.metadata.creationTimestamp),
      ]),
      tFmt(context, 'Last Sync: {0}', [
        getAge(item.status?.operationState?.finishedAt),
      ]),
    ];
  },
  detailsItemBuilder:
      (BuildContext context, Resource resource, dynamic detailsItem) {
        final item = detailsItem as IoArgoprojV1alpha1Application;

        return Column(
          children: [
            DetailsItemMetadata(kind: item.kind, metadata: item.metadata),
            const SizedBox(height: Constants.spacingMiddle),
            DetailsItem(
              title: t(context, 'Configuration'),
              details: [
                DetailsItemModel(
                  name: t(context, 'Project'),
                  values: item.spec.project,
                ),
                DetailsItemModel(
                  name: t(context, 'Info'),
                  values: item.spec.info != null && item.spec.info!.isNotEmpty
                      ? item.spec.info!.map((e) => e.value).toList()
                      : null,
                ),
                DetailsItemModel(
                  name: t(context, 'Cluster'),
                  values:
                      item.spec.destination.server ??
                      item.spec.destination.name,
                ),
                DetailsItemModel(
                  name: t(context, 'Source Type'),
                  values: item.status?.sourceType ?? '-',
                ),
                DetailsItemModel(
                  name: t(context, 'Repo URL'),
                  values: item.spec.source?.repoURL ?? '-',
                ),
                DetailsItemModel(
                  name: t(context, 'Target Revision'),
                  values: item.spec.source?.targetRevision ?? '-',
                ),
                DetailsItemModel(
                  name: t(context, 'Path'),
                  values: item.spec.source?.path ?? '-',
                ),
                DetailsItemModel(
                  name: t(context, 'Sync Policy'),
                  values: item.spec.syncPolicy != null
                      ? 'Auto sync enabled'
                      : 'Auto sync disabled',
                ),
                DetailsItemModel(
                  name: t(context, 'Prune'),
                  values: item.spec.syncPolicy?.automated?.prune == true
                      ? t(context, 'True')
                      : t(context, 'False'),
                ),
                DetailsItemModel(
                  name: t(context, 'SelfHeal'),
                  values: item.spec.syncPolicy?.automated?.selfHeal == true
                      ? t(context, 'True')
                      : t(context, 'False'),
                ),
              ],
            ),
            const SizedBox(height: Constants.spacingMiddle),
            DetailsItem(
              title: t(context, 'Status'),
              details: [
                DetailsItemModel(
                  name: t(context, 'App Health'),
                  values: item.status?.health?.status,
                ),
                DetailsItemModel(
                  name: t(context, 'Sync Status'),
                  values: item.status?.$sync?.status,
                ),
                DetailsItemModel(
                  name: t(context, 'Last Sync'),
                  values: getAge(item.status?.operationState?.finishedAt),
                ),
                DetailsItemModel(
                  name: t(context, 'Last Reconcile'),
                  values: getAge(item.status?.reconciledAt),
                ),
                DetailsItemModel(
                  name: t(context, 'Images'),
                  values: item.status?.summary?.images,
                ),
                DetailsItemModel(
                  name: t(context, 'URLs'),
                  values: item.status?.summary?.externalURLs,
                ),
                // TODO: this list should link to the customResource widgets for
                // non-supported resource kinds, it would also be useful to see
                // health and sync status per resource.
                DetailsItemModel(
                  name: t(context, 'Resources'),
                  values: item.status?.resources?.map((e) {
                    return '${e.kind}/${e.name}';
                  }).toList(),
                  onTap: (index) {
                    final res = item.status?.resources?[index];
                    if (kindToResource.containsKey(res?.kind)) {
                      navigate(
                        context,
                        ResourcesDetails(
                          name: res?.name ?? '',
                          namespace: res?.namespace,
                          resource: kindToResource[res?.kind]!,
                        ),
                      );
                      return;
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: Constants.spacingMiddle),
            DetailsResourcesPreview(
              resource: resourceEvent,
              namespace: item.metadata.namespace,
              selector:
                  'fieldSelector=involvedObject.name=${item.metadata.name ?? ''}',
              filter: null,
            ),
            const SizedBox(height: Constants.spacingMiddle),
          ],
        );
      },
);

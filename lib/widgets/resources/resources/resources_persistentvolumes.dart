import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:kubenav/models/kubernetes/schema.enums.swagger.dart' as enums;
import 'package:kubenav/models/kubernetes/schema.models.swagger.dart';
import 'package:kubenav/models/plugins/prometheus.dart';
import 'package:kubenav/utils/constants.dart';
import 'package:kubenav/utils/l10n.dart';
import 'package:kubenav/utils/navigate.dart';
import 'package:kubenav/utils/resources.dart';
import 'package:kubenav/widgets/resources/helpers/details_item.dart';
import 'package:kubenav/widgets/resources/helpers/details_item_metadata.dart';
import 'package:kubenav/widgets/resources/helpers/details_resources_preview.dart';
import 'package:kubenav/widgets/resources/resources/resources.dart';
import 'package:kubenav/widgets/resources/resources/resources_events.dart';
import 'package:kubenav/widgets/resources/resources/resources_persistentvolumeclaims.dart';
import 'package:kubenav/widgets/resources/resources/resources_storageclasses.dart';
import 'package:kubenav/widgets/resources/resources_details.dart';
import 'package:kubenav/widgets/resources/resources_list.dart';
import 'package:kubenav/widgets/shared/app_prometheus_charts_widget.dart';

final Resource resourcePersistentVolume = Resource(
  category: ResourceCategories.configAndStorage,
  plural: 'PersistentVolumes',
  singular: 'PersistentVolume',
  description: 'A PersistentVolume (PV) is a piece of storage in the cluster that has been provisioned by an administrator or dynamically provisioned using Storage Classes.',
  path: '/api/v1',
  resource: 'persistentvolumes',
  scope: ResourceScope.cluster,
  additionalPrinterColumns: [],
  icon: 'persistentvolumes',
  template: resourceDefaultTemplate,
  decodeListData: (ResourcesListData data) {
    final parsed = json.decode(data.list);
    final items = IoK8sApiCoreV1PersistentVolumeList.fromJson(parsed).items;

    return items
        .map(
          (e) => ResourceItem(
            item: e,
            metrics: null,
            status:
                e.status?.phase !=
                    enums.IoK8sApiCoreV1PersistentVolumeStatusPhase.bound
                ? ResourceStatus.danger
                : ResourceStatus.success,
          ),
        )
        .toList();
  },
  decodeList: (String data) {
    final parsed = json.decode(data);
    return IoK8sApiCoreV1PersistentVolumeList.fromJson(parsed).items;
  },
  getName: (dynamic item) {
    return (item as IoK8sApiCoreV1PersistentVolume).metadata?.name ?? '';
  },
  getNamespace: (dynamic item) {
    return (item as IoK8sApiCoreV1PersistentVolume).metadata?.namespace;
  },
  decodeItem: (String data) {
    final parsed = json.decode(data);
    return IoK8sApiCoreV1PersistentVolume.fromJson(parsed);
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
        final item = listItem.item as IoK8sApiCoreV1PersistentVolume;
        final status = listItem.status;

        return ResourcesListItem(
          name: item.metadata?.name ?? '',
          namespace: item.metadata?.namespace,
          resource: resource,
          item: item,
          status: status,
          details: [
            tFmt(context, 'Capacity: {0}', [
              item.spec?.capacity != null &&
                      item.spec!.capacity!.containsKey('storage')
                  ? item.spec!.capacity!['storage']
                  : '-',
            ]),
            tFmt(context, 'Access Modes: {0}', [
              item.spec?.accessModes?.map((e) => e.value).join(', ') ?? '-',
            ]),
            tFmt(context, 'Reclaim Policy: {0}', [
              item.spec?.persistentVolumeReclaimPolicy?.value ?? '-',
            ]),
            tFmt(context, 'Status: {0}', [item.status?.phase?.value ?? '-']),
            tFmt(context, 'Claim: {0}/{1}', [
              item.spec?.claimRef?.namespace ?? '-',
              item.spec?.claimRef?.name ?? '-',
            ]),
            tFmt(context, 'Storage Class: {0}', [
              item.spec?.storageClassName ?? '-',
            ]),
            tFmt(context, 'Reason: {0}', [item.status?.reason ?? '-']),
            tFmt(context, 'Age: {0}', [
              getAge(item.metadata?.creationTimestamp),
            ]),
          ],
        );
      },
  previewItemBuilder: (BuildContext context, dynamic listItem) {
    final item = listItem as IoK8sApiCoreV1PersistentVolume;

    return [
      tFmt(context, 'Capacity: {0}', [
        item.spec?.capacity != null &&
                item.spec!.capacity!.containsKey('storage')
            ? item.spec!.capacity!['storage']
            : '-',
      ]),
      tFmt(context, 'Access Modes: {0}', [
        item.spec?.accessModes?.map((e) => e.value).join(', ') ?? '-',
      ]),
      tFmt(context, 'Reclaim Policy: {0}', [
        item.spec?.persistentVolumeReclaimPolicy?.value ?? '-',
      ]),
      tFmt(context, 'Status: {0}', [item.status?.phase?.value ?? '-']),
      tFmt(context, 'Claim: {0}/{1}', [
        item.spec?.claimRef?.namespace ?? '-',
        item.spec?.claimRef?.name ?? '-',
      ]),
      tFmt(context, 'Storage Class: {0}', [item.spec?.storageClassName ?? '-']),
      tFmt(context, 'Reason: {0}', [item.status?.reason ?? '-']),
      tFmt(context, 'Age: {0}', [getAge(item.metadata?.creationTimestamp)]),
    ];
  },
  detailsItemBuilder: (BuildContext context, Resource resource, dynamic detailsItem) {
    final item = detailsItem as IoK8sApiCoreV1PersistentVolume;

    return Column(
      children: [
        DetailsItemMetadata(kind: item.kind, metadata: item.metadata),
        const SizedBox(height: Constants.spacingMiddle),
        DetailsItem(
          title: t(context, 'Configuration'),
          details: [
            DetailsItemModel(
              name: t(context, 'Storage Class'),
              values: item.spec?.storageClassName,
              onTap: item.spec?.storageClassName == null
                  ? null
                  : (index) {
                      navigate(
                        context,
                        ResourcesDetails(
                          name: item.spec!.storageClassName!,
                          namespace: null,
                          resource: resourceStorageClass,
                        ),
                      );
                    },
            ),
            DetailsItemModel(
              name: t(context, 'Reclaim Policy'),
              values: item.spec?.persistentVolumeReclaimPolicy?.value,
            ),
            DetailsItemModel(
              name: t(context, 'Access Modes'),
              values: item.spec?.accessModes?.map((e) => e.value).toList(),
            ),
            DetailsItemModel(
              name: t(context, 'Storage'),
              values:
                  item.spec?.capacity != null &&
                      item.spec!.capacity!.containsKey('storage')
                  ? item.spec?.capacity!['storage']
                  : null,
            ),
            DetailsItemModel(
              name: t(context, 'Mount Options'),
              values: item.spec?.mountOptions,
            ),
          ],
        ),
        const SizedBox(height: Constants.spacingMiddle),
        DetailsItem(
          title: t(context, 'Status'),
          details: [
            DetailsItemModel(
              name: t(context, 'Status'),
              values: item.status?.phase?.value,
            ),
            DetailsItemModel(
              name: t(context, 'Claim'),
              values:
                  '${item.spec?.claimRef?.namespace ?? '-'}/${item.spec?.claimRef?.name ?? '-'}',
              onTap:
                  item.spec?.claimRef?.namespace == null ||
                      item.spec?.claimRef?.name == null
                  ? null
                  : (index) {
                      navigate(
                        context,
                        ResourcesDetails(
                          name: item.spec!.claimRef!.name!,
                          namespace: item.spec!.claimRef!.namespace,
                          resource: resourcePersistentVolumeClaim,
                        ),
                      );
                    },
            ),
          ],
        ),
        const SizedBox(height: Constants.spacingMiddle),
        DetailsResourcesPreview(
          resource: resourceEvent,
          namespace: item.metadata?.namespace,
          selector:
              'fieldSelector=involvedObject.name=${item.metadata?.name ?? ''}',
          filter: null,
        ),
        const SizedBox(height: Constants.spacingMiddle),
        AppPrometheusChartsWidget(
          item: item,
          toJson: resource.toJson,
          defaultCharts: [
            Chart(
              title: t(context, 'Capacity'),
              unit: 'GiB',
              queries: [
                Query(
                  query: 'kube_persistentvolume_capacity_bytes{persistentvolume="{{with .metadata}}{{with .name}}{{.}}{{end}}{{end}}"} / 1024 / 1024 / 1024',
                  label: t(context, 'Capacity'),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  },
);

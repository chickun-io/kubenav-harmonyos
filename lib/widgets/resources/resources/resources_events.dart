import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:kubenav/models/kubernetes/schema.models.swagger.dart';
import 'package:kubenav/utils/constants.dart';
import 'package:kubenav/utils/l10n.dart';
import 'package:kubenav/utils/resources.dart';
import 'package:kubenav/widgets/resources/helpers/details_item.dart';
import 'package:kubenav/widgets/resources/helpers/details_item_metadata.dart';
import 'package:kubenav/widgets/resources/resources/resources.dart';
import 'package:kubenav/widgets/resources/resources_list.dart';
import 'package:kubenav/widgets/shared/app_prometheus_charts_widget.dart';

final resourceEvent = Resource(
  category: ResourceCategories.cluster,
  plural: 'Events',
  singular: 'Event',
  description: 'Events are automatically created when other resources have state changes, errors, or other messages that should be broadcast to the system.',
  path: '/api/v1',
  resource: 'events',
  scope: ResourceScope.namespaced,
  additionalPrinterColumns: [],
  icon: 'events',
  template: resourceDefaultTemplate,
  decodeListData: (ResourcesListData data) {
    final parsed = json.decode(data.list);
    final items = IoK8sApiCoreV1EventList.fromJson(parsed).items;

    return items
        .map(
          (e) => ResourceItem(
            item: e,
            metrics: null,
            status: e.type == 'Normal'
                ? ResourceStatus.success
                : ResourceStatus.warning,
          ),
        )
        .toList();
  },
  decodeList: (String data) {
    final parsed = json.decode(data);
    return IoK8sApiCoreV1EventList.fromJson(parsed).items;
  },
  getName: (dynamic item) {
    return (item as IoK8sApiCoreV1Event).metadata.name ?? '';
  },
  getNamespace: (dynamic item) {
    return (item as IoK8sApiCoreV1Event).metadata.namespace;
  },
  decodeItem: (String data) {
    final parsed = json.decode(data);
    return IoK8sApiCoreV1Event.fromJson(parsed);
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
        final item = listItem.item as IoK8sApiCoreV1Event;
        final status = listItem.status;

        return ResourcesListItem(
          name: item.metadata.name ?? '',
          namespace: item.metadata.namespace,
          resource: resource,
          item: item,
          status: status,
          details: [
            tFmt(context, 'Namespace: {0}', [item.metadata.namespace ?? '-']),
            tFmt(context, 'Last Seen: {0}', [
              getAge(
                item.lastTimestamp ??
                    item.eventTime ??
                    item.metadata.creationTimestamp,
              ),
            ]),
            tFmt(context, 'Type: {0}', [item.type ?? '-']),
            tFmt(context, 'Reason: {0}', [item.reason ?? '-']),
            tFmt(context, 'Object: {0}/{1}', [
              item.involvedObject.kind ?? '-',
              item.involvedObject.name ?? '-',
            ]),
            tFmt(context, 'Message: {0}', [item.message ?? '-']),
          ],
        );
      },
  previewItemBuilder: (BuildContext context, dynamic listItem) {
    final item = listItem as IoK8sApiCoreV1Event;

    return [
      tFmt(context, 'Namespace: {0}', [item.metadata.namespace ?? '-']),
      tFmt(context, 'Last Seen: {0}', [
        getAge(
          item.lastTimestamp ??
              item.eventTime ??
              item.metadata.creationTimestamp,
        ),
      ]),
      tFmt(context, 'Type: {0}', [item.type ?? '-']),
      tFmt(context, 'Reason: {0}', [item.reason ?? '-']),
      tFmt(context, 'Object: {0}/{1}', [
        item.involvedObject.kind ?? '-',
        item.involvedObject.name ?? '-',
      ]),
      tFmt(context, 'Message: {0}', [item.message ?? '-']),
    ];
  },
  detailsItemBuilder:
      (BuildContext context, Resource resource, dynamic detailsItem) {
        final item = detailsItem as IoK8sApiCoreV1Event;

        return Column(
          children: [
            DetailsItemMetadata(kind: item.kind, metadata: item.metadata),
            const SizedBox(height: Constants.spacingMiddle),
            DetailsItem(
              title: t(context, 'Details'),
              details: [
                DetailsItemModel(name: t(context, 'Type'), values: item.type),
                DetailsItemModel(
                  name: t(context, 'Reason'),
                  values: item.reason,
                ),
                DetailsItemModel(
                  name: t(context, 'Message'),
                  values: item.message,
                ),
                DetailsItemModel(
                  name: t(context, 'Event Time'),
                  values: getAge(item.eventTime),
                ),
                DetailsItemModel(
                  name: t(context, 'Last Seen'),
                  values: getAge(item.lastTimestamp),
                ),
                DetailsItemModel(
                  name: t(context, 'First Seen'),
                  values: getAge(item.firstTimestamp),
                ),
                DetailsItemModel(name: t(context, 'Count'), values: item.count),
                DetailsItemModel(
                  name: t(context, 'Source'),
                  values: item.source?.component,
                ),
                DetailsItemModel(
                  name: t(context, 'Reporting Component'),
                  values: item.reportingComponent,
                ),
              ],
            ),
            const SizedBox(height: Constants.spacingMiddle),
            DetailsItem(
              title: t(context, 'Involved Object'),
              goTo: t(context, 'View'),
              goToOnTap: () {
                goToReference(context, item.involvedObject, null);
              },
              details: [
                DetailsItemModel(
                  name: t(context, 'API Version'),
                  values: item.involvedObject.apiVersion,
                ),
                DetailsItemModel(
                  name: t(context, 'Kind'),
                  values: item.involvedObject.kind,
                ),
                DetailsItemModel(
                  name: t(context, 'Name'),
                  values: item.involvedObject.name,
                ),
                DetailsItemModel(
                  name: t(context, 'Namespace'),
                  values: item.involvedObject.namespace,
                ),
              ],
            ),
            const SizedBox(height: Constants.spacingMiddle),
            AppPrometheusChartsWidget(
              item: item,
              toJson: resource.toJson,
              defaultCharts: const [],
            ),
          ],
        );
      },
);

import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:kubenav/models/kubernetes/schema.models.swagger.dart';
import 'package:kubenav/models/plugins/prometheus.dart';
import 'package:kubenav/utils/constants.dart';
import 'package:kubenav/utils/l10n.dart';
import 'package:kubenav/utils/resources.dart';
import 'package:kubenav/widgets/resources/helpers/details_item.dart';
import 'package:kubenav/widgets/resources/helpers/details_item_conditions.dart';
import 'package:kubenav/widgets/resources/helpers/details_item_metadata.dart';
import 'package:kubenav/widgets/resources/helpers/details_resources_preview.dart';
import 'package:kubenav/widgets/resources/resources/resources.dart';
import 'package:kubenav/widgets/resources/resources/resources_events.dart';
import 'package:kubenav/widgets/resources/resources/resources_pods.dart';
import 'package:kubenav/widgets/resources/resources_list.dart';
import 'package:kubenav/widgets/shared/app_prometheus_charts_widget.dart';

final resourceDaemonSet = Resource(
  category: ResourceCategories.workload,
  plural: 'DaemonSets',
  singular: 'DaemonSet',
  description:
      'A DaemonSet ensures that all (or some) Nodes run a copy of a Pod.',
  path: '/apis/apps/v1',
  resource: 'daemonsets',
  scope: ResourceScope.namespaced,
  additionalPrinterColumns: [],
  icon: 'daemonsets',
  template: '{"apiVersion":"apps/v1","kind":"DaemonSet","metadata":{"name":"","namespace":""},"spec":{"selector":{"matchLabels":{"app":"nginx"}},"template":{"metadata":{"labels":{"app":"nginx"}},"spec":{"containers":[{"name":"nginx","image":"nginx:1.14.2"}]}}}}',
  decodeListData: (ResourcesListData data) {
    final parsed = json.decode(data.list);
    final items = IoK8sApiAppsV1DaemonSetList.fromJson(parsed).items;

    return items
        .map(
          (e) => ResourceItem(
            item: e,
            metrics: null,
            status: e.status!.desiredNumberScheduled == 0
                ? ResourceStatus.warning
                : e.status!.desiredNumberScheduled !=
                          e.status!.currentNumberScheduled ||
                      e.status!.desiredNumberScheduled !=
                          e.status!.numberReady ||
                      e.status!.desiredNumberScheduled !=
                          e.status!.updatedNumberScheduled ||
                      e.status!.desiredNumberScheduled !=
                          e.status!.numberAvailable ||
                      e.status!.numberMisscheduled > 0
                ? ResourceStatus.danger
                : ResourceStatus.success,
          ),
        )
        .toList();
  },
  decodeList: (String data) {
    final parsed = json.decode(data);
    return IoK8sApiAppsV1DaemonSetList.fromJson(parsed).items;
  },
  getName: (dynamic item) {
    return (item as IoK8sApiAppsV1DaemonSet).metadata?.name ?? '';
  },
  getNamespace: (dynamic item) {
    return (item as IoK8sApiAppsV1DaemonSet).metadata?.namespace;
  },
  decodeItem: (String data) {
    final parsed = json.decode(data);
    return IoK8sApiAppsV1DaemonSet.fromJson(parsed);
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
        final item = listItem.item as IoK8sApiAppsV1DaemonSet;
        final status = listItem.status;

        final nodeSelector =
            item.spec?.template.spec?.nodeSelector?.entries
                .map((e) => '${e.key}=${e.value}')
                .toList() ??
            [];

        return ResourcesListItem(
          name: item.metadata?.name ?? '',
          namespace: item.metadata?.namespace,
          resource: resource,
          item: item,
          status: status,
          details: [
            tFmt(context, 'Namespace: {0}', [item.metadata?.namespace ?? '-']),
            tFmt(context, 'Desired: {0}', [
              item.status?.desiredNumberScheduled ?? 0,
            ]),
            tFmt(context, 'Current: {0}', [
              item.status?.currentNumberScheduled ?? 0,
            ]),
            tFmt(context, 'Ready: {0}', [item.status?.numberReady ?? 0]),
            tFmt(context, 'Up to Date: {0}', [
              item.status?.updatedNumberScheduled ?? 0,
            ]),
            tFmt(context, 'Available: {0}', [
              item.status?.numberAvailable ?? 0,
            ]),
            tFmt(context, 'Misscheduled: {0}', [
              item.status?.numberMisscheduled ?? 0,
            ]),
            tFmt(context, 'Node Selector: {0}', [
              nodeSelector.isEmpty ? '-' : nodeSelector.join(', '),
            ]),
            tFmt(context, 'Age: {0}', [
              getAge(item.metadata?.creationTimestamp),
            ]),
          ],
        );
      },
  previewItemBuilder: (BuildContext context, dynamic listItem) {
    final item = listItem as IoK8sApiAppsV1DaemonSet;

    final nodeSelector =
        item.spec?.template.spec?.nodeSelector?.entries
            .map((e) => '${e.key}=${e.value}')
            .toList() ??
        [];

    return [
      tFmt(context, 'Namespace: {0}', [item.metadata?.namespace ?? '-']),
      tFmt(context, 'Desired: {0}', [item.status?.desiredNumberScheduled ?? 0]),
      tFmt(context, 'Current: {0}', [item.status?.currentNumberScheduled ?? 0]),
      tFmt(context, 'Ready: {0}', [item.status?.numberReady ?? 0]),
      tFmt(context, 'Up to Date: {0}', [
        item.status?.updatedNumberScheduled ?? 0,
      ]),
      tFmt(context, 'Available: {0}', [item.status?.numberAvailable ?? 0]),
      tFmt(context, 'Misscheduled: {0}', [
        item.status?.numberMisscheduled ?? 0,
      ]),
      tFmt(context, 'Node Selector: {0}', [
        nodeSelector.isEmpty ? '-' : nodeSelector.join(', '),
      ]),
      tFmt(context, 'Age: {0}', [getAge(item.metadata?.creationTimestamp)]),
    ];
  },
  detailsItemBuilder:
      (BuildContext context, Resource resource, dynamic detailsItem) {
        final item = detailsItem as IoK8sApiAppsV1DaemonSet;

        return Column(
          children: [
            DetailsItemMetadata(kind: item.kind, metadata: item.metadata),
            DetailsItemConditions(
              conditions: item.status?.conditions
                  ?.map(
                    (e) => IoK8sApimachineryPkgApisMetaV1Condition(
                      lastTransitionTime:
                          e.lastTransitionTime ?? DateTime.now(),
                      message: e.message ?? '',
                      observedGeneration: null,
                      reason: e.reason ?? '',
                      status: e.status,
                      type: e.type,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: Constants.spacingMiddle),
            DetailsItem(
              title: t(context, 'Configuration'),
              details: [
                DetailsItemModel(
                  name: t(context, 'Revision History Limit'),
                  values: item.spec?.revisionHistoryLimit,
                ),
                DetailsItemModel(
                  name: t(context, 'Update Strategy'),
                  values: item.spec?.updateStrategy?.type?.value,
                ),
                DetailsItemModel(
                  name: t(context, 'Selector'),
                  values: item.spec?.selector.matchLabels?.entries
                      .map(
                        (matchLabel) => '${matchLabel.key}=${matchLabel.value}',
                      )
                      .toList(),
                ),
              ],
            ),
            const SizedBox(height: Constants.spacingMiddle),
            DetailsItem(
              title: t(context, 'Status'),
              details: [
                DetailsItemModel(
                  name: t(context, 'Desired'),
                  values: item.status?.desiredNumberScheduled,
                ),
                DetailsItemModel(
                  name: t(context, 'Current'),
                  values: item.status?.currentNumberScheduled,
                ),
                DetailsItemModel(
                  name: t(context, 'Ready'),
                  values: item.status?.numberReady,
                ),
                DetailsItemModel(
                  name: t(context, 'Available'),
                  values: item.status?.numberAvailable,
                ),
                DetailsItemModel(
                  name: t(context, 'Up to Date'),
                  values: item.status?.updatedNumberScheduled,
                ),
                DetailsItemModel(
                  name: t(context, 'Misscheduled'),
                  values: item.status?.numberMisscheduled,
                ),
              ],
            ),
            const SizedBox(height: Constants.spacingMiddle),
            DetailsResourcesPreview(
              resource: resourcePod,
              namespace: item.metadata?.namespace,
              selector: getSelector(item.spec?.selector),
              filter: null,
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
                  title: t(context, 'Pods'),
                  unit: '',
                  queries: [
                    Query(
                      query: 'kube_daemonset_status_desired_number_scheduled{namespace="{{with .metadata}}{{with .namespace}}{{.}}{{end}}{{end}}", daemonset="{{with .metadata}}{{with .name}}{{.}}{{end}}{{end}}"}',
                      label: t(context, 'Desired'),
                    ),
                    Query(
                      query: 'kube_daemonset_status_current_number_scheduled{namespace="{{with .metadata}}{{with .namespace}}{{.}}{{end}}{{end}}", daemonset="{{with .metadata}}{{with .name}}{{.}}{{end}}{{end}}"}',
                      label: t(context, 'Current'),
                    ),
                    Query(
                      query: 'kube_daemonset_status_number_ready{namespace="{{with .metadata}}{{with .namespace}}{{.}}{{end}}{{end}}", daemonset="{{with .metadata}}{{with .name}}{{.}}{{end}}{{end}}"}',
                      label: t(context, 'Ready'),
                    ),
                    Query(
                      query: 'kube_daemonset_status_number_misscheduled{namespace="{{with .metadata}}{{with .namespace}}{{.}}{{end}}{{end}}", daemonset="{{with .metadata}}{{with .name}}{{.}}{{end}}{{end}}"}',
                      label: t(context, 'Misscheduled'),
                    ),
                    Query(
                      query: 'kube_daemonset_updated_number_scheduled{namespace="{{with .metadata}}{{with .namespace}}{{.}}{{end}}{{end}}", daemonset="{{with .metadata}}{{with .name}}{{.}}{{end}}{{end}}"}',
                      label: t(context, 'Updated'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      },
);

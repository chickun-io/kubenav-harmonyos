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

final resourcePodDisruptionBudget = Resource(
  category: ResourceCategories.configAndStorage,
  plural: 'PodDisruptionBudgets',
  singular: 'PodDisruptionBudget',
  description: 'PDBs provide a way to limit the number of concurrent disruptions that your application experiences.',
  path: '/apis/policy/v1',
  resource: 'poddisruptionbudgets',
  scope: ResourceScope.namespaced,
  additionalPrinterColumns: [],
  icon: 'poddisruptionbudgets',
  template: resourceDefaultTemplate,
  decodeListData: (ResourcesListData data) {
    final parsed = json.decode(data.list);
    final items = IoK8sApiPolicyV1PodDisruptionBudgetList.fromJson(parsed)
        .items;

    return items
        .map(
          (e) => ResourceItem(
            item: e,
            metrics: null,
            status:
                e.status!.currentHealthy == 0 ||
                    e.status!.desiredHealthy == 0 ||
                    e.status!.disruptionsAllowed == 0
                ? ResourceStatus.warning
                : (e.status!.currentHealthy ?? 0) <
                      (e.status!.desiredHealthy ?? 0)
                ? ResourceStatus.danger
                : ResourceStatus.success,
          ),
        )
        .toList();
  },
  decodeList: (String data) {
    final parsed = json.decode(data);
    return IoK8sApiPolicyV1PodDisruptionBudgetList.fromJson(parsed).items;
  },
  getName: (dynamic item) {
    return (item as IoK8sApiPolicyV1PodDisruptionBudget).metadata?.name ?? '';
  },
  getNamespace: (dynamic item) {
    return (item as IoK8sApiPolicyV1PodDisruptionBudget).metadata?.namespace;
  },
  decodeItem: (String data) {
    final parsed = json.decode(data);
    return IoK8sApiPolicyV1PodDisruptionBudget.fromJson(parsed);
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
        final item = listItem.item as IoK8sApiPolicyV1PodDisruptionBudget;
        final status = listItem.status;

        return ResourcesListItem(
          name: item.metadata?.name ?? '',
          namespace: item.metadata?.namespace,
          resource: resource,
          item: item,
          status: status,
          details: [
            tFmt(context, 'Namespace: {0}', [item.metadata?.namespace ?? '-']),
            tFmt(context, 'Min. Available: {0}', [
              item.spec?.minAvailable ?? '-',
            ]),
            tFmt(context, 'Max. Unavailable: {0}', [
              item.spec?.maxUnavailable ?? '-',
            ]),
            tFmt(context, 'Allowed Disruptions: {0}', [
              item.status?.disruptionsAllowed ?? 0,
            ]),
            tFmt(context, 'Age: {0}', [
              getAge(item.metadata?.creationTimestamp),
            ]),
          ],
        );
      },
  previewItemBuilder: (BuildContext context, dynamic listItem) {
    final item = listItem as IoK8sApiPolicyV1PodDisruptionBudget;

    return [
      tFmt(context, 'Namespace: {0}', [item.metadata?.namespace ?? '-']),
      tFmt(context, 'Min. Available: {0}', [item.spec?.minAvailable ?? '-']),
      tFmt(context, 'Max. Unavailable: {0}', [
        item.spec?.maxUnavailable ?? '-',
      ]),
      tFmt(context, 'Allowed Disruptions: {0}', [
        item.status?.disruptionsAllowed ?? 0,
      ]),
      tFmt(context, 'Age: {0}', [getAge(item.metadata?.creationTimestamp)]),
    ];
  },
  detailsItemBuilder:
      (BuildContext context, Resource resource, dynamic detailsItem) {
        final item = detailsItem as IoK8sApiPolicyV1PodDisruptionBudget;

        return Column(
          children: [
            DetailsItemMetadata(kind: item.kind, metadata: item.metadata),
            DetailsItemConditions(conditions: item.status?.conditions),
            const SizedBox(height: Constants.spacingMiddle),
            DetailsItem(
              title: t(context, 'Configuration'),
              details: [
                DetailsItemModel(
                  name: t(context, 'Selector'),
                  values: item.spec?.selector?.matchLabels?.entries
                      .map(
                        (matchLabels) =>
                            '${matchLabels.key}=${matchLabels.value}',
                      )
                      .toList(),
                ),
                DetailsItemModel(
                  name: t(context, 'Min. Available'),
                  values: item.spec?.minAvailable,
                ),
                DetailsItemModel(
                  name: t(context, 'Max. Unavailable'),
                  values: item.spec?.maxUnavailable,
                ),
              ],
            ),
            const SizedBox(height: Constants.spacingMiddle),
            DetailsItem(
              title: t(context, 'Status'),
              details: [
                DetailsItemModel(
                  name: t(context, 'Current Healthy'),
                  values: item.status?.currentHealthy,
                ),
                DetailsItemModel(
                  name: t(context, 'Desired Healthy'),
                  values: item.status?.desiredHealthy,
                ),
                DetailsItemModel(
                  name: t(context, 'Disruptions Allowed'),
                  values: item.status?.disruptionsAllowed,
                ),
                DetailsItemModel(
                  name: t(context, 'Expected Pods'),
                  values: item.status?.expectedPods,
                ),
                DetailsItemModel(
                  name: t(context, 'Observed Generation'),
                  values: item.status?.observedGeneration,
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
                      query: 'kube_poddisruptionbudget_status_desired_healthy{namespace="{{with .metadata}}{{with .namespace}}{{.}}{{end}}{{end}}", poddisruptionbudget="{{with .metadata}}{{with .name}}{{.}}{{end}}{{end}}"}',
                      label: t(context, 'Desired'),
                    ),
                    Query(
                      query: 'kube_poddisruptionbudget_status_current_healthy{namespace="{{with .metadata}}{{with .namespace}}{{.}}{{end}}{{end}}", poddisruptionbudget="{{with .metadata}}{{with .name}}{{.}}{{end}}{{end}}"}',
                      label: t(context, 'Current'),
                    ),
                    Query(
                      query: 'kube_poddisruptionbudget_status_pod_disruptions_allowed{namespace="{{with .metadata}}{{with .namespace}}{{.}}{{end}}{{end}}", poddisruptionbudget="{{with .metadata}}{{with .name}}{{.}}{{end}}{{end}}"}',
                      label: t(context, 'Allowed Disruptions'),
                    ),
                    Query(
                      query: 'kube_poddisruptionbudget_status_expected_pods{namespace="{{with .metadata}}{{with .namespace}}{{.}}{{end}}{{end}}", poddisruptionbudget="{{with .metadata}}{{with .name}}{{.}}{{end}}{{end}}"}',
                      label: t(context, 'Expected'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      },
);

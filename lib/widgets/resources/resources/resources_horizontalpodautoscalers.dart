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
import 'package:kubenav/widgets/resources/resources_list.dart';
import 'package:kubenav/widgets/shared/app_prometheus_charts_widget.dart';

final resourceHorizontalPodAutoscaler = Resource(
  category: ResourceCategories.discoveryandloadbalancing,
  plural: 'HorizontalPodAutoscalers',
  singular: 'HorizontalPodAutoscaler',
  description: 'A HorizontalPodAutoscaler automatically updates a workload resource, with the aim of automatically scaling the workload to match demand.',
  path: '/apis/autoscaling/v2',
  resource: 'horizontalpodautoscalers',
  scope: ResourceScope.namespaced,
  additionalPrinterColumns: [],
  icon: 'horizontalpodautoscalers',
  template: resourceDefaultTemplate,
  decodeListData: (ResourcesListData data) {
    final parsed = json.decode(data.list);
    final items = IoK8sApiAutoscalingV2HorizontalPodAutoscalerList.fromJson(
      parsed,
    ).items;

    return items.map((e) {
      final currentReplicas = e.status!.currentReplicas ?? 0;
      final desiredReplicas = e.status!.desiredReplicas;
      final maxReplicas = e.spec.maxReplicas;
      final minReplicas = e.spec.minReplicas;

      return ResourceItem(
        item: e,
        metrics: null,
        status:
            currentReplicas == maxReplicas || currentReplicas != desiredReplicas
            ? ResourceStatus.warning
            : currentReplicas < (minReplicas ?? 0) ||
                  currentReplicas > maxReplicas
            ? ResourceStatus.danger
            : ResourceStatus.success,
      );
    }).toList();
  },
  decodeList: (String data) {
    final parsed = json.decode(data);
    return IoK8sApiAutoscalingV2HorizontalPodAutoscalerList.fromJson(parsed)
        .items;
  },
  getName: (dynamic item) {
    return (item as IoK8sApiAutoscalingV2HorizontalPodAutoscaler)
            .metadata
            ?.name ??
        '';
  },
  getNamespace: (dynamic item) {
    return (item as IoK8sApiAutoscalingV2HorizontalPodAutoscaler)
        .metadata
        ?.namespace;
  },
  decodeItem: (String data) {
    final parsed = json.decode(data);
    return IoK8sApiAutoscalingV2HorizontalPodAutoscaler.fromJson(parsed);
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
        final item =
            listItem.item as IoK8sApiAutoscalingV2HorizontalPodAutoscaler;
        final status = listItem.status;

        return ResourcesListItem(
          name: item.metadata?.name ?? '',
          namespace: item.metadata?.namespace,
          resource: resource,
          item: item,
          status: status,
          details: [
            tFmt(context, 'Namespace: {0}', [item.metadata?.namespace ?? '-']),
            tFmt(context, 'Reference: {0}/{1}', [
              item.spec.scaleTargetRef.kind,
              item.spec.scaleTargetRef.name,
            ]),
            tFmt(context, 'Replicas: {0}/{1}', [
              item.status?.currentReplicas ?? 0,
              item.status?.desiredReplicas,
            ]),
            tFmt(context, 'Min. Pods: {0}', [item.spec.minReplicas]),
            tFmt(context, 'Max. Pods: {0}', [item.spec.maxReplicas]),
            tFmt(context, 'Age: {0}', [
              getAge(item.metadata?.creationTimestamp),
            ]),
          ],
        );
      },
  previewItemBuilder: (BuildContext context, dynamic listItem) {
    final item = listItem as IoK8sApiAutoscalingV2HorizontalPodAutoscaler;

    return [
      tFmt(context, 'Namespace: {0}', [item.metadata?.namespace ?? '-']),
      tFmt(context, 'Reference: {0}/{1}', [
        item.spec.scaleTargetRef.kind,
        item.spec.scaleTargetRef.name,
      ]),
      tFmt(context, 'Replicas: {0}/{1}', [
        item.status?.currentReplicas ?? 0,
        item.status?.desiredReplicas,
      ]),
      tFmt(context, 'Min. Pods: {0}', [item.spec.minReplicas]),
      tFmt(context, 'Max. Pods: {0}', [item.spec.maxReplicas]),
      tFmt(context, 'Age: {0}', [getAge(item.metadata?.creationTimestamp)]),
    ];
  },
  detailsItemBuilder: (BuildContext context, Resource resource, dynamic detailsItem) {
    final item = detailsItem as IoK8sApiAutoscalingV2HorizontalPodAutoscaler;

    return Column(
      children: [
        DetailsItemMetadata(kind: item.kind, metadata: item.metadata),
        DetailsItemConditions(
          conditions: item.status?.conditions
              ?.map(
                (e) => IoK8sApimachineryPkgApisMetaV1Condition(
                  lastTransitionTime: e.lastTransitionTime ?? DateTime.now(),
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
              name: t(context, 'Min. Replicas'),
              values: item.spec.minReplicas,
            ),
            DetailsItemModel(
              name: t(context, 'Max. Replicas'),
              values: item.spec.maxReplicas,
            ),
            DetailsItemModel(
              name: t(context, 'Reference'),
              values:
                  '${item.spec.scaleTargetRef.kind}/${item.spec.scaleTargetRef.name}',
              onTap: (int index) {
                goToReference(
                  context,
                  IoK8sApimachineryPkgApisMetaV1OwnerReference(
                    apiVersion: item.spec.scaleTargetRef.apiVersion ?? '',
                    kind: item.spec.scaleTargetRef.kind,
                    name: item.spec.scaleTargetRef.name,
                    uid: '',
                  ),
                  item.metadata?.namespace,
                );
              },
            ),
          ],
        ),
        const SizedBox(height: Constants.spacingMiddle),
        DetailsItem(
          title: t(context, 'Status'),
          details: [
            DetailsItemModel(
              name: t(context, 'Desired Replicas'),
              values: item.status?.desiredReplicas,
            ),
            DetailsItemModel(
              name: t(context, 'Current Replicas'),
              values: item.status?.currentReplicas,
            ),
            DetailsItemModel(
              name: t(context, 'Last Scale Time'),
              values: formatTime(item.status?.lastScaleTime),
            ),
          ],
        ),
        const SizedBox(height: Constants.spacingMiddle),
        ..._buildReference(item),
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
                  query: 'kube_horizontalpodautoscaler_status_desired_replicas{namespace="{{with .metadata}}{{with .namespace}}{{.}}{{end}}{{end}}", horizontalpodautoscaler="{{with .metadata}}{{with .name}}{{.}}{{end}}{{end}}"}',
                  label: t(context, 'Desired'),
                ),
                Query(
                  query: 'kube_horizontalpodautoscaler_status_current_replicas{namespace="{{with .metadata}}{{with .namespace}}{{.}}{{end}}{{end}}", horizontalpodautoscaler="{{with .metadata}}{{with .name}}{{.}}{{end}}{{end}}"}',
                  label: t(context, 'Current'),
                ),
                Query(
                  query: 'kube_horizontalpodautoscaler_spec_min_replicas{namespace="{{with .metadata}}{{with .namespace}}{{.}}{{end}}{{end}}", horizontalpodautoscaler="{{with .metadata}}{{with .name}}{{.}}{{end}}{{end}}"}',
                  label: t(context, 'Min'),
                ),
                Query(
                  query: 'kube_horizontalpodautoscaler_spec_max_replicas{namespace="{{with .metadata}}{{with .namespace}}{{.}}{{end}}{{end}}", horizontalpodautoscaler="{{with .metadata}}{{with .name}}{{.}}{{end}}{{end}}"}',
                  label: t(context, 'Max'),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  },
);

List<Widget> _buildReference(IoK8sApiAutoscalingV2HorizontalPodAutoscaler hpa) {
  if (hpa.spec.scaleTargetRef.kind != 'Deployment' &&
      hpa.spec.scaleTargetRef.kind != 'StatefulSet') {
    return [Container()];
  }

  return [
    DetailsResourcesPreview(
      resource: kindToResource[hpa.spec.scaleTargetRef.kind]!,
      namespace: hpa.metadata?.namespace,
      selector: 'fieldSelector=metadata.name=${hpa.spec.scaleTargetRef.name}',
      filter: null,
    ),
    const SizedBox(height: Constants.spacingMiddle),
  ];
}

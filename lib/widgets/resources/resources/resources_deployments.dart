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

final resourceDeployment = Resource(
  category: ResourceCategories.workload,
  plural: 'Deployments',
  singular: 'Deployment',
  description:
      'A Deployment provides declarative updates for Pods and ReplicaSets.',
  path: '/apis/apps/v1',
  resource: 'deployments',
  scope: ResourceScope.namespaced,
  additionalPrinterColumns: [],
  icon: 'deployments',
  template: '{"apiVersion":"apps/v1","kind":"Deployment","metadata":{"name":"","namespace":""},"spec":{"replicas":1,"selector":{"matchLabels":{"app":"nginx"}},"template":{"metadata":{"labels":{"app":"nginx"}},"spec":{"containers":[{"name":"nginx","image":"nginx:1.14.2"}]}}}}',
  decodeListData: (ResourcesListData data) {
    final parsed = json.decode(data.list);
    final items = IoK8sApiAppsV1DeploymentList.fromJson(parsed).items;

    return items
        .map(
          (e) => ResourceItem(
            item: e,
            metrics: null,
            status: e.status!.replicas == 0
                ? ResourceStatus.warning
                : e.status!.replicas != e.status!.readyReplicas ||
                      e.status!.replicas != e.status!.updatedReplicas ||
                      e.status!.replicas != e.status!.availableReplicas
                ? ResourceStatus.danger
                : ResourceStatus.success,
          ),
        )
        .toList();
  },
  decodeList: (String data) {
    final parsed = json.decode(data);
    return IoK8sApiAppsV1DeploymentList.fromJson(parsed).items;
  },
  getName: (dynamic item) {
    return (item as IoK8sApiAppsV1Deployment).metadata?.name ?? '';
  },
  getNamespace: (dynamic item) {
    return (item as IoK8sApiAppsV1Deployment).metadata?.namespace;
  },
  decodeItem: (String data) {
    final parsed = json.decode(data);
    return IoK8sApiAppsV1Deployment.fromJson(parsed);
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
        final item = listItem.item as IoK8sApiAppsV1Deployment;
        final status = listItem.status;

        return ResourcesListItem(
          name: item.metadata?.name ?? '',
          namespace: item.metadata?.namespace,
          resource: resource,
          item: item,
          status: status,
          details: [
            tFmt(context, 'Namespace: {0}', [item.metadata?.namespace ?? '-']),
            tFmt(context, 'Replicas: {0}', [item.status?.replicas ?? 0]),
            tFmt(context, 'Ready: {0}', [item.status?.readyReplicas ?? 0]),
            tFmt(context, 'Updated: {0}', [item.status?.updatedReplicas ?? 0]),
            tFmt(context, 'Available: {0}', [
              item.status?.availableReplicas ?? 0,
            ]),
            tFmt(context, 'Age: {0}', [
              getAge(item.metadata?.creationTimestamp),
            ]),
          ],
        );
      },
  previewItemBuilder: (BuildContext context, dynamic listItem) {
    final item = listItem as IoK8sApiAppsV1Deployment;

    return [
      tFmt(context, 'Namespace: {0}', [item.metadata?.namespace ?? '-']),
      tFmt(context, 'Replicas: {0}', [item.status?.replicas ?? 0]),
      tFmt(context, 'Ready: {0}', [item.status?.readyReplicas ?? 0]),
      tFmt(context, 'Updated: {0}', [item.status?.updatedReplicas ?? 0]),
      tFmt(context, 'Available: {0}', [item.status?.availableReplicas ?? 0]),
      tFmt(context, 'Age: {0}', [getAge(item.metadata?.creationTimestamp)]),
    ];
  },
  detailsItemBuilder:
      (BuildContext context, Resource resource, dynamic detailsItem) {
        final item = detailsItem as IoK8sApiAppsV1Deployment;

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
                  name: t(context, 'Replicas'),
                  values: item.spec?.replicas,
                ),
                DetailsItemModel(
                  name: t(context, 'Revision History Limit'),
                  values: item.spec?.revisionHistoryLimit,
                ),
                DetailsItemModel(
                  name: t(context, 'Progress Deadline Seconds'),
                  values: item.spec?.progressDeadlineSeconds,
                ),
                DetailsItemModel(
                  name: t(context, 'Min. Ready Seconds'),
                  values: item.spec?.minReadySeconds,
                ),
                DetailsItemModel(
                  name: t(context, 'Update Strategy'),
                  values: item.spec?.strategy?.type?.value,
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
                  name: t(context, 'Desired Replicas'),
                  values: item.status?.replicas,
                ),
                DetailsItemModel(
                  name: t(context, 'Ready Replicas'),
                  values: item.status?.readyReplicas,
                ),
                DetailsItemModel(
                  name: t(context, 'Available Replicas'),
                  values: item.status?.availableReplicas,
                ),
                DetailsItemModel(
                  name: t(context, 'Unavailable Replicas'),
                  values: item.status?.unavailableReplicas,
                ),
                DetailsItemModel(
                  name: t(context, 'Updated Replicas'),
                  values: item.status?.updatedReplicas,
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
                      query: 'kube_deployment_spec_replicas{namespace="{{with .metadata}}{{with .namespace}}{{.}}{{end}}{{end}}", deployment="{{with .metadata}}{{with .name}}{{.}}{{end}}{{end}}"}',
                      label: t(context, 'Desired'),
                    ),
                    Query(
                      query: 'kube_deployment_status_replicas{namespace="{{with .metadata}}{{with .namespace}}{{.}}{{end}}{{end}}", deployment="{{with .metadata}}{{with .name}}{{.}}{{end}}{{end}}"}',
                      label: t(context, 'Current'),
                    ),
                    Query(
                      query: 'kube_deployment_status_replicas_available{namespace="{{with .metadata}}{{with .namespace}}{{.}}{{end}}{{end}}", deployment="{{with .metadata}}{{with .name}}{{.}}{{end}}{{end}}"}',
                      label: t(context, 'Available'),
                    ),
                    Query(
                      query: 'kube_deployment_status_replicas_updated{namespace="{{with .metadata}}{{with .namespace}}{{.}}{{end}}{{end}}", deployment="{{with .metadata}}{{with .name}}{{.}}{{end}}{{end}}"}',
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

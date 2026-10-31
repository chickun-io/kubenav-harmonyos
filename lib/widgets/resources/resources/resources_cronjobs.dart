import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:kubenav/models/kubernetes/schema.models.swagger.dart';
import 'package:kubenav/utils/constants.dart';
import 'package:kubenav/utils/l10n.dart';
import 'package:kubenav/utils/resources.dart';
import 'package:kubenav/widgets/resources/helpers/details_item.dart';
import 'package:kubenav/widgets/resources/helpers/details_item_metadata.dart';
import 'package:kubenav/widgets/resources/helpers/details_resources_preview.dart';
import 'package:kubenav/widgets/resources/resources/resources.dart';
import 'package:kubenav/widgets/resources/resources/resources_events.dart';
import 'package:kubenav/widgets/resources/resources/resources_jobs.dart';
import 'package:kubenav/widgets/resources/resources_list.dart';
import 'package:kubenav/widgets/shared/app_prometheus_charts_widget.dart';

final resourceCronJob = Resource(
  category: ResourceCategories.workload,
  plural: 'CronJobs',
  singular: 'CronJob',
  description: 'A CronJob creates Jobs on a repeating schedule.',
  path: '/apis/batch/v1',
  resource: 'cronjobs',
  scope: ResourceScope.namespaced,
  additionalPrinterColumns: [],
  icon: 'cronjobs',
  template: '{"apiVersion":"batch/v1","kind":"CronJob","metadata":{"name":"","namespace":""},"spec":{"schedule":"5 4 * * *","suspend":false,"successfulJobsHistoryLimit":1,"failedJobsHistoryLimit":1,"jobTemplate":{"spec":{"backoffLimit":0,"template":{"spec":{"containers":[{"name":"nginx","image":"nginx:1.14.2"}]}}}}}}',
  decodeListData: (ResourcesListData data) {
    final parsed = json.decode(data.list);
    final items = IoK8sApiBatchV1CronJobList.fromJson(parsed).items;

    return items
        .map(
          (e) => ResourceItem(
            item: e,
            metrics: null,
            status: e.spec.suspend == false
                ? ResourceStatus.success
                : ResourceStatus.warning,
          ),
        )
        .toList();
  },
  decodeList: (String data) {
    final parsed = json.decode(data);
    return IoK8sApiBatchV1CronJobList.fromJson(parsed).items;
  },
  getName: (dynamic item) {
    return (item as IoK8sApiBatchV1CronJob).metadata?.name ?? '';
  },
  getNamespace: (dynamic item) {
    return (item as IoK8sApiBatchV1CronJob).metadata?.namespace;
  },
  decodeItem: (String data) {
    final parsed = json.decode(data);
    return IoK8sApiBatchV1CronJob.fromJson(parsed);
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
        final item = listItem.item as IoK8sApiBatchV1CronJob;
        final status = listItem.status;

        return ResourcesListItem(
          name: item.metadata?.name ?? '',
          namespace: item.metadata?.namespace,
          resource: resource,
          item: item,
          status: status,
          details: [
            tFmt(context, 'Namespace: {0}', [item.metadata?.namespace ?? '-']),
            tFmt(context, 'Schedule: {0}', [item.spec.schedule]),
            tFmt(context, 'Suspend: {0}', [
              item.spec.suspend == false
                  ? t(context, 'False')
                  : t(context, 'True'),
            ]),
            tFmt(context, 'Active: {0}', [item.status?.active?.length ?? '-']),
            tFmt(context, 'Last Schedule: {0}', [
              getAge(item.status?.lastScheduleTime),
            ]),
            tFmt(context, 'Age: {0}', [
              getAge(item.metadata?.creationTimestamp),
            ]),
          ],
        );
      },
  previewItemBuilder: (BuildContext context, dynamic listItem) {
    final item = listItem as IoK8sApiBatchV1CronJob;

    return [
      tFmt(context, 'Namespace: {0}', [item.metadata?.namespace ?? '-']),
      tFmt(context, 'Schedule: {0}', [item.spec.schedule]),
      tFmt(context, 'Suspend: {0}', [
        item.spec.suspend == false ? t(context, 'False') : t(context, 'True'),
      ]),
      tFmt(context, 'Active: {0}', [item.status?.active?.length ?? '-']),
      tFmt(context, 'Last Schedule: {0}', [
        getAge(item.status?.lastScheduleTime),
      ]),
      tFmt(context, 'Age: {0}', [getAge(item.metadata?.creationTimestamp)]),
    ];
  },
  detailsItemBuilder:
      (BuildContext context, Resource resource, dynamic detailsItem) {
        final item = detailsItem as IoK8sApiBatchV1CronJob;

        return Column(
          children: [
            DetailsItemMetadata(kind: item.kind, metadata: item.metadata),
            const SizedBox(height: Constants.spacingMiddle),
            DetailsItem(
              title: t(context, 'Configuration'),
              details: [
                DetailsItemModel(
                  name: t(context, 'Schedule'),
                  values: item.spec.schedule,
                ),
                DetailsItemModel(
                  name: t(context, 'Concurrency Policy'),
                  values: item.spec.concurrencyPolicy?.value,
                ),
                DetailsItemModel(
                  name: t(context, 'Suspend'),
                  values:
                      item.spec.suspend == null || item.spec.suspend == false
                      ? t(context, 'False')
                      : t(context, 'True'),
                ),
                DetailsItemModel(
                  name: t(context, 'Successful Job History Limit'),
                  values: item.spec.successfulJobsHistoryLimit,
                ),
                DetailsItemModel(
                  name: t(context, 'Failed Job History Limit'),
                  values: item.spec.failedJobsHistoryLimit,
                ),
                DetailsItemModel(
                  name: t(context, 'Starting Deadline Seconds'),
                  values: item.spec.startingDeadlineSeconds,
                ),
                DetailsItemModel(
                  name: t(context, 'Selector'),
                  values: item
                      .spec
                      .jobTemplate
                      .spec
                      ?.selector
                      ?.matchLabels
                      ?.entries
                      .map(
                        (matchLabel) => '${matchLabel.key}=${matchLabel.value}',
                      )
                      .toList(),
                ),
                DetailsItemModel(
                  name: t(context, 'Parallelism'),
                  values: item.spec.jobTemplate.spec?.parallelism,
                ),
                DetailsItemModel(
                  name: t(context, 'Completions'),
                  values: item.spec.jobTemplate.spec?.completions,
                ),
                DetailsItemModel(
                  name: t(context, 'Active Deadline Seconds'),
                  values: item.spec.jobTemplate.spec?.activeDeadlineSeconds,
                ),
                DetailsItemModel(
                  name: t(context, 'Backoff Limit'),
                  values: item.spec.jobTemplate.spec?.backoffLimit,
                ),
              ],
            ),
            const SizedBox(height: Constants.spacingMiddle),
            DetailsItem(
              title: t(context, 'Status'),
              details: [
                DetailsItemModel(
                  name: t(context, 'Last Schedule'),
                  values: getAge(item.status?.lastScheduleTime),
                ),
              ],
            ),
            const SizedBox(height: Constants.spacingMiddle),
            DetailsResourcesPreview(
              resource: resourceJob,
              namespace: item.metadata?.namespace,
              selector: '',
              filter: (List<dynamic> previewItems) {
                final jobs = previewItems as List<IoK8sApiBatchV1Job>;

                return jobs
                    .where(
                      (job) =>
                          job.metadata?.ownerReferences != null &&
                          job.metadata?.ownerReferences?.length == 1 &&
                          job.metadata?.ownerReferences![0].name ==
                              item.metadata?.name,
                    )
                    .toList();
              },
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
              defaultCharts: const [],
            ),
          ],
        );
      },
);

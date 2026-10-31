import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:kubenav/models/kubernetes/schema.models.swagger.dart';
import 'package:kubenav/utils/constants.dart';
import 'package:kubenav/utils/l10n.dart';
import 'package:kubenav/utils/resources.dart';
import 'package:kubenav/widgets/resources/helpers/details_item.dart';
import 'package:kubenav/widgets/resources/helpers/details_item_conditions.dart';
import 'package:kubenav/widgets/resources/helpers/details_item_metadata.dart';
import 'package:kubenav/widgets/resources/resources/resources.dart';
import 'package:kubenav/widgets/resources/resources_list.dart';
import 'package:kubenav/widgets/shared/app_prometheus_charts_widget.dart';

final resourceCertificateSigningRequest = Resource(
  category: ResourceCategories.cluster,
  plural: 'CertificateSigningRequests',
  singular: 'CertificateSigningRequest',
  description: 'A CertificateSigningRequest (CSR) resource is used to request that a certificate be signed by a denoted signer, after which the request may be approved or denied before finally being signed.',
  path: '/apis/certificates.k8s.io/v1',
  resource: 'certificatesigningrequests',
  scope: ResourceScope.cluster,
  additionalPrinterColumns: [],
  icon: 'certificatesigningrequests',
  template: resourceDefaultTemplate,
  decodeListData: (ResourcesListData data) {
    final parsed = json.decode(data.list);
    final items = IoK8sApiCertificatesV1CertificateSigningRequestList.fromJson(
      parsed,
    ).items;

    return items.map((e) {
      final condition = _getCondition(e.status?.conditions);

      return ResourceItem(
        item: e,
        metrics: null,
        status: condition == 'Approved'
            ? ResourceStatus.success
            : condition == 'Pending'
            ? ResourceStatus.warning
            : ResourceStatus.danger,
      );
    }).toList();
  },
  decodeList: (String data) {
    final parsed = json.decode(data);
    return IoK8sApiCertificatesV1CertificateSigningRequestList.fromJson(parsed)
        .items;
  },
  getName: (dynamic item) {
    return (item as IoK8sApiCertificatesV1CertificateSigningRequest)
            .metadata
            ?.name ??
        '';
  },
  getNamespace: (dynamic item) {
    return (item as IoK8sApiCertificatesV1CertificateSigningRequest)
        .metadata
        ?.namespace;
  },
  decodeItem: (String data) {
    final parsed = json.decode(data);
    return IoK8sApiCertificatesV1CertificateSigningRequest.fromJson(parsed);
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
            listItem.item as IoK8sApiCertificatesV1CertificateSigningRequest;
        final status = listItem.status;

        return ResourcesListItem(
          name: item.metadata?.name ?? '',
          namespace: item.metadata?.namespace,
          resource: resource,
          item: item,
          status: status,
          details: [
            tFmt(context, 'Signer Name: {0}', [item.spec.signerName]),
            tFmt(context, 'Requestor: {0}', [item.spec.username ?? '-']),
            tFmt(context, 'Requested Duration: {0}', [
              formatSeconds(item.spec.expirationSeconds),
            ]),
            tFmt(context, 'Condition: {0}', [
              t(context, _getCondition(item.status?.conditions)),
            ]),
            tFmt(context, 'Age: {0}', [
              getAge(item.metadata?.creationTimestamp),
            ]),
          ],
        );
      },
  previewItemBuilder: (BuildContext context, dynamic listItem) {
    final item = listItem as IoK8sApiCertificatesV1CertificateSigningRequest;

    return [
      tFmt(context, 'Signer Name: {0}', [item.spec.signerName]),
      tFmt(context, 'Requestor: {0}', [item.spec.username ?? '-']),
      tFmt(context, 'Requested Duration: {0}', [
        formatSeconds(item.spec.expirationSeconds),
      ]),
      tFmt(context, 'Condition: {0}', [
        t(context, _getCondition(item.status?.conditions)),
      ]),
      tFmt(context, 'Age: {0}', [getAge(item.metadata?.creationTimestamp)]),
    ];
  },
  detailsItemBuilder:
      (BuildContext context, Resource resource, dynamic detailsItem) {
        final item =
            detailsItem as IoK8sApiCertificatesV1CertificateSigningRequest;

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
                  name: t(context, 'Signer Name'),
                  values: item.spec.signerName,
                ),
                DetailsItemModel(
                  name: t(context, 'Requestor'),
                  values: item.spec.username,
                ),
                DetailsItemModel(
                  name: t(context, 'Requested Duration'),
                  values: formatSeconds(item.spec.expirationSeconds),
                ),
                DetailsItemModel(
                  name: t(context, 'Request'),
                  values: item.spec.request,
                ),
                DetailsItemModel(
                  name: t(context, 'Groups'),
                  values: item.spec.groups,
                ),
                DetailsItemModel(
                  name: t(context, 'Usages'),
                  values: item.spec.usages?.map((e) => e.value).toList(),
                ),
              ],
            ),
            const SizedBox(height: Constants.spacingMiddle),
            DetailsItem(
              title: t(context, 'Status'),
              details: [
                DetailsItemModel(
                  name: t(context, 'Condition'),
                  values: t(context, _getCondition(item.status?.conditions)),
                ),
                DetailsItemModel(
                  name: t(context, 'Certificate'),
                  values: item.status?.certificate,
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

String _getCondition(
  List<IoK8sApiCertificatesV1CertificateSigningRequestCondition>? conditions,
) {
  if (conditions == null || conditions.isEmpty) {
    return 'Pending';
  }

  for (final condition in conditions) {
    if (condition.type == 'Approved') {
      return 'Approved';
    } else if (condition.type == 'Denied') {
      return 'Denied';
    } else if (condition.type == 'Failed') {
      return 'Failed';
    }
  }

  return 'Pending';
}

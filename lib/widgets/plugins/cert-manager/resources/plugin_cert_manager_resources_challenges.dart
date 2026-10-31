import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:kubenav/models/kubernetes/schema.models.swagger.dart';
import 'package:kubenav/utils/constants.dart';
import 'package:kubenav/utils/l10n.dart';
import 'package:kubenav/utils/navigate.dart';
import 'package:kubenav/utils/resources.dart';
import 'package:kubenav/widgets/plugins/cert-manager/resources/plugin_cert_manager_resources.dart';
import 'package:kubenav/widgets/plugins/cert-manager/resources/plugin_cert_manager_resources_clusterissuers.dart';
import 'package:kubenav/widgets/plugins/cert-manager/resources/plugin_cert_manager_resources_issuers.dart';
import 'package:kubenav/widgets/resources/helpers/details_item.dart';
import 'package:kubenav/widgets/resources/helpers/details_item_metadata.dart';
import 'package:kubenav/widgets/resources/helpers/details_resources_preview.dart';
import 'package:kubenav/widgets/resources/resources/resources.dart';
import 'package:kubenav/widgets/resources/resources/resources_events.dart';
import 'package:kubenav/widgets/resources/resources_details.dart';
import 'package:kubenav/widgets/resources/resources_list.dart';

final Resource certManagerResourceChallenge = Resource(
  category: CertManagerResourceCategories.acme,
  plural: 'Challenges',
  singular: 'Challenge',
  description: 'Challenge is a type to represent a Challenge request with an ACME server',
  path: '/apis/acme.cert-manager.io/v1',
  resource: 'challenges',
  scope: ResourceScope.namespaced,
  additionalPrinterColumns: [],
  icon: 'cert-manager',
  template: resourceDefaultTemplate,
  decodeListData: (ResourcesListData data) {
    final parsed = json.decode(data.list);
    final items = IoCertManagerAcmeV1ChallengeList.fromJson(parsed).items;

    return items.map((e) {
      final state = e.status?.state?.value;

      return ResourceItem(
        item: e,
        metrics: null,
        status: state == 'valid'
            ? ResourceStatus.success
            : state == 'ready'
            ? ResourceStatus.warning
            : ResourceStatus.danger,
      );
    }).toList();
  },
  decodeList: (String data) {
    final parsed = json.decode(data);
    return IoCertManagerAcmeV1ChallengeList.fromJson(parsed).items;
  },
  getName: (dynamic item) {
    return (item as IoCertManagerAcmeV1Challenge).metadata.name ?? '';
  },
  getNamespace: (dynamic item) {
    return (item as IoCertManagerAcmeV1Challenge).metadata.namespace;
  },
  decodeItem: (String data) {
    final parsed = json.decode(data);
    return IoCertManagerAcmeV1Challenge.fromJson(parsed);
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
        final item = listItem.item as IoCertManagerAcmeV1Challenge;
        final status = listItem.status;

        return ResourcesListItem(
          name: item.metadata.name ?? '',
          namespace: item.metadata.namespace ?? '',
          resource: resource,
          item: item,
          status: status,
          details: [
            tFmt(context, 'Namespace: {0}', [item.metadata.namespace ?? '-']),
            tFmt(context, 'State: {0}', [item.status?.state?.value ?? '-']),
            tFmt(context, 'Reason: {0}', [item.status?.reason ?? '-']),
            tFmt(context, 'DNS Name: {0}', [item.spec.dnsName]),
            tFmt(context, 'Age: {0}', [
              getAge(item.metadata.creationTimestamp),
            ]),
          ],
        );
      },
  previewItemBuilder: (BuildContext context, dynamic listItem) {
    final item = listItem as IoCertManagerAcmeV1Challenge;

    return [
      tFmt(context, 'Namespace: {0}', [item.metadata.namespace ?? '-']),
      tFmt(context, 'State: {0}', [item.status?.state?.value ?? '-']),
      tFmt(context, 'Reason: {0}', [item.status?.reason ?? '-']),
      tFmt(context, 'DNS Name: {0}', [item.spec.dnsName]),
      tFmt(context, 'Age: {0}', [getAge(item.metadata.creationTimestamp)]),
    ];
  },
  detailsItemBuilder:
      (BuildContext context, Resource resource, dynamic detailsItem) {
        final item = detailsItem as IoCertManagerAcmeV1Challenge;

        return Column(
          children: [
            DetailsItemMetadata(kind: item.kind, metadata: item.metadata),
            const SizedBox(height: Constants.spacingMiddle),
            DetailsItem(
              title: t(context, 'Configuration'),
              details: [
                DetailsItemModel(
                  name: t(context, 'Issuer'),
                  values:
                      '${item.spec.issuerRef.kind} (${item.spec.issuerRef.name})',
                  onTap: (index) {
                    navigate(
                      context,
                      ResourcesDetails(
                        name: item.spec.issuerRef.name,
                        namespace: item.spec.issuerRef.kind == 'ClusterIssuer'
                            ? null
                            : item.metadata.namespace,
                        resource: item.spec.issuerRef.kind == 'ClusterIssuer'
                            ? certManagerResourceClusterIssuer
                            : certManagerResourceIssuer,
                      ),
                    );
                  },
                ),
                DetailsItemModel(
                  name: t(context, 'DNS Name'),
                  values: item.spec.dnsName,
                ),
                DetailsItemModel(
                  name: t(context, 'Url'),
                  values: item.spec.url,
                ),
                DetailsItemModel(
                  name: t(context, 'Authorization Url'),
                  values: item.spec.authorizationURL,
                ),
                DetailsItemModel(
                  name: t(context, 'Wildcard'),
                  values: item.spec.wildcard,
                ),
                DetailsItemModel(
                  name: t(context, 'Token'),
                  values: item.spec.token,
                ),
                DetailsItemModel(
                  name: t(context, 'Key'),
                  values: item.spec.key,
                ),
              ],
            ),
            const SizedBox(height: Constants.spacingMiddle),
            DetailsItem(
              title: t(context, 'Status'),
              details: [
                DetailsItemModel(
                  name: t(context, 'State'),
                  values: item.status?.state?.value,
                ),
                DetailsItemModel(
                  name: t(context, 'Reason'),
                  values: item.status?.reason,
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

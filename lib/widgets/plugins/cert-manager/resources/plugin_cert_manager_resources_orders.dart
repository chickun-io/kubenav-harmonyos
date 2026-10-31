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

final Resource certManagerResourceOrder = Resource(
  category: CertManagerResourceCategories.acme,
  plural: 'Orders',
  singular: 'Order',
  description: 'Order is a type to represent an Order with an ACME server',
  path: '/apis/acme.cert-manager.io/v1',
  resource: 'orders',
  scope: ResourceScope.namespaced,
  additionalPrinterColumns: [],
  icon: 'cert-manager',
  template: resourceDefaultTemplate,
  decodeListData: (ResourcesListData data) {
    final parsed = json.decode(data.list);
    final items = IoCertManagerAcmeV1OrderList.fromJson(parsed).items;

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
    return IoCertManagerAcmeV1OrderList.fromJson(parsed).items;
  },
  getName: (dynamic item) {
    return (item as IoCertManagerAcmeV1Order).metadata.name ?? '';
  },
  getNamespace: (dynamic item) {
    return (item as IoCertManagerAcmeV1Order).metadata.namespace;
  },
  decodeItem: (String data) {
    final parsed = json.decode(data);
    return IoCertManagerAcmeV1Order.fromJson(parsed);
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
        final item = listItem.item as IoCertManagerAcmeV1Order;
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
            tFmt(context, 'Issuer: {0}', [item.spec.issuerRef.name]),
            tFmt(context, 'Age: {0}', [
              getAge(item.metadata.creationTimestamp),
            ]),
          ],
        );
      },
  previewItemBuilder: (BuildContext context, dynamic listItem) {
    final item = listItem as IoCertManagerAcmeV1Order;

    return [
      tFmt(context, 'Namespace: {0}', [item.metadata.namespace ?? '-']),
      tFmt(context, 'State: {0}', [item.status?.state?.value ?? '-']),
      tFmt(context, 'Reason: {0}', [item.status?.reason ?? '-']),
      tFmt(context, 'Issuer: {0}', [item.spec.issuerRef.name]),
      tFmt(context, 'Age: {0}', [getAge(item.metadata.creationTimestamp)]),
    ];
  },
  detailsItemBuilder:
      (BuildContext context, Resource resource, dynamic detailsItem) {
        final item = detailsItem as IoCertManagerAcmeV1Order;

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
                  name: t(context, 'DNS Names'),
                  values: item.spec.dnsNames,
                ),
                DetailsItemModel(
                  name: t(context, 'IP Addresses'),
                  values: item.spec.ipAddresses,
                ),
                DetailsItemModel(
                  name: t(context, 'Common Name'),
                  values: item.spec.commonName,
                ),
                DetailsItemModel(
                  name: t(context, 'Request'),
                  values: item.spec.request,
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

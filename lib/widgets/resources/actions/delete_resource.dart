import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:kubenav/repositories/app_repository.dart';
import 'package:kubenav/repositories/clusters_repository.dart';
import 'package:kubenav/services/kubernetes_service.dart';
import 'package:kubenav/utils/constants.dart';
import 'package:kubenav/utils/l10n.dart';
import 'package:kubenav/utils/logger.dart';
import 'package:kubenav/utils/showmodal.dart';
import 'package:kubenav/utils/themes.dart';
import 'package:kubenav/widgets/resources/resources/resources.dart';
import 'package:kubenav/widgets/shared/app_bottom_sheet_widget.dart';

/// The [DeleteResource] widget can be used to delete the resource provided via
/// the [resource], [name] and [namespace] parameters. Within the widget a user
/// can also select if we should force the deletion of the resource or not.
class DeleteResource extends StatefulWidget {
  const DeleteResource({
    super.key,
    required this.resource,
    required this.name,
    required this.namespace,
  });

  final String name;
  final String? namespace;
  final Resource resource;

  @override
  State<DeleteResource> createState() => _DeleteResourceState();
}

class _DeleteResourceState extends State<DeleteResource> {
  bool _force = false;
  String? _propagationPolicy;
  bool _isLoading = false;

  /// [_delete] deletes the resource. If the [_force] parameter is set
  /// to true we will add a `{"gracePeriodSeconds": 0}` body to the Kubernetes
  /// API request. The user gets a snackbar message if the saving was successful
  /// or failed.
  Future<void> _delete() async {
    ClustersRepository clustersRepository = Provider.of<ClustersRepository>(
      context,
      listen: false,
    );
    AppRepository appRepository = Provider.of<AppRepository>(
      context,
      listen: false,
    );

    final body =
        '{"gracePeriodSeconds": ${_force ? 0 : null}, "propagationPolicy": ${_propagationPolicy != null ? '"$_propagationPolicy"' : null}}';

    try {
      setState(() {
        _isLoading = true;
      });

      final cluster = await clustersRepository.getClusterWithCredentials(
        clustersRepository.activeClusterId,
      );
      final url = widget.namespace == null
          ? '${widget.resource.path}/${widget.resource.resource}/${widget.name}'
          : '${widget.resource.path}/namespaces/${widget.namespace}/${widget.resource.resource}/${widget.name}';

      await KubernetesService(
        cluster: cluster!,
        proxy: appRepository.settings.proxy,
        timeout: appRepository.settings.timeout,
      ).deleteRequest(url, body);

      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        showSnackbar(
          context,
          tFmt(context, '{0} Deleted', [t(context, widget.resource.singular)]),
          widget.namespace == null
              ? tFmt(context, 'The {0} {1} was deleted', [
                  t(context, widget.resource.singular),
                  widget.name,
                ])
              : 'The ${widget.resource.singular} ${widget.namespace}/${widget.name} was deleted',
        );
        Navigator.pop(context);
      }
    } catch (err) {
      Logger.log(
        'DeleteResource _delete',
        'Failed to Delete ${widget.resource.singular}',
        err,
      );
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        showSnackbar(
          context,
          tFmt(context, 'Failed to Delete {0}', [
            t(context, widget.resource.singular),
          ]),
          err.toString(),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomSheetWidget(
      title: t(context, 'Delete'),
      subtitle: widget.namespace == null
          ? widget.name
          : '${widget.namespace}/${widget.name}',
      icon: Icons.delete,
      closePressed: () {
        Navigator.pop(context);
      },
      actionText: t(context, 'Delete'),
      actionPressed: () {
        _delete();
      },
      actionIsLoading: _isLoading,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
            top: Constants.spacingMiddle,
            bottom: Constants.spacingMiddle,
            left: Constants.spacingMiddle,
            right: Constants.spacingMiddle,
          ),
          child: Column(
            children: [
              Container(
                child: widget.namespace != null
                    ? Text(
                        tFmt(
                          context,
                          'Do you really want to delete {0} {1}/{2}?',
                          [
                            t(context, widget.resource.singular),
                            widget.namespace,
                            widget.name,
                          ],
                        ),
                      )
                    : Text(
                        tFmt(context, 'Do you really want to delete {0} {1}?', [
                          t(context, widget.resource.singular),
                          widget.name,
                        ]),
                      ),
              ),
              const SizedBox(height: Constants.spacingMiddle),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(t(context, 'Force')),
                  Switch(
                    activeThumbColor: Theme.of(context).colorScheme.primary,
                    onChanged: (value) {
                      setState(() {
                        _force = !_force;
                      });
                    },
                    value: _force,
                  ),
                ],
              ),
              const SizedBox(height: Constants.spacingMiddle),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(t(context, 'Propagation Policy')),
                  DropdownButton<String?>(
                    value: _propagationPolicy,
                    underline: Container(
                      height: 2,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onChanged: (String? value) {
                      setState(() {
                        _propagationPolicy = value;
                      });
                    },
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text(
                          '',
                          style: TextStyle(
                            color: Theme.of(context)
                                .extension<CustomColors>()!
                                .textPrimary,
                          ),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Background',
                        child: Text(
                          t(context, 'Background'),
                          style: TextStyle(
                            color: Theme.of(context)
                                .extension<CustomColors>()!
                                .textPrimary,
                          ),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Foreground',
                        child: Text(
                          t(context, 'Foreground'),
                          style: TextStyle(
                            color: Theme.of(context)
                                .extension<CustomColors>()!
                                .textPrimary,
                          ),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Orphan',
                        child: Text(
                          t(context, 'Orphan'),
                          style: TextStyle(
                            color: Theme.of(context)
                                .extension<CustomColors>()!
                                .textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

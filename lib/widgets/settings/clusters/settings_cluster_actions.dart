import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:kubenav/models/cluster.dart';
import 'package:kubenav/repositories/bookmarks_repository.dart';
import 'package:kubenav/repositories/clusters_repository.dart';
import 'package:kubenav/utils/l10n.dart';
import 'package:kubenav/utils/showmodal.dart';
import 'package:kubenav/utils/themes.dart';
import 'package:kubenav/widgets/settings/clusters/settings_edit_cluster.dart';
import 'package:kubenav/widgets/shared/app_actions_widget.dart';

/// The [SettingsClusterActions] can be used within an actions modal, to edit
/// or to delete a cluster. When the user selects the edit item, we show the
/// [SettingsEditCluster] in a new modal so that the user can modify the cluster
/// properties. If the user selects the delete item, we remove the cluster.
class SettingsClusterActions extends StatefulWidget {
  const SettingsClusterActions({super.key, required this.cluster});

  final Cluster cluster;

  @override
  State<SettingsClusterActions> createState() => _SettingsClusterActionsState();
}

class _SettingsClusterActionsState extends State<SettingsClusterActions> {
  /// [deleteCluster] is used to remove the provided cluster from our list
  /// of clusters in the clusters repository. For the success and the error case
  /// we show an snackbar to inform the user about the result of the operation.
  Future<void> deleteCluster() async {
    ClustersRepository clustersRepository = Provider.of<ClustersRepository>(
      context,
      listen: false,
    );
    BookmarksRepository bookmarksRepository = Provider.of<BookmarksRepository>(
      context,
      listen: false,
    );

    try {
      await clustersRepository.deleteCluster(widget.cluster.id);
      await bookmarksRepository.removeBookmarksForCluster(widget.cluster.id);
      if (mounted) {
        Navigator.pop(context);
        showSnackbar(
          context,
          t(context, 'Cluster Deleted'),
          tFmt(context, 'The cluster {0} was deleted', [widget.cluster.name]),
        );
      }
    } catch (err) {
      if (mounted) {
        Navigator.pop(context);
        showSnackbar(
          context,
          t(context, 'Failed to Delete Cluster'),
          err.toString(),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppActionsWidget(
      actions: [
        AppActionsWidgetAction(
          title: t(context, 'Edit'),
          color: Theme.of(context).colorScheme.primary,
          onTap: () {
            Navigator.pop(context);
            showModal(context, SettingsEditCluster(cluster: widget.cluster));
          },
        ),
        AppActionsWidgetAction(
          title: t(context, 'Delete'),
          color: Theme.of(context).extension<CustomColors>()!.error,
          onTap: () {
            deleteCluster();
          },
        ),
      ],
    );
  }
}

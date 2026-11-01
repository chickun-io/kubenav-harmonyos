import { FlutterAbility, FlutterEngine } from '@ohos/flutter_ohos';
import { GeneratedPluginRegistrant } from '../plugins/GeneratedPluginRegistrant';
import KubenavPlugin from '../plugins/KubenavPlugin';
import OhosPlatformPlugin from '../plugins/OhosPlatformPlugin';

export default class EntryAbility extends FlutterAbility {
  configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    GeneratedPluginRegistrant.registerWith(flutterEngine)
    flutterEngine.getPlugins()?.add(new KubenavPlugin())
    flutterEngine.getPlugins()?.add(new OhosPlatformPlugin())
  }
}

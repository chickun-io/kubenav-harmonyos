import { preferences } from '@kit.ArkData';
import { util } from '@kit.ArkTS';
import { fileIo, picker } from '@kit.CoreFileKit';
import { userAuth } from '@kit.UserAuthenticationKit';
import { BusinessError } from '@ohos.base';
import hilog from '@ohos.hilog';
import common from '@ohos.app.ability.common';
import Want from '@ohos.app.ability.Want';
import {
  AbilityAware,
  AbilityPluginBinding,
  FlutterPlugin,
  FlutterPluginBinding,
  MethodCall,
  MethodCallHandler,
  MethodChannel,
  MethodResult,
} from '@ohos/flutter_ohos';

const STORAGE_NAME = 'kubenav';

function argument(call: MethodCall, key: string): Object | null {
  try {
    return call.argument(key) as Object | null;
  } catch (error) {
    return null;
  }
}

class SecureStorageHandler implements MethodCallHandler {
  private store: preferences.Preferences;

  constructor(store: preferences.Preferences) {
    this.store = store;
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    const key = argument(call, 'key') as string | null;
    if (call.method === 'write' && key != null) {
      this.store.putSync(key, argument(call, 'value') as string);
      this.store.flushSync();
      result.success(null);
      return;
    }
    if (call.method === 'read' && key != null) {
      const values = this.store.getAllSync() as Record<string, preferences.ValueType>;
      result.success(values[key] ?? null);
      return;
    }
    if (call.method === 'containsKey' && key != null) {
      const values = this.store.getAllSync() as Record<string, preferences.ValueType>;
      result.success(values[key] !== undefined);
      return;
    }
    if (call.method === 'delete' && key != null) {
      this.store.deleteSync(key);
      this.store.flushSync();
      result.success(null);
      return;
    }
    if (call.method === 'deleteAll') {
      this.store.clearSync();
      this.store.flushSync();
      result.success(null);
      return;
    }
    if (call.method === 'readAll') {
      result.success(this.store.getAllSync());
      return;
    }
    result.success(null);
  }
}

class PathHandler implements MethodCallHandler {
  private context: common.Context;

  constructor(context: common.Context) {
    this.context = context;
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    if (call.method === 'getTemporaryDirectory' || call.method === 'getApplicationCacheDirectory') {
      result.success(this.context.cacheDir);
      return;
    }
    if (call.method === 'getApplicationSupportDirectory' || call.method === 'getApplicationDocumentsDirectory') {
      result.success(this.context.filesDir);
      return;
    }
    result.success(null);
  }
}

class UrlHandler implements MethodCallHandler {
  private abilityContext: common.UIAbilityContext | null;

  constructor(abilityContext: common.UIAbilityContext | null) {
    this.abilityContext = abilityContext;
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    if (call.method === 'canLaunch') {
      const url = argument(call, 'url') as string | null;
      result.success(url != null && (url.startsWith('http://') || url.startsWith('https://')));
      return;
    }
    if (call.method === 'launch') {
      const url = argument(call, 'url') as string | null;
      if (url == null || this.abilityContext == null) {
        result.success(false);
        return;
      }
      const want: Want = {
        action: 'ohos.want.action.viewData',
        uri: url,
        entities: ['entity.system.browsable']
      };
      this.abilityContext.startAbility(want).then(() => {
        result.success(true);
      }).catch(() => {
        result.success(false);
      });
      return;
    }
    if (call.method === 'closeWebView') {
      result.success(null);
      return;
    }
    result.notImplemented();
  }
}

const MAX_KUBECONFIG_BYTES = 8 * 1024 * 1024;

class KubeconfigPickerHandler implements MethodCallHandler {
  private abilityContext: common.UIAbilityContext | null;

  constructor(abilityContext: common.UIAbilityContext | null) {
    this.abilityContext = abilityContext;
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    if (call.method !== 'readText') {
      result.notImplemented();
      return;
    }
    if (this.abilityContext == null) {
      result.error('NO_CONTEXT', 'UIAbility context is unavailable', null);
      return;
    }
    const options = new picker.DocumentSelectOptions();
    options.maxSelectNumber = 1;
    const documentPicker = new picker.DocumentViewPicker(this.abilityContext);
    documentPicker.select(options).then((uris: Array<string>) => {
      if (uris.length === 0) {
        result.success(null);
        return;
      }
      const file = fileIo.openSync(uris[0], fileIo.OpenMode.READ_ONLY);
      try {
        const size = fileIo.statSync(file.fd).size;
        if (size <= 0) {
          result.success('');
          return;
        }
        if (size > MAX_KUBECONFIG_BYTES) {
          result.error('PICK_FAILED', 'File is too large', null);
          return;
        }
        const buffer = new ArrayBuffer(size);
        const readLength = fileIo.readSync(file.fd, buffer);
        if (readLength !== size) {
          result.error('PICK_FAILED', 'Failed to read the selected file', null);
          return;
        }
        const text = util.TextDecoder.create('utf-8', { ignoreBOM: true })
          .decodeToString(new Uint8Array(buffer));
        result.success(text);
      } catch (error) {
        result.error('PICK_FAILED', `${error}`, null);
      } finally {
        fileIo.closeSync(file);
      }
    }).catch((error: Object) => {
      result.error('PICK_FAILED', `${error}`, null);
    });
  }
}

function authLog(message: string): void {
  hilog.info(0xFF00, 'KubenavAuth', '%{public}s', message);
}

function authResultCallback(methodResult: MethodResult): userAuth.IAuthCallback {
  let finished = false;
  const callback: userAuth.IAuthCallback = {
    onResult: (authResult: userAuth.UserAuthResult) => {
      if (finished) {
        return;
      }
      finished = true;
      authLog(`onResult ${authResult.result}`);
      methodResult.success(authResult.result === userAuth.UserAuthResultCode.SUCCESS);
    }
  };
  return callback;
}

class LocalAuthHandler implements MethodCallHandler {
  private activeAuth: userAuth.UserAuthInstance | null = null;
  private activeCallback: userAuth.IAuthCallback | null = null;
  private cachedBiometrics: string[] | null = null;

  onMethodCall(call: MethodCall, result: MethodResult): void {
    authLog(`call ${call.method}`);
    setTimeout(() => {
      this.handleCall(call, result);
    }, 0);
  }

  private handleCall(call: MethodCall, result: MethodResult): void {
    try {
      if (call.method === 'isDeviceSupported') {
        result.success(this.supportsBiometrics());
        return;
      }
      if (call.method === 'getAvailableBiometrics') {
        const enrolled = this.enrolledBiometrics();
        authLog(`enrolled ${enrolled.join(',')}`);
        result.success(enrolled);
        return;
      }
      if (call.method === 'stopAuthentication') {
        if (this.activeAuth != null) {
          this.activeAuth.cancel();
          this.activeAuth = null;
        }
        result.success(true);
        return;
      }
      if (call.method === 'authenticate') {
        this.authenticate(call, result);
        return;
      }
      result.notImplemented();
    } catch (error) {
      authLog(`handle ${call.method} failed ${error}`);
      result.error('AUTH_FAILED', `${error}`, null);
    }
  }

  private supportsBiometrics(): boolean {
    return this.enrolledBiometrics().length > 0 || this.biometricStatus(userAuth.UserAuthType.PIN) !== 'unsupported';
  }

  private enrolledBiometrics(): string[] {
    if (this.cachedBiometrics != null) {
      return this.cachedBiometrics;
    }
    const enrolled: string[] = [];
    if (this.biometricStatus(userAuth.UserAuthType.FACE) === 'enrolled') {
      enrolled.push('face');
    }
    if (this.biometricStatus(userAuth.UserAuthType.FINGERPRINT) === 'enrolled') {
      enrolled.push('fingerprint');
    }
    this.cachedBiometrics = enrolled;
    return enrolled;
  }

  private biometricStatus(authType: userAuth.UserAuthType): string {
    try {
      userAuth.getAvailableStatus(authType, userAuth.AuthTrustLevel.ATL1);
      return 'enrolled';
    } catch (error) {
      const code = (error as BusinessError).code;
      authLog(`status ${authType} code ${code}`);
      if (code === 12500010) {
        return 'not_enrolled';
      }
      return 'unsupported';
    }
  }

  private authenticate(call: MethodCall, result: MethodResult): void {
    const authTypes = this.authTypes();
    if (authTypes.length === 0) {
      authLog('no auth types');
      result.success(false);
      return;
    }
    const reason = argument(call, 'localizedReason') as string | null;
    const challenge = new Uint8Array(16);
    for (let index = 0; index < challenge.length; index++) {
      challenge[index] = index + 1;
    }
    const widgetParam: userAuth.WidgetParam = {
      title: reason != null && reason.length > 0 ? reason : 'kubenav'
    };
    const levels: userAuth.AuthTrustLevel[] = [
      userAuth.AuthTrustLevel.ATL3,
      userAuth.AuthTrustLevel.ATL1
    ];
    let lastError: Object | null = null;
    for (let index = 0; index < levels.length; index++) {
      const authParam: userAuth.AuthParam = {
        challenge: challenge,
        authType: authTypes,
        authTrustLevel: levels[index]
      };
      try {
        authLog(`start auth level ${levels[index]}`);
        const authInstance = userAuth.getUserAuthInstance(authParam, widgetParam);
        const callback = authResultCallback(result);
        this.activeAuth = authInstance;
        this.activeCallback = callback;
        authInstance.on('result', callback);
        authInstance.start();
        authLog('auth widget started');
        return;
      } catch (error) {
        lastError = error as Object;
        authLog(`start auth failed ${error}`);
        this.activeAuth = null;
        this.activeCallback = null;
      }
    }
    result.success(false);
    authLog(`auth gave up ${lastError}`);
  }

  private authTypes(): userAuth.UserAuthType[] {
    const authTypes: userAuth.UserAuthType[] = [];
    if (this.biometricStatus(userAuth.UserAuthType.PIN) !== 'unsupported') {
      authTypes.push(userAuth.UserAuthType.PIN);
    }
    if (this.biometricStatus(userAuth.UserAuthType.FACE) === 'enrolled') {
      authTypes.push(userAuth.UserAuthType.FACE);
    }
    if (this.biometricStatus(userAuth.UserAuthType.FINGERPRINT) === 'enrolled') {
      authTypes.push(userAuth.UserAuthType.FINGERPRINT);
    }
    return authTypes;
  }
}

class QuickActionsHandler implements MethodCallHandler {
  onMethodCall(call: MethodCall, result: MethodResult): void {
    if (call.method === 'getLaunchAction') {
      result.success(null);
      return;
    }
    result.success(null);
  }
}

class PackageInfoHandler implements MethodCallHandler {
  onMethodCall(call: MethodCall, result: MethodResult): void {
    if (call.method === 'getAll') {
      result.success({
        'appName': 'kubenav',
        'packageName': 'io.kubenav.kubenav',
        'version': '5.6.0',
        'buildNumber': '124',
        'buildSignature': ''
      });
      return;
    }
    result.notImplemented();
  }
}

export default class OhosPlatformPlugin implements FlutterPlugin, AbilityAware {
  private channels: MethodChannel[] = [];
  private urlHandler: UrlHandler = new UrlHandler(null);
  private filePickerHandler: KubeconfigPickerHandler = new KubeconfigPickerHandler(null);
  private localAuthHandler: LocalAuthHandler = new LocalAuthHandler();

  getUniqueClassName(): string {
    return 'OhosPlatformPlugin';
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    const context = binding.getApplicationContext();
    const store = preferences.getPreferencesSync(context, { name: STORAGE_NAME });
    const messenger = binding.getBinaryMessenger();
    const secure = new MethodChannel(messenger, 'plugins.it_nomads.com/flutter_secure_storage');
    secure.setMethodCallHandler(new SecureStorageHandler(store));
    const appStorage = new MethodChannel(messenger, 'kubenav.io/storage');
    appStorage.setMethodCallHandler(new SecureStorageHandler(store));
    const paths = new MethodChannel(messenger, 'plugins.flutter.io/path_provider');
    paths.setMethodCallHandler(new PathHandler(context));
    const urls = new MethodChannel(messenger, 'plugins.flutter.io/url_launcher');
    urls.setMethodCallHandler(this.urlHandler);
    const shortcuts = new MethodChannel(messenger, 'plugins.flutter.io/quick_actions');
    shortcuts.setMethodCallHandler(new QuickActionsHandler());
    const info = new MethodChannel(messenger, 'dev.fluttercommunity.plus/package_info');
    info.setMethodCallHandler(new PackageInfoHandler());
    const files = new MethodChannel(messenger, 'kubenav.io/file_picker');
    files.setMethodCallHandler(this.filePickerHandler);
    const biometrics = new MethodChannel(messenger, 'plugins.flutter.io/local_auth');
    biometrics.setMethodCallHandler(this.localAuthHandler);
    this.channels = [secure, appStorage, paths, urls, shortcuts, info, files, biometrics];
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    for (const channel of this.channels) {
      channel.setMethodCallHandler(null);
    }
    this.channels = [];
  }

  onAttachedToAbility(binding: AbilityPluginBinding): void {
    const abilityContext = binding.getAbility().context;
    this.urlHandler = new UrlHandler(abilityContext);
    const urlChannel = this.channels[3];
    if (urlChannel != null) {
      urlChannel.setMethodCallHandler(this.urlHandler);
    }
    this.filePickerHandler = new KubeconfigPickerHandler(abilityContext);
    const fileChannel = this.channels[6];
    if (fileChannel != null) {
      fileChannel.setMethodCallHandler(this.filePickerHandler);
    }
  }

  onDetachedFromAbility(): void {
    this.urlHandler = new UrlHandler(null);
    this.filePickerHandler = new KubeconfigPickerHandler(null);
  }
}

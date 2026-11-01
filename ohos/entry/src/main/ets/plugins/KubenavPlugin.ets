import {
  FlutterPlugin,
  FlutterPluginBinding,
  MethodCall,
  MethodCallHandler,
  MethodChannel,
  MethodResult,
} from '@ohos/flutter_ohos';
import { HashMap } from '@kit.ArkTS';
import kubenav from 'libkubenav_ffi.so';

interface NativeReply {
  ok?: boolean;
  data?: string;
  code?: string;
  message?: string;
}

function toPlain(value: Object | null): Object | null {
  if (value == null) {
    return null;
  }
  if (value instanceof Map) {
    const mapped: Record<string, Object | null> = {};
    value.forEach((item: Object, key: Object) => {
      mapped[`${key}`] = toPlain(item as Object | null);
    });
    return mapped;
  }
  if (value instanceof HashMap) {
    const mapped: Record<string, Object | null> = {};
    value.forEach((item: Object, key: Object) => {
      mapped[`${key}`] = toPlain(item as Object | null);
    });
    return mapped;
  }
  if (Array.isArray(value)) {
    const listed: Object[] = [];
    const items = value as Object[];
    for (let index = 0; index < items.length; index++) {
      const plain = toPlain(items[index]);
      if (plain != null) {
        listed.push(plain);
      }
    }
    return listed;
  }
  return value;
}

export default class KubenavPlugin implements FlutterPlugin, MethodCallHandler {
  private channel: MethodChannel | null = null;

  getUniqueClassName(): string {
    return 'KubenavPlugin';
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.channel = new MethodChannel(binding.getBinaryMessenger(), 'kubenav.io');
    this.channel.setMethodCallHandler(this);
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    if (this.channel != null) {
      this.channel.setMethodCallHandler(null);
    }
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    try {
      const payload = JSON.stringify(toPlain(call.args as Object | null) ?? {});
      const raw = kubenav.call(call.method, payload);
      const reply = JSON.parse(raw) as NativeReply;
      if (reply.ok === true) {
        result.success(reply.data ?? '');
        return;
      }
      result.error(reply.code ?? 'KUBENAV_OHOS_FAILED', reply.message ?? '', null);
    } catch (error) {
      result.error('KUBENAV_OHOS_FAILED', `${error}`, null);
    }
  }
}

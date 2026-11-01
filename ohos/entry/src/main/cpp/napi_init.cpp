#include "napi/native_api.h"

#include <string>
#include <vector>

extern "C" {
char *KubenavCall(const char *method, const char *args);
void KubenavFree(char *value);
}

static std::string ReadUtf8(napi_env env, napi_value value) {
    size_t length = 0;
    napi_get_value_string_utf8(env, value, nullptr, 0, &length);
    std::vector<char> buffer(length + 1);
    napi_get_value_string_utf8(env, value, buffer.data(), buffer.size(), &length);
    return std::string(buffer.data(), length);
}

static napi_value Call(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value argv[2] = {nullptr, nullptr};
    napi_get_cb_info(env, info, &argc, argv, nullptr, nullptr);

    napi_value result;
    if (argc < 2) {
        napi_create_string_utf8(env, "{\"ok\":false,\"code\":\"BAD_ARGUMENTS\",\"message\":\"expected method and args\"}", NAPI_AUTO_LENGTH, &result);
        return result;
    }

    std::string method = ReadUtf8(env, argv[0]);
    std::string args = ReadUtf8(env, argv[1]);
    char *raw = KubenavCall(method.c_str(), args.c_str());
    napi_create_string_utf8(env, raw == nullptr ? "" : raw, NAPI_AUTO_LENGTH, &result);
    if (raw != nullptr) {
        KubenavFree(raw);
    }
    return result;
}

EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports) {
    napi_property_descriptor desc[] = {
        {"call", nullptr, Call, nullptr, nullptr, nullptr, napi_default, nullptr},
    };
    napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc);
    return exports;
}
EXTERN_C_END

static napi_module kubenavModule = {
    .nm_version = 1,
    .nm_flags = 0,
    .nm_filename = nullptr,
    .nm_register_func = Init,
    .nm_modname = "kubenav_ffi",
    .nm_priv = nullptr,
    .reserved = {0},
};

extern "C" __attribute__((constructor)) void RegisterKubenavFfiModule(void) {
    napi_module_register(&kubenavModule);
}

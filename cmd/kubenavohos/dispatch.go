package main

import (
	"encoding/json"
	"fmt"
	"sync"

	kubenav "github.com/kubenav/kubenav/cmd/kubenav"
)

var serverOnce sync.Once

// Dispatch runs a kubenav method and returns a JSON object:
// {"ok":true,"data":"..."} or {"ok":false,"code":"...","message":"..."}.
func Dispatch(method, rawArgs string) string {
	args := map[string]any{}
	if rawArgs != "" {
		if err := json.Unmarshal([]byte(rawArgs), &args); err != nil {
			return fail("BAD_ARGUMENTS", err)
		}
	}

	switch method {
	case "kubernetesRequest":
		return callCluster(args, "KUBERNETES_REQUEST_FAILED", func(c clusterArgs) (string, error) {
			text, err := needStrings(args, "requestMethod", "requestURL", "requestBody")
			if err != nil {
				return "", err
			}
			return kubenav.KubernetesRequest(c.server, c.tlsServerName, c.caData, c.insecure, c.certData, c.keyData, c.token, c.username, c.password, c.proxy, c.timeout, text["requestMethod"], text["requestURL"], text["requestBody"])
		})
	case "prettifyYAML":
		values, err := needStrings(args, "jsonStr")
		if err != nil {
			return fail("BAD_ARGUMENTS", err)
		}
		data, err := kubenav.PrettifyYAML(values["jsonStr"])
		return done("PRETTIFY_YAML_FAILED", data, err)
	case "createJSONPatch":
		values, err := needStrings(args, "source", "target")
		if err != nil {
			return fail("BAD_ARGUMENTS", err)
		}
		data, err := kubenav.CreateJSONPatch(values["source"], values["target"])
		return done("CREATE_JSON_PATCH_FAILED", data, err)
	case "kubernetesGetLogs":
		return callCluster(args, "KUBERNETES_GET_LOGS_FAILED", func(c clusterArgs) (string, error) {
			text, err := needStrings(args, "names", "namespace", "container", "filter")
			if err != nil {
				return "", err
			}
			since, err := needInt(args, "since")
			if err != nil {
				return "", err
			}
			previous, err := needBool(args, "previous")
			if err != nil {
				return "", err
			}
			return kubenav.KubernetesGetLogs(c.server, c.tlsServerName, c.caData, c.insecure, c.certData, c.keyData, c.token, c.username, c.password, c.proxy, c.timeout, text["names"], text["namespace"], text["container"], since, text["filter"], previous)
		})
	case "kubernetesStartServer":
		serverOnce.Do(func() {
			go kubenav.KubernetesStartServer()
		})
		return ok("")
	case "azureGetClusters":
		text, err := needStrings(args, "subscriptionID", "tenantID", "clientID", "clientSecret")
		if err != nil {
			return fail("BAD_ARGUMENTS", err)
		}
		isAdmin, err := needBool(args, "isAdmin")
		if err != nil {
			return fail("BAD_ARGUMENTS", err)
		}
		data, err := kubenav.AzureGetClusters(text["subscriptionID"], text["tenantID"], text["clientID"], text["clientSecret"], isAdmin)
		return done("AZURE_GET_CLUSTERS_FAILED", data, err)
	case "awsGetClusters":
		text, err := needStrings(args, "accessKeyID", "secretKey", "region", "sessionToken", "roleArn")
		if err != nil {
			return fail("BAD_ARGUMENTS", err)
		}
		data, err := kubenav.AWSGetClusters(text["accessKeyID"], text["secretKey"], text["region"], text["sessionToken"], text["roleArn"])
		return done("AWS_GET_CLUSTERS_FAILED", data, err)
	case "awsGetToken":
		text, err := needStrings(args, "accessKeyID", "secretKey", "region", "sessionToken", "roleArn", "clusterID")
		if err != nil {
			return fail("BAD_ARGUMENTS", err)
		}
		data, err := kubenav.AWSGetToken(text["accessKeyID"], text["secretKey"], text["region"], text["sessionToken"], text["roleArn"], text["clusterID"])
		return done("AWS_GET_TOKEN_FAILED", data, err)
	case "awsGetSSOConfig":
		text, err := needStrings(args, "ssoRegion", "startURL")
		if err != nil {
			return fail("BAD_ARGUMENTS", err)
		}
		data, err := kubenav.AWSGetSSOConfig(text["ssoRegion"], text["startURL"])
		return done("AWS_GET_SSO_CONFIG_FAILED", data, err)
	case "awsGetSSOToken":
		text, err := needStrings(args, "accountID", "roleName", "ssoRegion", "ssoClientID", "ssoClientSecret", "ssoDeviceCode", "accessToken")
		if err != nil {
			return fail("BAD_ARGUMENTS", err)
		}
		expire, err := needInt(args, "accessTokenExpire")
		if err != nil {
			return fail("BAD_ARGUMENTS", err)
		}
		data, err := kubenav.AWSGetSSOToken(text["accountID"], text["roleName"], text["ssoRegion"], text["ssoClientID"], text["ssoClientSecret"], text["ssoDeviceCode"], text["accessToken"], expire)
		return done("AWS_GET_SSO_TOKEN_FAILED", data, err)
	case "awsGetSSOAccounts":
		text, err := needStrings(args, "ssoRegion", "ssoClientID", "ssoClientSecret", "ssoDeviceCode")
		if err != nil {
			return fail("BAD_ARGUMENTS", err)
		}
		data, err := kubenav.AWSGetSSOAccounts(text["ssoRegion"], text["ssoClientID"], text["ssoClientSecret"], text["ssoDeviceCode"])
		return done("AWS_GET_SSO_ACCOUNTS_FAILED", data, err)
	case "helmListReleases":
		return callCluster(args, "HELM_LIST_RELEASES_FAILED", func(c clusterArgs) (string, error) {
			text, err := needStrings(args, "namespace")
			if err != nil {
				return "", err
			}
			return kubenav.HelmListReleases(c.server, c.tlsServerName, c.caData, c.insecure, c.certData, c.keyData, c.token, c.username, c.password, c.proxy, c.timeout, text["namespace"])
		})
	case "helmGetRelease":
		return callCluster(args, "HELM_GET_RELEASES_FAILED", func(c clusterArgs) (string, error) {
			text, err := needStrings(args, "namespace", "name")
			if err != nil {
				return "", err
			}
			version, err := needInt(args, "version")
			if err != nil {
				return "", err
			}
			return kubenav.HelmGetRelease(c.server, c.tlsServerName, c.caData, c.insecure, c.certData, c.keyData, c.token, c.username, c.password, c.proxy, c.timeout, text["namespace"], text["name"], version)
		})
	case "helmListReleaseHistory":
		return callCluster(args, "HELM_GET_LIST_RELEASE_HISTORY_FAILED", func(c clusterArgs) (string, error) {
			text, err := needStrings(args, "namespace", "name")
			if err != nil {
				return "", err
			}
			return kubenav.HelmListReleaseHistory(c.server, c.tlsServerName, c.caData, c.insecure, c.certData, c.keyData, c.token, c.username, c.password, c.proxy, c.timeout, text["namespace"], text["name"])
		})
	case "helmRollbackRelease":
		return callCluster(args, "HELM_ROLLBACK_RELEASE_FAILED", func(c clusterArgs) (string, error) {
			text, err := needStrings(args, "namespace", "name", "options")
			if err != nil {
				return "", err
			}
			version, err := needInt(args, "version")
			if err != nil {
				return "", err
			}
			err = kubenav.HelmRollbackRelease(c.server, c.tlsServerName, c.caData, c.insecure, c.certData, c.keyData, c.token, c.username, c.password, c.proxy, c.timeout, text["namespace"], text["name"], version, text["options"])
			return "", err
		})
	case "helmUninstallRelease":
		return callCluster(args, "HELM_UNINSTALL_RELEASE_FAILED", func(c clusterArgs) (string, error) {
			text, err := needStrings(args, "namespace", "name", "options")
			if err != nil {
				return "", err
			}
			return kubenav.HelmUninstallRelease(c.server, c.tlsServerName, c.caData, c.insecure, c.certData, c.keyData, c.token, c.username, c.password, c.proxy, c.timeout, text["namespace"], text["name"], text["options"])
		})
	case "oidcGetLink":
		text, err := needStrings(args, "discoveryURL", "clientID", "clientSecret", "certificateAuthority", "scopes", "redirectURL", "pkceMethod", "state")
		if err != nil {
			return fail("BAD_ARGUMENTS", err)
		}
		addDefaultScopes, err := needBool(args, "addDefaultScopes")
		if err != nil {
			return fail("BAD_ARGUMENTS", err)
		}
		data, err := kubenav.OIDCGetLink(text["discoveryURL"], text["clientID"], text["clientSecret"], text["certificateAuthority"], text["scopes"], addDefaultScopes, text["redirectURL"], text["pkceMethod"], text["state"])
		return done("OIDC_GET_LINK_FAILED", data, err)
	case "oidcGetRefreshToken":
		text, err := needStrings(args, "discoveryURL", "clientID", "clientSecret", "certificateAuthority", "scopes", "redirectURL", "pkceMethod", "code", "verifier")
		if err != nil {
			return fail("BAD_ARGUMENTS", err)
		}
		addDefaultScopes, err := needBool(args, "addDefaultScopes")
		if err != nil {
			return fail("BAD_ARGUMENTS", err)
		}
		useAccessToken, err := needBool(args, "useAccessToken")
		if err != nil {
			return fail("BAD_ARGUMENTS", err)
		}
		data, err := kubenav.OIDCGetRefreshToken(text["discoveryURL"], text["clientID"], text["clientSecret"], text["certificateAuthority"], text["scopes"], addDefaultScopes, text["redirectURL"], text["pkceMethod"], text["code"], text["verifier"], useAccessToken)
		return done("OIDC_GET_REFRESH_TOKEN_FAILED", data, err)
	case "oidcGetAccessToken":
		text, err := needStrings(args, "discoveryURL", "clientID", "clientSecret", "certificateAuthority", "scopes", "redirectURL", "refreshToken")
		if err != nil {
			return fail("BAD_ARGUMENTS", err)
		}
		addDefaultScopes, err := needBool(args, "addDefaultScopes")
		if err != nil {
			return fail("BAD_ARGUMENTS", err)
		}
		useAccessToken, err := needBool(args, "useAccessToken")
		if err != nil {
			return fail("BAD_ARGUMENTS", err)
		}
		data, err := kubenav.OIDCGetAccessToken(text["discoveryURL"], text["clientID"], text["clientSecret"], text["certificateAuthority"], text["scopes"], addDefaultScopes, text["redirectURL"], text["refreshToken"], useAccessToken)
		return done("OIDC_GET_ACCESS_TOKEN_FAILED", data, err)
	case "oidcDeviceAuth":
		text, err := needStrings(args, "discoveryURL", "clientID", "certificateAuthority", "scopes")
		if err != nil {
			return fail("BAD_ARGUMENTS", err)
		}
		addDefaultScopes, err := needBool(args, "addDefaultScopes")
		if err != nil {
			return fail("BAD_ARGUMENTS", err)
		}
		data, err := kubenav.OIDCDeviceAuth(text["discoveryURL"], text["clientID"], text["certificateAuthority"], text["scopes"], addDefaultScopes)
		return done("OIDC_DEVICE_AUTH_FAILED", data, err)
	case "oidcDeviceAuthGetRefreshToken":
		text, err := needStrings(args, "discoveryURL", "clientID", "certificateAuthority", "scopes", "deviceCode")
		if err != nil {
			return fail("BAD_ARGUMENTS", err)
		}
		addDefaultScopes, err := needBool(args, "addDefaultScopes")
		if err != nil {
			return fail("BAD_ARGUMENTS", err)
		}
		useAccessToken, err := needBool(args, "useAccessToken")
		if err != nil {
			return fail("BAD_ARGUMENTS", err)
		}
		data, err := kubenav.OIDCDeviceAuthGetRefreshToken(text["discoveryURL"], text["clientID"], text["certificateAuthority"], text["scopes"], addDefaultScopes, text["deviceCode"], useAccessToken)
		return done("OIDC_DEVICE_AUTH_GET_REFRESH_TOKEN_FAILED", data, err)
	case "prometheusGetData":
		return callCluster(args, "PROMETHEUS_GET_DATA_FAILED", func(c clusterArgs) (string, error) {
			text, err := needStrings(args, "request")
			if err != nil {
				return "", err
			}
			return kubenav.PrometheusGetData(c.server, c.tlsServerName, c.caData, c.insecure, c.certData, c.keyData, c.token, c.username, c.password, c.proxy, c.timeout, text["request"])
		})
	case "verifyIAP":
		return fail("NOT_IMPLEMENTED", fmt.Errorf("HarmonyOS does not use the iOS purchase verifier"))
	default:
		return fail("NOT_IMPLEMENTED", fmt.Errorf("unknown method %s", method))
	}
}

type clusterArgs struct {
	server, tlsServerName, caData, certData, keyData, token, username, password, proxy string
	insecure                                                                           bool
	timeout                                                                            int64
}

func callCluster(args map[string]any, code string, fn func(clusterArgs) (string, error)) string {
	c, err := readCluster(args)
	if err != nil {
		return fail("BAD_ARGUMENTS", err)
	}
	data, err := fn(c)
	if err != nil && data == "" && isArgumentError(err) {
		return fail("BAD_ARGUMENTS", err)
	}
	return done(code, data, err)
}

func isArgumentError(err error) bool {
	return err != nil && len(err.Error()) >= 8 && err.Error()[:8] == "missing "
}

func readCluster(args map[string]any) (clusterArgs, error) {
	text, err := needStrings(args, "clusterServer", "clusterTLSServerName", "clusterCertificateAuthorityData", "userClientCertificateData", "userClientKeyData", "userToken", "userUsername", "userPassword", "proxy")
	if err != nil {
		return clusterArgs{}, err
	}
	insecure, err := needBool(args, "clusterInsecureSkipTLSVerify")
	if err != nil {
		return clusterArgs{}, err
	}
	timeout, err := needInt(args, "timeout")
	if err != nil {
		return clusterArgs{}, err
	}
	return clusterArgs{
		server: text["clusterServer"], tlsServerName: text["clusterTLSServerName"], caData: text["clusterCertificateAuthorityData"],
		certData: text["userClientCertificateData"], keyData: text["userClientKeyData"], token: text["userToken"],
		username: text["userUsername"], password: text["userPassword"], proxy: text["proxy"], insecure: insecure, timeout: timeout,
	}, nil
}

func needStrings(args map[string]any, keys ...string) (map[string]string, error) {
	values := make(map[string]string, len(keys))
	for _, key := range keys {
		value, ok := args[key]
		if !ok || value == nil {
			return nil, fmt.Errorf("missing %s", key)
		}
		text, ok := value.(string)
		if !ok {
			return nil, fmt.Errorf("missing %s", key)
		}
		values[key] = text
	}
	return values, nil
}

func needBool(args map[string]any, key string) (bool, error) {
	value, ok := args[key]
	if !ok || value == nil {
		return false, fmt.Errorf("missing %s", key)
	}
	typed, ok := value.(bool)
	if !ok {
		return false, fmt.Errorf("missing %s", key)
	}
	return typed, nil
}

func needInt(args map[string]any, key string) (int64, error) {
	value, ok := args[key]
	if !ok || value == nil {
		return 0, fmt.Errorf("missing %s", key)
	}
	switch typed := value.(type) {
	case float64:
		return int64(typed), nil
	case int64:
		return typed, nil
	case json.Number:
		return typed.Int64()
	default:
		return 0, fmt.Errorf("missing %s", key)
	}
}

func ok(data string) string {
	return done("", data, nil)
}

func done(code, data string, err error) string {
	if err != nil {
		return fail(code, err)
	}
	encoded, marshalErr := json.Marshal(map[string]any{"ok": true, "data": data})
	if marshalErr != nil {
		return fail(code, marshalErr)
	}
	return string(encoded)
}

func fail(code string, err error) string {
	message := ""
	if err != nil {
		message = err.Error()
	}
	encoded, marshalErr := json.Marshal(map[string]any{"ok": false, "code": code, "message": message})
	if marshalErr != nil {
		return `{"ok":false,"code":"KUBENAV_OHOS_FAILED","message":"failed to encode error"}`
	}
	return string(encoded)
}

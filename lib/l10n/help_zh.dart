/// Chinese help articles keyed by the English help title.
/// Screenshots stay on the original English paths.
const Map<String, String> helpZh = {
  'Add a Cluster': r'''
要把新集群加入 kubenav，请打开**设置**页面，在集群区域选择**查看全部**。

![添加集群](resource:assets/help/clusters-add-cluster-1.png)

在下一页顶部选择一种集群提供方，把集群加入 kubenav。不同提供方的用法见文档中的提供方一节。

![添加集群](resource:assets/help/clusters-add-cluster-2.png)
''',
  'Edit a Cluster': r'''
编辑集群时，先进入**集群**页面（**设置** -> **查看全部**）。然后**长按**集群名称，在弹出的面板中选择**编辑**。

![编辑集群](resource:assets/help/clusters-options-cluster-1.png)

可以修改集群的这些属性：

- 名称
- 服务器
- 证书颁发机构数据
- 不安全：跳过 TLS 校验
- 客户端证书数据
- 客户端密钥数据
- 令牌
- 用户名
- 密码
- 命名空间
''',
  'Delete a Cluster': r'''
删除集群时，先进入**集群**页面（**设置** -> **查看全部**）。然后**长按**集群名称，在弹出的面板中选择**删除**。

![删除集群](resource:assets/help/clusters-options-cluster-1.png)
''',
  'Switch between Clusters': r'''
可以用下面几种方式切换集群：

- 打开**设置**页面，在**集群**区域选择一个集群
- 进入**设置** -> **查看全部**，再选择一个集群
- 点击**集群**图标，再选择一个集群

![切换集群](resource:assets/help/clusters-switch-clusters-1.png)
''',
  'Sort Clusters': r'''
可以在**集群**页面（**设置** -> **查看全部**）给集群排序，让最常用的集群始终排在最上面。

排序时请**点击排序图标**，然后把集群上移或下移。
''',
  'Kubeconfig': r'''
请确认 Kubeconfig 文件里没有证书路径，而是包含 Base64 编码后的证书。例如：如果文件中有 **certificate-authority** 字段并指向证书路径，需要把它换成 `certificate-authority-data`，并填入证书的 Base64 编码值。

如果要通过文件对话框选择 Kubeconfig，请保证文件扩展名是 **.yaml**、**.yml**、**.txt** 或 **.conf**。

Kubeconfig 里的集群和用户不要依赖云厂商或 OIDC 来访问集群，这类文件导入会失败。请改用对应的云厂商提供方导入这些集群。
''',
  'Google': r'''
可以直接从 Google Cloud 导入 GKE 集群。导入时需要提供一个 Google OAuth 2.0 应用的有效 **客户端 ID** 和**客户端密钥**。配置方法如下。

### Google OAuth 2.0 配置

登录 [Google Cloud Console](https://console.cloud.google.com)，在菜单中依次选择 **API 和服务**、**OAuth 同意屏幕**。

![Google OAuth 2.0 配置](resource:assets/help/providers-google-1.png)

点击 **EDIT APP**，把 **https://www.googleapis.com/auth/cloud-platform** 加到 **Scopes for Google APIs**，然后保存 OAuth 同意屏幕。

![Google OAuth 2.0 配置](resource:assets/help/providers-google-2.png)

在菜单中选择 **Credentials** 以创建新的客户端 ID。点击 **CREATE CREDENTIALS**，再选择 **OAuth client ID**。

#### Web

配置一个新的 Web 应用客户端，取得 **客户端 ID** 和**客户端密钥**。

必须在设置中把 **https://kubenav.io/auth/google.html** 加为合法的重定向 URL，也可以在添加提供方时指定自定义重定向 URL。重定向地址应指向一个方便复制返回的 **code** 参数的页面。示例 HTML 见 https://github.com/kubenav/kubenav/blob/main/kubenav.io/auth/google.html。

![Google OAuth 2.0 配置](resource:assets/help/providers-google-3.png)

#### 启用 API

最后需要启用 **Kubernetes Engine API** 和 **Cloud Resource Manager API**：

- **Kubernetes Engine API：** [https://console.cloud.google.com/apis/library/container.googleapis.com](https://console.cloud.google.com/apis/library/container.googleapis.com)
- **Cloud Resource Manager API：** [https://console.cloud.google.com/apis/library/cloudresourcemanager.googleapis.com](https://console.cloud.google.com/apis/library/cloudresourcemanager.googleapis.com)
''',
  'Amazon Web Services': r'''
使用 Amazon Web Services 提供方导入 EKS 集群时，需要提供 **访问密钥 ID**、**秘密密钥**和**区域**。

这些凭据也会用来访问 EKS 集群的 Kubernetes API。请确认该**访问密钥 ID**有权列出 EKS 集群并访问集群。
''',
  'AWS Single Sign-On': r'''
也可以在 kubenav 中使用 AWS Single Sign-On。需要提供 **起始 URL**、**账号 ID**、**角色名称**、**SSO 区域**和**区域**。
''',
  'Azure': r'''
从 Microsoft Azure 导入 AKS 集群需要一组凭据。获取或创建这些凭据的方法如下。

### Microsoft Azure：创建应用凭据

登录 [Microsoft Azure 门户](https://portal.azure.com/)。在 kubenav 中使用 Azure 集成需要这些信息：

- 订阅 ID
- 客户端 ID
- 客户端密钥
- 租户 ID
- 资源组名称

要取得客户端 ID、客户端密钥和租户 ID，需要在 **Azure Active Directory** 中创建**应用注册**。进入 **Azure Active Directory**、**应用注册**，然后**新注册**。不需要填写重定向 URI。创建后记下 **应用程序(客户端) ID** 和**目录(租户) ID**。

![Microsoft Azure：创建应用凭据](resource:assets/help/providers-azure-1.png)

然后在这个**应用注册**中进入**证书和机密**，新建一个**客户端密钥**。

![Microsoft Azure：创建应用凭据](resource:assets/help/providers-azure-2.png)

接着在这个**应用注册**中进入**清单**，把 **"oAuth2AllowImplicitFlow": true** 设上并保存。

![Microsoft Azure：创建应用凭据](resource:assets/help/providers-azure-3.png)

接下来要给新的**应用注册**授予管理上述资源的权限。进入**订阅**，选择要给 kubenav 使用的订阅，记下**订阅 ID**，再进入该订阅的**访问控制(IAM)**。

![Microsoft Azure：创建应用凭据](resource:assets/help/providers-azure-4.png)

在这里新增一个**角色分配**，把**参与者**角色授给刚刚创建的 **Azure AD 用户、组或服务主体**。

![Microsoft Azure：创建应用凭据](resource:assets/help/providers-azure-5.png)
''',
  'OIDC': r'''
为 OIDC 提供方填写**名称**、**发现 URL** 和**客户端 ID**。如果没有选择 PKCE 方法，还必须填写**客户端密钥**。

也可以选填**范围**、**证书颁发机构**和**刷新令牌**。

填完后点击**登录**并完成认证流程。认证结束后会跳转到 **kubenav.io**，在那里复制 **Code**。

点击**保存并添加集群**完成提供方设置。

必须在 OIDC 提供方的设置中把 **https://kubenav.io/auth/oidc.html** 加为合法的重定向 URL，也可以在添加提供方时指定自定义重定向 URL。重定向地址应指向一个方便复制返回的 **code** 参数的页面。示例 HTML 见 https://github.com/kubenav/kubenav/blob/main/kubenav.io/auth/oidc.html。
''',
  'DigitalOcean': r'''
使用 DigitalOcean 提供方时，只需要一个用于访问 DigitalOcean API 的[个人访问令牌](https://www.digitalocean.com/docs/apis-clis/api/create-personal-access-token/)。
''',
  'Rancher': r'''
使用 Rancher 提供方时，需要提供 Rancher API 的**地址**。地址末尾不要带斜杠（“/”）。如果 Rancher 使用自签名证书，请打开**允许不安全连接**。

还需要提供**用户名**和**密码**。填好后可以用**登录**按钮生成新的**令牌**，也可以自己填入令牌。
''',
  'Manual': r'''
当需要手工配置每个集群时可以使用这种方式。如果当前提供方不受支持，可以通过**服务账号**访问集群。

### 使用服务账号

如果没有与 kubenav 兼容的 Kubeconfig，或者云厂商不受支持，可以创建服务账号并用它的凭据认证。

第一步是创建 **ServiceAccount**、**ClusterRole** 和 **ClusterRoleBinding**。下面的例子在名为 **kubenav** 的新命名空间中创建这些资源：

```sh
cat <<EOF | kubectl apply -f -
---
apiVersion: v1
kind: Namespace
metadata:
  name: kubenav

---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: kubenav
  namespace: kubenav

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: kubenav
  namespace: kubenav
rules:
  - apiGroups: ["*"]
    resources: ["*"]
    verbs: ["*"]

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: kubenav
  namespace: kubenav
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: kubenav
subjects:
  - kind: ServiceAccount
    name: kubenav
    namespace: kubenav
EOF
```

接下来使用这个服务账号对应的 Secret。用下面的命令取得 Secret 名称：

```sh
export SECRET_NAME=$(kubectl get sa --namespace kubenav kubenav -o=jsonpath='{.secrets[*].name}')
```

用下面的命令取得访问 Kubernetes API 所需的证书和令牌：

```sh
kubectl get secret $SECRET_NAME -o=jsonpath='{.data.ca.crt}'
kubectl get secret $SECRET_NAME -o=jsonpath='{.data.token}' | base64 --decode
```

第一条命令的输出填到**证书颁发机构数据**，第二条命令的输出填到**令牌**。

示例中的 RBAC 规则会授予不受限制的完整集群访问权限。更多说明见 Kubernetes 文档：[Using RBAC Authorization](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)。
''',
  'Switch between Namespaces': r'''
在资源列表页点击**命名空间**图标即可切换命名空间。

如果没有相应权限，可以通过**编辑集群**或维护一份命名空间列表来切换。如何管理这份列表见**添加命名空间**。

![切换命名空间](resource:assets/help/namespaces-switch-namespaces-1.png)
''',
  'Add a Namespace': r'''
可以维护一份命名空间列表，方便快速切换。要添加命名空间，请打开**设置**页面，在**设置**区域选择**命名空间**。

![添加命名空间](resource:assets/help/namespaces-add-namespace-1.png)

在命名空间页面点击右上角的**加号**。

![添加命名空间](resource:assets/help/namespaces-add-namespace-2.png)

然后填写命名空间的**名称**，点击**添加命名空间**。

![添加命名空间](resource:assets/help/namespaces-add-namespace-3.png)

也可以在命名空间详情页使用**星标图标**，把该命名空间加入或移出列表。

![添加命名空间](resource:assets/help/namespaces-add-namespace-4.png)
''',
  'Delete a Namespace': r'''
删除命名空间时，进入**设置** -> **命名空间**，**点击**要删除的命名空间，在弹出的面板中点击**删除**。

![删除命名空间](resource:assets/help/namespaces-delete-namespace-1.png)
''',
  'Sort Namespaces': r'''
排序命名空间列表时，进入**设置** -> **命名空间**。

**按住命名空间的拖动手柄**，然后上移或下移。
''',
  'Add a Bookmark': r'''
书签可以更快地打开 Kubernetes 资源。

在资源列表或详情页点击**书签**图标即可添加。

![添加书签](resource:assets/help/bookmarks-add-bookmark-1.png)

![添加书签](resource:assets/help/bookmarks-add-bookmark-2.png)
''',
  'Delete a Bookmark': r'''
在资源列表或详情页点击**书签**图标即可删除书签。

![删除书签](resource:assets/help/bookmarks-delete-bookmark-1.png)

![删除书签](resource:assets/help/bookmarks-delete-bookmark-2.png)

也可以在**书签**区域点击**查看全部**。在书签页面**长按**一条书签，然后在弹出的面板中点击**删除**。

![删除书签](resource:assets/help/bookmarks-delete-bookmark-3.png)
''',
  'Sort Bookmarks': r'''
可以在**书签**页面给书签排序。

**按住书签的拖动手柄**，然后上移或下移。
''',
  'Get Logs of a Container': r'''
点击**日志**图标即可查看容器日志。

![日志](resource:assets/help/logs-1.png)

在弹出的面板中选择容器和时间范围，然后点击**获取日志**。

![日志](resource:assets/help/logs-2.png)

要关闭显示日志的终端，请**长按**终端标签。

![日志](resource:assets/help/logs-3.png)
''',
  'Create a Terminal of a Container': r'''
点击**终端**图标即可打开容器终端。

![终端](resource:assets/help/terminals-1.png)

在弹出的面板中选择容器和 Shell，然后点击**获取终端**。

![终端](resource:assets/help/terminals-2.png)

要关闭已打开的终端，请**长按**终端标签。

![终端](resource:assets/help/terminals-3.png)

也可以先关闭面板，之后通过全局**终端**按钮重新打开。

![终端](resource:assets/help/terminals-4.png)
''',
  'Establish a Port-Forwarding Session': r'''
要建立到容器的端口转发，请在**配置**区域选择一个**端口**。

![端口转发会话](resource:assets/help/pfs-1.png)

然后等待全局**端口转发会话**图标出现。

![端口转发会话](resource:assets/help/pfs-2.png)

在弹出的面板中选择要使用的端口转发会话。

![端口转发会话](resource:assets/help/pfs-3.png)

在这里可以打开浏览器、复制地址，或删除端口转发会话。

![端口转发会话](resource:assets/help/pfs-4.png)
''',
  'Helm': r'''
使用 Helm 插件时，必须能够查看集群或命名空间中的全部 Secret。

除了这项权限，插件不需要其他配置。
''',
  'Prometheus': r'''
使用 Prometheus 插件前，请在**设置** -> **Prometheus** 中启用并配置它。

Prometheus 插件可以连接公开的 Prometheus，也可以连接集群内以 Pod 运行的 Prometheus。

使用公开的 Prometheus 时，在配置中填写**地址**。也可以在凭据区域填写**用户名**、**密码**和**令牌**。

使用集群内的 Prometheus Pod 时，**地址必须留空**。改为填写**命名空间**、**标签选择器**、**容器**和**端口**，以选中集群中的 Pod。还可以选填 Prometheus API 在该端口上的**路径**。集群内配置同样可以使用凭据区域。

Prometheus 插件依赖 `kubelet` 和 `kube-state-metrics` 指标来显示工作负载的默认指标。请确认集群中有这些指标，否则插件无法工作。
''',
  'Prometheus - Custom Metrics': r'''
启用 Prometheus 插件后，应用会在每个工作负载的详情页自动显示一些重要指标。

也可以给资源加上 `kubenav.io/prometheus` 注解，为任意资源添加自定义指标。下面的例子给 Deployment 增加一个自定义指标，按响应码（同时作为标签）显示 HTTP 请求数：

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
  namespace: default
  labels:
    app: myapp
  annotations:
    kubenav.io/prometheus: |
      - title: 'HTTP Requests'
        unit: 'req/s'
        queries:
          - label: '{{.response_code}}'
            query: 'sum(irate(istio_requests_total{reporter=~"destination",destination_workload_namespace=~"default",destination_workload=~"myapp"}[5m])) by (response_code)'
spec:
```

![Prometheus 自定义指标](resource:assets/help/plugins-prometheus-1.png)
''',
  'Prometheus - Dashboards': r'''
除了默认指标和上一节中的自定义指标，还可以定义自定义 Prometheus 仪表盘。

仪表盘用带有 `kubenav.io/prometheus=dashboard` 标签的 ConfigMap 定义，通过**插件** -> **Prometheus** 进入。该页面会列出当前命名空间中带此标签的全部 ConfigMap。

下面是一个 Prometheus 仪表盘 ConfigMap 示例：

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: mydashboard
  namespace: default
  labels:
    kubenav.io/prometheus: dashboard
data:
  charts: |
    - title: 'HTTP Requests'
      unit: 'req/s'
      queries:
        - label: '{{.response_code}}'
          query: 'sum(irate(istio_requests_total{reporter=~"destination",destination_workload_namespace=~"default",destination_workload=~"myapp"}[5m])) by (response_code)'
```
''',
};

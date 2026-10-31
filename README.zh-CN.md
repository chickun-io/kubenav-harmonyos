[English](README.md) | 简体中文

<div align="center">
  <img src="utils/images/repo/github-readme-logo.png" width="200" />
  <br><br>

**kubenav** 把 **Kubernetes** 集群装进你的口袋。它是一款**移动**应用，用来管理 Kubernetes 集群，并查看 Kubernetes 资源的状态。

</div>

<p align="center">
  <a href="https://apps.apple.com/us/app/kubenav/id1494512160" target="_blank"><img src="utils/images/repo/badge-app-store.png" height="50" /></a>
  <a href="https://play.google.com/store/apps/details?id=io.kubenav.kubenav" target="_blank"><img src="utils/images/repo/badge-google-play.png" height="50" /></a>
</p>

<table>
  <tr>
    <td><img src="utils/images/stores/iphone65-1.png" /></td>
    <td><img src="utils/images/stores/iphone65-2.png" /></td>
    <td><img src="utils/images/stores/iphone65-3.png" /></td>
  </tr>
</table>

kubenav 是一款用来管理 Kubernetes 集群的移动应用。应用会总览集群中的资源，并显示工作负载的当前状态。资源详情页提供更多信息。你可以查看日志和事件，或进入容器的 Shell。也可以在应用里编辑、删除资源，或扩缩工作负载。

应用使用 [Flutter](https://flutter.dev) 和 [Go](https://go.dev) 开发。开发相关说明见[贡献指南](https://github.com/kubenav/kubenav/blob/main/CONTRIBUTING.md)。

## 功能

- **移动端可用：** kubenav 在手机上提供与 kubectl 相同的体验。
- **管理资源：** 支持 Deployment、StatefulSet、DaemonSet、Pod 等主要资源。
- **自定义资源定义：** 查看全部 Custom Resource Definition，并管理自定义资源。
- **修改资源：** 编辑和删除可用资源，或扩缩 Deployment、StatefulSet、DaemonSet。
- **筛选和搜索：** 按命名空间筛选资源，并按名称查找。
- **状态信息：** 快速查看工作负载状态，以及包含事件在内的详细信息。
- **资源用量：** 查看 Pod 和容器的请求、限制与当前用量。
- **日志：** 查看容器日志，或实时跟踪日志。
- **终端：** 直接从手机进入容器 Shell。
- **管理多个集群：** 通过 `kubeconfig` 或云厂商添加多个集群，包括 Google、AWS 和 Azure。
- **端口转发：** 建立到 Pod 的端口转发，并在浏览器中打开对应页面。
- **Prometheus 集成：** 在仪表盘中查看 Prometheus 指标，并通过 Prometheus 插件搭建自己的仪表盘。

应用界面跟随设备系统语言。这一版包含英语（en-US）和简体中文（zh-CN）。其他语言回退到英语。

## 使用

kubenav 移动版可以从 [App Store](https://apps.apple.com/us/app/kubenav/id1494512160) 或 [Google Play](https://play.google.com/store/apps/details?id=io.kubenav.kubenav) 下载。为了试用新功能和更快获得反馈，我们通过 [Apple TestFlight](https://testflight.apple.com/join/RQUFGkHi) 和 [Google Play](https://play.google.com/apps/testing/io.kubenav.kubenav) 提供**测试版**。

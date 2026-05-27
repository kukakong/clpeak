# clpeak Android 构建说明

## 构建产物

我们已成功为 Android 平台构建了 clpeak，包括：
- **clpeak-armeabi-v7a** - 适用于 32 位 ARM 处理器的可执行文件
- **clpeak-arm64-v8a** - 适用于 64 位 ARM 处理器的可执行文件

构建产物位于：
```
/workspace/clpeak/build-android-output/
```

## 在 Android 设备上运行

### 前置条件

1. 启用 Android 设备的**开发者选项**
2. 启用**USB 调试**
3. 安装 `adb` 工具（Android Debug Bridge）

### 步骤

1. **推送可执行文件到设备**

```bash
# 对于 64 位设备
adb push build-android-output/clpeak-arm64-v8a /data/local/tmp/clpeak

# 对于 32 位设备
adb push build-android-output/clpeak-armeabi-v7a /data/local/tmp/clpeak
```

2. **设置可执行权限**

```bash
adb shell chmod +x /data/local/tmp/clpeak
```

3. **运行 clpeak**

```bash
# 进入 shell
adb shell

# 运行完整的性能测试
cd /data/local/tmp
./clpeak

# 或者直接从主机运行
adb shell /data/local/tmp/clpeak
```

## 可用命令

```bash
# 运行所有测试（默认行为）
./clpeak

# 列出可用设备
./clpeak --list-devices

# 运行特定平台和设备的测试
./clpeak --cl-platform 0 --cl-device 0

# 仅运行特定测试
./clpeak --single-precision-compute
./clpeak --global-bandwidth

# 导出结果到文件
./clpeak --json-file results.json
./clpeak --csv-file results.csv
```

## 注意事项

- 这个构建使用 OpenCL 后端（Vulkan、CUDA、Metal 已禁用）
- 设备需要支持 OpenCL 才能运行大多数测试
- 构建的可执行文件静态链接了 OpenCL stub 库，通过 dlopen 在运行时加载设备的 OpenCL 实现
- Android 平台要求 API 级别 28+（Android 9+）

## 重新构建

如果需要重新构建可执行文件：

```bash
cd /workspace/clpeak
./build-final.sh
```

## 文件位置

- 32 位可执行文件：`/workspace/clpeak/build-android-output/clpeak-armeabi-v7a`
- 64 位可执行文件：`/workspace/clpeak/build-android-output/clpeak-arm64-v8a`

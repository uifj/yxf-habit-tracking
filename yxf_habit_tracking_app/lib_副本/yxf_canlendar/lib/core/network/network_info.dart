/// 网络连接信息接口
/// 用于检查设备的网络连接状态
abstract class NetworkInfo {
  /// 检查是否有网络连接
  Future<bool> get isConnected;
  
  /// 获取网络连接类型
  Future<NetworkType> get connectionType;
  
  /// 监听网络连接状态变化
  Stream<bool> get onConnectivityChanged;
}

/// 网络连接类型枚举
enum NetworkType {
  none,
  wifi,
  mobile,
  ethernet,
  bluetooth,
  vpn,
  other,
}

/// 网络连接信息实现类
class NetworkInfoImpl implements NetworkInfo {
  // 这里可以使用 connectivity_plus 包来实现
  // 为了简化，先提供基础实现
  
  @override
  Future<bool> get isConnected async {
    // 简化实现，实际应该使用 connectivity_plus
    return true;
  }
  
  @override
  Future<NetworkType> get connectionType async {
    // 简化实现，实际应该使用 connectivity_plus
    return NetworkType.wifi;
  }
  
  @override
  Stream<bool> get onConnectivityChanged {
    // 简化实现，实际应该使用 connectivity_plus
    return Stream.periodic(const Duration(seconds: 5), (count) => true);
  }
}
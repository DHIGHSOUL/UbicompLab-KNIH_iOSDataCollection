//
//  NetworkManager.swift
//  iOSDataCollection
//
//  Created by ROLF J. on 2022/07/28.
//

import Foundation
import Network

final class NetWorkManager {
    
    static let shared = NetWorkManager()
    
    private let queue = DispatchQueue.global()
    private let monitor: NWPathMonitor
    public private(set) var isConnected: Bool = false
    public private(set) var connectionType: ConnectionType = .unknown
    
    // 연결 방식을 나타내는 열거형
    enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case unknown
    }
    
    private init() {
        monitor = NWPathMonitor()
    }
    
    // 인터넷 연결 모니터링을 시작하는 메소드
    public func startMonitoring() {
        print("인터넷 모니터링을 시작함")
        
        monitor.start(queue: queue)
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status == .satisfied
            self?.getConnectionType(path)
            
            if self?.isConnected == true {
                print("인터넷에 연결되어 있음")
            } else {
                print("인터넷에 연결되어 있지 않음")
            }
        }
    }
    
    // 인터넷 연결 모니터링을 끝내는 메소드
    public func stopMonitoring() {
        monitor.cancel()
        print("인터넷 모니터링을 종료함")
    }
    
    // 어떤 방식으로 인터넷에 연결되어 있는지 확인
    private func getConnectionType(_ path: NWPath) {
        if path.usesInterfaceType(.wifi) {
            connectionType = .wifi
            print("와이파이로 연결됨")
        } else if path.usesInterfaceType(.cellular) {
            connectionType = .cellular
            print("셀룰러 데이터로 연결됨")
        } else if path.usesInterfaceType(.wiredEthernet) {
            connectionType = .ethernet
            print("이더넷으로 연결됨")
        } else {
            connectionType = .unknown
            print("Internet Connection: Unknown")
        }
    }
    
}

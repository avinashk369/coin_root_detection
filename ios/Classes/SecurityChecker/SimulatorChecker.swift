import Foundation

internal struct SimulatorChecker {
    
    func amIRunInSimulator() -> Bool {
        return checkCompile() || checkRuntime()
    }
    
    private  func checkRuntime() -> Bool {
        return ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"] != nil
    }
    
    private  func checkCompile() -> Bool {
#if targetEnvironment(simulator)
        return true
#else
        return false
#endif
    }
}


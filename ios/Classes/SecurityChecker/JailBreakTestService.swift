import Foundation

internal struct JailBreakTestService {
    typealias CheckResult = (failed: Bool, msg: String)
    
    
    func isJailBroken() -> CheckResult {
         
        let privatePathWriteTestResult = privatePathWriteTestResult()
        if privatePathWriteTestResult.failed {
            return privatePathWriteTestResult
        }
         
        let suspiciousFilesExistenceTestResult = suspiciousFilesExistenceTestResult()
        if suspiciousFilesExistenceTestResult.failed {
            return suspiciousFilesExistenceTestResult
        }
         
        if !SimulatorChecker().amIRunInSimulator() {
            let forkTestResult = forkTestResult()
            if forkTestResult.failed {
                return forkTestResult
            }
        } else {
            debugPrint("App is running in simulator skipping the fork check.")
        }
         
        let suspiciousAppPresenceTestResult = suspiciousAppPresenceTestResult()
        if suspiciousAppPresenceTestResult.failed {
            return suspiciousAppPresenceTestResult
        }
         
        if let advancedChecksResult = performAdvancedJailbreakChecks() {
            return advancedChecksResult
        }
                
        return (false, "All the jail break tests passed")
    }
    
    
    private func privatePathWriteTestResult() -> CheckResult {
        let paths = [
            "/",
            "/root/",
            "/private/",
            "/jb/"
        ]
        
         
        for path in paths {
            do {
                let pathWithSomeRandom = path + UUID().uuidString
                try "AmIJailbroken?".write(
                    toFile: pathWithSomeRandom,
                    atomically: true,
                    encoding: String.Encoding.utf8
                ) 
                try FileManager.default.removeItem(atPath: pathWithSomeRandom)
                return (true, "Private path Write test result failed. Wrote to restricted path: \(path)")
            } catch {}
        }
        return (false, "")
    }
     
    private func suspiciousFilesExistenceTestResult() -> CheckResult {
        var paths = [
            "/var/mobile/Library/Preferences/ABPattern",  
            "/usr/lib/ABDYLD.dylib",  
            "/usr/lib/ABSubLoader.dylib",  
            "/usr/sbin/frida-server",  
            "/etc/apt/sources.list.d/electra.list",  
            "/etc/apt/sources.list.d/sileo.sources",  
            "/.bootstrapped_electra", 
            "/usr/lib/libjailbreak.dylib",  
            "/jb/lzma",  
            "/.cydia_no_stash",  
            "/.installed_unc0ver",  
            "/jb/offsets.plist",  
            "/usr/share/jailbreak/injectme.plist",  
            "/etc/apt/undecimus/undecimus.list",  
            "/var/lib/dpkg/info/mobilesubstrate.md5sums",  
            "/Library/MobileSubstrate/MobileSubstrate.dylib",
            "/jb/jailbreakd.plist",  
            "/jb/amfid_payload.dylib",  
            "/jb/libjailbreak.dylib",  
            "/usr/libexec/cydia/firmware.sh",
            "/var/lib/cydia",
            "/etc/apt",
            "/private/var/lib/apt",
            "/private/var/Users/",
            "/var/log/apt",
            "/Applications/Cydia.app",
            "/private/var/stash",
            "/private/var/lib/apt/",
            "/private/var/lib/cydia",
            "/private/var/cache/apt/",
            "/private/var/log/syslog",
            "/private/var/tmp/cydia.log",
            "/Applications/Icy.app",
            "/Applications/MxTube.app",
            "/Applications/RockApp.app",
            "/Applications/blackra1n.app",
            "/Applications/SBSettings.app",
            "/Applications/FakeCarrier.app",
            "/Applications/WinterBoard.app",
            "/Applications/IntelliScreen.app",
            "/private/var/mobile/Library/SBSettings/Themes",
            "/Library/MobileSubstrate/CydiaSubstrate.dylib",
            "/System/Library/LaunchDaemons/com.ikey.bbot.plist",
            "/Library/MobileSubstrate/DynamicLibraries/Veency.plist",
            "/Library/MobileSubstrate/DynamicLibraries/LiveClock.plist",
            "/System/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist",
            "/Applications/Sileo.app",
            "/var/binpack",
            "/Library/PreferenceBundles/LibertyPref.bundle",
            "/Library/PreferenceBundles/ShadowPreferences.bundle",
            "/Library/PreferenceBundles/ABypassPrefs.bundle",
            "/Library/PreferenceBundles/FlyJBPrefs.bundle",
            "/Library/PreferenceBundles/Cephei.bundle",
            "/Library/PreferenceBundles/SubstitutePrefs.bundle",
            "/Library/PreferenceBundles/libhbangprefs.bundle",
            "/usr/lib/libhooker.dylib",
            "/usr/lib/libsubstitute.dylib",
            "/usr/lib/substrate",
            "/usr/lib/TweakInject",
            "/var/binpack/Applications/loader.app",  
            "/Applications/FlyJB.app",  
            "/Applications/Zebra.app",  
            "/Library/BawAppie/ABypass",  
            "/Library/MobileSubstrate/DynamicLibraries/SSLKillSwitch2.plist",  
            "/Library/MobileSubstrate/DynamicLibraries/PreferenceLoader.plist", 
            "/Library/MobileSubstrate/DynamicLibraries/PreferenceLoader.dylib",  
            "/Library/MobileSubstrate/DynamicLibraries",  
            "/var/mobile/Library/Preferences/me.jjolano.shadow.plist"
        ]
        
         
        if !SimulatorChecker().amIRunInSimulator() {
            paths += [
                "/bin/bash",
                "/usr/sbin/sshd",
                "/usr/libexec/ssh-keysign",
                "/bin/sh",
                "/etc/ssh/sshd_config",
                "/usr/libexec/sftp-server",
                "/usr/bin/ssh"
            ]
        }
        let fileManager = FileManager.default
        for aPath in paths {
             
            if fileManager.fileExists(atPath: aPath) {
                return (true, "Suspicious File exist test failed. Suspicious file present at path:- \(aPath)")
            }
        }
        
        return (false, "")
    }
    
    
    private func forkTestResult() -> CheckResult {
        let pointerToFork = UnsafeMutableRawPointer(bitPattern: -2)
        let forkPtr = dlsym(pointerToFork, "fork")
        typealias ForkType = @convention(c) () -> pid_t
        let fork = unsafeBitCast(forkPtr, to: ForkType.self)
        let forkResult = fork()
        
        if forkResult >= 0 {
            if forkResult > 0 {
                kill(forkResult, SIGTERM)
            }
            return (true, "Fork Test failed. Fork was able to create a new process (sandbox violation)")
        }
        
        return (false, "")
    }
    
    
    private func suspiciousAppPresenceTestResult() -> CheckResult {
        let urlSchemes = [
            "undecimus://",
            "sileo://",
            "zbra://",
            "filza://",
            "cydia://"
        ]
        for aScheme in urlSchemes {
            if let url = URL(string: aScheme) {
                if UIApplication.shared.canOpenURL(url) {
                    return (true, "Suspicious app presence Test failed. Suspicious app present with url scheme:- \(url)")
                }
            }
        }
        return (false, "")
    }
    
    private let suspiciousDylibs = [
        "/usr/lib/libshadow.dylib",
        "/usr/lib/Shadow.dylib",
        "/Library/MobileSubstrate/DynamicLibraries/Shadow.dylib",
        "/Library/MobileSubstrate/DynamicLibraries/libshadow.dylib"
    ]

    private let shadowPaths = [
        "/Library/PreferenceBundles/ShadowPreferences.bundle",
        "/var/mobile/Library/Preferences/me.jjolano.shadow.plist",
        "/Library/MobileSubstrate/DynamicLibraries/Shadow.dylib"
    ]

    private let suspiciousEnvVars = [
        "DYLD_INSERT_LIBRARIES",
        "DYLD_FORCE_FLAT_NAMESPACE"
    ]

    private let hookingLibraries = [
        "libhooker.dylib",
        "SubstrateBootstrap.dylib",
        "Substitute.dylib",
        "TSInject.dylib"
    ]

    private func checkFilesExistence(atPaths paths: [String], failureMessage: String) -> CheckResult {
        for path in paths {
            if FileManager.default.fileExists(atPath: path) {
                return (true, "\(failureMessage) found at path: \(path)")
            }
        }
        return (false, "")
    }

    private func shadowDylibCheck() -> CheckResult {
        return checkFilesExistence(atPaths: suspiciousDylibs, failureMessage: "Shadow Dylib Check failed. Suspicious dylib")
    }

    private func shadowFilesCheck() -> CheckResult {
        return checkFilesExistence(atPaths: shadowPaths, failureMessage: "Shadow Files Check failed. Shadow-related file")
    }

   
    private func methodSwizzlingCheck() -> CheckResult {
        guard
            let originalMethod = class_getInstanceMethod(NSObject.self, #selector(NSObject.description)),
            let swizzledMethod = class_getInstanceMethod(NSObject.self, Selector(("shadow_description"))),
            method_getImplementation(originalMethod) != method_getImplementation(swizzledMethod)
        else {
            return (false, "")
        }
        return (true, "Method Swizzling Check failed. Description method has been swizzled.")
    }

    private func debuggerCheck() -> CheckResult {
        var info = kinfo_proc()
        var mib = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
        var size = MemoryLayout<kinfo_proc>.stride
        let sysctlResult = sysctl(&mib, u_int(mib.count), &info, &size, nil, 0)
        
        if sysctlResult == 0 && (info.kp_proc.p_flag & P_TRACED) != 0 {
            return (true, "Debugger Check failed. A debugger is attached to the process.")
        }
        return (false, "")
    }

    private func environmentVariablesCheck() -> CheckResult {
        for varName in suspiciousEnvVars {
            if let value = getenv(varName), !String(cString: value).isEmpty {
                return (true, "Environment Variables Check failed. Suspicious environment variable found: \(varName)")
            }
        }
        return (false, "")
    }

    
    private func sandboxIntegrityCheck() -> CheckResult {
        let testFilePath = "/private/var/mobile/Library/SandboxTest.txt"
        
        do {
            try "Sandbox Test".write(toFile: testFilePath, atomically: true, encoding: .utf8)
            try FileManager.default.removeItem(atPath: testFilePath)
            return (true, "Sandbox Integrity Check failed. Writing to a protected directory was successful.")
        } catch {
            return (false, "")
        }
    }

    private func systemFrameworkIntegrityCheck() -> CheckResult {
        guard let handle = dlopen("/System/Library/Frameworks/UIKit.framework/UIKit", RTLD_NOW) else {
            return (true, "System Framework Integrity Check failed. Unable to load UIKit framework.")
        }
        
        defer {
            dlclose(handle)
        }
        
        let expectedSymbol = dlsym(handle, "UIApplicationMain")
        if expectedSymbol == nil {
            return (true, "System Framework Integrity Check failed. UIApplicationMain symbol is missing or tampered.")
        }
        
        return (false, "")
    }
 
    private func hookingLibrariesCheck() -> CheckResult {
        for library in hookingLibraries {
            if let handle = dlopen(library, RTLD_NOW) {
                dlclose(handle)
                return (true, "Hooking Libraries Check failed. Detected hooking library: \(library)")
            }
        }
        return (false, "")
    }

     
    private func multipleForkChecks() -> CheckResult {
        for _ in 0..<5 {
            let result = forkTestResult()
            if result.failed {
                return result
            }
        }
        return (false, "")
    }
    
    private func libertyCheck() -> CheckResult {
        let libertyPaths = [
            "/usr/lib/liberty.dylib",
            "/Library/MobileSubstrate/DynamicLibraries/Liberty.dylib",
            "/Library/MobileSubstrate/DynamicLibraries/LibertyLite.dylib"
        ]
        
        for path in libertyPaths {
            if FileManager.default.fileExists(atPath: path) {
                return (true, "Liberty Check failed. Detected Liberty files at path: \(path)")
            }
        }
        return (false, "")
    }

    private func objectionCheck() -> CheckResult { 
        let objectionFiles = [
            "/usr/lib/frida-gadget.dylib",
            "/Library/MobileSubstrate/DynamicLibraries/frida.dylib"
        ]
        
        for path in objectionFiles {
            if FileManager.default.fileExists(atPath: path) {
                return (true, "Objection Check failed. Detected Frida gadget or objection-related files at path: \(path)")
            }
        }
        return (false, "")
    }
    
    private func fridaCheck() -> CheckResult { 
        let fridaLibraries = [
            "FridaGadget",  
            "frida-agent"   
        ]
        
        for library in fridaLibraries {
            if let handle = dlopen(library, RTLD_NOW) {
                dlclose(handle)
                return (true, "Frida Check failed. Detected loaded Frida library: \(library)")
            }
        }
        
        
        let fridaSymbols = [
            "frida_version",  
            "gum_interceptor_begin_transaction" 
        ]
        
        for symbol in fridaSymbols {
            if dlsym(UnsafeMutableRawPointer(bitPattern: -2), symbol) != nil {
                return (true, "Frida Check failed. Detected Frida symbol in memory: \(symbol)")
            }
        }
        
        return (false, "")
    }
    
    private func shadowConfigCheck() -> CheckResult {
        let shadowConfigPaths = [
            "/var/mobile/Library/Preferences/me.jjolano.shadow.plist",
            "/Library/PreferenceLoader/Preferences/Shadow.plist"
        ]
        
        for path in shadowConfigPaths {
            if FileManager.default.fileExists(atPath: path) {
                return (true, "Shadow Configuration Check failed. Detected Shadow configuration file at path: \(path)")
            }
        }
        return (false, "")
    }
    
    private func shadowHooksCheck() -> CheckResult {
         
        let originalMethod = class_getInstanceMethod(NSObject.self, #selector(NSObject.description))
        let shadowedMethod = class_getInstanceMethod(NSObject.self, Selector(("shadow_description")))
        
        if let originalMethod = originalMethod, let shadowedMethod = shadowedMethod {
            if method_getImplementation(originalMethod) != method_getImplementation(shadowedMethod) {
                return (true, "Shadow Hooks Check failed. NSObject description method has been swizzled by Shadow.")
            }
        }
        
        return (false, "")
    }

    private func performAdvancedJailbreakChecks() -> CheckResult? {
        let checks: [() -> CheckResult] = [
            debuggerCheck,
            environmentVariablesCheck,
            sandboxIntegrityCheck,
            systemFrameworkIntegrityCheck,
            hookingLibrariesCheck,
            multipleForkChecks,
            shadowDylibCheck,
            shadowFilesCheck,
            shadowConfigCheck,
            shadowHooksCheck,
            methodSwizzlingCheck,
            libertyCheck, 
            objectionCheck, 
            fridaCheck
        ]
        
        for check in checks {
            let result = check()
            if result.failed {
                return result
            }
        }
        return nil
    }
    
}

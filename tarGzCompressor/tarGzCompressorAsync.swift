//
//  tarGzCompressorAsync.swift
//  tarGzCompressor
//
//  Created by n1a9o92egtd on 2022/8/11.
//

import Foundation

enum COMPRESSOR_ACTIONS {
    case INIT
    case TO_TARGZ
    case FROM_TARGZ
}

func tar_gz(files:[URL])->AppSignerTaskOutput {
    let tarPath = "/usr/bin/tar"
    let workingDirectory:String = files[0].deletingLastPathComponent().appendingPathComponent("/").path
    let targz_name:String = files[0].appendingPathExtension("tar.gz").path
    var tar_args:[String] = ["zcvf", targz_name]
    for item in files {
        tar_args.append(item.lastPathComponent)
    }
//    NSLog("%@", tar_args)
    return Process().execute(launchPath: tarPath, workingDirectory: workingDirectory, arguments: tar_args)
}

final class TarGzCompressorAsync: ObservableObject {
    var filepaths:[URL] = []
    var action:COMPRESSOR_ACTIONS = .INIT
    @Published private(set) var isRunning: Bool = false
    @Published private(set) var isBuildSuccess: Bool = false
    typealias CALL_BACK = ((Bool)->Void)
    var complitionHandler: CALL_BACK?
    
    func setFile(_ path:[URL], action:COMPRESSOR_ACTIONS) {
        self.isBuildSuccess = false
        self.filepaths = path
        self.action = action
    }
    func waitForRebuildDone() ->Bool{
        if isRunning {
            return isBuildSuccess
        }
        if isBuildSuccess == false {
            Task {
                self.SetRunning(true)
                self.SetBuildSuccess(false)
                let work = Task.detached(priority: .low) {
                    self.heavyWork(files: self.filepaths)
                }

                // (3) non-blocking wait for value
                let result = await work.value
    //            print("result on main thread", result)
                self.SetBuildSuccess(result)
                self.SetRunning(false)
            }
        }
        return isBuildSuccess
    }
    nonisolated func heavyWork(files:[URL]) -> Bool {
        if self.action == .TO_TARGZ {
            self.complitionHandler!(true)
            var is_recompile_ok:Bool = false
            if !files.isEmpty {
                tar_gz(files: files)
//                sleep(10)
            }
            self.complitionHandler!(false)
            is_recompile_ok = true
            return is_recompile_ok
        }
        else if self.action == .FROM_TARGZ {
            return true
        }
        else {
            return true
        }
    }
    
    func SetRunning(_ b:Bool) {
        DispatchQueue.main.sync {
            self.isRunning = b
        }
    }
    public func SetBuildSuccess(_ b:Bool) {
        DispatchQueue.main.sync {
            self.isBuildSuccess = b
        }
    }
    public func SetClosureFunc(callback:(Bool)) {
        
    }
    func ClosureFunc(closure: @escaping CALL_BACK) {
        self.complitionHandler = closure
    }
}

//
//  ContentView.swift
//  tarGzCompressor
//
//  Created by n1a9o92egtd on 2022/8/11.
//

import SwiftUI
import UniformTypeIdentifiers
#if os(iOS)
import UIKit
#endif

struct BtnStyle: ButtonStyle {
    var color: Color
    var w:CGFloat
    var h:CGFloat
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .frame(width: w, height: h, alignment: .center)
            .padding(.horizontal,20)
            .padding(10)
            .background(Color.green.opacity(0.8))
            .cornerRadius(40)
            .scaleEffect(configuration.isPressed ? 0.99 : 1.0)
    }
}

struct FirstPageView: View {
#if os(iOS)
    let btn_w:CGFloat = CGFloat((UIScreen.screens[0].bounds.width / 2 ) / 5)
#else
    let btn_w:CGFloat = CGFloat((NSScreen.screens[0].frame.width / 2 ) / 5)
#endif
    @EnvironmentObject public var compressor:TarGzCompressorAsync
    @Binding public var files: [URL]
    @Binding public var is_dropd:Bool
    var body: some View {
        VStack{
            let btn1 = Button(action: {
                if files.count != 0 {
                    let src_files:[URL] = files
                    self.compressor.ClosureFunc(closure :  { is_begining in
                        self.is_dropd = is_begining
                    })
                    for file in files {
                        if FileManager.default.fileExists(atPath: file.path) == false {
                            return
                        }
                    }
                    self.compressor.setFile(src_files, action: COMPRESSOR_ACTIONS.TO_TARGZ)
                    self.compressor.waitForRebuildDone()
                    self.files.removeAll()
                }
                else {
                    let openDlg = NSOpenPanel()
                    openDlg.allowsMultipleSelection = true
                    openDlg.canChooseFiles = true
                    openDlg.canChooseDirectories = true
                    if openDlg.runModal() == NSApplication.ModalResponse.OK {
                        let files:URL = openDlg.url!
                        let file:String = files.lastPathComponent
                        let file_ext:String = files.pathExtension
                        if !FileManager.default.fileExists(atPath: files.path) {
                            return
                        }
                        self.files.append(files)
                    }
                }
            }) {
                HStack {
                    if files.count != 0 {
                        Text(String("\(files.count)")).fontWeight(.semibold).font(.largeTitle).background(Color.clear).foregroundColor(.white)
                    }
                    else {
                        Image(systemName: "plus.circle").foregroundColor(Color.white).font(.system(size: 64, weight: .regular, design: .rounded))
                    }
                }
            }
            btn1.buttonStyle(BtnStyle(color: Color.white, w: self.btn_w, h: self.btn_w))
        }
    }
}



struct tarGzCompressorView: View {
    @State public var compressor:TarGzCompressorAsync = TarGzCompressorAsync()
    @State public var files: [URL] = []
    @State public var is_dropd:Bool = false
    var body: some View {
        VStack {
            if self.is_dropd == false {
                FirstPageView(files : $files, is_dropd: $is_dropd).environmentObject(compressor)
                    .onDrop(of: [.fileURL, .item], isTargeted: nil, perform: { providers, _ in
                        self.files.removeAll()
                        for item in providers {
            #if os(iOS)
                            _ = item.loadFileRepresentation(forTypeIdentifier: UTType.item.identifier) { url, _ in
                                self.files.append(url!)
                            }
            #else
//                            _ = item.loadObject(ofClass: NSPasteboard.PasteboardType.self) { pasteboardItem, _ in
//                                if pasteboardItem != nil {
//                                    self.files.append(URL(string: pasteboardItem!.rawValue)!)
//                                }
//                            }
                            _ = item.loadFileRepresentation(forTypeIdentifier: UTType.item.identifier) { url, _ in
                                if FileManager.default.fileExists(atPath: url!.path) == false {
                                    return
                                }
                                self.files.append(URL(string: url!.path)!)
                            }
            #endif
                        }
    //                    DispatchQueue.main.async {
    //                        self.compressor.ClosureFunc(closure :  { is_begining in
    //                            self.is_dropd = is_begining
    //                        })
    //                        self.compressor.setFile(files, action: COMPRESSOR_ACTIONS.TO_TARGZ)
    //                        self.compressor.waitForRebuildDone()
    //                    }
                        return true;
                    })
            }
            else {
                Text(String("Please wait......(^_^)")).fontWeight(.semibold).font(.largeTitle).background(Color.clear).foregroundColor(.white)
            }
        }
        
    }
}

//func describeDroppedURL(_ url: URL) -> String {
//    do {
//        var messageRows: [String] = []
//
//        if try url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory == false {
//            messageRows.append("Dropped file named `\(url.lastPathComponent)`")
//
//            messageRows.append("  which starts with `\(try String(contentsOf: url).components(separatedBy: "\n")[0]))`")
//        } else {
//            messageRows.append("Dropped folder named `\(url.lastPathComponent)`")
//
//            for childUrl in try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: []) {
//                messageRows.append("  Containing file named `\(childUrl.lastPathComponent)`")
//
//                messageRows.append("    which starts with `\((try String(contentsOf: childUrl)).components(separatedBy: "\n")[0])`")
//            }
//        }
//
//        return messageRows.joined(separator: "\n")
//    } catch {
//        return "Error: \(error)"
//    }
//}

//
//  AppDelegate.swift
//  Wally
//
//  Created by Hershal Bhave on 12/28/15.
//  Copyright © 2015 Hershal Bhave. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let colorPanel = NSColorPanel.shared
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    var timer: Timer?
    var selectedColor: NSColor?

    @IBOutlet weak var statusMenu: NSMenu!
    @IBAction func quitClicked(_ sender: AnyObject) {
        NSApplication.shared.terminate(self)
    }

    @IBAction func pickColor(_ sender: AnyObject) {
        colorPanel.makeKeyAndOrderFront(self)
        NSApplication.shared.activate(ignoringOtherApps: true)
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem.title = "Hi"
        statusItem.menu = statusMenu
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }

    override func changeColor(_ sender: Any?) {
        selectedColor = colorPanel.color
        if timer != nil && timer!.isValid {
            timer?.invalidate()
        }
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(AppDelegate.timerFireMethod(_:)), userInfo: nil, repeats: false)
    }

    @objc func timerFireMethod(_ timer: Timer) {
        guard let selectedColor = selectedColor else {
            NSLog("could not make image")
            return
        }
        NSLog(selectedColor.hexString)

        let searchPath = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).last!
        let wallyDir = URL(fileURLWithPath: "\(searchPath)/Wally/")

        let fm = FileManager.default
        var error: NSError?
        if !(wallyDir as NSURL).checkResourceIsReachableAndReturnError(&error) {
            do {
                try fm.createDirectory(at: wallyDir, withIntermediateDirectories: false, attributes: nil)
            } catch {
                NSLog("error: \(error)")
            }
        }
        let filePath = URL(fileURLWithPath: "\(selectedColor.hexString).png", relativeTo: wallyDir)

        do {
            try PixelRenderer.render(selectedColor, toFile: filePath)

            let screen = NSScreen.main!
            do {
                try NSWorkspace.shared.setDesktopImageURL(filePath, for: screen, options: [:])
                NSLog("set screen")
            } catch {
                NSLog("\(error)")
            }
        } catch {
            NSLog("error: \(error)")
        }
    }
}

extension NSColor {
    var hexString: String {
        let red = Int(round(self.redComponent * 0xFF))
        let green = Int(round(self.greenComponent * 0xFF))
        let blue = Int(round(self.blueComponent * 0xFF))
        let hexString = NSString(format: "%02X%02X%02X", red, green, blue)
        return hexString as String
    }
    var hsvString: String {
        let h = self.hueComponent
        let s = self.saturationComponent
        let v = self.brightnessComponent
        return "\(h), \(s), \(v)"
    }
}

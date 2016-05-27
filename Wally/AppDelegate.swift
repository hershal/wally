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

    let colorPanel = NSColorPanel.sharedColorPanel()
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
    var timer: NSTimer?
    var selectedColor: NSColor?

    @IBOutlet weak var statusMenu: NSMenu!
    @IBAction func quitClicked(sender: AnyObject) {
        NSApplication.sharedApplication().terminate(self)
    }

    @IBAction func pickColor(sender: AnyObject) {
        colorPanel.makeKeyAndOrderFront(self)
        NSApplication.sharedApplication().activateIgnoringOtherApps(true)
    }

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        statusItem.title = "Hi"
        statusItem.menu = statusMenu
    }

    func applicationWillTerminate(aNotification: NSNotification) {
    }

    override func changeColor(sender: AnyObject?) {
        selectedColor = colorPanel.color
        if timer != nil && timer!.valid {
            timer?.invalidate()
        }
        timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(AppDelegate.timerFireMethod(_:)), userInfo: nil, repeats: false)
    }

    func timerFireMethod(timer: NSTimer) {
        guard let selectedColor = selectedColor else {
            NSLog("could not make image")
            return
        }
        NSLog(selectedColor.hexString)

        let searchPath = NSSearchPathForDirectoriesInDomains(.ApplicationSupportDirectory, .UserDomainMask, true).last!
        let wallyDir = NSURL(fileURLWithPath: "\(searchPath)/Wally/")

        let fm = NSFileManager.defaultManager()
        var error: NSError?
        if !wallyDir.checkResourceIsReachableAndReturnError(&error) {
            do {
                try fm.createDirectoryAtURL(wallyDir, withIntermediateDirectories: false, attributes: nil)
            } catch {
                NSLog("error: \(error)")
            }
        }
        let filePath = NSURL(fileURLWithPath: "\(selectedColor.hexString).png", relativeToURL: wallyDir)

        do {
            try PixelRenderer.render(selectedColor, toFile: filePath)

            let screen = NSScreen.mainScreen()!
            do {
                try NSWorkspace.sharedWorkspace().setDesktopImageURL(filePath, forScreen: screen, options: [:])
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
}

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
        print(selectedColor?.hexString)
        guard let selectedColor = selectedColor else {
            print("could not make image")
            return
        }
        let filePath = NSURL(string: "file:///tmp/\(selectedColor.hexString).png")!
        let img = NSImage.imageWithColor(selectedColor)
        let cgimg = img.CGImageForProposedRect(nil, context: nil, hints: nil)!
        let rep = NSBitmapImageRep(CGImage: cgimg)
        let data = rep.representationUsingType(.NSPNGFileType, properties: [:])

        print("saving to \(filePath.absoluteString)")
        do {
            try data?.writeToURL(filePath, options: .AtomicWrite)
            print("wrote file: \(filePath.absoluteString)")
        } catch {
            print(error)
        }

        let screens = NSScreen.screens()
        for screen in screens! {
            do {
                try NSWorkspace.sharedWorkspace().setDesktopImageURL(filePath, forScreen: screen, options: [:])
                print("set screen")
            } catch {
                print(error)
            }
        }
    }
}

extension NSImage {
    class func imageWithColor(color: NSColor) -> NSImage {
        let img = NSImage.init(size: NSSize(width: 1.0, height: 1.0))
        let path = NSBezierPath(rect: NSRect(x: 0, y: 0, width: 1, height: 1))
        img.lockFocus()
        color.set()
        path.fill()
        img.unlockFocus()
        return img
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

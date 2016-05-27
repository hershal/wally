//
//  PixelRenderer.swift
//  Wally
//
//  Created by Hershal Bhave on 2016-05-27.
//  Copyright © 2016 Hershal Bhave. All rights reserved.
//

import Foundation
import Cocoa

class PixelRenderer {
    class func render(color: NSColor, toFile url: NSURL) throws {
        let img = NSImage.imageWithColor(color)
        let cgimg = img.CGImageForProposedRect(nil, context: nil, hints: nil)!
        let rep = NSBitmapImageRep(CGImage: cgimg)
        let data = rep.representationUsingType(.NSPNGFileType, properties: [:])

        try data?.writeToURL(url, options: .AtomicWrite)
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

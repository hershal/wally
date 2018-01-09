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
    class func render(_ color: NSColor, toFile url: URL) throws {
        let img = NSImage.imageWithColor(color)
        let cgimg = img.cgImage(forProposedRect: nil, context: nil, hints: nil)!
        let rep = NSBitmapImageRep(cgImage: cgimg)
        let data = rep.representation(using: .png, properties: [:])

        try data?.write(to: url, options: .atomicWrite)
    }
}

extension NSImage {
    class func imageWithColor(_ color: NSColor) -> NSImage {
        let img = NSImage.init(size: NSSize(width: 1.0, height: 1.0))
        let path = NSBezierPath(rect: NSRect(x: 0, y: 0, width: 1, height: 1))
        img.lockFocus()
        color.set()
        path.fill()
        img.unlockFocus()
        return img
    }
}

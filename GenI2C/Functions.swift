//
//  Functions.swift
//  GenI2C
//
//  Created by 梁怀宇 on 2020/3/10.
//  Copyright © 2020 梁怀宇. All rights reserved.
//

import Foundation
import Cocoa

func Pop_up(messageText:String, informativeText:String) {
    let Pop_up = NSAlert()
    Pop_up.messageText = messageText
    Pop_up.informativeText = informativeText
    Pop_up.alertStyle = .informational
    Pop_up.addButton(withTitle: NSLocalizedString("OK", comment: ""))
    //Pop_up.beginSheetModal(for: AMLDecomplier, completionHandler: {respose -> Void in})
    Pop_up.runModal()
}

func iasl(path:String) {
    let t = Process()
    t.launchPath = Bundle.main.path(forResource: "iasl", ofType: nil)
    t.arguments = [path]
    t.launch()
}

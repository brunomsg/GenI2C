//
//  Analysis2.swift
//  GenI2C
//
//  Created by 梁怀宇 on 2020/3/10.
//  Copyright © 2020 梁怀宇. All rights reserved.
//

import Foundation
import Cocoa

var alert = NSAlert()


func Analysis2() {
    //verbose(text: "Start func : Analysis2()")
    if Choice == 0 {
        InterruptEnabled = true
    } else if Choice == 1 {
        PollingEnabled = true
    } else {
        
    }
    if ExAPIC && APICPIN >= 24 && APICPIN <= 47 {
        //verbose(text: "APIC Pin value < 2F, Native APIC Supported, using instead\n")
        if Hetero == true {
            APICNAME = "SBFX"
        }
        PatchCRS2APIC()
        analysis3()
    } else if ExAPIC == false && ExGPIO == true {
        if InterruptEnabled == true {
            PatchCRS2GPIO()
        }
        if PollingEnabled == true {
            APICPIN = 63
            APICNAME = "SBFX"
            PatchCRS2APIC()
        }
        analysis3()
    } else if (ExAPIC && (APICPIN > 47 || APICPIN == 0) && InterruptEnabled && ExGPIO == false && APICPIN == 0) || (ExAPIC == false && ExGPIO == false && ExSLAV && InterruptEnabled) {
        alert.beginSheetModal(for: AD.mainWindow, completionHandler: {response -> Void in
            analysis3()
        })
    } else {
        analysis3()
    }
}

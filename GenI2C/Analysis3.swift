//
//  Analysis3.swift
//  GenI2C
//
//  Created by 梁怀宇 on 2020/3/10.
//  Copyright © 2020 梁怀宇. All rights reserved.
//

import Foundation
import Cocoa

func analysis3() {
    //verbose(text: "Start func : Analysis3()")
    if ExAPIC == true && (APICPIN > 47 || APICPIN == 0) {
        if InterruptEnabled == true {
            if ExGPIO == false {
                if APICPIN == 0 {
                    if APICPIN >= 24 && APICPIN <= 47 {
                        //verbose(text: "APIC Pin value < 2F, Native APIC Supported, using instead\n")
                        if Hetero {
                            APICNAME = "SBFX"
                            PatchCRS2APIC()
                        }
                    } else {
                        GPIONAME = "SBFZ"
                        APIC2GPIO()
                        PatchCRS2GPIO()
                    }
                } else if APICPIN > 47 {
                    //verbose(text: "No native GpioInt found, Generating instead")
                    GPIONAME = "SBFZ"
                    APIC2GPIO()
                    PatchCRS2GPIO()
                }
            } else if ExGPIO {
                PatchCRS2GPIO()
            }
        } else if PollingEnabled == true {
            if Hetero {
                APICNAME = "SBFX"
                APICPIN = 63
            }
            if APICPIN == 0 {
                //verbose(text: "APIC Pin size uncertain, could be either APIC or polling")
            }
            PatchCRS2APIC()
        }
    } else if ExAPIC == false && ExGPIO == false && ExSLAV {
        if InterruptEnabled {
            if APICPIN >= 24 && APICPIN <= 47 {
                //verbose(text: "APIC Pin value < 2F, Native APIC Supported, No _CRS Patch required\n")
            } else {
                GPIONAME = "SBFZ"
                APIC2GPIO()
                PatchCRS2GPIO()
            }
        } else if PollingEnabled {
            APICNAME = "SBFX"
            APICPIN = 63
            PatchCRS2APIC()
        }
    } else {
        //verbose(text: "Undefined Situation")
    }
    GenSSDT()
    NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: FolderPath)
}

func BreakCombine() {
    //verbose(text: "Start func : BreakCombine()")
    for BreakIndex in 0...3 {
        CRSInfo[CRSInfo.count - 1 - (total + 1 - (CheckConbLine + 7)) + BreakIndex] = ""
    }
}

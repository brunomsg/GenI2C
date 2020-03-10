//
//  PatchCRS2APIC.swift
//  GenI2C
//
//  Created by 梁怀宇 on 2020/3/10.
//  Copyright © 2020 梁怀宇. All rights reserved.
//

import Foundation

func PatchCRS2APIC() {
    //verbose(text: "Start func : PatchCRS2APIC()")
    for CRSLine in 0...n {
        if CRSInfo[CRSLine].contains("Return (ConcatenateResTemplate") {
            if ExI2CM {
                let index = CRSInfo[CRSLine].index(CRSInfo[CRSLine].startIndex, offsetBy: CRSInfo[CRSLine].positionOf(sub: "BADR, "))
                CRSInfo[CRSLine] = String(CRSInfo[CRSLine][..<index]) + "\\_SB.PCI0.I2C" + scope + "." + TPAD + ".BADR, " + "\\_SB.PCI0.I2C" + scope + "." + TPAD + ".SPED)" + ", " + APICNAME + "))"
            } else {
                let index = CRSInfo[CRSLine].index(CRSInfo[CRSLine].startIndex, offsetBy: CRSInfo[CRSLine].positionOf(sub: ", SBF"))
                CRSInfo[CRSLine] = String(CRSInfo[CRSLine][..<index]) + ", " + APICNAME + "))"
            }
            CRSPatched = true
        } else if CRSInfo[CRSLine].contains("Return (SBF") {
            let index = CRSInfo[CRSLine].index(CRSInfo[CRSLine].startIndex, offsetBy: CRSInfo[CRSLine].positionOf(sub: "("))
            CRSInfo[CRSLine] = String(CRSInfo[CRSLine][..<index]) + "(ConcatenateResTemplate (" + SLAVName + ", " + APICNAME + ")) // Usually this return won't function, please check your Windows Patch"
            CRSPatched = true
        }
    }
    if CRSPatched == false {
        //verbose(text: "Error! No _CRS Patch Applied!")
    }
}

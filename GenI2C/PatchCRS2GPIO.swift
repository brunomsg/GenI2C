//
//  PatchCRS2GPIO.swift
//  GenI2C
//
//  Created by 梁怀宇 on 2020/3/10.
//  Copyright © 2020 梁怀宇. All rights reserved.
//

import Foundation

func PatchCRS2GPIO() {
    if CPUChoice != 3 {
        //verbose(text: "Start func : PatchCRS2GPIO")
        for CRSLine in 0...n {
            if CRSInfo[CRSLine].contains("Return (ConcatenateResTemplate") {
                if ExI2CM {
                    let index = CRSInfo[CRSLine].index(CRSInfo[CRSLine].startIndex, offsetBy: CRSInfo[CRSLine].positionOf(sub: "BADR, "))
                    CRSInfo[CRSLine] = String(CRSInfo[CRSLine][..<index]) + "\\_SB.PCI0.I2C" + scope + "." + TPAD + ".BADR, " + "\\_SB.PCI0.I2C" + scope + "." + TPAD + ".SPED)" + ", " + GPIONAME + "))"
                } else {
                    let index = CRSInfo[CRSLine].index(CRSInfo[CRSLine].startIndex, offsetBy: CRSInfo[CRSLine].positionOf(sub: ", SBF"))
                    CRSInfo[CRSLine] = String(CRSInfo[CRSLine][..<index]) + ", " + GPIONAME + "))"
                }
                CRSPatched = true
            } else if CRSInfo[CRSLine].contains("Return (SBF") {
                let index = CRSInfo[CRSLine].index(CRSInfo[CRSLine].startIndex, offsetBy: CRSInfo[CRSLine].positionOf(sub: "("))
                CRSInfo[CRSLine] = String(CRSInfo[CRSLine][..<index]) + "(ConcatenateResTemplate (" + SLAVName + ", " + GPIONAME + ")) // Usually this return won't function, please check your Windows Patch"
                CRSPatched = true
            }
        }
        if CRSPatched == false {
            //verbose(text: "Error! No _CRS Patch Applied!")
        }
        if PatchChoice == 0 {
            GPI0SSDT[0] = #"/* "#
            GPI0SSDT[1] = #" * Find _STA:          5F 53 54 41"#
            GPI0SSDT[2] = #" * Replace XSTA:       58 53 54 41"#
            GPI0SSDT[3] = #" * Target Bridge GPI0: 47 50 49 30"#
            GPI0SSDT[4] = #" */"#
            GPI0SSDT[5] = "DefinitionBlock(\"\", \"SSDT\", 2, \"hack\", \"GPI0\", 0)"
            GPI0SSDT[6] = #"{"#
            GPI0SSDT[7] = #"    External(_SB.PCI0.GPI0, DeviceObj)"#
            GPI0SSDT[8] = #"    Scope (_SB.PCI0.GPI0)"#
            GPI0SSDT[9] = #"    {"#
            GPI0SSDT[10] = #"        Method (_STA, 0, NotSerialized)"#
            GPI0SSDT[11] = #"        {"#
            GPI0SSDT[12] = #"            Return (0x0F)"#
            GPI0SSDT[13] = #"        }"#
            GPI0SSDT[14] = #"    }"#
            GPI0SSDT[15] = #"}"#
        } else {
            var GPI0STA = [String]()
            var line:Int = 0
            var spaceopen, spaceclose, startline, closeline:Int
            var Paranthesesopen:String = ""
            var Paranthesesclose:String = ""
            while line < GPI0Lines.count {
                if GPI0Lines[line].contains("Method (_STA") {
                    startline = line + 1
                    Paranthesesopen = GPI0Lines[line + 1]
                    line += 1
                    spaceopen = Paranthesesopen.positionOf(sub: "{")
                    repeat {
                        Paranthesesclose = GPI0Lines[line]
                        line += 1
                        spaceclose = Paranthesesclose.positionOf(sub: "}")
                        closeline = line
                    } while spaceclose != spaceopen
                    GPI0STA = [String](repeating: "", count: closeline - startline + 1)
                    for i in startline...closeline {
                        GPI0STA[i - startline] = GPI0Lines[i - 1]
                    }
                }
                line += 1
            }
        }
        
        var SSDT:String = ""
        try! FileManager.default.createDirectory(atPath: FolderPath, withIntermediateDirectories: true, attributes: nil)
        let path:String = FolderPath + "/SSDT-GPI0.dsl"
        if FileManager.default.fileExists(atPath: path) {
            try! FileManager.default.removeItem(atPath: path)
            FileManager.default.createFile(atPath: path, contents: nil, attributes: nil)
        } else {
            FileManager.default.createFile(atPath: path, contents: nil, attributes: nil)
        }
        for Genindex in 0...15{
            SSDT += GPI0SSDT[Genindex] + "\n"
        }
        try! SSDT.write(toFile: path, atomically: true, encoding: String.Encoding.utf8)
        iasl(path: path)
    }
}

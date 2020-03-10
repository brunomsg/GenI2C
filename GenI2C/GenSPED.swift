//
//  GenSPED.swift
//  GenI2C
//
//  Created by 梁怀宇 on 2020/3/10.
//  Copyright © 2020 梁怀宇. All rights reserved.
//

import Foundation
import Cocoa

func GenSPED() {
    //verbose(text: "Start func : GenSPED()")
    if CPUChoice == 0 || CPUChoice == 3 {
        if scope == "0" || scope == "2" || scope == "3" {
            ManualSPED[0] = Spacing + "Name (SSCN, Package () { 432, 507, 30 })"
            ManualSPED[1] = Spacing + "Name (FMCN, Package () { 72, 160, 30 })"
        } else if scope == "1" {
            ManualSPED[0] = Spacing + "Name (SSCN, Package () { 528, 640, 30 })"
            ManualSPED[1] = Spacing + "Name (FMCN, Package () { 128, 160, 30 })"
        }
    } else if CPUChoice == 1 {
        if ExSSCN {
            CNL_H_SPED[0] = "/* "
            CNL_H_SPED[1] = " * Find SSCN:          53 53 43 4E"
            CNL_H_SPED[2] = " * Replace XSCN:       58 53 43 4E"
            CNL_H_SPED[3] = " */"
        }
        CNL_H_SPED[4] = #"DefinitionBlock("", "SSDT", 2, "hack", "I2C-SPED", 0)"#
        CNL_H_SPED[5] = "{"
        CNL_H_SPED[6] = "    External(_SB_.PCI0.I2C" + scope + ", DeviceObj)"
        CNL_H_SPED[7] = "    External(FMD" + scope + ", IntObj)"
        CNL_H_SPED[8] = "    External(FMH" + scope + ", IntObj)"
        CNL_H_SPED[9] = "    External(FML" + scope + ", IntObj)"
        CNL_H_SPED[10] = "    External(SSD" + scope + ", IntObj)"
        CNL_H_SPED[11] = "    External(SSH" + scope + ", IntObj)"
        CNL_H_SPED[12] = "    External(SSL" + scope + ", IntObj)"
        CNL_H_SPED[13] = "    Scope(_SB.PCI0.I2C\(scope))"
        CNL_H_SPED[14] = "    {"
        CNL_H_SPED[15] = "        Method (PKGX, 3, Serialized)"
        CNL_H_SPED[16] = "        {"
        CNL_H_SPED[17] = "            Name (PKG, Package (0x03)"
        CNL_H_SPED[18] = "            {"
        CNL_H_SPED[19] = "                Zero, "
        CNL_H_SPED[20] = "                Zero, "
        CNL_H_SPED[21] = "                Zero"
        CNL_H_SPED[22] = "            })"
        CNL_H_SPED[23] = "        Store (Arg0, Index (PKG, Zero))"
        CNL_H_SPED[24] = "        Store (Arg1, Index (PKG, One))"
        CNL_H_SPED[25] = "        Store (Arg2, Index (PKG, 0x02))"
        CNL_H_SPED[26] = "        Return (PKG)"
        CNL_H_SPED[27] = "        }"
        CNL_H_SPED[28] = "        Method (SSCN, 0, NotSerialized)"
        CNL_H_SPED[29] = "        {"
        CNL_H_SPED[30] = "            Return (PKGX (SSH" + scope + ", SSL" + scope + ", SSD" + scope + "))"
        CNL_H_SPED[31] = "        }"
        CNL_H_SPED[32] = "        Method (FMCN, 0, NotSerialized)"
        CNL_H_SPED[33] = "        {"
        CNL_H_SPED[34] = "            Name (PKG, Package (0x03)"
        CNL_H_SPED[35] = "            {"
        CNL_H_SPED[36] = "                0x0101, "
        CNL_H_SPED[37] = "                0x012C, "
        CNL_H_SPED[38] = "                0x62"
        CNL_H_SPED[39] = "            })"
        CNL_H_SPED[40] = "            Return (PKG)"
        CNL_H_SPED[41] = "        }"
        CNL_H_SPED[42] = "    }"
        CNL_H_SPED[43] = "}"
        
        let path:String = FolderPath + "/SSDT-I2C\(scope)-SPED.dsl"
        var fileContent:String = ""
        for Genindex in 0..<CNL_H_SPED.count{
            if CNL_H_SPED[Genindex] != "" && CNL_H_SPED[Genindex] != "\n" {
                fileContent += CNL_H_SPED[Genindex] + "\n"
            }
        }
        try! FileManager.default.createDirectory(atPath: FolderPath, withIntermediateDirectories: true, attributes: nil)
        if FileManager.default.fileExists(atPath: path) {
            try! FileManager.default.removeItem(atPath: path)
            FileManager.default.createFile(atPath: path, contents: nil, attributes: nil)
        } else {
            FileManager.default.createFile(atPath: path, contents: nil, attributes: nil)
        }
        try! fileContent.write(toFile: path, atomically: true, encoding: String.Encoding.utf8)
        iasl(path: path)
    }
}

func GenSKL() {

}

func GenBlockI2C() {
    
}

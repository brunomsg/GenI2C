//
//  GenSSDT.swift
//  GenI2C
//
//  Created by 梁怀宇 on 2020/3/10.
//  Copyright © 2020 梁怀宇. All rights reserved.
//

import Foundation

var RenameText:String = ""

func GenSSDT() {
    //verbose(text: "Start func : GenSSDT")
    if InterruptEnabled || PollingEnabled {
        if ExAPIC == false && ExGPIO == false && APICPIN < 47 {
            
        } else {
            try! FileManager.default.createDirectory(atPath: FolderPath, withIntermediateDirectories: true, attributes: nil)
            let path:String = FolderPath + "/SSDT-" + TPAD + ".dsl"
            if FileManager.default.fileExists(atPath: path) {
                try! FileManager.default.removeItem(atPath: path)
                FileManager.default.createFile(atPath: path, contents: nil, attributes: nil)
            } else {
                FileManager.default.createFile(atPath: path, contents: nil, attributes: nil)
            }
            
            var RenameCRS = [String](repeating: "", count: 4)
            RenameCRS[0] = "/*"
            RenameCRS[1] = " * Find _CRS:          5F 43 52 53"
            RenameCRS[2] = " * Replace XCRS:       58 43 52 53"
            RenameCRS[3] = " * Target Bridge " + TPAD + ": " + HexTPAD
            
            var RenameUSTP = [String](repeating: "", count: 3)
            RenameUSTP[0] = " * "
            RenameUSTP[1] = " * Find USTP:          55 53 54 50 08"
            RenameUSTP[2] = " * Replace XSTP:       58 53 54 50 08"
            
            var Filehead = [String](repeating: "", count: 33)
            Filehead[0] = #"DefinitionBlock("", "SSDT", 2, "hack", "I2Cpatch", 0)"#
            Filehead[1] = "{"
            Filehead[2] = "    External(_SB.PCI0.I2C" + scope + "." + TPAD + ", DeviceObj)"
            if CheckSLAVLocation < CRSLocation {
                Filehead[3] = "    External(_SB.PCI0.I2C" + scope + "." + TPAD + "." + SLAVName + ", IntObj)"
                if (PollingEnabled && ExAPIC && Hetero == false) || APICPIN < 47 && APICPIN != 0 && ExAPIC && Hetero == false {
                    Filehead[4] = "    External(_SB.PCI0.I2C" + scope + "." + TPAD + "." + APICNAME + ", IntObj)"
                }
                if InterruptEnabled && ExGPIO && (APICPIN > 47 || APICPIN == 0 || ExAPIC == false) {
                    Filehead[5] = "    External(_SB.PCI0.I2C" + scope + "." + TPAD + "." + GPIONAME + ", IntObj)"
                }
            }
            
            var AddFhLe:Int = 6
            var AddFhEq:Int = 12
            var AddFhIf2B:Int = 18
            
            for Genindex in 0...5 {
                if IfLLess[Genindex] != "" && (IfLLess[Genindex] != "Zero" || IfLLess[Genindex] != "One)") {
                    Filehead[AddFhLe] = "    External(" + IfLLess[Genindex] + ", FieldUnitObj)"
                    AddFhLe += 1
                }
                if IfLEqual[Genindex] != "" && (IfLEqual[Genindex] != "Zero" || IfLEqual[Genindex] != "One)") {
                    Filehead[AddFhEq] = "    External(" + IfLEqual[Genindex] + ", FieldUnitObj)"
                    AddFhEq += 1
                }
                if If2Brackets[Genindex] != "" && (If2Brackets[Genindex] != "Zero" || If2Brackets[Genindex] != "One)") {
                    Filehead[AddFhIf2B] = "    External(" + If2Brackets[Genindex] + ", FieldUnitObj)"
                    AddFhIf2B += 1
                }
            }
            if ExI2CM {
                Filehead[24] = "    External(_SB.PCI0.I2C" + scope + ".I2CX, IntObj)"
                Filehead[25] = "    External(_SB.PCI0.I2CM, MethodObj)"
                Filehead[26] = "    External(_SB.PCI0.I2C" + scope + "." + TPAD + ".BADR, IntObj)"
                Filehead[27] = "    External(_SB.PCI0.I2C" + scope + "." + TPAD + ".SPED, IntObj)"
            }
            if ExBADR && ExI2CM == false {
                Filehead[28] = "    External(_SB.PCI0.I2C" + scope + "." + TPAD + ".BADR, IntObj)"
            }
            if ExHID2 {
                Filehead[29] = "    External(_SB.PCI0.I2C" + scope + "." + TPAD + ".HID2, IntObj)"
            }
            if ExUSTP {
                Filehead[30] = "    Name (USTP, One)"
            }
            Filehead[31] = "    Scope(_SB.PCI0.I2C" + scope + "." + TPAD + ")"
            Filehead[32] = "    {"
            
            var fileContent:String = ""
            for Genindex in 0..<RenameCRS.count {
                if RenameCRS[Genindex] != "" && RenameCRS[Genindex] != "\n" {
                    fileContent += RenameCRS[Genindex] + "\n"
                }
            }
            if ExUSTP {
                for Genindex in 0..<RenameUSTP.count {
                    fileContent += RenameUSTP[Genindex] + "\n"
                }
            }
            fileContent += " */\n"
            for Genindex in 0..<Filehead.count {
                if Filehead[Genindex] != "" && Filehead[Genindex] != "\n" {
                    fileContent += Filehead[Genindex] + "\n"
                }
            }
            if ExUSTP == false && (ExFMCN == false || ExSSCN == false) {
                GenSPED()
                if CPUChoice == 0 || CPUChoice == 3 {
                    if ExSSCN == false && ExFMCN {
                        fileContent += ManualSPED[0] + "\n"
                    } else if ExFMCN == false && ExSSCN {
                        fileContent += ManualSPED[1] + "\n"
                    } else {
                        fileContent += ManualSPED[0] + "\n" + ManualSPED[1] + "\n"
                    }
                }
            }
            if InterruptEnabled && ExGPIO == false && APICPIN > 47 {
                GenGPIO()
                for Genindex in 0..<ManualGPIO.count {
                    fileContent += ManualGPIO[Genindex] + "\n"
                }
            }
            if (PollingEnabled && ExAPIC == false) || Hetero {
                GenAPIC()
                for Genindex in 0..<ManualAPIC.count {
                    fileContent += ManualAPIC[Genindex] + "\n"
                }
            }
            for Genindex in 0...CRSInfo.count - 2 {
                if (CRSInfo[Genindex] != "" && CRSInfo[Genindex] != "\n") || Hetero == false {
                    fileContent += CRSInfo[Genindex] + "\n"
                }
            }
            fileContent += "    }\n}"
            try! fileContent.write(toFile: path, atomically: true, encoding: String.Encoding.utf8)
            iasl(path: path)
        }
    }
    RenameText += "++++++++++++++++++++++++++++++++++++++\n\n"
    if InterruptEnabled || PollingEnabled {
        RenameText += "    Find _CRS:          5F 43 52 53\n"
        RenameText += "    Replace XCRS:       58 43 52 53\n"
        RenameText += "    Target Bridge \(TPAD): \(HexTPAD)\n\n"
        if InterruptEnabled && (APICPIN > 47 || (APICPIN == 0 && ExGPIO && ExAPIC)) {
            RenameText += "    Find _STA:          5F 53 54 41\n"
            RenameText += "    Replace XSTA:       58 53 54 41\n"
            RenameText += "    Target Bridge GPI0: 47 50 49 30\n\n"
        }
        if ExUSTP && BlockI2C == false {
            RenameText += "    Find USTP:          55 53 54 50 08\n"
            RenameText += "    Replace XSTP:       58 53 54 50 08\n\n"
        } else if ExUSTP == false && ExSSCN && ExFMCN == false && CPUChoice == 1 && BlockI2C == false {
            RenameText += "    Find SSCN:          53 53 43 4E\n"
            RenameText += "    Replace XSCN:       58 53 43 4E\n"
        }
    } else if BlockI2C {
        RenameText += "    Find _STA:          5F 53 54 41\n"
        RenameText += "    Replace XSTA:       58 53 54 41\n"
        RenameText += "    Target Bridge \(BlockBus): \(HexBlockBus)\n\n"
    }
    RenameText += "Please use the Rename(s) above in the given order\n\n"
    RenameText += "++++++++++++++++++++++++++++++++++++++"
    GenReadme(Rename: RenameText)
}

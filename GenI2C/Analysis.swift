//
//  Analysis.swift
//  GenI2C
//
//  Created by 梁怀宇 on 2020/3/10.
//  Copyright © 2020 梁怀宇. All rights reserved.
//

import Foundation

func Analysis() {
    var Paranthesesopen:String = ""
    var Paranthesesclose:String = ""
    var DSDTLine:String = ""
    
    //verbose(text: "Start func : Analysis()")
    if MultiTPAD {
        Code = [String](repeating: "", count: MultiTPADLineCount[MultiTPADUSRSelect] + 1)
    } else {
        Code = [String](repeating: "", count: total + 1)
    }
    var line:Int = 0
    var i = 0
    while line < count - 1 {
        DSDTLine = lines[line]
        line += 1
        if DSDTLine.contains(Device){
            if (MultiTPAD && TargetTPAD == MultiTPADUSRSelect) || MultiTPAD == false {
                var spaceopen, spaceclose:Int
                Code[i] = DSDTLine
                i += 1
                Paranthesesopen = lines[line]
                line += 1
                Code[i] = Paranthesesopen
                i += 1
                spaceopen = Paranthesesopen.positionOf(sub: "{")
                repeat{
                    Paranthesesclose = lines[line]
                    line += 1
                    spaceclose = Paranthesesclose.positionOf(sub: "}")
                    Code[i] = Paranthesesclose
                    i += 1
                } while spaceopen != spaceclose
            }
            TargetTPAD = TargetTPAD + 1
        }
    }
    for i in 0...total {
        if Code[i].contains("Method (_CRS,") {
            var CRSStart, CRSEnd, CRSRangeScan:Int
            CRSRangeScan = i + 1
            CRSStart = Code[CRSRangeScan].positionOf(sub: "{") - 1
            repeat {
                CRSEnd = Code[CRSRangeScan].positionOf(sub: "}") - 1
                CRSRangeScan += 1
            } while CRSStart != CRSEnd
            n = CRSRangeScan - i
            CRSLocation = i
            CRSInfo = [String](repeating: "", count: n + 1)
            n = 0
            for CRSInfoLine in i...(CRSRangeScan - 1) {
                CRSInfo[n] = Code[CRSInfoLine]
                n += 1
            }
        } else if Code[i].contains("Method (XCRS,") {
            //verbose(text: "\nRenamed _CRS detected!\nPlease use an error-corrected vanilla DSDT instead!\n")
            Pop_up(messageText: NSLocalizedString("Renamed _CRS detected!", comment: ""), informativeText: NSLocalizedString("Please use an error-corrected vanilla DSDT instead!", comment: ""))
            exit(0)
        }
        if Code[i].contains("GpioInt"){
            if ExGPIO == true {
                ExGPIO = true
                GPIONameLineFound = false
            }
            //verbose(text: "Native GpioInt Found in \(TPAD) at line \(i)\n")
            ExGPIO = true
            GPIONAMELine = i
            for GPIONAMELine in (1...GPIONAMELine).reversed(){
                if Code[GPIONAMELine].contains("Name (SBF") && GPIONameLineFound == false {
                    let str = Code[GPIONAMELine]
                    let index1 = str.index(str.startIndex, offsetBy: (Code[GPIONAMELine].positionOf(sub: "SBF")))
                    let index2 = str.index(str.startIndex, offsetBy: (Code[GPIONAMELine].positionOf(sub: "SBF") + 4))
                    GPIONAME = String(str[index1..<index2])
                    GPIONameLineFound = true
                }
            }
            GPIOPinLine = i + 4
            let index1 = Code[GPIOPinLine].index(Code[GPIOPinLine].startIndex, offsetBy: Code[GPIOPinLine].positionOf(sub: "0x"))
            let HEXPIN = String(Code[GPIOPinLine][index1..<Code[GPIOPinLine].endIndex])
            GPIOPIN = Int(strtoul(HEXPIN, nil, 16))
            //verbose(text: "GPIO Pin \(GPIOPIN)\n")
        }
        if Code[i].contains("Interrupt (ResourceConsumer") {
            if ExAPIC == true {
                APICNameLineFound = false
            }
            //verbose(text: "Native APIC Found in \(TPAD) at line \(i + 1)\n")
            ExAPIC = true
            APICNameLine = i
            for APICNameLine1 in (1...APICNameLine).reversed() {
                if Code[APICNameLine1].contains("Name (SBF") && APICNameLineFound == false {
                    let index1 = Code[APICNameLine1].index(Code[APICNameLine1].startIndex, offsetBy: Code[APICNameLine1].positionOf(sub: "SBF"))
                    let index2 = Code[APICNameLine1].index(Code[APICNameLine1].startIndex, offsetBy: Code[APICNameLine1].positionOf(sub: "SBF") + 4)
                    APICNAME = String(Code[APICNameLine1][index1..<index2])
                    APICNameLineFound = true
                }
            }
            APICPinLine = i + 2
            let index1 = Code[APICPinLine].index(Code[APICPinLine].startIndex, offsetBy: Code[APICPinLine].positionOf(sub: "0x"))
            let index2 = Code[APICPinLine].index(Code[APICPinLine].startIndex, offsetBy: Code[APICPinLine].positionOf(sub: "0x") + 10)
            APICPIN = Int(strtoul(String(Code[APICPinLine][index1..<index2]), nil, 16))
            //verbose(text: "APIC Pin \(APICPIN)\n")
        }
        if Code[i].contains("I2cSerialBusV2 (0x") || Code[i].contains("I2cSerialBus (0x"){
            if ExSLAV == true {
                SLAVNameLineFound = false
                //verbose(text: "Warning! Multiple I2C Bus Addresses exist in " + TPAD + " _CRS patching may be wrong!")
            }
            //verbose(text: "Slave Address Found in \(TPAD) at line \(i + 1)\n")
            ExSLAV = true
            SLAVNameLine = i
            for SLAVNameLine1 in (1...SLAVNameLine).reversed() {
                if Code[SLAVNameLine1].contains("Name (SBF") && SLAVNameLineFound == false {
                    let index1 = Code[SLAVNameLine1].index(Code[SLAVNameLine1].startIndex, offsetBy: Code[SLAVNameLine1].positionOf(sub: "SBF"))
                    let index2 = Code[SLAVNameLine1].index(Code[SLAVNameLine1].startIndex, offsetBy: Code[SLAVNameLine1].positionOf(sub: "SBF") + 4)
                    SLAVName = String(Code[SLAVNameLine1][index1..<index2])
                    SLAVNameLineFound = true
                    CheckConbLine = SLAVNameLine1
                    CheckSLAVLocation = SLAVNameLine1
                }
            }
            ScopeLine = i + 1
            if scope == "" {
                if Code[ScopeLine].contains("NULL") && MultiTPAD == false {
                    scope = MultiScope[0]
                } else {
                    scope = String(Code[ScopeLine][Code[ScopeLine].index(Code[ScopeLine].startIndex, offsetBy: Code[ScopeLine].positionOf(sub: "\",") - 1)])
                }
            }
            //verbose(text: Code[ScopeLine] + "\n")
        }
        if Code[i].contains("Name (") && CatchSpacing == false {
            let index1 = Code[i].index(Code[i].startIndex, offsetBy: 0)
            let index2 = Code[i].index(Code[i].startIndex, offsetBy: Code[i].positionOf(sub: "Name (") - 4)
            Spacing = String(Code[i][index1..<index2])
            CatchSpacing = true
        }
    }
    if SLAVNameLineFound == true && APICNameLineFound == true && SLAVName == APICNAME && Hetero == false {
        Hetero = true
        if CheckSLAVLocation > CRSLocation {
            BreakCombine()
        }
    }
    var IfString:String = ""
    var LLessCount:Int = 0
    var LEqualCount:Int = 0
    var If2BracketsCount:Int = 0
    for CRSLine in 0...n {
        if CRSInfo[CRSLine].contains("If (LLess (") {
            let index1 = CRSInfo[CRSLine].index(CRSInfo[CRSLine].startIndex, offsetBy: CRSInfo[CRSLine].positionOf(sub: "If (LLess (") + 11)
            let index2 = CRSInfo[CRSLine].index(CRSInfo[CRSLine].startIndex, offsetBy: CRSInfo[CRSLine].positionOf(sub: "If (LLess (") + 15)
            if !(IfString.contains(String(CRSInfo[CRSLine][index1..<index2]))) || LLess == false {
                IfLLess[LLessCount] = String(CRSInfo[CRSLine][index1..<index2])
                IfString += IfLLess[LLessCount] + " "
                LLessCount += 1
                LLess = true
            }
        }
        if CRSInfo[CRSLine].contains("If (LEqual (") {
            let index1 = CRSInfo[CRSLine].index(CRSInfo[CRSLine].startIndex, offsetBy: CRSInfo[CRSLine].positionOf(sub: "If (LEqual (")+12)
            let index2 = CRSInfo[CRSLine].index(CRSInfo[CRSLine].startIndex, offsetBy: CRSInfo[CRSLine].positionOf(sub: "If (LEqual (")+16)
            if !(IfString.contains(String(CRSInfo[CRSLine][index1..<index2]))) || LEqual == false {
                IfLEqual[LEqualCount] = String(CRSInfo[CRSLine][index1..<index2])
                IfString += IfLEqual[LEqualCount] + " "
                LEqualCount += 1
                LEqual = true
            }
        }
        if CRSInfo[CRSLine].contains("If ((") && (CRSInfo[CRSLine].contains("<") || CRSInfo[CRSLine].contains("==")) {
            let index1 = CRSInfo[CRSLine].index(CRSInfo[CRSLine].startIndex, offsetBy: CRSInfo[CRSLine].positionOf(sub: "If ((")+5)
            let index2 = CRSInfo[CRSLine].index(CRSInfo[CRSLine].startIndex, offsetBy: CRSInfo[CRSLine].positionOf(sub: "If ((")+9)
            if !(IfString.contains(String(CRSInfo[CRSLine][index1..<index2]))) || If2BracketsBool == false {
                If2Brackets[If2BracketsCount] = String(CRSInfo[CRSLine][index1..<index2])
                IfString += If2Brackets[If2BracketsCount] + " "
                If2BracketsCount += 1
                If2BracketsBool = true
            }
        }
        if CRSInfo[CRSLine].contains("I2CM (I2CX, BADR, SPED)") {
            ExI2CM = true
        }
        if CRSInfo[CRSLine].contains("BADR") {
            ExBADR = true
        }
        if CRSInfo[CRSLine].contains("HID2") {
            ExHID2 = true
        }
    }
    if SLAVNameLineFound == false {
        //verbose(text: "\nThis is not a I2C Device!\n")
        Pop_up(messageText: NSLocalizedString("Warning", comment: ""), informativeText: NSLocalizedString("This is not a I2C Device!", comment: ""))
        exit(0)
    } else {
        
    }
}

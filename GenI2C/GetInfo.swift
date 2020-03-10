//
//  Info.swift
//  GenI2C
//
//  Created by 梁怀宇 on 2020/3/10.
//  Copyright © 2020 梁怀宇. All rights reserved.
//

import Foundation

var CPUInfo:String = ""
var NativeDeviceName:String = ""
var NativePin = ""
var SatelliteName:String = ""
var VoodooI2CVersion:String = ""
var NativeIOName:String = ""
var PinText:String = ""
var Mode:String = ""
var isVooLoaded:Bool = false
var isNameFound:Bool = false
var isPinFound:Bool = false
var isNativeIONameFound:Bool = false


func GetInfo() {
    let CPUModel = Process()
    let pipeCPU = Pipe()
    CPUModel.standardOutput = pipeCPU
    CPUModel.launchPath = "/usr/sbin/sysctl"
    CPUModel.arguments = ["machdep.cpu.brand_string"]
    CPUModel.launch()
    let CPUdata = pipeCPU.fileHandleForReading.readDataToEndOfFile()
    let CPUString = String(data: CPUdata, encoding: String.Encoding.utf8)!
    CPUInfo = String(CPUString[CPUString.index(CPUString.startIndex, offsetBy: 26)..<CPUString.endIndex])
    
    let kextstat = Process()
    let pipe1 = Pipe()
    kextstat.standardOutput = pipe1
    kextstat.launchPath = "/usr/sbin/kextstat"
    kextstat.arguments = ["-b", "com.alexandred.VoodooI2C"]
    kextstat.launch()
    let kextdata = pipe1.fileHandleForReading.readDataToEndOfFile()
    let kextStrings = String(data: kextdata, encoding: String.Encoding.utf8)!.components(separatedBy: "\n")
    if kextStrings.count <= 2 {
        isVooLoaded = false
    } else {
        isVooLoaded = true
        let Satellites = ["com.alexandred.VoodooI2CHID", "me.kishorprins.VoodooI2CELAN", "com.alexandred.VoodooI2CSynaptics", "me.kishorprins.VoodooI2CFTE", "org.coolstar.VoodooI2CAtmelMXT", "com.blankmac.VoodooI2CUPDDEngine"]
        for i in Satellites {
            let Satellite = Process()
            let SatellitePipe = Pipe()
            Satellite.standardOutput = SatellitePipe
            Satellite.launchPath = "/usr/sbin/kextstat"
            Satellite.arguments = ["-b", i]
            Satellite.launch()
            let Satellitedata = SatellitePipe.fileHandleForReading.readDataToEndOfFile()
            let SatelliteStrings = String(data: Satellitedata, encoding: String.Encoding.utf8)!.components(separatedBy: "\n")
            if SatelliteStrings.count > 2 {
                 SatelliteName = i.components(separatedBy: ".")[2] + " "
            }
        }
        
        let ioregPCI = Process()
        let pipePCI = Pipe()
        ioregPCI.standardOutput = pipePCI
        ioregPCI.launchPath = "/usr/sbin/ioreg"
        ioregPCI.arguments = ["-x", "-n", "PCI0", "-r", "-d", "3"]
        ioregPCI.launch()
        let PCIdata = pipePCI.fileHandleForReading.readDataToEndOfFile()
        let PCIStrings = String(data: PCIdata, encoding: String.Encoding.utf8)!.components(separatedBy: "\n")
        var I2CCount:Int = 0
        for line in 0..<PCIStrings.count {
            if PCIStrings[line].contains("I2C") {
                I2CCount += 1
            }
        }
        var index:Int = 0
        var I2CName = [String](repeating: "", count: I2CCount)
        for line in 0..<PCIStrings.count {
            if PCIStrings[line].contains("I2C") {
                I2CName[index] = String(PCIStrings[line][PCIStrings[line].index(PCIStrings[line].startIndex, offsetBy: 8)..<PCIStrings[line].index(PCIStrings[line].startIndex, offsetBy: 12)])
                index += 1
            }
        }
        
        for i in 0..<I2CCount {
            let ioregI2C = Process()
            let pipeI2C = Pipe()
            ioregI2C.standardOutput = pipeI2C
            ioregI2C.launchPath = "/usr/sbin/ioreg"
            ioregI2C.arguments = ["-x", "-n", I2CName[i], "-r", "-d", "5"]
            ioregI2C.launch()
            let I2Cdata = pipeI2C.fileHandleForReading.readDataToEndOfFile()
            let I2CStrings = String(data: I2Cdata, encoding: String.Encoding.utf8)!
            if I2CStrings.contains("<class VoodooI2CDeviceNub") {
                isNameFound = true
                NativeDeviceName = String(I2CStrings[I2CStrings.index(I2CStrings.startIndex, offsetBy: I2CStrings.positionOf(sub: "<class VoodooI2CDeviceNub")-6)..<I2CStrings.index(I2CStrings.startIndex, offsetBy: I2CStrings.positionOf(sub: "<class VoodooI2CDeviceNub")-2)])
            }
        }
        let VoodooI2CInfo = kextStrings[1][kextStrings[1].index(kextStrings[1].startIndex, offsetBy: 52)..<kextStrings[1].endIndex].components(separatedBy: " ")
        VoodooI2CVersion = VoodooI2CInfo[1].replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "")
        
        let ioreg = Process()
        let pipe = Pipe()
        ioreg.standardOutput = pipe
        ioreg.launchPath = "/usr/sbin/ioreg"
        ioreg.arguments = ["-x", "-n", NativeDeviceName, "-r"]
        ioreg.launch()
        let ioregdata = pipe.fileHandleForReading.readDataToEndOfFile()
        let ioregStrings = String(data: ioregdata, encoding: String.Encoding.utf8)!.components(separatedBy: "\n")
        var openline:Int = 0
        var closeline:Int = 0
        for line in 0..<ioregStrings.count {
            if ioregStrings[line].contains("<class VoodooI2CDeviceNub") {
                openline = line + 2
                for i in 1..<ioregStrings.count - line {
                    if ioregStrings[line + i].contains("}") && !ioregStrings[line + i].contains("=") {
                        closeline = line + i - 1
                        break
                    }
                }
                break
            }
        }
        var ioregVoodooI2C = [String](repeating: "", count: closeline - openline + 1)
        for line in openline...closeline {
            ioregVoodooI2C[line - openline] = ioregStrings[line]
        }
        for line in 0..<ioregVoodooI2C.count {
            if ioregVoodooI2C[line].contains("IOName") {
                isNativeIONameFound = true
                NativeIOName = String(ioregVoodooI2C[line][ioregVoodooI2C[line].index(ioregVoodooI2C[line].startIndex, offsetBy: 18)..<ioregVoodooI2C[line].index(ioregVoodooI2C[line].startIndex, offsetBy: ioregVoodooI2C[line].count - 1)])
                
            }
            if ioregVoodooI2C[line].contains("IOInterruptSpecifiers") {
                NativePin = String(ioregVoodooI2C[line][ioregVoodooI2C[line].index(ioregVoodooI2C[line].startIndex, offsetBy: 34)..<ioregVoodooI2C[line].index(ioregVoodooI2C[line].startIndex, offsetBy: 36)])
                PinText += "Pin : 0x" + NativePin
            }
            if ioregVoodooI2C[line].contains("IOInterruptControllers") {
                if ioregVoodooI2C[line].contains("io-apic") {
                    PinText = "APIC " + PinText
                    if NativePin == "" || Int(strtoul(NativePin, nil, 16)) > 47 {
                        Mode += NSLocalizedString("Polling", comment: "")
                    } else {
                        Mode += NSLocalizedString("Interrupt(APIC)", comment: "")
                    }
                } else {
                    Mode += NSLocalizedString("Interrupt(GPIO)", comment: "")
                    PinText = "GPIO " + PinText
                }
            }
            if ioregVoodooI2C[line].contains("gpioPin") {
                NativePin = String(ioregVoodooI2C[line][ioregVoodooI2C[line].index(ioregVoodooI2C[line].startIndex, offsetBy: 18)..<ioregVoodooI2C[line].endIndex])
                PinText = "GPIO Pin : " + NativePin
                Mode += NSLocalizedString("Interrupt(GPIO)", comment: "")
            }
        }
    }
}

//
//  ReadDSDT.swift
//  GenI2C
//
//  Created by 梁怀宇 on 2020/3/10.
//  Copyright © 2020 梁怀宇. All rights reserved.
//

import Foundation

let AD = AppDelegate()
let Verbose = AD.VerboseTextView
var Matched:Bool = false
var lines = [String]()
var count:Int = 0
var ExUSTP:Bool = false
var ExSSCN:Bool = false
var ExFMCN:Bool = false
var total:Int = 0
var MultiTPAD:Bool = false
var MultiScopeBool:Bool = false
var MultiScope = [String](repeating: "", count: 6)
var MultiScopeCount:Int = 0
var MultiTPADLineCount = [Int](repeating: 0, count: 6)
var MultiTPADLineCountIndex:Int = 0
var GPI0Lines = [String]()

func ReadDSDT() {
    
    var line:Int = 0
    var DSDTLine:String = ""
    var Paranthesesopen:String = ""
    var Paranthesesclose:String = ""
    
    //Verbose?.string += "start"//verbose(text: "Start func : Countline()")
    let readHandler =  FileHandle(forReadingAtPath: DSDTFile)
    let data = readHandler?.readDataToEndOfFile()
    let readString = String(data: data!, encoding: String.Encoding.utf8)
    Matched = false
    lines = (readString?.components(separatedBy: "\n"))!
    count = lines.count
    ExUSTP = false
    ExSSCN = false
    ExFMCN = false
    total = 0
    
    GetPath(Name: "_STA")

    while line < count
    {
        DSDTLine = lines[line]
        line += 1
        if DSDTLine.contains("If (USTP)"){
            //AD.verbose(text: "Found for USTP in DSDT at line \(line)\n")
            ExUSTP = true
        }
        if DSDTLine.contains("SSCN"){
            //AD.verbose(text: "Found for SSCN in DSDT at line \(line)\n")
            ExSSCN = true
        }
        if DSDTLine.contains("FMCN"){
            //AD.verbose(text: "Found for FMCN in DSDT at line \(line)\n")
            ExFMCN = true
        }
        if DSDTLine.contains(Device){
            var spaceopen, spaceclose, startline:Int
            
            if Matched {
                MultiTPAD = true
                MultiScopeBool = false
                total = 0
            }
            //AD.verbose(text: "Found for \(Device) in DSDT at line \(line)\n")
            startline = line
            Paranthesesopen = lines[line]
            line += 1
            spaceopen = Paranthesesopen.positionOf(sub: "{")
            repeat {
                Paranthesesclose = lines[line]
                line += 1
                spaceclose = Paranthesesclose.positionOf(sub: "}")
                if Paranthesesclose.contains("_SB.PCI0.I2C") {
                    if MultiScopeBool {
                        if MultiScope[MultiScopeCount - 1] != String(Paranthesesclose[Paranthesesclose.index(Paranthesesclose.startIndex ,offsetBy: Paranthesesclose.positionOf(sub: "_SB.PCI0.I2C") + 12)]) {
                            MultiScope[MultiScopeCount] = String(Paranthesesclose[Paranthesesclose.index(Paranthesesclose.startIndex ,offsetBy: Paranthesesclose.positionOf(sub: "_SB.PCI0.I2C") + 12)])
                            MultiScopeCount += 1
                        }
                    } else {
                        MultiScope[MultiScopeCount] = String(Paranthesesclose[Paranthesesclose.index(Paranthesesclose.startIndex ,offsetBy: Paranthesesclose.positionOf(sub: "_SB.PCI0.I2C") + 12)])
                        MultiScopeCount += 1
                        MultiScopeBool = true
                    }
                }
            } while spaceclose != spaceopen
            if total == 0 {
                total += (line - startline)
            }
            else{
                total += (line - startline) + 1
            }
            Matched = true
            MultiTPADLineCount[MultiTPADLineCountIndex] = total
            MultiTPADLineCountIndex += 1
        }
        if DSDTLine.contains("Device (GPI0)") {
            var spaceopen, spaceclose, startline, closeline:Int
            startline = line
            Paranthesesopen = lines[line]
            line += 1
            spaceopen = Paranthesesopen.positionOf(sub: "{")
            repeat {
                Paranthesesclose = lines[line]
                line += 1
                spaceclose = Paranthesesclose.positionOf(sub: "}")
                closeline = line
            } while spaceclose != spaceopen
            GPI0Lines = [String](repeating: "", count: closeline - startline + 1)
            for i in startline...closeline {
                GPI0Lines[i - startline] = lines[i - 1]
            }
        }
    }
}

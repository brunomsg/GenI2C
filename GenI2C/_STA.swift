//
//  _STA.swift
//  GenI2C
//
//  Created by 梁怀宇 on 2020/3/12.
//  Copyright © 2020 梁怀宇. All rights reserved.
//

import Foundation

func STA(STACode:Array<String>, mode:Int) -> (String, String) {
    
    var DevCode = [String]()
    var Var:String = ""
    var Val:String = ""
    var DecVal:Int = 0
    var line:Int = 0
    var RtnPos:Int = 0
    
    func GetDevCode(Name:String) {
        var Paranthesesopen:String = ""
        var Paranthesesclose:String = ""
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
        DevCode = [String](repeating: "", count: closeline - startline + 1)
        for i in startline...closeline {
            DevCode[i - startline] = lines[i - 1]
        }
    }
    
    func VarVal(Str:String) {
        let letters = Array(STACode[line])
        if Str.contains("If (L") {
            var p:Int = STACode[line].positionOf(sub: "If")
            var flag:Int = 0
            while p < letters.count {
                if letters[p] == "," {
                    flag -= 1
                    break
                }
                if flag == 2 {
                    Var += String(letters[p])
                }
                if letters[p] == "(" {
                    flag += 1
                }
                p += 1
            }
            p += 1
            while p < letters.count {
                if letters[p] == ")" {
                    flag = 0
                    break
                }
                if flag == 2 {
                    Val += String(letters[p])
                }
                if letters[p] == " " {
                    flag += 1
                }
                p += 1
            }
        } else if Str.contains("If ((") {
            var p:Int = STACode[line].positionOf(sub: "If") + 3
            var flag:Int = 0
            while p < letters.count {
                if letters[p] == " " {
                    flag -= 1
                    break
                }
                if flag == 2 {
                    Var += String(letters[p])
                }
                if letters[p] == "(" {
                    flag += 1
                }
                p += 1
            }
            p += 1
            while p < letters.count {
                if letters[p] == ")" {
                    flag = 0
                    break
                }
                if flag == 2 {
                    Val += String(letters[p])
                }
                if letters[p] == " " {
                    flag += 1
                }
                p += 1
            }
        }
        if Val == "Zero" {
            Val = "0x00"
        }
        if Val == "One" {
            Val = "0x01"
        }
        DecVal = Int(strtoul(Val, nil, 16))
    }
    
    while line < STACode.count {
        if STACode[line].contains("Return (0x0F)") {
            if STACode[line].positionOf(sub: "Return (0x0F)") == STACode[0].positionOf(sub: "Method") + 4 {
                RtnPos = 0
            } else {
                RtnPos = 1
            }
        }
        line += 1
    }
    line = 0
    while line < STACode.count {
        if STACode[line].contains("If (") {
            VarVal(Str: STACode[line])
            if mode == 1 {
                if RtnPos == 0 {
                    if STACode[line].contains("LEqual") || STACode[line].contains("==") {
                        DecVal += 1
                    }
                    if STACode[line].contains("LLess") || STACode[line].contains("<") {
                        DecVal += 1
                    }
                    if STACode[line].contains("LGreater") || STACode[line].contains(">") {
                        DecVal -= 1
                    }
                    if STACode[line].contains("LNotEqual") || STACode[line].contains("!=") {
                        
                    }
                }
            } else {
                if RtnPos == 1 {
                    if STACode[line].contains("LEqual") || STACode[line].contains("==") {
                        DecVal += 1
                    }
                    if STACode[line].contains("LLess") || STACode[line].contains("<") {
                        DecVal += 1
                    }
                    if STACode[line].contains("LGreater") || STACode[line].contains(">") {
                        DecVal -= 1
                    }
                    if STACode[line].contains("LNotEqual") || STACode[line].contains("!=") {
                        
                    }
                }
            }
        }
        line += 1
    }
    Val = String(format: "0x%02X", DecVal)
    print(Var, Val)
    return (Var, Val)
}

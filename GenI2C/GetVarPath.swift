//
//  GetVarPath.swift
//  GenI2C
//
//  Created by 梁怀宇 on 2020/3/11.
//  Copyright © 2020 梁怀宇. All rights reserved.
//

import Foundation

func GetPath(Name:String) -> String {
    
    func GetName(Str:String) -> String {
        var n:String = ""
        var flag:Int = 0
        for letter in Str {
            if letter == ")" || letter == "," {
                flag = 0
            }
            if flag == 1 {
                n += String(letter)
            }
            if letter == "("{
                flag = 1
            }
        }
        return n
    }

    var AllPATH:String = ""
    var line:Int = 0
    var DSDTLine:String = ""
    while line < count {
        DSDTLine = lines[line]
        line += 1
        if DSDTLine.contains("Method (" + Name) {
            var PATH:String = ""
            var i:Int = line
            var spaceName = DSDTLine.positionOf(sub: "Method (" + Name)
            var space:Int = 0
            
            while spaceName >= 4 {
                repeat {
                    space = 0
                    i -= 1
                    let letters = Array(lines[i])
                    for letter in letters {
                        if letter != " " {
                            break
                        }
                        space += 1
                    }
                } while space != spaceName - 4
                spaceName -= 4
                if !lines[i - 1].contains("Field (") && !lines[i - 1].contains("If (") {
                    if lines[i - 1].contains("Scope (") {
                        if GetName(Str: lines[i - 1]) == "\\" {
                            PATH = "\\" + PATH
                            break
                        }
                        if GetName(Str: lines[i - 1]).contains("_SB") {
                            PATH = GetName(Str: lines[i - 1]) + "." + PATH
                            break
                        }
                    }
                    PATH = GetName(Str: lines[i - 1]) + "." + PATH
                }
            }
            PATH = PATH + Name
            AllPATH += PATH + "\n"
        }
        
        if DSDTLine.contains("Name (" + Name) {
            var PATH:String = ""
            var i:Int = line
            var spaceName = DSDTLine.positionOf(sub: "Name (" + Name)
            var space:Int = 0
            
            while spaceName >= 4 {
                repeat {
                    space = 0
                    i -= 1
                    let letters = Array(lines[i])
                    for letter in letters {
                        if letter != " " {
                            break
                        }
                        space += 1
                    }
                } while space != spaceName - 4
                spaceName -= 4
                if !lines[i - 1].contains("Field (") && !lines[i - 1].contains("If (") {
                    if lines[i - 1].contains("Scope (") {
                        if GetName(Str: lines[i - 1]) == "\\" {
                            PATH = "\\" + PATH
                            break
                        }
                        if GetName(Str: lines[i - 1]).contains("_SB") {
                            PATH = GetName(Str: lines[i - 1]) + "." + PATH
                            break
                        }
                    }
                    PATH = GetName(Str: lines[i - 1]) + "." + PATH
                }
            }
            PATH = PATH + Name
            AllPATH += PATH + "\n"
        }
        
        if DSDTLine.contains("    " + Name) {
            var PATH:String = ""
            var i:Int = line
            var spaceName = DSDTLine.positionOf(sub: Name)
            var space:Int = 0
            
            while spaceName >= 4 {
                repeat {
                    space = 0
                    i -= 1
                    let letters = Array(lines[i])
                    for letter in letters {
                        if letter != " " {
                            break
                        }
                        space += 1
                    }
                } while space != spaceName - 4
                spaceName -= 4
                if !lines[i - 1].contains("Field (") && !lines[i - 1].contains("If (") {
                    if lines[i - 1].contains("Scope (") {
                        if GetName(Str: lines[i - 1]) == "\\" {
                            PATH = "\\" + PATH
                            break
                        }
                        if GetName(Str: lines[i - 1]).contains("_SB") {
                            PATH = GetName(Str: lines[i - 1]) + "." + PATH
                            break
                        }
                    }
                    PATH = GetName(Str: lines[i - 1]) + "." + PATH
                }
            }
            PATH = PATH + Name
            AllPATH += PATH + "\n"
        }
    }
    return AllPATH
}

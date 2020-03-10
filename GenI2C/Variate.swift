//
//  Variate.swift
//  GenI2C
//
//  Created by 梁怀宇 on 2020/3/10.
//  Copyright © 2020 梁怀宇. All rights reserved.
//

import Foundation

var TPAD:String = ""
var Device:String = ""
var DSDTFile:String = ""
var scope:String = ""
var Spacing:String = ""
var APICNAME:String = ""
var SLAVName:String = ""
var GPIONAME:String = ""
var APICPin:String = ""
var HexTPAD:String = ""
var BlockBus:String = ""
var HexBlockBus:String = ""
var FolderPath:String = "\(NSHomeDirectory())/desktop/I2C-PATCH"
var BlockSSDT = [String](repeating: "", count: 16)
var GPI0SSDT = [String](repeating: "", count: 16)
var ScopeSelect:String = ""
var RenameFile:String = ""
var HexI2C:String = ""
var HexI2X:String = ""
var ManualGPIO = [String](repeating: "", count: 9)
var ManualAPIC = [String](repeating: "", count: 7)
var ManualSPED = [String](repeating: "", count: 2)
var CRSInfo = [String]()
var CNL_H_SPED = [String](repeating: "", count: 44)
var Code = [String](), IfLLess = [String](repeating: "", count: 6)
var IfLEqual = [String](repeating: "", count: 6)
var If2Brackets = [String](repeating: "", count: 6)
var CRSPatched:Bool = false
var ExAPIC:Bool = false
var ExSLAV:Bool = false
var ExGPIO:Bool = false
var CatchSpacing:Bool = false
var APICNameLineFound:Bool = false
var SLAVNameLineFound:Bool = false
var GPIONameLineFound:Bool = false
var InterruptEnabled:Bool = false
var PollingEnabled:Bool = false
var Hetero:Bool = false
var BlockI2C:Bool = false
var ExI2CM:Bool = false
var ExBADR:Bool = false
var ExHID2:Bool = false
var LLess:Bool = false
var LEqual:Bool = false
var If2BracketsBool:Bool = false
var n:Int = 0
var APICPinLine:Int = 0
var GPIOPinLine:Int = 0
var APICPIN:Int = 0
var GPIOPIN:Int = 0
var GPIOPIN2:Int = 0
var GPIOPIN3:Int = 0
var APICNameLine:Int = 0
var SLAVNameLine:Int = 0
var GPIONAMELine:Int = 0
var CheckConbLine:Int = 0
var PatchChoice:Int = -1
var Choice:Int = -1
var preChoice:Int = -1
var ScopeLine:Int = 0
var CRSLocation:Int = 0
var CheckSLAVLocation:Int = 0
var CPUChoice:Int = -1
var MultiTPADUSRSelect:Int = 0
var TargetTPAD:Int = 0

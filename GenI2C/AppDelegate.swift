//
//  AppDelegate.swift
//  GenI2C
//
//  Created by 梁怀宇 on 2019/5/26.
//  Copyright © 2019 梁怀宇. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSTextFieldDelegate {

    @IBOutlet weak var mainWindow: NSWindow!
    @IBOutlet weak var VerboseWindow: NSWindow!
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var DSDTPath: NSTextField!
    @IBOutlet weak var TabView: NSTabView!
    @IBOutlet weak var Next1: NSButton!
    @IBOutlet weak var Next2: NSButton!
    @IBOutlet weak var Next3: NSButton!
    @IBOutlet weak var Next4: NSButton!
    @IBOutlet weak var SelectDevice: NSPopUpButton!
    @IBOutlet weak var DeviceName: NSTextField!
    @IBOutlet weak var Verbose: NSScrollView!
    @IBOutlet weak var InputAPICPin: NSView!
    @IBOutlet weak var APICPinText: NSTextField!
    @IBOutlet weak var Warning: NSTextField!
    @IBOutlet var VerboseTextView: NSTextView!
    @IBOutlet weak var RenameLabel: NSTextField!
    
    let queue = DispatchQueue(label: "queue", attributes: .concurrent)
    let queue1 = DispatchQueue(label: "queue", attributes: .concurrent)
    var alert = NSAlert()
    var TPAD:String = "", Device:String = "", DSDTFile:String = "", Paranthesesopen:String = "", Paranthesesclose:String = "", DSDTLine:String = "", scope:String = "", Spacing:String = "", APICNAME:String = "", SLAVName:String = "", GPIONAME:String = "", APICPin:String = "", HexTPAD:String = "", BlockBus:String = "", HexBlockBus:String = "", FolderPath:String = "\(NSHomeDirectory())/desktop/I2C-PATCH", BlockSSDT = [String](repeating: "", count: 16), GPI0SSDT = [String](repeating: "", count: 16)
    var ManualGPIO = [String](repeating: "", count: 9), ManualAPIC = [String](repeating: "", count: 7),  ManualSPED = [String](repeating: "", count: 2), CRSInfo = [String](), CNL_H_SPED = [String](repeating: "", count: 44), Code = [String](), lines = [String](), IfLLess = [String](repeating: "", count: 6), IfLEqual = [String](repeating: "", count: 6)
    var Matched:Bool = false, CRSPatched:Bool = false, ExUSTP:Bool = false, ExSSCN:Bool = false, ExFMCN:Bool = false, ExAPIC:Bool = false, ExSLAV:Bool = false, ExGPIO:Bool = false, CatchSpacing:Bool = false, APICNameLineFound:Bool = false, SLAVNameLineFound:Bool = false, GPIONameLineFound:Bool = false, InterruptEnabled:Bool = false, PollingEnabled:Bool = false, Hetero:Bool = false, BlockI2C:Bool = false, ExI2CM:Bool = false, ExBADR:Bool = false, ExHID2:Bool = false, LLess:Bool = false, LEqual:Bool = false
    var line:Int = 0, i:Int = 0, n:Int = 0, total:Int = 0, APICPinLine:Int = 0, GPIOPinLine:Int = 0, APICPIN:Int = 0, GPIOPIN:Int = 0, GPIOPIN2:Int = 0, GPIOPIN3:Int = 0, APICNameLine:Int = 0, SLAVNameLine:Int = 0, GPIONAMELine:Int = 0, CheckConbLine:Int = 0, Choice:Int = -1, preChoice:Int = -1, ScopeLine:Int = 0, count:Int = 0, CRSLocation:Int = 0, CheckSLAVLocation:Int = 0, CPUChoice:Int = -1
    
    @IBAction func SelectMode(_ sender: Any) {
        Choice = (sender as! NSButton).tag
        Next4.isEnabled = true
    }

    @IBAction func SelectCPU(_ sender: Any) {
        CPUChoice = (sender as! NSButton).tag
        Next3.isEnabled = true
    }
    
    @IBAction func InputDeviceName(_ sender: Any) {
        if DeviceName.stringValue.count == 0 {
            Next2.isEnabled = false
        } else if DeviceName.stringValue == TPAD {
        } else {
            TPAD = DeviceName.stringValue
            Device = "Device (\(TPAD))"
            verbose(text: "\nDevice: \(TPAD)\n")
            HexTPAD = Data(TPAD.utf8).map{String(format: "%02x", $0)}.joined()
            verbose(text: "\(HexTPAD)\n")
            Countline()
        }
    }
    
    @IBAction func InputAPICPin(_ sender: Any) {
        if APICPinText.stringValue.count >= 2 {
            let index = APICPinText.stringValue.index(APICPinText.stringValue.startIndex, offsetBy: 2)
            if String(APICPinText.stringValue[..<index]) == "0x" && APICPinText.stringValue.count == 4  {
                if Int(strtoul(APICPinText.stringValue, nil, 16)) >= 24 && Int(strtoul(APICPinText.stringValue, nil, 16)) <= 119 {
                    alert.buttons[0].isEnabled = true
                    Warning.stringValue = ""
                    APICPin = APICPinText.stringValue
                    APICPIN = Int(strtoul(APICPin, nil, 16))
                    verbose(text: "APIC Pin you input is \(APICPin)\n")
                } else {
                    Warning.stringValue = "APIC Pin should be between 0x2F and 0x77"
                }
            } else {
                alert.buttons[0].isEnabled = false
            }
        } else {
            alert.buttons[0].isEnabled = false
        }
    }
    
    @IBAction func SelectDSDTButtom(_ sender: Any) {
        selectDSDT()
    }
    @IBAction func Next1(_ sender: Any) {
        TabView.selectNextTabViewItem(Any?.self)
    }
    @IBAction func Next2(_ sender: Any) {
        TabView.selectNextTabViewItem(Any?.self)
    }
    @IBAction func Next3(_ sender: Any) {
        TabView.selectNextTabViewItem(Any?.self)
    }
    @IBAction func Next4(_ sender: Any) {
        TabView.selectNextTabViewItem(Any?.self)
        if Choice != preChoice {
            if Choice == 0 {
                verbose(text: "Selection: Interrupt (APIC or GPIO)\n")
            } else {
                verbose(text: "Selection: Polling (Will be set back to APIC if supported)\n")
            }
            preChoice = Choice
            Analysis2()
        }
    }
    @IBAction func Back2(_ sender: Any) {
        TabView.selectPreviousTabViewItem(Any?.self)
    }
    @IBAction func Back3(_ sender: Any) {
        TabView.selectPreviousTabViewItem(Any?.self)
    }
    @IBAction func Back4(_ sender: Any) {
        TabView.selectPreviousTabViewItem(Any?.self)
    }
    
    func selectDSDT() {
        let openPanel:NSOpenPanel = NSOpenPanel()
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true
        openPanel.allowedFileTypes = ["dsl"]
        openPanel.allowsMultipleSelection = false
        openPanel.beginSheetModal(for: mainWindow, completionHandler: {result in
            if (result == NSApplication.ModalResponse.OK)
            {
                let path:NSURL = openPanel.urls[0] as NSURL
                openPanel.close()
                let pathStr = path.absoluteString!.removingPercentEncoding!
                let index1 = pathStr.index(pathStr.startIndex, offsetBy: 7)
                let index2 = pathStr.index(pathStr.startIndex, offsetBy: pathStr.count)
                self.DSDTFile = String(pathStr[index1..<index2])
                self.DSDTPath.stringValue = self.DSDTFile
                self.verbose(text: "\(self.DSDTFile)\n")
                self.Next1.isEnabled = true
            }
        })
    }
    
    func Countline() {
        let readHandler =  FileHandle(forReadingAtPath: DSDTFile)
        let data = readHandler?.readDataToEndOfFile()
        let readString = String(data: data!, encoding: String.Encoding.utf8)
        Matched = false
        line = 0
        lines = (readString?.components(separatedBy: "\n"))!
        count = lines.count
        ExUSTP = false
        ExSSCN = false
        ExFMCN = false
        Paranthesesopen = ""
        Paranthesesclose = ""
        total = 0
        while line < count
        {
            DSDTLine = lines[line]
            line += 1
            if DSDTLine.contains("If (USTP)"){
                verbose(text: "Found for USTP in DSDT at line \(line)\n")
                ExUSTP = true
            }
            if DSDTLine.contains("SSCN"){
                verbose(text: "Found for SSCN in DSDT at line \(line)\n")
                ExSSCN = true
            }
            if DSDTLine.contains("FMCN"){
                verbose(text: "Found for FMCN in DSDT at line \(line)\n")
                ExFMCN = true
            }
            if DSDTLine.contains(Device){
                verbose(text: "Found for \(Device) in DSDT at line \(line)\n")
                var spaceopen, spaceclose, startline:Int
                startline = line
                Paranthesesopen = lines[line]
                line += 1
                spaceopen = Paranthesesopen.positionOf(sub: "{")
                repeat{
                    Paranthesesclose = lines[line]
                    line += 1
                    spaceclose = Paranthesesclose.positionOf(sub: "}")
                } while spaceclose != spaceopen
                if total == 0 {
                    total += (line - startline)
                }
                else{
                    total += (line - startline) + 1
                }
                Matched = true
                total += 1
            }
        }
        if Matched == false{
            verbose(text: "No Device Found\n")
            let noDevice = NSAlert()
            noDevice.messageText = "No Device Found"
            noDevice.informativeText = "There is no \(TPAD) in your DSDT. Please input again or exit"
            noDevice.alertStyle = .informational
            noDevice.addButton(withTitle: "Input again")
            noDevice.addButton(withTitle: "Exit")
            noDevice.beginSheetModal(for: self.window, completionHandler: {response -> Void in
                if response.rawValue == 1001 {
                    exit(0)
                }
                /*print(response*/})
        }
        else{
            Next2.isEnabled = true
            Analysis()
        }
    }
    
    func Analysis() {
        Code = [String](repeating: "", count: total)
        line = 0
        DSDTLine = ""
        Paranthesesopen = ""
        Paranthesesclose = ""
        i = 0
        while line < count-1 {
            DSDTLine = lines[line]
            line += 1
            if DSDTLine.contains(Device){
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
                Matched = true
            }
        }
        for i in 0..<total {
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
                verbose(text: "\nRenamed _CRS detected!\nPlease use an error-corrected vanilla DSDT instead!\n")
            }
            if Code[i].contains("GpioInt"){
                if ExGPIO == true {
                    ExGPIO = true
                    GPIONameLineFound = false
                }
                verbose(text: "Native GpioInt Found in \(TPAD) at line \(i)\n")
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
                verbose(text: "GPIO Pin \(GPIOPIN)\n")
            }
            if Code[i].contains("Interrupt (ResourceConsumer") {
                if ExAPIC == true {
                    APICNameLineFound = false
                }
                verbose(text: "Native APIC Found in \(TPAD) at line \(i + 1)\n")
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
                verbose(text: "APIC Pin \(APICPIN)\n")
            }
            if Code[i].contains("I2cSerialBusV2 (0x") {
                if ExSLAV == true {
                    SLAVNameLineFound = false
                    verbose(text: "Warning! Multiple I2C Bus Addresses exist in " + TPAD + " _CRS patching may be wrong!")
                }
                verbose(text: "Slave Address Found in \(TPAD) at line \(i + 1)\n")
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
                verbose(text: Code[ScopeLine] + "\n")
                let index1 = Code[ScopeLine].index(Code[ScopeLine].startIndex, offsetBy: Code[ScopeLine].positionOf(sub: "\",") - 1)
                let index2 = Code[ScopeLine].index(Code[ScopeLine].startIndex, offsetBy: Code[ScopeLine].positionOf(sub: "\","))
                scope = String(Code[ScopeLine][index1..<index2])
            }
            if Code[i].contains("Name (") && CatchSpacing == false {
                let index1 = Code[i].index(Code[i].startIndex, offsetBy: 0)
                let index2 = Code[i].index(Code[i].startIndex, offsetBy: Code[i].positionOf(sub: "Name (") - 4)
                Spacing = String(Code[i][index1..<index2])
                CatchSpacing = true
            }
            if SLAVNameLineFound == true && APICNameLineFound == true && SLAVName == APICNAME && Hetero == false {
                Hetero = true
                if CheckSLAVLocation < CRSLocation {
                    BreakCombine()
                }
            }
        }
        var IfString:String = ""
        var LLessCount:Int = 0
        var LEqualCount:Int = 0
        print(n)
        for i in 0..<CRSInfo.count {
            print(CRSInfo[i])
        }
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
                print("lequal \(CRSLine)")
                let index1 = CRSInfo[CRSLine].index(CRSInfo[CRSLine].startIndex, offsetBy: CRSInfo[CRSLine].positionOf(sub: "If (LEqual (")+12)
                let index2 = CRSInfo[CRSLine].index(CRSInfo[CRSLine].startIndex, offsetBy: CRSInfo[CRSLine].positionOf(sub: "If (LEqual (")+16)
                if !(IfString.contains(String(CRSInfo[CRSLine][index1..<index2]))) || LEqual == false {
                    IfLEqual[LEqualCount] = String(CRSInfo[CRSLine][index1..<index2])
                    IfString += IfLEqual[LEqualCount] + " "
                    LEqualCount += 1
                    LEqual = true
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
            verbose(text: "\nThis is not a I2C Trackpad!\n")
        } else {
            
        }
        TabView.selectNextTabViewItem(Any?.self)
    }
    
    func Analysis2() {
        print("Analysis2()")
        if Choice == 0 {
            InterruptEnabled = true
        } else if Choice == 1 {
            PollingEnabled = true
        } else {
            
        }
        if ExAPIC && APICPIN >= 24 && APICPIN <= 47 {
            verbose(text: "APIC Pin value < 2F, Native APIC Supported, using instead\n")
            if Hetero == true {
                APICNAME = "SBFX"
            }
            PatchCRS2APIC()
        } else if ExAPIC == false && ExGPIO == true {
            if InterruptEnabled == true {
                PatchCRS2GPIO()
            }
            if PollingEnabled == true {
                APICPIN = 63
                APICNAME = "SBFX"
                PatchCRS2APIC()
            }
        } else if (ExAPIC && (APICPIN > 47 || APICPIN == 0) && InterruptEnabled && ExGPIO == false && APICPIN == 0) || (ExAPIC == false && ExGPIO == false && ExSLAV && InterruptEnabled) {
            alert.beginSheetModal(for: self.window, completionHandler: {response -> Void in self.analysis3()})
        } else {
            analysis3()
        }
        GenSSDT()
    }
    
    func analysis3() {
        print("analysis3()")
        if ExAPIC == true && (APICPIN > 47 || APICPIN == 0) {
            if InterruptEnabled == true {
                if ExGPIO == false {
                    if APICPIN == 0 {
                        if APICPIN >= 24 && APICPIN <= 47 {
                            verbose(text: "APIC Pin value < 2F, Native APIC Supported, using instead\n")
                            if Hetero {
                                APICNAME = "SBFX"
                                PatchCRS2APIC()
                            }
                        } else {
                            GPIONAME = "SBFZ"
                            APIC2GPIO()
                            PatchCRS2GPIO()
                        }
                    } else if APICPIN > 47 {
                        verbose(text: "No native GpioInt found, Generating instead")
                        GPIONAME = "SBFZ"
                        APIC2GPIO()
                        PatchCRS2GPIO()
                    }
                } else if ExGPIO {
                    PatchCRS2GPIO()
                }
            } else if PollingEnabled == true {
                if Hetero {
                    APICNAME = "SBFX"
                    APICPIN = 63
                }
                if APICPIN == 0 {
                    verbose(text: "APIC Pin size uncertain, could be either APIC or polling")
                }
                PatchCRS2APIC()
            }
        } else if ExAPIC == false && ExGPIO == false && ExSLAV {
            if InterruptEnabled {
                if APICPIN >= 24 && APICPIN <= 47 {
                    verbose(text: "APIC Pin value < 2F, Native APIC Supported, No _CRS Patch required\n")
                } else {
                    GPIONAME = "SBFZ"
                    APIC2GPIO()
                    PatchCRS2GPIO()
                }
            } else if PollingEnabled {
                APICNAME = "SBFX"
                APICPIN = 63
                PatchCRS2APIC()
            }
        } else {
            verbose(text: "Undefined Situation")
        }
    }
    
    func PatchCRS2GPIO() {
        print("PatchCRS2GPIO()")
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
        print(CRSPatched)
        if CRSPatched == false {
            verbose(text: "Error! No _CRS Patch Applied!")
        }
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
    
    func PatchCRS2APIC() {
        print("PatchCRS2APIC()")
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
            verbose(text: "Error! No _CRS Patch Applied!")
        }
    }
    
    func APIC2GPIO() {
        print("APIC2GPIO()")
        if APICPIN >= 24 && APICPIN <= 47 {
            verbose(text: "APIC Pin value < 2F, Native APIC Supported, Generation Cancelled")
        } else {
            switch CPUChoice {
            case 0 :
                if APICPIN > 47 && APICPIN <= 79 {
                    GPIOPIN = APICPIN - 24
                    GPIOPIN2 = APICPIN + 72
                } else if APICPIN > 79 && APICPIN <= 119 {
                    GPIOPIN = APICPIN - 24
                }
            case 1 :
                if APICPIN > 47 && APICPIN <= 71 {
                    GPIOPIN = APICPIN - 16
                    GPIOPIN2 = APICPIN + 240
                    if APICPIN > 47 && APICPIN <= 59 {
                        GPIOPIN3 = APICPIN + 304
                    }
                } else if APICPIN > 71 && APICPIN <= 95 {
                    GPIOPIN = APICPIN - 8
                    GPIOPIN3 = APICPIN + 152
                    GPIOPIN2 = APICPIN + 120
                } else if APICPIN > 95 && APICPIN <= 119 {
                    GPIOPIN = APICPIN
                    if APICPIN > 108 && APICPIN <= 115 {
                        GPIOPIN2 = APICPIN + 20
                    }
                }
            case 2 :
                if APICPIN > 47 && APICPIN <= 71 {
                    GPIOPIN = APICPIN - 16
                    GPIOPIN2 = APICPIN + 80
                } else if APICPIN > 71 && APICPIN <= 95 {
                    GPIOPIN2 = APICPIN + 184
                    GPIOPIN = APICPIN + 88
                } else if APICPIN > 95 && APICPIN <= 119 {
                    GPIOPIN = APICPIN
                    if APICPIN > 108 && APICPIN <= 115 {
                        GPIOPIN2 = APICPIN - 44
                    }
                }
            default:
                print("default")
            }
        }
    }
    
    func GenGPIO() {
        print("GenGPIO()")
        ManualGPIO[0] = Spacing + "Name (SBFZ, ResourceTemplate ()"
        ManualGPIO[1] = Spacing + "{"
        ManualGPIO[2] = Spacing + "    GpioInt (Level, ActiveLow, Exclusive, PullUp, 0x0000,"
        ManualGPIO[3] = Spacing + #"       "\\ _SB.PCI0.GPI0", 0x00, ResourceConsumer, ,"#
        ManualGPIO[4] = Spacing + "        )"
        ManualGPIO[5] = Spacing + "        {   // Pin list"
        if GPIOPIN2 == 0 {
            ManualGPIO[6] = Spacing + "            0x" + String(format: "%0X", GPIOPIN)
        } else if GPIOPIN2 != 0 && GPIOPIN3 == 0 {
            ManualGPIO[6] = Spacing + "            0x" + String(format: "%0X", GPIOPIN) + " // Try this if the first one doesn't work: 0x" + String(format: "%0X", GPIOPIN2)
        } else {
            ManualGPIO[6] = Spacing + "            0x" + String(format: "%0X", GPIOPIN) + " // Try the following ones if the first one doesn't work: 0x" + String(format: "%0X", GPIOPIN2) + " 0x" + String(format: "%0X", GPIOPIN3)
        }
        ManualGPIO[7] = Spacing + "        }"
        ManualGPIO[8] = Spacing + "})"
    }
    
    func GenAPIC() {
        print("GenAPIC()")
        ManualAPIC[0] = Spacing + "Name (SBFX, ResourceTemplate ()"
        ManualAPIC[1] = Spacing + "{"
        ManualAPIC[2] = Spacing + "    Interrupt (ResourceConsumer, Level, ActiveHigh, Exclusive, ,,)"
        ManualAPIC[3] = Spacing + "    {"
        ManualAPIC[4] = Spacing + "        0x000000" + String(format: "%0X", APICPIN) + ","
        ManualAPIC[5] = Spacing + "    }"
        ManualAPIC[6] = Spacing + "})"
    }
    
    func GenSSDT() {
        print("GenSSDT()")
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
                
                var Filehead = [String](repeating: "", count: 27)
                Filehead[0] = #"DefinitionBlock("", "SSDT", 2, "hack", "I2Cpatch", 0)"#
                Filehead[1] = "{"
                Filehead[2] = "    External(_SB.PCI0.I2C" + scope + "." + TPAD + ", DeviceObj)"
                if CheckSLAVLocation < CRSLocation {
                    Filehead[3] = "    External(_SB.PCI0.I2C" + scope + "." + TPAD + "." + SLAVName + ", UnknownObj)"
                    if (PollingEnabled && ExAPIC && Hetero == false) || APICPIN < 47 && APICPIN != 0 && ExAPIC && Hetero == false {
                        Filehead[4] = "    External(_SB.PCI0.I2C" + scope + "." + TPAD + "." + APICNAME + ", UnknownObj)"
                    }
                    if InterruptEnabled && ExGPIO && (APICPIN > 47 || APICPIN == 0 || ExAPIC == false) {
                        Filehead[5] = "    External(_SB.PCI0.I2C" + scope + "." + TPAD + "." + GPIONAME + ", UnknownObj)"
                    }
                }
                
                var AddFhLe:Int = 6
                var AddFhEq:Int = 12
                
                for Genindex in 0...5 {
                    if IfLLess[Genindex] != "" && (IfLLess[Genindex] != "Zero" || IfLLess[Genindex] != "One)") {
                        Filehead[AddFhLe] = "    External(" + IfLLess[Genindex] + ", FieldUnitObj)"
                        AddFhLe += 1
                    }
                    if IfLEqual[Genindex] != "" && (IfLEqual[Genindex] != "Zero" || IfLEqual[Genindex] != "One)") {
                        Filehead[AddFhEq] = "    External(" + IfLEqual[Genindex] + ", FieldUnitObj)"
                        AddFhEq += 1
                    }
                }
                if ExI2CM {
                    Filehead[18] = "    External(_SB.PCI0.I2C" + scope + ".I2CX, UnknownObj)"
                    Filehead[19] = "    External(_SB.PCI0.I2CM, MethodObj)"
                    Filehead[20] = "    External(_SB.PCI0.I2C" + scope + "." + TPAD + ".BADR, IntObj)"
                    Filehead[21] = "    External(_SB.PCI0.I2C" + scope + "." + TPAD + ".SPED, IntObj)"
                }
                if ExBADR && ExI2CM == false {
                    Filehead[22] = "    External(_SB.PCI0.I2C" + scope + "." + TPAD + ".BADR, IntObj)"
                }
                if ExHID2 {
                    Filehead[23] = "    External(_SB.PCI0.I2C" + scope + "." + TPAD + ".HID2, UnknownObj)"
                }
                if ExUSTP {
                    Filehead[24] = "    Name (USTP, One)"
                }
                Filehead[25] = "    Scope(_SB.PCI0.I2C" + scope + "." + TPAD + ")"
                Filehead[26] = "    {"
                for i in 0..<Filehead.count {
                    print(Filehead[i])
                }
                
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
                print(Filehead)
                fileContent += " */\n"
                for Genindex in 0..<Filehead.count {
                    if Filehead[Genindex] != "" && Filehead[Genindex] != "\n" {
                        fileContent += Filehead[Genindex] + "\n"
                    }
                }
                if ExUSTP == false && (ExFMCN == false || ExSSCN == false) {
                    GenSPED()
                    if CPUChoice == 0 {
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
        RenameLabel.stringValue += "++++++++++++++++++++++++++++++++++++++\n\n"
        if InterruptEnabled || PollingEnabled {
            RenameLabel.stringValue += "Find _CRS:          5F 43 52 53\n"
            RenameLabel.stringValue += "Replace XCRS:       58 43 52 53\n"
            RenameLabel.stringValue += "Target Bridge \(TPAD): \(HexTPAD)\n\n"
            if InterruptEnabled && (APICPIN > 47 || (APICPIN == 0 && ExGPIO && ExAPIC)) {
                RenameLabel.stringValue += "Find _STA:          5F 53 54 41\n"
                RenameLabel.stringValue += "Replace XSTA:       58 53 54 41\n"
                RenameLabel.stringValue += "Target Bridge GPI0: 47 50 49 30\n\n"
            }
        } else if BlockI2C {
            RenameLabel.stringValue += "Find _STA:          5F 53 54 41\n"
            RenameLabel.stringValue += "Replace XSTA:       58 53 54 41\n"
            RenameLabel.stringValue += "Target Bridge \(BlockBus): \(HexBlockBus)\n\n"
        }
        if ExUSTP && BlockI2C == false {
            RenameLabel.stringValue += "Find USTP:          55 53 54 50 08\n"
            RenameLabel.stringValue += "Replace XSTP:       58 53 54 50 08\n\n"
        } else if ExUSTP == false && ExSSCN && ExFMCN == false && CPUChoice == 1 && BlockI2C == false {
            RenameLabel.stringValue += "Find SSCN:          53 53 43 4E\n"
            RenameLabel.stringValue += "Replace XSCN:       58 53 43 4E\n"
        }
        RenameLabel.stringValue += "++++++++++++++++++++++++++++++++++++++"
    }
    
    func BreakCombine() {
        for BreakIndex in 0...3 {
            CRSInfo[CRSInfo.count - 1 - (total - (CheckConbLine + 7)) + BreakIndex] = ""
        }
    }
    
    func GenSPED() {
        if CPUChoice == 0 {
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
            
            let path:String = FolderPath + "/SSDT-I2C-SPED.dsl"
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
    
    func GenBlockI2C() {
        
    }
    
    //Handle for the dock icon click
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if flag {
            return false
        } else {
            window.makeKeyAndOrderFront(self)
            return true
        }
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        Next1.isEnabled = false
        Next2.isEnabled = false
        Next3.isEnabled = false
        Next4.isEnabled = false
        mainWindow.standardWindowButton(.zoomButton)?.isHidden = true
        mainWindow = NSApplication.shared.windows[0]
        
        /*
        let accessory = NSTextField(frame: NSRect(x: 0, y: 0, width: 50, height: 20))
        let font = NSFont.systemFont(ofSize: NSFont.systemFontSize)
        accessory.stringValue = "0x"
        accessory.isEditable = true
        accessory.drawsBackground = true
        */
        alert.accessoryView = InputAPICPin
        alert.messageText = "No native APIC found"
        alert.informativeText = "Failed to extract APIC Pin. Please input your APIC Pin in Hex, and start with \"0x\""
        alert.helpAnchor = "NSAlert"
        alert.showsHelp = true
        //alert.showsSuppressionButton = true
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK").isEnabled = false
        //alert.window.contentView?.addSubview(AlertView)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func verbose(text:String) {
        VerboseTextView.string += text
    }
    
    @IBAction func OpenVerbose(_ sender: Any) {
        VerboseWindow.setIsVisible(true)
    }
    
    @IBAction func OpenMacLog(_ sender: Any) {
        let t = Process()
        t.launchPath = Bundle.main.path(forResource: "maclog", ofType: nil)
        t.launch()
    }
    
    func controlTextDidChange(_ notification: Notification) {
        if DeviceName.stringValue.count > 4 {
            let index = DeviceName.stringValue.index(DeviceName.stringValue.startIndex, offsetBy: 4)
            DeviceName.stringValue = String(DeviceName.stringValue[..<index])
        }
    }
    
    func iasl(path:String) {
        let t = Process()
        t.launchPath = Bundle.main.path(forResource: "iasl", ofType: nil)
        t.arguments = [path]
        t.launch()
    }

}

extension String {
    //返回第一次出现的指定子字符串在此字符串中的索引
    //（如果backwards参数设置为true，则返回最后出现的位置）
    func positionOf(sub:String, backwards:Bool = false)->Int {
        var pos = -1
        if let range = range(of:sub, options: backwards ? .backwards : .literal ) {
            if !range.isEmpty {
                pos = self.distance(from:startIndex, to:range.lowerBound)
            }
        }
        return pos
    }
}

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
    @IBOutlet weak var DeviceName: NSTextField!
    @IBOutlet weak var Verbose: NSScrollView!
    @IBOutlet weak var InputAPICPin: NSView!
    @IBOutlet weak var APICPinText: NSTextField!
    @IBOutlet weak var Warning: NSTextField!
    @IBOutlet var VerboseTextView: NSTextView!
    @IBOutlet var RenameLabel: NSTextView!
    @IBOutlet weak var StateLabel: NSTextField!
    @IBOutlet weak var VersionLabel: NSTextField!
    @IBOutlet weak var IONameLabel: NSTextField!
    @IBOutlet weak var ModeLabel: NSTextField!
    @IBOutlet weak var PinLabel: NSTextField!
    @IBOutlet weak var DeviceNameLabel: NSTextField!
    @IBOutlet weak var CPUModelLabel: NSTextField!
    @IBOutlet weak var SatelliteLabel: NSTextField!
    @IBOutlet weak var SelectDeviceView: NSView!
    @IBOutlet weak var ScopeRadio0: NSButton!
    @IBOutlet weak var ScopeRadio1: NSButton!
    @IBOutlet weak var ScopeRadio2: NSButton!
    @IBOutlet weak var ScopeRadio3: NSButton!
    @IBOutlet weak var AMLPath: NSTextField!
    @IBOutlet weak var Decomplie: NSButton!
    @IBOutlet var DisassemblerVerbose: NSTextView!
    @IBOutlet weak var MainTab: NSTabView!
    @IBOutlet weak var Information: NSTabViewItem!
    @IBOutlet weak var GenSSDTTab: NSTabViewItem!
    @IBOutlet weak var Disassembler: NSTabViewItem!
    @IBOutlet weak var About: NSTabViewItem!
    @IBOutlet weak var Gen4ThisComputer: NSButton!
    @IBOutlet weak var IssueLabel: NSTextFieldCell!
    @IBOutlet weak var GenStep2: NSTabViewItem!
    @IBOutlet weak var GenStep4: NSTabViewItem!
    @IBOutlet weak var Diagnosis: NSTabViewItem!
    @IBOutlet weak var Indicator1: NSProgressIndicator!
    @IBOutlet weak var Indicator2: NSProgressIndicator!
    @IBOutlet weak var Indicator3: NSProgressIndicator!
    @IBOutlet weak var Indicator4: NSProgressIndicator!
    @IBOutlet weak var Indicator5: NSProgressIndicator!
    @IBOutlet weak var Indicator6: NSProgressIndicator!
    @IBOutlet weak var State1: NSImageView!
    @IBOutlet weak var State2: NSImageView!
    @IBOutlet weak var State3: NSImageView!
    @IBOutlet weak var State4: NSImageView!
    @IBOutlet weak var State5: NSImageView!
    @IBOutlet weak var State6: NSImageView!
    @IBOutlet var ErrorLabel: NSTextView!
    @IBOutlet weak var DiagnosisScrollView: NSScrollView!
    @IBOutlet weak var Version: NSTextField!
    
    let SelectDevice = NSAlert()
    
    
    @IBAction func InformationClick(_ sender: Any) {
        MainTab.selectTabViewItem(Information)
    }
    
    @IBAction func GenSSDTClick(_ sender: Any) {
        MainTab.selectTabViewItem(GenSSDTTab)
    }
    
    @IBAction func DiagnosisClick(_ sender: Any) {
        MainTab.selectTabViewItem(Diagnosis)
    }
    
    @IBAction func DisassemblerClick(_ sender: Any) {
        MainTab.selectTabViewItem(Disassembler)
    }
    
    @IBAction func PatchFor(_ sender: Any) {
        PatchChoice = (sender as! NSButton).tag
        if DSDTFile == "" {
            Next1.isEnabled = false
        } else {
            Next1.isEnabled = true
        }
    }
    
    @IBAction func SelectMode(_ sender: Any) {
        Choice = (sender as! NSButton).tag
        Next4.isEnabled = true
    }
    
    @IBAction func AboutClick(_ sender: Any) {
        MainTab.selectTabViewItem(About)
    }
    
    @IBAction func SelectDevice(_ sender: Any) {
        MultiTPADUSRSelect = (sender as! NSButton).tag
        scope = MultiScope[MultiTPADUSRSelect]
        SelectDevice.buttons[0].isEnabled = true
        verbose(text: "Choice : \((sender as! NSButton).tag)")
    }
    
    @IBAction func SelectCPU(_ sender: Any) {
        CPUChoice = (sender as! NSButton).tag
        Next3.isEnabled = true
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
                    Warning.stringValue = NSLocalizedString("APIC Pin should be between 0x18 and 0x77", comment: "")
                }
            } else {
                alert.buttons[0].isEnabled = false
            }
        } else {
            alert.buttons[0].isEnabled = false
        }
    }
    
    @IBAction func SelectDSDTButtom(_ sender: Any) {
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
                DSDTFile = String(pathStr[index1..<index2])
                self.DSDTPath.stringValue = DSDTFile
                self.verbose(text: "\(DSDTFile)\n")
                if PatchChoice != -1 {
                    self.Next1.isEnabled = true
                }
            }
        })
    }
    
    @IBAction func Next1(_ sender: Any) {
        if Gen4ThisComputer.state.rawValue == 0 {
            TabView.selectNextTabViewItem(Any?.self)
        } else {
            TPAD = NativeDeviceName
            Device = "Device (\(TPAD))"
            HexTPAD = Data(TPAD.utf8).map{String(format: "%02x", $0)}.joined()
            let CPUModel = CPUInfo.components(separatedBy: " ")[2].components(separatedBy: "-")[1]
            if CPUModel[CPUModel.index(CPUModel.startIndex, offsetBy: 0)] == "6" {
                CPUChoice = 0
            } else if CPUModel[CPUModel.index(CPUModel.startIndex, offsetBy: 0)] == "7" {
                CPUChoice = 1
            } else if CPUModel[CPUModel.index(CPUModel.startIndex, offsetBy: 0)] == "8" {
                if CPUModel.count == 5 {
                    if CPUModel[CPUModel.index(CPUModel.startIndex, offsetBy: 4)] == "H" {
                        CPUChoice = 1
                    } else if CPUModel[CPUModel.index(CPUModel.startIndex, offsetBy: 4)] == "U" {
                        CPUChoice = 2
                    } else {
                        IssueLabel.stringValue += "This CPU Model (\(CPUInfo)) is not supported\n"
                    }
                } else {
                    IssueLabel.stringValue += "This CPU Model (\(CPUInfo)) is not supported\n"
                }
            } else {
                IssueLabel.stringValue += "This CPU Model (\(CPUInfo)) is not supported\n"
            }
            Countline()
        }
    }
    
    @IBAction func Next2(_ sender: Any) {
        verbose(text: "\nDevice: \(TPAD)\n")
        HexTPAD = Data(TPAD.utf8).map{String(format: "%02x", $0)}.joined()
        verbose(text: "\(HexTPAD)\n")
        Countline()
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
                verbose(text: "Selection: Polling\n")
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
    
    func Countline() {
        ReadDSDT()
        if Matched == false{
            TabView.selectTabViewItem(GenStep2)
            verbose(text: "No Device Found\n")
            let noDevice = NSAlert()
            noDevice.messageText = NSLocalizedString("No Device Found", comment: "")
            noDevice.informativeText = NSLocalizedString("There is no ", comment: "") + TPAD + NSLocalizedString(" in your DSDT. Please input again or exit", comment: "")
            noDevice.alertStyle = .informational
            noDevice.addButton(withTitle: NSLocalizedString("Input again", comment: ""))
            noDevice.addButton(withTitle: NSLocalizedString("Exit", comment: ""))
            verbose(text: "Pop-up to ask if input again")
            noDevice.beginSheetModal(for: self.window, completionHandler: {response -> Void in
                if response.rawValue == 1001 {
                    self.verbose(text: "Exit")
                    exit(0)
                }
            })
        } else {
            if Gen4ThisComputer.state.rawValue == 1 {
                TabView.selectTabViewItem(GenStep4)
            } else {
                TabView.selectTabViewItem(at: 1)
            }
            preAnalysis()
        }
    }
    
    func preAnalysis() {
        verbose(text: "Start func : preAnalysis()")
        if MultiTPAD {
            var count:Int = 0
            for _ in 0..<MultiScope.count {
                if MultiScope[count] != "" {
                    if count == 0 {
                        ScopeRadio0.isHidden = false
                        ScopeRadio0.title = "I2C" + MultiScope[count]
                    } else if count == 1 {
                        ScopeRadio1.isHidden = false
                        ScopeRadio1.title = "I2C" + MultiScope[count]
                    } else if count == 2 {
                        ScopeRadio2.isHidden = false
                        ScopeRadio2.title = "I2C" + MultiScope[count]
                    } else if count == 3 {
                        ScopeRadio3.isHidden = false
                        ScopeRadio3.title = "I2C" + MultiScope[count]
                    }
                    count += 1
                }
            }
            SelectDevice.accessoryView = SelectDeviceView
            SelectDevice.informativeText = NSLocalizedString("Multiple ", comment: "") + TPAD + NSLocalizedString(" found in the DSDT\nWhich Path is the Correct one?", comment: "")
            SelectDevice.alertStyle = .informational
            SelectDevice.addButton(withTitle: NSLocalizedString("OK", comment: ""))
            verbose(text: "Pop-up to ask which is the correct device path")
            SelectDevice.beginSheetModal(for: self.window, completionHandler: {respose -> Void in
                Analysis()
                self.TabView.selectNextTabViewItem(Any?.self)
            })
        } else {
            Analysis()
            TabView.selectNextTabViewItem(Any?.self)
        }
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
        t.arguments = ["-b", "-F", "voodoo"]
        t.launch()
    }
    
    func controlTextDidChange(_ notification: Notification) {
        if DeviceName.stringValue.count < 4 {
            Next2.isEnabled = false
        } else if DeviceName.stringValue.count == 4 {
            TPAD = DeviceName.stringValue
            Device = "Device (\(TPAD))"
            Next2.isEnabled = true
        }
        if DeviceName.stringValue.count > 4 {
            let index = DeviceName.stringValue.index(DeviceName.stringValue.startIndex, offsetBy: 4)
            DeviceName.stringValue = String(DeviceName.stringValue[..<index])
        }
        if APICPinText.stringValue.count < 4 {
            alert.buttons[0].isEnabled = false
        } else if APICPinText.stringValue.count == 4 {
            let index = APICPinText.stringValue.index(APICPinText.stringValue.startIndex, offsetBy: 2)
            if String(APICPinText.stringValue[..<index]) == "0x" && APICPinText.stringValue.count == 4  {
                if Int(strtoul(APICPinText.stringValue, nil, 16)) >= 24 && Int(strtoul(APICPinText.stringValue, nil, 16)) <= 119 {
                    alert.buttons[0].isEnabled = true
                    Warning.stringValue = ""
                    APICPin = APICPinText.stringValue
                    APICPIN = Int(strtoul(APICPin, nil, 16))
                    verbose(text: "APIC Pin you input is \(APICPin)\n")
                } else {
                    Warning.stringValue = NSLocalizedString("APIC Pin should be between 0x18 and 0x77", comment: "")
                }
            }
        } else if APICPinText.stringValue.count > 4 {
            APICPinText.stringValue = String(APICPinText.stringValue[..<APICPinText.stringValue.index(APICPinText.stringValue.startIndex, offsetBy: 4)])
        }
        if APICPinText.stringValue.count >= 2 {
            if String(APICPinText.stringValue[..<APICPinText.stringValue.index(APICPinText.stringValue.startIndex,offsetBy: 2)]) != "0x" {
                APICPinText.stringValue = "0x"
            }
        } else {
            APICPinText.stringValue = "0x"
        }
    }
    
    @IBAction func SaveLog(_ sender: Any) {
        let a = Process()
        let pipe = Pipe()
        a.standardOutput = pipe
        a.launchPath = "/usr/bin/who"
        a.launch()
        a.waitUntilExit()
        let outdata = pipe.fileHandleForReading.availableData
        let outputString = String(data: outdata, encoding: String.Encoding.utf8)!
        let timeline = outputString.components(separatedBy: "\n")[0]
        let month = timeline.components(separatedBy: " ").filter{$0 != ""}[2]//time.components(separatedBy: " ")[0]
        let date = Date()
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy"
        let year = dateFormat.string(from: date)
        var month_num:String = ""
        switch month {
        case "Jan":
            month_num = "1"
        case "Feb":
            month_num = "2"
        case "Mar":
            month_num = "3"
        case "Apr":
            month_num = "4"
        case "May":
            month_num = "5"
        case "Jun":
            month_num = "6"
        case "Jul":
            month_num = "7"
        case "Aug":
            month_num = "8"
        case "Sept":
            month_num = "9"
        case "Oct":
            month_num = "10"
        case "Nov":
            month_num = "11"
        case "Dec":
            month_num = "12"
        default:
            print("default")
        }
        var curDate:String = ""
        curDate = "\(year)-\(month_num)-\(timeline.components(separatedBy: " ").filter{$0 != ""}[3]) \(timeline.components(separatedBy: " ").filter{$0 != ""}[4]):00"
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        var dateDate = dateFormatter.date(from: curDate)!
        dateDate = dateDate - 60
        curDate = dateFormatter.string(from: dateDate)
        let b = Process()
        let pipe1 = Pipe()
        b.standardOutput = pipe1
        b.launchPath = "/usr/bin/log"
        b.arguments = ["show", "--predicate", "(eventMessage CONTAINS[c] \"VoodooI2C\") || (eventMessage CONTAINS[c] \"VoodooGPIO\")", "--last", "boot"]// "--start", "\(curDate)"]
        b.launch()
        b.waitUntilExit()
        var data:Data
        data = pipe1.fileHandleForReading.readDataToEndOfFile()
        let Log = String(data: data, encoding: String.Encoding.utf8)!
        
        let path = FolderPath + "/GenI2C.log"
        try! FileManager.default.createDirectory(atPath: FolderPath, withIntermediateDirectories: true, attributes: nil)
        if FileManager.default.fileExists(atPath: path) {
            try! FileManager.default.removeItem(atPath: path)
            FileManager.default.createFile(atPath: path, contents: nil, attributes: nil)
        } else {
            FileManager.default.createFile(atPath: path, contents: nil, attributes: nil)
        }
        try! Log.write(toFile: path, atomically: true, encoding: String.Encoding.utf8)
        NSWorkspace.shared.selectFile(path, inFileViewerRootedAtPath: FolderPath)
    }
    
    @IBAction func SelectAMLPath(_ sender: Any) {
        let openPanel:NSOpenPanel = NSOpenPanel()
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        openPanel.allowsMultipleSelection = false
        openPanel.beginSheetModal(for: mainWindow, completionHandler: {result in
            if (result == NSApplication.ModalResponse.OK)
            {
                let path:NSURL = openPanel.urls[0] as NSURL
                openPanel.close()
                let pathStr = path.absoluteString!.removingPercentEncoding!
                let index1 = pathStr.index(pathStr.startIndex, offsetBy: 7)
                let index2 = pathStr.index(pathStr.startIndex, offsetBy: pathStr.count)
                DSDTFile = String(pathStr[index1..<index2])
                self.AMLPath.stringValue = DSDTFile
                self.Decomplie.isEnabled = true
            }
        })
    }
    
    @IBAction func Disassemble(_ sender: Any) {
        let Disassemble = Process()
        let DisassemblePipe = Pipe()
        Disassemble.standardOutput = DisassemblePipe
        Disassemble.launchPath = Bundle.main.path(forResource: "iasl", ofType: nil)
        Disassemble.arguments = ["-d"]
        for file in try! FileManager.default.contentsOfDirectory(atPath: AMLPath.stringValue) {
            if file == "DSDT.aml" || (file.contains("SSDT-") && file.contains(".aml")) {
                Disassemble.arguments?.append(AMLPath.stringValue + file)
            }
        }
        Disassemble.launch()
        Disassemble.waitUntilExit()
        if FileManager.default.fileExists(atPath: AMLPath.stringValue + "DSDT.dsl") && (Int((try! FileManager.default.attributesOfItem(atPath: AMLPath.stringValue + "DSDT.aml") as NSDictionary).fileSize()) > 128){
            
        } else {
            Disassemble.arguments = ["-d", "-da"]
            for file in try! FileManager.default.contentsOfDirectory(atPath: AMLPath.stringValue) {
                if file == "DSDT.aml" || (file.contains("SSDT-") && file.contains(".aml")) {
                    Disassemble.arguments?.append(AMLPath.stringValue + file)
                }
            }
            Disassemble.launch()
        }
        if FileManager.default.fileExists(atPath: AMLPath.stringValue + "DSDT.dsl") && (Int((try! FileManager.default.attributesOfItem(atPath: AMLPath.stringValue + "DSDT.aml") as NSDictionary).fileSize()) > 128) {
            Pop_up(messageText: "Success!", informativeText: "")
        } else {
            Pop_up(messageText: "Failed!", informativeText: "")
        }
        let DisassembleData = DisassemblePipe.fileHandleForReading.readDataToEndOfFile()
        let DisassembleString = String(data: DisassembleData, encoding: String.Encoding.utf8)!
        DisassemblerVerbose.string = DisassembleString
        NSWorkspace.shared.selectFile(AMLPath.stringValue + "DSDT.dsl", inFileViewerRootedAtPath: AMLPath.stringValue)
    }
    
    @IBAction func Diagnosis(_ sender: Any) {
        State1.isHidden = true
        State2.isHidden = true
        State3.isHidden = true
        State4.isHidden = true
        State5.isHidden = true
        State6.isHidden = true
        Indicator1.startAnimation(self)
        Indicator2.startAnimation(self)
        Indicator3.startAnimation(self)
        Indicator4.startAnimation(self)
        Indicator5.startAnimation(self)
        Indicator6.startAnimation(self)
        
        if DiagnosisCPU() {
            Indicator1.stopAnimation(self)
            State1.isHidden = false
        } else {
            Indicator1.stopAnimation(self)
            State1.isHidden = false
            State1.image = NSImage.init(named: "NSStatusUnavailable")
        }
        if DiagnosisAppleIntel().0 {
            Indicator2.stopAnimation(self)
            State2.isHidden = false
            State2.image = NSImage.init(named: "NSStatusUnavailable")
        } else {
            Indicator2.stopAnimation(self)
            State2.isHidden = false
        }
        if DiagnosisAppleIntel().1 {
            Indicator3.stopAnimation(self)
            State3.isHidden = false
            State3.image = NSImage.init(named: "NSStatusUnavailable")
        } else {
            Indicator3.stopAnimation(self)
            State3.isHidden = false
        }
        if DiagnosisVoodooI2C() {
            Indicator4.stopAnimation(self)
            State4.isHidden = false
        } else {
            Indicator4.stopAnimation(self)
            State4.isHidden = false
            State4.image = NSImage.init(named: "NSStatusUnavailable")
        }
        if DiagnosisMT2() {
            Indicator5.stopAnimation(self)
            State5.isHidden = false
        } else {
            Indicator5.stopAnimation(self)
            State5.isHidden = false
            State5.image = NSImage.init(named: "NSStatusUnavailable")
        }
        var haveError:Bool = false, haveWarning:Bool = false
        var Errors = [String]()
        let queue = DispatchQueue.init(label: "queue")
        queue.async {
            (haveError, haveWarning, Errors) = DiagnosisLog()
            if haveError {
                DispatchQueue.main.async {
                    self.Indicator6.stopAnimation(self)
                    self.State6.isHidden = false
                    self.State6.image = NSImage.init(named: "NSStatusUnavailable")
                    for error in Errors {
                        self.ErrorLabel.string += error + "\n"
                    }
                }
            } else if haveWarning && !haveError {
                DispatchQueue.main.async {
                    self.DiagnosisScrollView.isHidden = false
                    self.Indicator6.stopAnimation(self)
                    self.State6.isHidden = false
                    for error in Errors {
                        self.ErrorLabel.string += error + "\n"
                    }
                    self.State6.image = NSImage.init(named: "NSStatusPartiallyAvailable")
                }
            } else {
                DispatchQueue.main.async {
                    self.Indicator6.stopAnimation(self)
                    self.State6.isHidden = false
                }
            }
        }
    }
    
    @IBAction func Feedback(_ sender: Any) {
        Pop_up(messageText: NSLocalizedString("Report your bug", comment: ""), informativeText: NSLocalizedString("Please open a new issue on Github", comment: ""))
        NSWorkspace.shared.open(URL(string: "https://github.com/williambj1/GenI2C/issues")!)
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        VerboseTextView.string = ""
        let infoDictionary = Bundle.main.infoDictionary!
        let minorVersion = infoDictionary["CFBundleShortVersionString"]!//版本号（内部标示） let appVersion = minorVersion as! String
        Version.stringValue = "Version \(minorVersion)"
        
        mainWindow.standardWindowButton(.zoomButton)?.isHidden = true
        mainWindow = NSApplication.shared.windows[0]
        
        GetInfo()
        CPUModelLabel.stringValue += CPUInfo
        SatelliteLabel.stringValue += SatelliteName
        if isVooLoaded {
            StateLabel.stringValue += NSLocalizedString("Loaded", comment: "")
        } else {
            Gen4ThisComputer.isEnabled = false
            IssueLabel.stringValue += "VoodooI2C is not loaded\n"
            StateLabel.stringValue += NSLocalizedString("Not Loaded", comment: "")
            VersionLabel.stringValue += NSLocalizedString("nil", comment: "")
            DeviceNameLabel.stringValue += NSLocalizedString("nil", comment: "")
            IONameLabel.stringValue +=  NSLocalizedString("nil", comment: "")
            ModeLabel.stringValue += NSLocalizedString("nil", comment: "")
            PinLabel.stringValue +=  "Pin : " + NSLocalizedString("nil", comment: "")
            SatelliteLabel.stringValue += NSLocalizedString("nil", comment: "")
        }
        if isNameFound {
            Gen4ThisComputer.isEnabled = true
            DeviceNameLabel.stringValue += NativeDeviceName
        } else {
            Gen4ThisComputer.isEnabled = false
            IssueLabel.stringValue += "Native device name not found\n"
        }
        VersionLabel.stringValue += VoodooI2CVersion
        if isNativeIONameFound {
            IONameLabel.stringValue += NativeIOName
        }
        PinLabel.stringValue += PinText
        ModeLabel.stringValue += Mode

        alert.accessoryView = InputAPICPin
        alert.messageText = NSLocalizedString("No native APIC found", comment: "")
        alert.informativeText = NSLocalizedString("Failed to extract APIC Pin. Please input your APIC Pin in Hex, and start with \"0x\"", comment: "")
        alert.helpAnchor = "NSAlert"
        alert.showsHelp = true
        //alert.showsSuppressionButton = true
        alert.alertStyle = .informational
        alert.addButton(withTitle: NSLocalizedString("OK", comment: "")).isEnabled = false
    }
    
    func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        DSDTFile = filename
        DSDTPath.stringValue = DSDTFile
        verbose(text: "\(DSDTFile)\n")
        MainTab.selectTabViewItem(GenSSDTTab)
        if PatchChoice != -1 {
            Next1.isEnabled = true
        }
        return true
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
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    @IBAction func Github(_ sender: Any) {
        NSWorkspace.shared.open(URL(string: "https://github.com/williambj1/GenI2C")!)
    }
    @IBAction func VoodooI2C(_ sender: Any) {
        NSWorkspace.shared.open(URL(string: "https://github.com/alexandred/VoodooI2C")!)
    }
    @IBAction func Guide(_ sender: Any) {
        //NSWorkspace.shared.open(URL(string: "https://github.com/alexandred/VoodooI2C")!)
    }
    @IBAction func Donate(_ sender: Any) {
        NSWorkspace.shared.open(URL(string: "https://github.com/williambj1/GenI2C#donation")!)
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

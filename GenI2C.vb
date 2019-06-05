Imports System.IO
Imports System.Text
Module GenI2C

    Public TPAD, Device, DSDTFile, Paranthesesopen, Paranthesesclose, DSDTLine, Scope, Spacing, APICNAME, SLAVName, GPIONAME, HexTPAD, CPUChoice, BlockBus, HexBlockBus, BlockSSDT(15), GPI0SSDT(15), IfLLess, IfLEqual As String
    Dim Code(), CRSInfo(), ManualGPIO(8), ManualAPIC(6), ManualSPED(1) As String
    Public Matched, CRSPatched, ExUSTP, ExSSCN, ExFMCN, ExAPIC, ExSLAV, ExGPIO, CatchSpacing, APICNameLineFound, SLAVNameLineFound, GPIONameLineFound, InterruptEnabled, PollingEnabled, Hetero, BlockI2C, ExI2CM As Boolean
    Public line, i, n, total, APICPinLine, GPIOPinLine, ScopeLine, APICPIN, GPIOPIN, GPIOPIN2, GPIOPIN3, APICNameLine, SLAVNameLine, GPIONAMELine, CRSMethodLine, CRSInfoLine, CheckCombLine, CheckSLAVLocation As Integer

    Sub Main()
        Try
            Console.WriteLine()
            Console.WriteLine("         _              _            _              _        _                _      ")
            Console.WriteLine("        /\ \           /\ \         /\ \     _     /\ \    /\ \             /\ \     ")
            Console.WriteLine("       /  \ \         /  \ \       /  \ \   /\_\   \ \ \  /  \ \           /  \ \    ")
            Console.WriteLine("      / /\ \_\       / /\ \ \     / /\ \ \_/ / /   /\ \_\/ /\ \ \         / /\ \ \   ")
            Console.WriteLine("     / / /\/_/      / / /\ \_\   / / /\ \___/ /   / /\/_/\/_/\ \ \       / / /\ \ \  ")
            Console.WriteLine("    / / / ______   / /_/_ \/_/  / / /  \/____/   / / /       / / /      / / /  \ \_\ ")
            Console.WriteLine("   / / / /\_____\ / /____/\    / / /    / / /   / / /       / / /      / / /    \/_/ ")
            Console.WriteLine("  / / /  \/____ // /\____\/   / / /    / / /   / / /       / / /  _   / / /          ")
            Console.WriteLine(" / / /_____/ / // / /______  / / /    / / /___/ / /__     / / /_/\_\ / / /________   ")
            Console.WriteLine("/ / /______\/ // / /_______\/ / /    / / //\__\/_/___\   / /_____/ // / /_________\  ")
            Console.WriteLine("\/___________/ \/__________/\/_/     \/_/ \/_________/   \________/ \/____________/  ")
            'http://patorjk.com Impossible
            Console.WriteLine()
            While True
                Console.Write("File Path (Drag and Drop the dsl file into the Form) : ")
                DSDTFile = Console.ReadLine()
                Try
                    If Dir(DSDTFile) <> "" Then
                        If InStr(Dir(DSDTFile), ".dsl") > 0 Then
                            Exit While
                        ElseIf InStr(Dir(DSDTFile), ".aml") > 0 Then
                            Console.WriteLine("AML files aren't supported! Please input again!")
                            Console.WriteLine()
                        Else
                            Console.WriteLine("Unknown File! Please input again!")
                            Console.WriteLine()
                        End If
                    Else
                        Console.WriteLine("File doesn't exist, please input again!")
                        Console.WriteLine()
                    End If
                Catch ex As Exception
                    Console.WriteLine("Illegal Characters exists, please input again!")
                    Console.WriteLine()
                End Try
            End While
            Console.WriteLine("")
            Console.WriteLine("Search for a Device")
            While True
                Console.WriteLine()
                Console.Write("Device: ")
                TPAD = Console.ReadLine()
                If Len(TPAD) = 4 Then
                    Exit While
                Else
                    Console.WriteLine()
                    Console.WriteLine("Please Input your device name correctly (e.g. " & Chr(34) & "TPD0" & Chr(34) & ")!")
                End If
            End While
            Device = "Device (" & TPAD & ")"
            For GenIndex = 0 To 3
                HexTPAD += Hex(Asc(TPAD.Substring(GenIndex, 1))) + " "
            Next GenIndex
            Countline()
        Catch ex As Exception
            Console.WriteLine()
            Console.WriteLine("Unknown error (main), please open an issue and provide your files")
            Console.WriteLine("Exiting")
            Console.ReadLine()
            End
        End Try
    End Sub

    Sub Countline()
        Try
            FileOpen(1, DSDTFile, OpenMode.Input, OpenAccess.Read)
            While Not EOF(1)
                DSDTLine = LineInput(1)
                line = line + 1
                If InStr(DSDTLine, "If (USTP)") > 0 Then
                    Console.WriteLine("Found for USTP in DSDT at line " & line + 1)
                    ExUSTP = True
                End If
                If InStr(DSDTLine, "SSCN") > 0 Then
                    Console.WriteLine("Found for SSCN in DSDT at line " & line + 1)
                    ExSSCN = True
                End If
                If InStr(DSDTLine, "FMCN") > 0 Then
                    Console.WriteLine("Found for FMCN in DSDT at line " & line + 1)
                    ExFMCN = True
                End If
                If InStr(DSDTLine, Device) > 0 Then
                    Dim spaceopen, spaceclose, startline As Integer
                    startline = line
                    Paranthesesopen = LineInput(1)
                    line = line + 1
                    spaceopen = InStr(Paranthesesopen, "{")
                    Do
                        Paranthesesclose = LineInput(1)
                        spaceclose = InStr(Paranthesesclose, "}")
                        line = line + 1
                    Loop Until spaceclose = spaceopen
                    If total = 0 Then
                        total = total + (line - startline)
                    Else
                        total = total + (line - startline) + 1
                    End If
                    Matched = True
                End If
            End While
            FileClose()
            If Matched = False Then
                Console.WriteLine()
                Console.WriteLine("This is not a Device that exists in the DSDT")
                Console.WriteLine("Exiting")
                Console.ReadLine()
                End
            Else
                Console.WriteLine()
                Analysis()
            End If
        Catch ex As Exception
            Console.WriteLine()
        Console.WriteLine("Unknown error (CL), please open an issue and provide your files")
        Console.WriteLine("Exiting")
        Console.ReadLine()
        End
        End Try
    End Sub

    Sub Analysis()
        Try
            ReDim Code(total)
            FileOpen(1, DSDTFile, OpenMode.Input, OpenAccess.Read)
            While Not EOF(1)
                DSDTLine = LineInput(1)
                If InStr(DSDTLine, Device) > 0 Then
                    Dim spaceopen, spaceclose As Integer
                    Code(i) = DSDTLine
                    i = i + 1
                    Paranthesesopen = LineInput(1)
                    Code(i) = Paranthesesopen
                    i = i + 1
                    spaceopen = InStr(Paranthesesopen, "{")
                    Do
                        Paranthesesclose = LineInput(1)
                        spaceclose = InStr(Paranthesesclose, "}")
                        Code(i) = Paranthesesclose
                        i = i + 1
                    Loop Until spaceclose = spaceopen
                End If
            End While
            FileClose()

            For i = 0 To total
                If InStr(Code(i), "Method (_CRS,") > 0 Then
                    n = total - i
                    ReDim CRSInfo(n)
                    n = 0
                    For CRSInfoLine = i To total - 1
                        CRSInfo(n) = Code(CRSInfoLine)
                        n = n + 1
                    Next
                End If
                If InStr(Code(i), "GpioInt") > 0 Then
                    If ExGPIO = True Then
                        ExGPIO = False
                        GPIONameLineFound = False
                    End If
                    Console.WriteLine("Native GpioInt Found in " & TPAD & " at line " & i + 1)
                    ExGPIO = True
                    GPIONAMELine = i
                    For GPIONAMELine = GPIONAMELine To 1 Step -1
                        If InStr(Code(GPIONAMELine), "Name (SBF") > 0 And GPIONameLineFound = False Then
                            GPIONAME = Code(GPIONAMELine).Substring((InStr(Code(GPIONAMELine), "SBF") - 1), 4)
                            GPIONameLineFound = True
                        End If
                    Next
                    GPIOPinLine = i + 4
                    GPIOPIN = Convert.ToInt32(Code(GPIOPinLine).Substring(InStr(Code(GPIOPinLine), "0x") - 1), 16)
                    Console.WriteLine("GPIO Pin " & GPIOPIN & " (0x" & Hex(GPIOPIN) & ")")
                End If
                If InStr(Code(i), "Interrupt (ResourceConsumer") > 0 Then
                    If ExAPIC = True Then APICNameLineFound = False
                    Console.WriteLine("Native APIC Found in " & TPAD & " at line " & i + 1)
                    ExAPIC = True
                    APICNameLine = i
                    For APICNameLine = APICNameLine To 1 Step -1
                        If InStr(Code(APICNameLine), "Name (SBF") > 0 And APICNameLineFound = False Then
                            APICNAME = Code(APICNameLine).Substring((InStr(Code(APICNameLine), "SBF") - 1), 4)
                            APICNameLineFound = True
                        End If
                    Next
                    APICPinLine = i + 2
                    APICPIN = Convert.ToInt32(Code(APICPinLine).Substring(InStr(Code(APICPinLine), "0x") - 1, 10), 16)
                    Console.WriteLine("APIC Pin " & APICPIN & " (0x" & Hex(APICPIN) & ")")
                End If
                If InStr(Code(i), "I2cSerialBusV2 (0x") > 0 Then
                    If ExSLAV = True Then SLAVNameLineFound = False
                    Console.WriteLine("Slave Address Found in " & TPAD & " at line " & i + 1)
                    ExSLAV = True
                    SLAVNameLine = i
                    For SLAVNameLine = SLAVNameLine To 1 Step -1
                        If InStr(Code(SLAVNameLine), "Name (SBF") > 0 And SLAVNameLineFound = False Then
                            SLAVName = Code(SLAVNameLine).Substring((InStr(Code(SLAVNameLine), "SBF") - 1), 4)
                            SLAVNameLineFound = True
                            CheckCombLine = SLAVNameLine
                            CheckSLAVLocation = SLAVNameLine
                        End If
                    Next
                    ScopeLine = i + 1
                    Scope = Code(ScopeLine).Substring((InStr(Code(ScopeLine), (Chr(34) & ",")) - 2), 1)
                End If
                If InStr(Code(i), "Name (") > 0 And CatchSpacing = False Then
                    Spacing = Code(i).Substring(0, InStr(Code(i), "Name (") - 1)
                    CatchSpacing = True
                End If
                If SLAVNameLineFound = True And APICNameLineFound = True And SLAVName = APICNAME And Hetero = False Then
                    Hetero = True
                    BreakCombine()
                End If
            Next

            For CRSLine = 0 To n
                If InStr(CRSInfo(CRSLine), "If (LLess (") > 0 Then
                    IfLLess = CRSInfo(CRSLine).Substring((InStr(CRSInfo(CRSLine), "If (LLess (") + 10), 4)
                End If
                If InStr(CRSInfo(CRSLine), "If (LEqual (") > 0 Then
                    IfLEqual = CRSInfo(CRSLine).Substring((InStr(CRSInfo(CRSLine), "If (LEqual (") + 11), 4)
                End If
                If InStr(CRSInfo(CRSLine), "I2CM (I2CX, BADR, SPED)") > 0 Then
                    ExI2CM = True
                End If
            Next

            If SLAVNameLineFound = False Then
                Console.WriteLine()
                Console.WriteLine("This is not a I2C Trackpad!")
                Console.WriteLine("Exiting")
                Console.ReadLine()
                End
            End If

            While CPUChoice < 1 Or CPUChoice > 3
                Console.WriteLine()
                Console.WriteLine("Select your CPU architecture:")
                Console.WriteLine()
                Console.WriteLine("1) Sunrise Point:  SKL, KBL, KBL-R")
                Console.WriteLine("2) Cannon Lake (Point)-H:  CFL-H (8750H, 8300H)")
                Console.WriteLine("3) Cannon Lake (Point)-LP: CFL-R (8565U, 8265U)")
                Console.WriteLine()
                Console.Write("Your Choice: ")
                CPUChoice = Console.ReadLine()
            End While

            Console.WriteLine()
            Console.WriteLine("Choose the mode you'd like to patch")
            Console.WriteLine()
            Console.WriteLine("1) Interrupt (APIC or GPIO)")
            Console.WriteLine("2) Polling (Will be set back to APIC if supported)")
            Console.WriteLine("3) Block an I2C Bus")
            Console.WriteLine()
            Console.Write("Selection: ")
            Dim Choice As Integer = Console.ReadLine()
            Select Case Choice
                Case 1
                    InterruptEnabled = True
                    Console.WriteLine()
                Case 2
                    PollingEnabled = True
                    Console.WriteLine()
                Case 3
                    Console.WriteLine()
                    Console.WriteLine("Which I2C Bus you'd like to block?")
                    Console.WriteLine()
                    Console.WriteLine("1) I2C0")
                    Console.WriteLine("2) I2C1")
                    Console.WriteLine("3) I2C2")
                    Console.WriteLine("4) I2C3")
                    Console.WriteLine()
                    Console.Write("Selection: ")
                    Choice = Console.ReadLine()
                    Select Case Choice
                        Case 1
                            BlockBus = "I2C0"
                        Case 2
                            BlockBus = "I2C1"
                        Case 3
                            BlockBus = "I2C2"
                        Case 4
                            BlockBus = "I2C3"
                    End Select
                    GenBlockI2C()
                    BlockI2C = True
                Case Else
                    Console.WriteLine()
                    Console.WriteLine("Undefined Behaviour, Exiting")
                    Console.ReadLine()
                    End
            End Select

            If ExAPIC = True And 24 <= APICPIN And APICPIN <= 47 Then '<= 0x2F Group A & E
                Console.WriteLine("APIC Pin value < 2F, Native APIC Supported, using instead")
                If Hetero = True Then APICNAME = "SBFX"
                PatchCRS2APIC()
            ElseIf ExAPIC = False And ExGPIO = True Then
                If InterruptEnabled = True Then
                    PatchCRS2GPIO()
                End If
                If PollingEnabled = True Then
                    APICPIN = 63
                    APICNAME = "SBFX"
                    PatchCRS2APIC()
                End If
            ElseIf ExAPIC = True And (APICPIN > 47 Or APICPIN = 0) Then
                If InterruptEnabled = True Then
                    If ExGPIO = False Then
                        If APICPIN = 0 Then
                            Console.WriteLine("Failed to extract APIC Pin, filled by system start up. Please input your APIC Pin in Hex")
                            Console.Write("APIC Pin: ")
                            APICPIN = Convert.ToInt32(Console.ReadLine(), 16)
                            While APICPIN < 24 Or APICPIN > 119
                                Console.WriteLine()
                                Console.WriteLine("APIC Pin out of range!")
                                Console.WriteLine("Select your choice:")
                                Console.WriteLine("1) Input again")
                                Console.WriteLine("2) Exit")
                                Console.WriteLine()
                                Console.Write("Your Choice: ")
                                If Console.ReadLine() = 1 Then
                                    Console.Write("APIC Pin: ")
                                    APICPIN = Convert.ToInt32(Console.ReadLine(), 16)
                                ElseIf Console.ReadLine() = 2 Then
                                    Console.WriteLine("Exiting")
                                    Console.ReadLine()
                                    End
                                Else
                                    Console.WriteLine("Unknown Behaviour, Exiting")
                                    Console.ReadLine()
                                    End
                                End If
                            End While
                            If APICPIN >= 24 And APICPIN <= 47 Then
                                Console.WriteLine("APIC Pin value < 2F, Native APIC Supported, using instead")
                                If Hetero = True Then APICNAME = "SBFX"
                                PatchCRS2APIC()
                            Else
                                GPIONAME = "SBFZ"
                                APIC2GPIO()
                                PatchCRS2GPIO()
                            End If
                        ElseIf APICPIN > 47 Then
                            Console.WriteLine("No native GpioInt found, Generating instead")
                            GPIONAME = "SBFZ"
                            APIC2GPIO()
                            PatchCRS2GPIO()
                        End If
                    ElseIf ExGPIO = True Then
                        PatchCRS2GPIO()
                    End If
                ElseIf PollingEnabled = True Then
                    If Hetero = True Then
                        APICNAME = "SBFX"
                        APICPIN = 63
                    End If
                    If APICPIN = 0 Then Console.WriteLine("APIC Pin size uncertain, could be either APIC or polling")
                    PatchCRS2APIC()
                End If
            ElseIf ExAPIC = False And ExGPIO = False And ExSLAV = True Then ' I don't think this situation exists
                If InterruptEnabled = True Then
                    Console.WriteLine("No native APIC found, failed to extract APIC Pin. Please input your APIC Pin in Hex")
                    Console.Write("APIC Pin: ")
                    APICPIN = Convert.ToInt32(Console.ReadLine(), 16)
                    While APICPIN < 24 Or APICPIN > 119
                        Console.WriteLine()
                        Console.WriteLine("APIC Pin out of range!")
                        Console.WriteLine("Select your choice:")
                        Console.WriteLine("1) Input again")
                        Console.WriteLine("2) Exit")
                        Console.WriteLine()
                        Console.Write("Your Choice: ")
                        If Console.ReadLine() = 1 Then
                            Console.Write("APIC Pin: ")
                            APICPIN = Convert.ToInt32(Console.ReadLine(), 16)
                        Else
                            Console.WriteLine("Undefined Behaviour, Exiting")
                            Console.ReadLine()
                            End
                        End If
                    End While
                    If APICPIN >= 24 And APICPIN <= 47 Then
                        Console.WriteLine("APIC Pin value < 2F, Native APIC Supported, No _CRS Patch required")
                    Else
                        GPIONAME = "SBFZ"
                        APIC2GPIO()
                        PatchCRS2GPIO()
                    End If
                ElseIf PollingEnabled = True Then
                    APICNAME = "SBFX"
                    APICPIN = 63
                    PatchCRS2APIC()
                End If
            Else
                Console.WriteLine("Undefined Situation")
                Console.ReadLine()
                End
            End If
            GenSSDT()
        Catch ex As Exception
            Console.WriteLine()
        Console.WriteLine("Unknown error (AL), please open an issue and provide your files")
        Console.WriteLine("Exiting")
        Console.ReadLine()
        End
        End Try
    End Sub

    Sub PatchCRS2GPIO()
        Try
            For CRSLine = 0 To n
                If InStr(CRSInfo(CRSLine), "Return (ConcatenateResTemplate") > 0 Then
                    CRSInfo(CRSLine) = CRSInfo(CRSLine).Substring(0, InStr(CRSInfo(CRSLine), ", SBF") - 1) & ", " & GPIONAME & "))"
                    CRSPatched = True
                ElseIf InStr(CRSInfo(CRSLine), "Return (SBF") > 0 Then
                    ' Capture “Spaces & 'Return'” inject "ConcatenateResTemplate", add original return method name, add GpioInt Name                       
                    CRSInfo(CRSLine) = CRSInfo(CRSLine).Substring(0, InStr(CRSInfo(CRSLine), "(") - 1) & "(ConcatenateResTemplate (" & SLAVName & ", " & GPIONAME & ")) // Usually this return won't function, please check your Windows Patch"
                    CRSPatched = True
                End If
            Next
            If CRSPatched = False Then Console.WriteLine("Error! No _CRS Patch Applied!")
        Catch ex As Exception
            Console.WriteLine()
            Console.WriteLine("Unknown error (P2G), please open an issue and provide your files")
            Console.WriteLine("Exiting")
            Console.ReadLine()
            End
        End Try
    End Sub

    Sub PatchCRS2APIC()
        Try
            For CRSLine = 0 To n
                If InStr(CRSInfo(CRSLine), "Return (ConcatenateResTemplate") > 0 Then
                    CRSInfo(CRSLine) = CRSInfo(CRSLine).Substring(0, InStr(CRSInfo(CRSLine), ", SBF") - 1) & ", " & APICNAME & "))"
                    CRSPatched = True
                ElseIf InStr(CRSInfo(CRSLine), "Return (SBF") > 0 Then
                    ' Capture “Spaces & 'Return'” inject "ConcatenateResTemplate", add original return method name, add APIC Name
                    CRSInfo(CRSLine) = CRSInfo(CRSLine).Substring(0, InStr(CRSInfo(CRSLine), "(") - 1) & "(ConcatenateResTemplate (" & SLAVName & ", " & APICNAME & ")) // Usually this return won't function, please check your Windows Patch"
                    CRSPatched = True
                End If
            Next
            If CRSPatched = False Then Console.WriteLine("Error! No _CRS Patch Applied!")
        Catch ex As Exception
            Console.WriteLine()
            Console.WriteLine("Unknown error (P2A), please open an issue and provide your files")
            Console.WriteLine("Exiting")
            Console.ReadLine()
            End
        End Try
    End Sub

    Sub APIC2GPIO()
        Try
            If APICPIN >= 24 And APICPIN <= 47 Then           '< 0x2F Group A & E (& I)
                Console.WriteLine("APIC Pin value < 2F, Native APIC Supported, Generation Cancelled")
            Else
                Select Case CPUChoice
                    Case 1
                        If APICPIN > 47 And APICPIN <= 79 Then      '0x30 Group B & F
                            GPIOPIN = APICPIN - 24   'B
                            GPIOPIN2 = APICPIN + 72  'F
                        ElseIf APICPIN > 79 And APICPIN <= 119 Then '0x50 Group C & D & G
                            GPIOPIN = APICPIN - 24
                        End If

                    Case 2
                        If APICPIN > 47 And APICPIN <= 71 Then      '0x30 Group B & F & J
                            GPIOPIN = APICPIN - 16   'B
                            GPIOPIN2 = APICPIN + 240 'F
                            If APICPIN > 47 And APICPIN <= 59 Then GPIOPIN3 = APICPIN + 304  'J
                        ElseIf APICPIN > 71 And APICPIN <= 95 Then  '0x48 Group C & H & K
                            GPIOPIN = APICPIN - 8    'C
                            GPIOPIN3 = APICPIN + 152 'H
                            GPIOPIN2 = APICPIN + 120 'K
                        ElseIf APICPIN > 95 And APICPIN <= 119 Then '0x60 Group D & G
                            GPIOPIN = APICPIN        'D
                            If APICPIN > 108 And APICPIN <= 115 Then GPIOPIN2 = APICPIN + 20 'G
                        End If

                    Case 3
                        If APICPIN > 47 And APICPIN <= 71 Then      '0x30 Group B & F
                            GPIOPIN = APICPIN - 16   'B
                            GPIOPIN2 = APICPIN + 80  'F
                        ElseIf APICPIN > 71 And APICPIN <= 95 Then  '0x48 Group C & H
                            GPIOPIN2 = APICPIN + 184 'C
                            GPIOPIN = APICPIN + 88   'H
                        ElseIf APICPIN > 95 And APICPIN <= 119 Then '0x60 Group D & G
                            GPIOPIN = APICPIN        'D
                            If APICPIN > 108 And APICPIN <= 115 Then GPIOPIN2 = APICPIN - 44 'G
                        End If

                    Case Else
                        Console.WriteLine("Unknown Behaviour, Exiting")
                        Console.ReadLine()
                        End
                End Select
            End If

        Catch ex As Exception
            Console.WriteLine()
            Console.WriteLine("Unknown error (A2G), please open an issue and provide your files")
            Console.WriteLine("Exiting")
            Console.ReadLine()
            End
        End Try
    End Sub

    Sub GenGPIO()
        Try
            ManualGPIO(0) = Spacing & "Name (SBFZ, ResourceTemplate ()"
            ManualGPIO(1) = Spacing & "{"
            ManualGPIO(2) = Spacing & "    GpioInt (Level, ActiveLow, Exclusive, PullUp, 0x0000,"
            ManualGPIO(3) = Spacing & "       " & Chr(34) & "\\ _SB.PCI0.GPI0" & Chr(34) & ", 0x00, ResourceConsumer, ,"
            ManualGPIO(4) = Spacing & "        )"
            ManualGPIO(5) = Spacing & "        {   // Pin list"
            If GPIOPIN2 = 0 Then
                ManualGPIO(6) = Spacing & "            0x" & Hex(GPIOPIN)
            ElseIf GPIOPIN2 <> 0 And GPIOPIN3 = 0 Then
                ManualGPIO(6) = Spacing & "            0x" & Hex(GPIOPIN) & " // Try this if the first one doesn't work: 0x" & Hex(GPIOPIN2)
            Else
                ManualGPIO(6) = Spacing & "            0x" & Hex(GPIOPIN) & " // Try the following ones if the first one doesn't work: 0x" & Hex(GPIOPIN2) & " 0x" & Hex(GPIOPIN3)
            End If
            ManualGPIO(7) = Spacing & "        }"
            ManualGPIO(8) = Spacing & "})"


            GPI0SSDT(0) = "/* "
            GPI0SSDT(1) = " * Find _STA:          5F 53 54 41"
            GPI0SSDT(2) = " * Replace XSTA:       58 53 54 41"
            GPI0SSDT(3) = " * Target Bridge GPI0: 47 50 49 30"
            GPI0SSDT(4) = " */"
            GPI0SSDT(5) = "DefinitionBlock(" & Chr(34) & Chr(34) & ", " & Chr(34) & "SSDT" & Chr(34) & ", 2, " & Chr(34) & "hack" & Chr(34) & ", " & Chr(34) & "GPI0" & Chr(34) & ", 0)"
            GPI0SSDT(6) = "{"
            GPI0SSDT(7) = "    External(_SB.PCI0.GPI0, DeviceObj)"
            GPI0SSDT(8) = "    Scope (_SB.PCI0.GPI0)"
            GPI0SSDT(9) = "    {"
            GPI0SSDT(10) = "        Method (_STA, 0, NotSerialized)"
            GPI0SSDT(11) = "        {"
            GPI0SSDT(12) = "            Return (0x0F)"
            GPI0SSDT(13) = "        }"
            GPI0SSDT(14) = "    }"
            GPI0SSDT(15) = "}"

            Dim path As String = My.Computer.FileSystem.SpecialDirectories.Desktop & "\SSDT-GPI0.dsl"
            Dim fs As FileStream = File.Create(path)
            For Genindex = 0 To 15
                fs.Write(New UTF8Encoding(True).GetBytes(GPI0SSDT(Genindex) & vbLf), 0, (GPI0SSDT(Genindex) & vbLf).Length)
            Next
            fs.Close()

        Catch ex As Exception
            Console.WriteLine()
            Console.WriteLine("Unknown error (GG), please open an issue and provide your files")
            Console.WriteLine("Exiting")
            Console.ReadLine()
            End
        End Try
    End Sub

    Sub GenAPIC()
        Try
            ManualAPIC(0) = Spacing & "Name (SBFX, ResourceTemplate ()"
            ManualAPIC(1) = Spacing & "{"
            ManualAPIC(2) = Spacing & "    Interrupt (ResourceConsumer, Level, ActiveHigh, Exclusive, ,, )"
            ManualAPIC(3) = Spacing & "    {"
            ManualAPIC(4) = Spacing & "        0x000000" & Hex(APICPIN) & ","
            ManualAPIC(5) = Spacing & "    }"
            ManualAPIC(6) = Spacing & "})"
        Catch ex As Exception
            Console.WriteLine()
            Console.WriteLine("Unknown error (GA), please open an issue and provide your files")
            Console.WriteLine("Exiting")
            Console.ReadLine()
            End
        End Try
    End Sub

    Sub GenSSDT()
        Try
            If InterruptEnabled = True Or PollingEnabled = True Then
                If ExAPIC = False And ExGPIO = False And APICPIN < 47 Then
                    'No Patch Required, No SSDT Generated
                Else
                    Dim path As String = My.Computer.FileSystem.SpecialDirectories.Desktop & "\SSDT-" & TPAD & ".dsl"
                    Dim fs As FileStream = File.Create(path)

                    Dim RenameCRS(3) As String
                    RenameCRS(0) = "/*"
                    RenameCRS(1) = " * Find _CRS:          5F 43 52 53"
                    RenameCRS(2) = " * Replace XCRS:       58 43 52 53"
                    RenameCRS(3) = " * Target Bridge " & TPAD & ": " & HexTPAD

                    Dim Filehead(12) As String
                    Filehead(0) = "DefinitionBlock(" & Chr(34) & Chr(34) & ", " & Chr(34) & "SSDT" & Chr(34) & ", 2, " & Chr(34) & "hack" & Chr(34) & ", " & Chr(34) & "I2Cpatch" & Chr(34) & ", 0)"
                    Filehead(1) = "{"
                    Filehead(2) = "    External(_SB.PCI0.I2C" & Scope & "." & TPAD & ", DeviceObj)"
                    If CheckSLAVLocation < CRSMethodLine Then
                        Filehead(3) = "    External(_SB.PCI0.I2C" & Scope & "." & TPAD & "." & SLAVName & ", UnknownObj)"
                        If (PollingEnabled = True And ExAPIC = True And Hetero = False) Or APICPIN < 47 And APICPIN <> 0 And ExAPIC = True And Hetero = False Then
                            Filehead(4) = "    External(_SB.PCI0.I2C" & Scope & "." & TPAD & "." & APICNAME & ", UnknownObj)"
                        End If
                        If InterruptEnabled = True And ExGPIO = True And (APICPIN > 47 Or APICPIN = 0 Or ExAPIC = False) Then
                            Filehead(5) = "    External(_SB.PCI0.I2C" & Scope & "." & TPAD & "." & GPIONAME & ", UnknownObj)"
                        End If
                    End If
                    If IfLLess <> "" And (IfLLess <> "Zero" Or IfLLess <> "One)") Then
                        Filehead(6) = "    External(" & IfLLess & ", FieldUnitObj)"
                    End If
                    If IfLEqual <> "" And (IfLEqual <> "Zero" Or IfLEqual <> "One)") Then
                        Filehead(7) = "    External(" & IfLEqual & ", FieldUnitObj)"
                    End If
                    If ExI2CM = True Then
                        Filehead(8) = "    External(_SB.PCI0.I2C" & Scope & ".I2CX, UnknownObj)"
                        Filehead(9) = "    External(_SB.PCI0.I2CM, MethodObj)"
                    End If
                    If ExUSTP = True Then
                        Filehead(10) = "    Name (USTP, One)"
                    End If
                    Filehead(11) = "    Scope(_SB.PCI0.I2C" & Scope & "." & TPAD & ")"
                    Filehead(12) = "    {"

                    For Genindex = 0 To RenameCRS.Length - 1
                        fs.Write(New UTF8Encoding(True).GetBytes(RenameCRS(Genindex) & vbLf), 0, (RenameCRS(Genindex) & vbLf).Length)
                    Next
                    If ExUSTP = True Then
                        Dim RenameUSTP(2) As String
                        RenameUSTP(0) = " * "
                        RenameUSTP(1) = " * Find USTP:          55 53 54 50"
                        RenameUSTP(2) = " * Replace XSTP:       58 53 54 50"
                        For Genindex = 0 To RenameUSTP.Length - 1
                            fs.Write(New UTF8Encoding(True).GetBytes(RenameUSTP(Genindex) & vbLf), 0, (RenameUSTP(Genindex) & vbLf).Length)
                        Next
                    End If

                    fs.Write(New UTF8Encoding(True).GetBytes(" */" & vbLf), 0, (" */" & vbLf).Length)

                    For i = 0 To Filehead.Length - 1
                        fs.Write(New UTF8Encoding(True).GetBytes(Filehead(i) & vbLf), 0, (Filehead(i) & vbLf).Length)
                    Next
                    If ExUSTP = False And CPUChoice = 1 Then
                        GenSPED()
                        If ExSSCN = False And ExFMCN = True Then
                            fs.Write(New UTF8Encoding(True).GetBytes(ManualSPED(0) & vbLf), 0, (ManualSPED(0) & vbLf).Length)
                        ElseIf ExFMCN = False And ExSSCN = True Then
                            fs.Write(New UTF8Encoding(True).GetBytes(ManualSPED(1) & vbLf), 0, (ManualSPED(1) & vbLf).Length)
                        Else
                            For GenIndex = 0 To 1
                                fs.Write(New UTF8Encoding(True).GetBytes(ManualSPED(GenIndex) & vbLf), 0, (ManualSPED(GenIndex) & vbLf).Length)
                            Next
                        End If
                    End If
                    If InterruptEnabled = True And ExGPIO = False And APICPIN > 47 Then
                        GenGPIO()
                        For GenIndex = 0 To ManualGPIO.Length - 1
                            fs.Write(New UTF8Encoding(True).GetBytes(ManualGPIO(GenIndex) & vbLf), 0, (ManualGPIO(GenIndex) & vbLf).Length)
                        Next
                    End If
                    If (PollingEnabled = True And ExAPIC = False) Or Hetero = True Then
                        GenAPIC()
                        For GenIndex = 0 To ManualAPIC.Length - 1
                            fs.Write(New UTF8Encoding(True).GetBytes(ManualAPIC(GenIndex) & vbLf), 0, (ManualAPIC(GenIndex) & vbLf).Length)
                        Next
                    End If
                    For GenIndex = 0 To CRSInfo.Length - 2
                        fs.Write(New UTF8Encoding(True).GetBytes(CRSInfo(GenIndex) & vbLf), 0, (CRSInfo(GenIndex) & vbLf).Length)
                    Next
                    fs.Write(New UTF8Encoding(True).GetBytes("    }" & vbLf), 0, ("    }" & vbLf).Length)
                    fs.Write(New UTF8Encoding(True).GetBytes("}" & vbLf), 0, ("}" & vbLf).Length)

                    fs.Close()
                End If
            End If

            If BlockI2C = True Then
                Dim path As String = My.Computer.FileSystem.SpecialDirectories.Desktop & "\SSDT-Block-" & BlockBus & ".dsl"
                Dim fs As FileStream = File.Create(path)
                For Genindex = 0 To 15
                    fs.Write(New UTF8Encoding(True).GetBytes(BlockSSDT(Genindex) & vbLf), 0, (BlockSSDT(Genindex) & vbLf).Length)
                Next
                fs.Close()
            End If

            Console.WriteLine()
            Console.WriteLine("++++++++++++++++++++++++++++++++++++++")
            Console.WriteLine()
            If InterruptEnabled = True Or PollingEnabled = True Then
                Console.WriteLine("Find _CRS:          5F 43 52 53")
                Console.WriteLine("Replace XCRS:       58 43 52 53")
                Console.WriteLine("Target Bridge " & TPAD & ": " & HexTPAD)
                Console.WriteLine()
                If InterruptEnabled = True And APICPIN > 47 Then
                    Console.WriteLine("Find _STA:          5F 53 54 41")
                    Console.WriteLine("Replace XSTA:       58 53 54 41")
                    Console.WriteLine("Target Bridge GPI0: 47 50 49 30")
                    Console.WriteLine()
                End If
            ElseIf BlockI2C = True Then
                Console.WriteLine("Find _STA:          5F 53 54 41")
                Console.WriteLine("Replace XSTA:       58 53 54 41")
                Console.WriteLine("Target Bridge " & BlockBus & ": " & HexBlockBus)
                Console.WriteLine()
            End If
            If ExUSTP = True And BlockI2C = False Then
                Console.WriteLine("Find USTP:          55 53 54 50")
                Console.WriteLine("Replace XSTP:       58 53 54 50")
                Console.WriteLine()
            End If
            Console.WriteLine("++++++++++++++++++++++++++++++++++++++")
            Console.WriteLine()
            Console.WriteLine("Enjoy!")
            Console.WriteLine("Type in " & Chr(34) & "Exit" & Chr(34) & " to exit")
            While True
                If Console.ReadLine() = "Exit" Then End
            End While
        Catch ex As Exception
            Console.WriteLine()
            Console.WriteLine("Unknown error (GS), please open an issue and provide your files")
            Console.WriteLine("Exiting")
            Console.ReadLine()
            End
        End Try
    End Sub

    Sub BreakCombine()
        Try
            For BreakIndex = 0 To 3
                CRSInfo(CRSInfo.Length - 1 - (total + 1 - (CheckCombLine + 7)) + BreakIndex) = ""
            Next
        Catch ex As Exception
            Console.WriteLine()
            Console.WriteLine("Unknown error (BC), please open an issue and provide your files")
            Console.WriteLine("Exiting")
            Console.ReadLine()
            End
        End Try
    End Sub

    Sub GenSPED()
        If Scope = 0 Then
            ManualSPED(0) = Spacing & "Name (SSCN, Package () { 432, 507, 30 })"
            ManualSPED(1) = Spacing & "Name (FMCN, Package () { 72, 160, 30 })"
        ElseIf Scope = 1 Then
            ManualSPED(0) = Spacing & "Name (SSCN, Package () { 528, 640, 30 })"
            ManualSPED(1) = Spacing & "Name (FMCN, Package () { 128, 160, 30 })"
        ElseIf Scope = 2 Then
            ManualSPED(0) = Spacing & "Name (SSCN, Package () { 432, 507, 30 })"
            ManualSPED(1) = Spacing & "Name (FMCN, Package () { 72, 160, 30 })"
        ElseIf Scope = 3 Then
            ManualSPED(0) = Spacing & "Name (SSCN, Package () { 432, 507, 30 })"
            ManualSPED(1) = Spacing & "Name (FMCN, Package () { 72, 160, 30 })"
        End If
    End Sub

    Sub GenBlockI2C()
        BlockSSDT(0) = "/*"
        BlockSSDT(1) = " * Find _STA:          5F 53 54 41"
        BlockSSDT(2) = " * Replace XSTA:       58 53 54 41"
        BlockSSDT(3) = " * Target Bridge " & BlockBus & ": " & HexBlockBus
        BlockSSDT(4) = " */"
        BlockSSDT(5) = "DefinitionBlock(" & Chr(34) & Chr(34) & ", " & Chr(34) & "SSDT" & Chr(34) & ", 2, " & Chr(34) & "hack" & Chr(34) & ", " & Chr(34) & "PCI-" & BlockBus & Chr(34) & ", 0)"
        BlockSSDT(6) = "{"
        BlockSSDT(7) = "    External(_SB.PCI0." & BlockBus & ", DeviceObj)"
        BlockSSDT(8) = "    Scope (_SB.PCI0." & BlockBus & ")"
        BlockSSDT(9) = "    {"
        BlockSSDT(10) = "        Method (_STA, 0, NotSerialized)"
        BlockSSDT(11) = "        {"
        BlockSSDT(12) = "            Return (0)"
        BlockSSDT(13) = "        }"
        BlockSSDT(14) = "    }"
        BlockSSDT(15) = "}"
        For GenIndex = 0 To 3
            HexBlockBus += Hex(Asc(BlockBus.Substring(GenIndex, 1))) + " "
        Next GenIndex
    End Sub
End Module
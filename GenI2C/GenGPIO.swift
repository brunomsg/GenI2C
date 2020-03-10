//
//  GenGPIO.swift
//  GenI2C
//
//  Created by 梁怀宇 on 2020/3/10.
//  Copyright © 2020 梁怀宇. All rights reserved.
//

import Foundation

func GenGPIO() {
    //verbose(text: "Start func : GenGPIO()")
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

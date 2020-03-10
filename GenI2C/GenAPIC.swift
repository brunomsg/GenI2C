//
//  GenAPIC.swift
//  GenI2C
//
//  Created by 梁怀宇 on 2020/3/10.
//  Copyright © 2020 梁怀宇. All rights reserved.
//

import Foundation

func GenAPIC() {
    //verbose(text: "Start func : GenAPIC()")
    ManualAPIC[0] = Spacing + "Name (SBFX, ResourceTemplate ()"
    ManualAPIC[1] = Spacing + "{"
    ManualAPIC[2] = Spacing + "    Interrupt (ResourceConsumer, Level, ActiveHigh, Exclusive, ,,)"
    ManualAPIC[3] = Spacing + "    {"
    ManualAPIC[4] = Spacing + "        0x000000" + String(format: "%0X", APICPIN) + ","
    ManualAPIC[5] = Spacing + "    }"
    ManualAPIC[6] = Spacing + "})"
}

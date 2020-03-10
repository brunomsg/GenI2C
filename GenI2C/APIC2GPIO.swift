//
//  APIC2GPIO.swift
//  GenI2C
//
//  Created by 梁怀宇 on 2020/3/10.
//  Copyright © 2020 梁怀宇. All rights reserved.
//

import Foundation

func APIC2GPIO() {
    //verbose(text: "Start func : APIC2GPIO()")
    if APICPIN >= 24 && APICPIN <= 47 {
        //verbose(text: "APIC Pin value < 2F, Native APIC Supported, Generation Cancelled")
    } else {
        switch CPUChoice {
        case 0, 3 :
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

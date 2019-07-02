//
//  GenReadme.swift
//  GenI2C
//
//  Created by 梁怀宇 on 2019/7/1.
//  Copyright © 2019 梁怀宇. All rights reserved.
//

import Foundation

func GenReadme (Rename: String) {
    print("GenReadme()")
    var Readme:String = ""
    Readme += "1. Put VoodooI2C and the Satellite into Clover/Kexts/Other\n"
    Readme += "2. Add rename(s) to Clover config.plist\n\n"
    Readme += Rename
    Readme += "\n\n3. Place SSDT aml files into Clover/ACPI/patched"
    let path:String = FolderPath + "/Readme.txt"
    try! FileManager.default.createDirectory(atPath: FolderPath, withIntermediateDirectories: true, attributes: nil)
    if FileManager.default.fileExists(atPath: path) {
        try! FileManager.default.removeItem(atPath: path)
        FileManager.default.createFile(atPath: path, contents: nil, attributes: nil)
    } else {
        FileManager.default.createFile(atPath: path, contents: nil, attributes: nil)
    }
    try! Readme.write(toFile: path, atomically: true, encoding: String.Encoding.utf8)
}

# GenI2C

![Release](https://img.shields.io/github/release/williambj1/GenI2C.svg)
![Testers](https://img.shields.io/badge/Testers-Welcome-brightgreen.svg)

Generate a SSDT for your Trackpad and get ready for VoodooI2C! 😜

**[简体中文](https://github.com/williambj1/GenI2C/wiki/Readme-CN)**

## Download

👉 [![Release](https://img.shields.io/github/release/williambj1/GenI2C.svg)](https://github.com/williambj1/GenI2C/releases)

## Features

- VoodooI2C Information
  - Loaded States
  - ~~Attatched Submodule~~ (In development🚧)
  - Log Extracting
  - Working Mode (APIC, GPIO, Polling)
  - APIC/GPIO Pin showing

- SSDT Generation
  - Using **External** to maintain APIC Pin / GPIO Pin Bios injection
  - Generate I2C Bus Speed Patch
  - ~~Generate Skylake I2C Controller Patch~~ (In development🚧)
  - Generate GPIO Pin when manually pinning is required
  - Polling mode patch supported (VoodooI2CHID only)

- Tools
  - ACPI Disassembler

## Credits

- Bat.bat [(@williambj1)](https://github.com/williambj1) for the idea and the **Visual Basic .Net** part of the project
- DogAndPot [(@DogAndPot)](https://github.com/DogAndPot) for the **Swift** part of the project
- [Alexandred](https://github.com/alexandred) for VoodooI2C [(Full Credits)](https://voodooi2c.github.io/#Credits%20and%20Acknowledgments/Credits%20and%20Acknowledgments)
- Startpenghubingzhou [(@penghubingzhou)](https://github.com/penghubingzhou) for providing theoretical support and his fancy DSDT
- Steve Zheng [(@stevezhengshiqi)](https://github.com/stevezhengshiqi) for testing and bug reporting
- http://patorjk.com for the amazing ASCII Art font `Impossible`

## Donation

**Writing Code and Debugging are not easy, if you appreciate my work, please buy me a coffee. It's not required but will be highly appreciated.😋😋😋**

<details>
<summary>WeChat Pay & Alipay</summary>
<img src="/Donation/DAPWP.jpg" align=center>
<img src="/Donation/DAPAP.jpg" align=center>
</details>

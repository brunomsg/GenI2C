# GenI2C

[![Build Status](https://dev.azure.com/UndefinedSS/GenI2C/_apis/build/status/williambj1.GenI2C?branchName=master)](https://dev.azure.com/UndefinedSS/GenI2C/_build/latest?definitionId=1&branchName=master)
[![Release](https://img.shields.io/github/release/williambj1/GenI2C.svg)](https://github.com/williambj1/GenI2C/releases)
[![Language](https://img.shields.io/github/languages/top/williambj1/GenI2C.svg?color=orange&label=swift)](https://github.com/williambj1/GenI2C)
[![Repo Size](https://img.shields.io/github/repo-size/williambj1/GenI2C.svg?color=blueviolet)](https://github.com/williambj1/GenI2C)
[![Issues](https://img.shields.io/github/issues/williambj1/GenI2C.svg)](https://github.com/williambj1/GenI2C/issues)
[![Testers](https://img.shields.io/badge/Testers-Welcome-brightgreen.svg)](https://github.com/williambj1/GenI2C)

Generate SSDT hotpatches for your Touchable Device and get ready for VoodooI2C! 😜

**[简体中文](https://github.com/williambj1/GenI2C/wiki/Readme-CN)**

## WARNING

THIS TOOL IS *NOT* SUPPORTED BY VoodooI2C DEVELOPER TEAM

DO NOT REQUEST ANY SUPPORT FROM VOODOOI2C GITTER CHAT ROOM WITH ANY INFORMATION GENERATED FROM THIS APPLICATION. INFORMATION INCLUDED BUT NOT LIMITED TO SCREENSHOTS, GENERATED PATCHES, SYSTEM LOGS.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## Download

👉 [![Release](https://img.shields.io/github/release/williambj1/GenI2C.svg)](https://github.com/williambj1/GenI2C/releases)

## Features

- VoodooI2C Information
  - Loaded Status
  - Attatched Submodules
  - Log Extracting
  - Working Mode (APIC, GPIO, Polling)
  - APIC/GPIO Pin showing

- SSDT Generation
  - Using **External** references to maintain APIC/GPIO Pin Bios injection
  - Generate I2C Bus Speed Patch
  - ~~Generate Skylake I2C Controller Patch~~ (In development🚧)
  - Generate GPIO Pin when manually pinning is required
  - Polling mode patch supported (VoodooI2CHID only)

- Tools
  - ACPI Disassembler

- VoodooI2C Diagnosis
  - Ckeck CPU Generation Support
  - AppleIntelLpssI2C.kext/AppleIntelLpssI2CController.kext blocking detection
  - Check VoodooI2C Status
  - Check Magic Trackpad 2 Simulator Engine Status
  - Analyze VoodooI2C Logs

## Credits

- Bat.bat [(@williambj1)](https://github.com/williambj1) for the idea and the **Visual Basic .Net** part of the project
- DogAndPot [(@DogAndPot)](https://github.com/DogAndPot) for the **Swift** part of the project
- **宪武** for sample SSDTs and theoretical support
- [Alexandred](https://github.com/alexandred) for VoodooI2C [(Full Credits)](https://voodooi2c.github.io/#Credits%20and%20Acknowledgments/Credits%20and%20Acknowledgments)
- Startpenghubingzhou [(@penghubingzhou)](https://github.com/penghubingzhou) for providing theoretical support and his fancy DSDT
- Steve Zheng [(@stevezhengshiqi)](https://github.com/stevezhengshiqi) for testing and bug reporting
- http://patorjk.com for the amazing ASCII Art font `Impossible`

## Donation

**Writing Code and Debugging are not easy, if you appreciate my work, please buy me a coffee. It's not required but will be highly appreciated😋😋😋.**

<details>
<summary>WeChat Pay & Alipay</summary>
<img src="https://ae01.alicdn.com/kf/U78f9c297004649579dffcc77577e7bbdI.jpg" align=center>
<img src="https://ae01.alicdn.com/kf/U97363b0bf93d4af1b33a36ccb3d59875w.jpg" align=center>
</details>

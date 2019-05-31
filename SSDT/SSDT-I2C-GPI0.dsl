/*
 * In config ACPI, GPI0:_STA to XSTA
 * Find:     5F 53 54 41
 * Replace:  58 53 54 41
 * TgtBridge:47 50 49 30
 * 
 */ 
#ifndef NO_DEFINITIONBLOCK
DefinitionBlock("", "SSDT", 2, "hack", "GPI0", 0)
{
#endif
    //path:_SB.PCI0.GPI0
    External(_SB.PCI0.GPI0, DeviceObj)
    Scope (_SB.PCI0.GPI0)
    {
        Method(_STA, 0, NotSerialized)
        {
            Return (0x0F)
        }
    }
#ifndef NO_DEFINITIONBLOCK
}
#endif
//EOF
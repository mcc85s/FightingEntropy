Function Get-FEHive
{
    [CmdLetBinding()]Param(
    [ValidateSet("Win32_Client","Win32_Server","RHELCentOS","UnixBSD")]
    [Parameter(Mandatory)][String]$Type,

    [ValidateSet("2021.1.0","2021.1.1","2021.2.0","2021.3.0","2021.3.1","2021.4.0","2021.6.0","2021.8.0")]
    [Parameter(Mandatory)][String]$Version)

    [_Hive]::new($Type,$Version)
}

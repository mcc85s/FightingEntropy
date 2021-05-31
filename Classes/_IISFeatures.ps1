Class _IISFeatures
{
    [String[]] $Features = ("BITS BITS-IIS-Ext DSC-Service FS-SMBBW ManagementOData Net-Framework-45-ASPN" +
                            "et Net-WCF-HTTP-Activation45 RSAT-BITS-Server WAS WAS-Config-APIs WAS-Proces" +
                            "s-Model WebDAV-Redirector {0}App-Dev {0}AppInit {0}Asp-Net45 {0}Basic-Auth {" + 
                            "0}Common-Http {0}Custom-Logging {0}DAV-Publishing {0}Default-Doc {0}Digest-A" + 
                            "uth {0}Dir-Browsing {0}Errors {0}Filtering {0}Health {0}Includes {0}Logging " +
                            "{0}Log-Libraries {0}Metabase {0}Mgmt-Console {0}Net-Ext45 {0}Performance {0}" +
                            "Redirect {0}Request-Monitor {0}Security {0}Stat-Compression {0}Static-Conten" + 
                            "t {0}Tracing {0}Url-Auth {0}WebServer {0}Windows-Auth Web-ISAPI-Ext Web-ISAP" +
                            "I-Filter Web-Server WindowsPowerShellWebAccess") -f "Web-HTTP-" -Split " "
    _IISFeatures()
    {

    }
}

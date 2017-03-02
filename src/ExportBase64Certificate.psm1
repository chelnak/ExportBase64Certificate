function Export-Base64Certificate {
    <#

    .SYNOPSIS 
    Export a certificate as Base-64 encoded X.509

    .DESCRIPTION
    Exports a certificate from the local certificate store as a Base-64 encoded X.509 FileSystemInfo

    .PARAMETER Cert
    The certificate to be exported

    .PARAMETER FilePath
    The destination of the exported certificate

    .PARAMETER Raw
    The exported file will not contian -----BEGIN CERTIFICATE----- or -----END CERTIFICATE-----
    or any line breaks.

    .INPUTS
    System.String
    Switch
    System.Security.Cryptography.X509Certificates.X509Certificate2

    .OUTPUTS
    System.IO.FileSystemInfo

    .EXAMPLE
    $Cert = Get-ChildItem -Path Cert:\LocalMachine\My\FF040E76A99731965DC35691463AB33D55F59261
    Export-Base64Certificate -Cert $Cert -FilePath .\ExportedCert.cer

    .EXAMPLE
    $Cert = Get-ChildItem -Path Cert:\LocalMachine\My\FF040E76A99731965DC35691463AB33D55F59261
    $Cert | Export-Base64Certificate -FilePath .\ExportedCert.cer

    .EXAMPLE
    $Cert = Get-ChildItem -Path Cert:\LocalMachine\My\FF040E76A99731965DC35691463AB33D55F59261
    Export-Base64Certificate -Cert $Cert -FilePath .\ExportedCert.cer -Raw

    .EXAMPLE
    $Cert = Get-ChildItem -Path Cert:\LocalMachine\My\FF040E76A99731965DC35691463AB33D55F59261
    $Cert | Export-Base64Certificate -FilePath .\ExportedCert.cer -Raw

#>

    [CmdletBinding()][OutputType('[System.IO.FileSystemInfo]')]
    Param(

        [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [System.Security.Cryptography.X509Certificates.X509Certificate2]$Cert,

        [Parameter(Mandatory=$true, Position=1)]
        [ValidateNotNullOrEmpty()]
        [String]$FilePath,

        [Parameter(Position=2)]
        [ValidateNotNullOrEmpty()]
        [Switch]$Raw
        
    )

    Begin {

    }

    Process {

        if ($PSBoundParameters.ContainsKey("Raw")) {

            $Base64Cert = [System.Convert]::ToBase64String($Cert.RawData, "None")

        } else {

            $Base64Cert = @(
                '-----BEGIN CERTIFICATE-----'
                [System.Convert]::ToBase64String($Cert.RawData, "InsertLineBreaks")
                '-----END CERTIFICATE-----'
            )

        }

        Write-Verbose -Message "Exporting certificate"
        $Base64Cert | Out-File -FilePath $FilePath -Encoding ascii -Verbose:$VerbosePreference
        Get-ChildItem -Path (Resolve-Path -Path $FilePath -Verbose:$VerbosePreference).Path -Verbose:$VerbosePreference

    }

    End {

    }

}
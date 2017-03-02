# Export-Base64Certificate

A small module that provides the functionality to export Base-64 X509 certificates

## Installation

```PowerShell
Install-Module -Name ExportBase64Certificate -Scope CurrentUser
```

## Usage

### Example 1
```PowerShell
$Cert = Get-ChildItem -Path Cert:\LocalMachine\My\FF040E76A99731965DC35691463AB33D55F59261
Export-Base64Certificate -Cert $Cert -FilePath .\ExportedCert.cer
```

### Example 2
```PowerShell
$Cert = Get-ChildItem -Path Cert:\LocalMachine\My\FF040E76A99731965DC35691463AB33D55F59261
$Cert | Export-Base64Certificate -FilePath .\ExportedCert.cer
```

### Example 3
```PowerShell
$Cert = Get-ChildItem -Path Cert:\LocalMachine\My\FF040E76A99731965DC35691463AB33D55F59261
Export-Base64Certificate -Cert $Cert -FilePath .\ExportedCert.cer -Raw
```

### Example
```PowerShell
$Cert = Get-ChildItem -Path Cert:\LocalMachine\My\FF040E76A99731965DC35691463AB33D55F59261
$Cert | Export-Base64Certificate -FilePath .\ExportedCert.cer -Raw
```
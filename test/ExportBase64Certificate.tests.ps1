$CertificateStorePath = "Cert:\CurrentUser\My"
$SelfSignedCertificate = New-SelfSignedCertificate -Subject "CN=TestCert-$(Get-Random -Maximum 10)" -CertStoreLocation $CertificateStorePath

Describe 'Test Export-CertificateBase64' -Fixture {

    It -Name "Exports a certificate" -Test {

        $FilePath = "TestDrive:\ExportedDefault.cer"
        Export-Base64Certificate -Cert $SelfSignedCertificate -FilePath $FilePath
        (Get-Content -Path $FilePath).Count | Should BeGreaterThan 1
        
    }

    It -Name "Exports a certificate from pipeline input" -Test {

        $FilePath = "TestDrive:\ExportedPipeline.cer"
        $SelfSignedCertificate | Export-Base64Certificate -FilePath $FilePath
        (Get-Content -Path $FilePath).Count | Should BeGreaterThan 1

    }

    It -Name "Exports a certificate in Raw format" -Test {

        $FilePath = "TestDrive:\ExportedDefaultRaw.cer"
        Export-Base64Certificate -Cert $SelfSignedCertificate -FilePath $FilePath -Raw
        (Get-Content -Path $FilePath).Count | Should Be 1

    }

    It -Name "Exports a certificate in Raw format from pipeline input" -Test {

        $FilePath = "TestDrive:\ExportedPipelineRaw.cer"
        $SelfSignedCertificate | Export-Base64Certificate -FilePath $FilePath -Raw
        (Get-Content -Path $FilePath).Count | Should Be 1

    }
}
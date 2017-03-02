<#

    PSake Build steps:

        1. Stage release files
        2. Test
        4. BumpVersion
        3. Create CreateArtifact
        4. Publish Release

#>

Properties {

    $ModuleName = ".\ExportBase64Certificate"
    $GitHubUsername = "chelnak"
    $SrcDir = "$($PSScriptRoot)\src"
    $ModuleManifestPath = "$($SrcDir)\$($ModuleName).psd1"
    $Script:ModuleVersion = (Import-PowerShellDataFile -Path $ModuleManifestPath).ModuleVersion
    $ReleaseDir = "$($PSScriptRoot)\Release\$($ModuleName)"
    $TestsDir = "$($PSScriptRoot)\test"

}

Task Default -Depends Build
Task Build -Depends BumpVersion, Stage, CreateArtifact

Task Test {

    Push-Location
    Set-Location -Path $TestsDir

    $Result = Invoke-Pester -OutputFormat NUnitXml -OutputFile .\PesterResults.xml -Verbose:$VerbosePreference -PassThru
    $ResultsFile = (Resolve-Path .\PesterResults.xml).Path

    Write-Output "Uploading test $($ResultsFile) for job $($env:APPVEYOR_JOB_ID)"
    $WebClient = [System.Net.WebClient]::new()
    $WebClient.UploadFile("https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)", $ResultsFile)

    if ($Result.FailedCount -gt 0) {

        Write-Error -Message "Tests failed"

    }

    Pop-Location

}

Task BumpVersion {

    # --- Get the current version
    [Int]$MajorVersion = $ModuleVersion.Split(".")[0]
    [Int]$MinorVersion = $ModuleVersion.Split(".")[1]
    [Int]$PatchVersion = $ModuleVersion.Split(".")[2]

    # --- Retrieve MAJOR MINOR PATCH from commit message
    $RegEx = [regex] "\[([^\[]*)\]"
    $BumpVersion = "NONE" #$RegEx.Match($ENV:APPVEYOR_REPO_COMMIT_MESSAGE).Groups[1].Value

    switch ($BumpVersion) {

        'MAJOR' {

            $MajorVersion++
            $MinorVersion = 0
            $PatchVersion = 0

            BumpVersion -NewVersion "$($MajorVersion).$($MinorVersion).$($PatchVersion)"
            break

        }

        'MINOR' {

            $MinorVersion++
            $PatchVersion = 0

            BumpVersion -NewVersion "$($MajorVersion).$($MinorVersion).$($PatchVersion)"
            break

        }

        'PATCH' {

            $PatchVersion++

            BumpVersion -NewVersion "$($MajorVersion).$($MinorVersion).$($PatchVersion)"
            break
        }

        default {

            # --- Do nothing
            Write-Output "Not bumping module version"
            break

        }

    }

}

Task Stage {

    if ((Test-Path -Path $ReleaseDir)) {
        Remove-Item -Path $ReleaseDir -Recurse -Force | Out-Null
    }

    New-Item $ReleaseDir -ItemType Directory -Verbose:$VerbosePreference | Out-Null
    Copy-Item -Path $SrcDir\* -Destination $ReleaseDir -Recurse -Confirm:$false -Verbose:$VerbosePreference

}

Task CreateArtifact {

    Write-Output "Creating artifacts for version $($Script:ModuleVersion)"

    $ArtifactName = "$($ModuleName).$($Script:ModuleVersion).$($ENV:APPVEYOR_BUILD_NUMBER).zip"
    Compress-Archive -Path $ReleaseDir -DestinationPath  "$($PSScriptRoot)\Release\$($ArtifactName)" -Force -Confirm:$false -Verbose:$VerbosePreference | Out-Null
    #Push-AppveyorArtifact  "$($PSScriptRoot)\Release\$($ArtifactName)"

}

Task Publish {

    $ArtifactName = "$($ModuleName).$($Script:ModuleVersion).$($ENV:APPVEYOR_BUILD_NUMBER).zip"
    Write-Output "Publishing $($ArtifactName)"

<#
    Set-GitHubSessionInformation -UserName $GitHubUsername -APIKey $ENV:GitToken -Verbose:$VerbosePreference | Out-Null

    $CurrentModuleVersion = (Import-PowerShellDataFile -Path $ModuleManifestPath).ModuleVersion

    Write-Verbose -Message "Current module version is $($CurrentModuleVersion)"

    $AssetPath = "$($OutDir)\$($ModuleName)-$($CurrentModuleVersion).zip"

    Write-Verbose -Message "Asset path is $($AssetPath)"

    $Asset = @{
        "Path" = $AssetPath
        "Content-Type" = "application/zip"
    }

    New-GitHubRelease -Repository $GithubRepositoryName -Name $ModuleName -Target $GitHubReleaseTarget `
        -Tag "v$($CurrentModuleVersion)" -Asset $Asset -Verbose:$VerbosePreference -Confirm:$false | Out-Null

#>

}

# --- Helper functions

function BumpVersion {

    [CmdletBinding()]

    Param(
        [Parameter()]
        [String]$NewVersion,

        [Parameter()]
        [String]$CurrentModuleVersion = $ModuleVersion
    )

    # --- Only bump versions if
    if ([version]$NewVersion -gt [version]$CurrentModuleVersion) {

        # --- Update ModuleManifest version
        Update-ModuleManifest -Path $ModuleManifestPath -ModuleVersion $NewVersion | Out-Null

        # --- Update appveyor build version
        $AppveyorYMLPath = "$($PSScriptRoot)\appveyor.yml"
        $AppveyorVersion = "$($NewVersion).{build}"
        $NewAppveyorYML = Get-Content -Path $AppveyorYMLPath | ForEach-Object { $_ -replace '^version: .+$', "version: $($AppveyorVersion)";}
        $NewAppveyorYML | Set-Content -Path $AppveyorYMLPath -Force

        # --- Update $ModuleVersion session variable
        $Script:ModuleVersion = $NewVersion
        Write-Output "Version updated to $($Script:ModuleVersion)"

    }

}
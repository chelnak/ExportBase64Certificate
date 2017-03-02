[Cmdletbinding()]

Param (

    [Parameter()]
    [ValidateSet("Default", "Test", "Build")]
    [String]$Task = "Default"

)

# --- Start Build
Invoke-psake -BuildFile "$($PSScriptRoot)\build.psake.ps1" -TaskList $Task -Nologo -Verbose:$VerbosePreference

exit ( [int]( -not $psake.build_success ) )
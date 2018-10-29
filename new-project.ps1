<#
.SYNOPSIS
    Stands up basic NUnit tested Class Library project and init the Git
.DESCRIPTION
    Creates a Git repository of a .Net Solution with a Class Library that is refered to by an NUnit Test Class library. Optionally creates a console class.
.EXAMPLE
    PS C:\> <example usage>
    Explanation of what the example does

.PARAMETER Path
    The destination path for your solution
    Defaults to the working directory

.PARAMETER Solution
    The Solution name
    Creates a solution with that name provided by this parameter

.PARAMETER Class
    The .Net Standard Class Library name
    Creates a Class Library with the name provided by this parameter

.PARAMETER MakeConsole
    Creates Console Application Class project
    Default $Console to "consClass" if none is provided without -Console

.PARAMETER Console
    The Console Class name. Will casue creation of Console Application Class project
    This causes -MakeConsole to be true

.PARAMETER NoGit
    Doesn't create a git repository of the solution

.INPUTS
    No inputs

.OUTPUTS
    No outputs

.NOTES
    No notes

.LINK
    https://github.com/jadenguy/New-NUnitProject
#>

param (
    [switch]$verbose,
    $path = $(Get-Item .),
    $solution = "newSolution",
    $class = "newClass",
    [switch] $MakeConsole,
    [string]$console,
    [switch] $NoGit
)

function Invoke-Creation {

    Write-Output "Creating new Project $solution at $solutionDir"
    $solutionDir = Join-Path $path $solution
    dotnet new sln  -n $solution -o $solutionDir
    $Sln = Join-Path $solutionDir "$solution.sln"

    Write-Output "Creating new Class Library $class at $classDir"
    $classDir = Join-Path $solutionDir $class
    dotnet new classlib -n $class -o $classDir
    $classLib = Join-Path $classDir "$class.csproj"
    dotnet sln $Sln add $classLib

    Write-Output "Creating new NUnit Test $test at $testDir"
    $test = "$class.Test"
    $testDir = Join-Path $solutionDir $test
    dotnet new nunit -n $test -o $testDir
    $nUnit = Join-Path $testDir "$class.Test.csproj"
    dotnet add $nUnit reference  $classLib
    dotnet sln $Sln add $nUnit

    if ($MakeConsole -and -not $console) {
        $console = "conClass"
    }
    if ( $console ) {
        Write-Output "Creating new Console Class $console at $consoleTest"
        $consoleDir = Join-Path $solutionDir $console
        dotnet new console -n $console -o $consoleDir
        $consoleClass = Join-Path $consoleDir "$console.csproj"
        dotnet add $consoleClass reference $classLib
        dotnet sln $Sln add $consoleClass
    }

    if (!$NoGit) {
        Write-Output "Initing Git of $solutionDir"
        $gitIgnore = Join-Path $PSScriptRoot "gitignore"
        $gitIgnoreDestination = Join-Path $solutionDir ".gitignore"
        Copy-Item -path $gitIgnore -Destination $gitIgnoreDestination 
        git init $solutionDir
        git -C $solutionDir add .
        git -C $solutionDir commit --all -m "Initial Commit"
        git -C $solutionDir log
    }

    code $solutionDir
}

if ($verbose) {
    Invoke-Creation 
}
else {
    Invoke-Creation | Out-Null
}
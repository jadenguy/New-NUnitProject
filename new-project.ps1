<#
.SYNOPSIS
    Stands up basic NUnit tested Class Library project and init the Git
.DESCRIPTION
    Creates a Git repository of a .Net Solution with a Class Library that is refered to by an NUnit Test Class library. Optionally creates a console class.
    See below for project layout format
    https://gist.github.com/davidfowl/ed7564297c61fe9ab814
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
    [switch]$Verbose,
    $Path = $(Get-Item .),
    $Solution = "newSolution",
    $Class = "Common",
    [switch] $MakeConsole,
    [string]$Console,
    [switch] $NoGit
)

function Invoke-Creation {
    param(
        $path,
        $solution,
        $class,
        $MakeConsole,
        $console,
        $NoGit
    )    
    
    Write-Output "Creating new Project $solution at $solutionDir"
    $solutionDir = Join-Path $path $solution
    dotnet new sln  -n $solution -o $solutionDir
    $Sln = Join-Path $solutionDir "$solution.sln"

    $srcDir = Join-Path $solutionDir "src"
    New-Item -ItemType Directory -path $srcDir -Force

    $classDir = Join-Path $srcDir $class
    Write-Output "Creating new Class Library $class at $classDir"
    dotnet new classlib -n $class -o $classDir
    $classLib = Join-Path $classDir "$class.csproj"
    dotnet sln $Sln add $classLib

 
    $testsDir = Join-Path $solutionDir "tests"
    New-Item -ItemType Directory -path $testsDir -Force

    $test = "$class.Test"
    $testDir = Join-Path $testsdir $test
    Write-Output "Creating new NUnit Test $test at $testDir"
    dotnet new nunit -n $test -o $testDir
    $nUnit = Join-Path $testDir "$class.Test.csproj"
    dotnet add $nUnit reference  $classLib
    dotnet sln $Sln add $nUnit

    if ($MakeConsole -and -not $console) {
        $console = "App"
    }
    if ( $console ) {
        Write-Output "Creating new Console Class $console at $consoleTest"
        $consoleDir = Join-Path $srcDir $console
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
$arguments = @{ path = $path
    solution = $solution 
    class = $class 
    MakeConsole = $MakeConsole
    console = $console
    NoGit = $NoGit}
if ($verbose) {
    Invoke-Creation @arguments
}
else {
    Invoke-Creation @arguments | Out-Null
}
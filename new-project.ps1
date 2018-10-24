param (
    $path = $(Get-Item .),
    $solution = "newSolution",
    $class = "newClass",
    [switch] $MakeConsole,
    [string]$console,
    [switch] $NoGit
)

$test = "$class.Test"

$solutionDir = Join-Path $path $solution
$classDir = Join-Path $solutionDir $class
$testDir = Join-Path $solutionDir $test
$consoleDir = Join-Path $solutionDir $console

Write-Verbose "Creating new Project $solution at $solutionDir"

dotnet new sln  -n $solution -o $solutionDir
$Sln = Join-Path $solutionDir "$solution.sln"

Write-Verbose "Creating new Class Library $class at $classDir"

dotnet new classlib -n $class -o $classDir
$classLib = Join-Path $classDir "$class.csproj"
dotnet sln $Sln add $classLib

Write-Verbose "Creating new NUnit Test $test at $testDir"

dotnet new nunit -n $test -o $testDir
$nUnit = Join-Path $testDir "$class.Test.csproj"
dotnet add $nUnit reference  $classLib
dotnet sln $Sln add $nUnit
if ($MakeConsole -and -not $console)
{$console = "conClass"}
if ( $console ) {

    Write-Verbose "Creating new Console Class $console at $consoleTest"

    dotnet new console -n $console -o $consoleDir
    $consoleClass = Join-Path $consoleDir "$console.csproj"
    dotnet add $consoleClass reference $classLib
    dotnet sln $Sln add $consoleClass
}

if (!$NoGit) {
    $gitIgnore = Join-Path $PSScriptRoot "gitignore"
    $gitIgnoreDestination = Join-Path $solutionDir ".gitignore"

    Write-Verbose "Initing Git of $solutionDir"

    Copy-Item -path $gitIgnore -Destination $gitIgnoreDestination 
    git init $solutionDir
    git -C $solutionDir add .
    git -C $solutionDir commit --all -m "Initial Commit"
    git -C $solutionDir log
}

code $solutionDir
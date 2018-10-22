param (
    $root = $(Get-Item .),
    $solution = "newProject",
    $class = "newClass",
    $con = "consoleClass",
    [switch] $MakeConsole,
    [switch] $NoGit
)

$test = "$class.Test"

$solutionDir = Join-Path $root $solution
$classDir = Join-Path $solutionDir $class
$testDir = Join-Path $solutionDir $test
$conDir = Join-Path $solutionDir $con

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

if ($MakeConsole) {

    Write-Verbose "Creating new Console Class $con at $conTest"

    dotnet new console -n $con -o $conDir
    $conClass = Join-Path $conDir "$con.csproj"
    dotnet add $conClass reference $classLib
    dotnet sln $Sln add $conClass
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
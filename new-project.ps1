$root = Get-Item .
$project = "newProject"
$class = "newClass"
$test = "$class.Test"
$con = "consoleClass"

$projectDir = Join-Path $root $project
$classDir = Join-Path $projectDir $class
$testDir = Join-Path $projectDir $test
$conDir = Join-Path $projectDir $con

Write-Verbose "Creating new Project $project at $projectDir"

dotnet new sln  -n $project -o $projectDir
$projectSln = Join-Path $projectDir "$project.sln"

Write-Verbose "Creating new Class Library $class at $classDir"

dotnet new classlib -n $class -o $classDir
$classLib = Join-Path $classDir "$class.csproj"
dotnet sln $projectSln add $classLib

dotnet new nunit -n $test -o $testDir
$nUnit = Join-Path $testDir "$class.Test.csproj"
dotnet add $nUnit reference  $classLib
dotnet sln $projectSln add $nUnit

dotnet new console -n $con -o $conDir
$conClass = Join-Path $conDir "$con.csproj"
dotnet add $conClass reference $classLib
dotnet sln $projectSln add $conClass

code $projectDir
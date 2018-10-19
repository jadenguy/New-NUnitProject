$root = Get-Item .
$project = "newProject"
$class = "newClass"

$projectDir = Join-Path $root $project
$classDir = Join-Path $projectDir $class
$testDir = Join-Path $projectDir "$class.Test"
#Get-Item $projectDir | Remove-Item -Recurse -Force

dotnet new sln  -n $project -o $projectDir
$projectSln = Join-Path $projectDir "$project.sln"
dotnet new classlib -n $class -o $classDir
$classLib = Join-Path $classDir "$class.csproj"
dotnet sln $projectSln add $classLib

dotnet new nunit -n "$class.Test" -o $testDir
$nUnit = Join-Path $testDir "$class.Test.csproj"
dotnet add $nUnit reference  $classLib
dotnet sln $projectSln add $nUnit

code $projectDir
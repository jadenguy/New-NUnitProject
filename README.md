# New-NUnitProject
Powershell Script to stand up basic NUnit tested Class Library project and init the Git

## Usage

Run this script in the directory you want to create the solution folder in, or designate a path

### "-Path" is destination path for your solution

* Defaults to the working directory "."

### "-Solution" is the Solution name

* Defaults to "newSolution"
* It creates a solution with that name provided by this parameter

### "-Class" is the .Net Standard Class Library name

* Defaults to "newClass"
* It creates a project with that name provided by this parameter

### "-Console" creates Console Application Class project

* Will create on providing a name for the Console Class

### "-MakeConsole" creates Console Application Class project

* Switch that is turned off by default
* Will default $Console to "consClass"

## TODO

* Maybe add tests for the Console class, but that should usually run off of a class library and just kind of start and end the project.
* Add standard Powershell comment-based help
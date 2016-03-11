# PowerShell.Continuous module

Main module that set up environment and performs continuous action.


### Resposibility

 1. Create drives:
   * `Workspace:` - default is current working directory - witch root points to main working directory
   * `Action:` -  witch root points to directory of selected action assets
   * `Artifacts:` - default is `Workspace:\.Artifacts` - witch root points the main directory that will store itermediate and final artifacts of continous action.
 2. Extends modules path.
 3. Invokes contnous action.

 
## Usage

The minimum usage is show bellow.

```powershell
PS1> Import-Module PowerShell.Continuous
PS2> Invoke-Continuous Workspace:\Continuous.Integration { ... }
```

 1. Load the module
 2. Invoke continous action with:
    * `Action:` drive points to `Continuous.Integration` directory in the `Workspace:` drive.
    * action defined inside script block
    * `Workspace:` drive points to current working directory
    * `Artifacts:` drive points to `.Artifacts` directory in the `Workspace:` drive.
    * Modules path extends with root of `Workspace:` drive. 

So the structure of folder looks:
    
* `.\` as `Workspace:\`
* `.\Continuous.Integration\` as `Action:\`
* `.\.Artifacts\` as `Artifacts:\`


## Example


### Visual Studio C# solution integration

__TODO:__ describe example with using nuget package, Invoke-Build as task runner


## License

PowerShell.Continuous module is released under the [MIT license](http://www.opensource.org/licenses/MIT).
# PowerShell.Continuous

PowerShell Continuous Integration and beyond...

## Main concepts

 * workspace
 * artifacts
 * action
 	* task input
 	* task
 	* task output
	 
## Structure
 * Workspace:
 * Artifacts:
 * Action:
 * Input:
 * Output:
 
 
### Example 1 - Integration (C#)

The example action has fllowing tasks:
 1. `Version` - modifing or generating the assets according to corect versioning of the artifacts
 2. `Build` - create the artifacts from assets
    1. `Measure` - Verify Build artifacts metrics
 3. `Test` - Perform test (unit) on the Build artifacts
    1. `Measure` - Verify Test artifacts metrics
 4. `Package` - Prepare Build artifacts for publication
 5. `Publish` - Perform Package artifacts publicaly avaiable

The data are featched from SCM into directory `C:\workspace\` and the action `integration` is performed.

* `Workspace:\` is set to `C:\Workspace\`
* `Artifacts:\` points to newly created directory `Workspace:\Artifacts` wich is `C:\Workspace\.Artifacts`.
* `Action:\` points to existing directory `Workspace:\Continuous.Integration` wich is C:\Workspace\Continuous.Integration.    

The action is invoked and the Version task is Performed:
* `Input:\` - is set to `Action:\` 
* `Output:\` - is set to `Action:\` 


## License

PowerShell.Continuous is released under the [MIT license](http://www.opensource.org/licenses/MIT).

# PowerShell.Continuous.AssemblyInfo module

Module to operate on `AssemblyInfo.cs` projects files.


### Resposibility

 1. Get the Assembly version form `AssemblyInfo` files in fallowing order:
   * `AssemblyInformationalVersion` - as most free in form. Sugested format `major.minor.patch.revison-branche (checkin).
   * `AssemblyFileVersion` - as it can contains full version numbers informations. Sugested format `major.minor.patch.revison`.
   * `AssemblyVersion` - as it can influence assembly loading and force mapping.
     Sugested format `major.minor.0.0` or even `major.0.0.0` if [semantic versioning](http://semver.org/) is used.
 2. Edit `AssemblyInfo` files with requred version.

By default module use the PowerShell drives conventions and search the `AssemblyInfo` files in `Proeprties` subfolder of `action:` drive.


## Usage

__TODO:__ describe minimal usage

## Example


### Visual Studio C# solution integration

__TODO:__ describe example with using module in such a project


## License

PowerShell.Continuous.AssemblyInfo module is released under the [MIT license](http://www.opensource.org/licenses/MIT).
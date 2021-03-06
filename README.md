# perl-module-autoloader V1.1.0
This perl module perform an autoloading for perl modules

### Options

option | action
------ | ------
Autoload-DebugLib | print each imported library
Autoload-LibPath=s | define the ModuleAutoloaderLib path
Autoload-DebugConfig | print each configuration file informations
Autoload-ConfigPath=s | define the ModuleAutoloaderConfig path

### Configuration :

The Autoloader allow you to define the configuration into a yaml file write into the ConfigPath directory.

The default ConfigPath directory is './moduleAutoloaderConfig'.
The configuration file must finish by '.yaml' or '.yml' and contain the 'autoloader' key.

The allowed things for the configuration are the default recursivity and a set of directory to load. See the following example :
```yaml
autoloader:
    default:
        recursive: true	# The default recursivity for the import directories (false as default)
        strict: true   	# define that the directories must be strict included (false as default)
        basePath:  "/"  # define the root base path to process real path of relative directories
    directories:
        firstKey: # Configuration key (user defined, no one requirement)
            dir: "/perl/some/directory/to/load"
        secondKey: 
            dir: "/perl/some/other/directory/to/load"
            recursive: false # override the default recursivity for the current dir
            strict: false    # override the default strict for the current dir
        thirdKey: # Configuration key (user defined, no one requirement)
            dir: "relative/directory/to/load" # 
```
The 'strict' element force the autoloader to inject the directory as it without check that it contain any pm|t|pl file.

Note you can use a relative path since version 1.1.0. The relative path is parsed as real path before include.
The real path take at relative base path the ModuleAutoloader.pm file path as default. This is override by the Autoload-RelativeBasePath
option, or by the RelativeBasePath use message. See example for usage.

### Example of use :
```perl
use strict;
use warnings;
use FindBin;

BEGIN
{
	push @INC, $FindBin::Bin;
}
use ModuleAutoloader;
```

If you want to use specific path, you can import parameters as in this example :
```perl
use strict;
use warnings;
use Getopt::Long;

BEGIN
{
	push @INC, $FindBin::Bin;
}
use ModuleAutoloader ["DebugLib=1", "DebugConfig=1", "LibPath=/some/path", "ConfigPath=/some/other/path", "RelativeBasePath=$FindBin::Bin/"];
```

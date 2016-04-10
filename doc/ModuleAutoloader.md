# ModuleAutoloader
The ModuleAutoloader package is used to load dynamicaly
the include path of a perl script..

Use [strict](http://perldoc.perl.org/strict.html)

Use [warnings](http://perldoc.perl.org/warnings.html)

Use [FindBin](http://perldoc.perl.org/FindBin.html)

Use [Try::Tiny](http://search.cpan.org/~ether/Try-Tiny-0.24/lib/Try/Tiny.pm)

Use [Getopt::Long](http://perldoc.perl.org/Getopt/Long.html)

Use [Data::Dumper](http://perldoc.perl.org/Data/Dumper.html)

Version: 1.0

Date: 2016/04/09

Author: Matthieu vallance <matthieu.vallance@cscfa.fr>

Module: [ModuleAutoloader](./ModuleAutoloader.md)

License: MIT

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
    directories:
        firstKey: # Configuration key (user defined, no one requirement)
            dir: "/perl/some/directory/to/load"
        secondKey: 
            dir: "/perl/some/other/directory/to/load"
            recursive: false # override the default recursivity for the current dir
            strict: false    # override the default strict for the current dir
```
The 'strict' element force the autoloader to inject the directory as it without check that it contain any pm|t|pl file.

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
use ModuleAutoloader ["DebugLib=1", "DebugConfig=1", "LibPath=/some/path", "ConfigPath=/some/other/path"];
```


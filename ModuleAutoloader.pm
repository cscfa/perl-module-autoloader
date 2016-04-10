package ModuleAutoloader;
use strict;
use warnings;
use FindBin;
use Try::Tiny;
use Getopt::Long qw(GetOptions);
use Data::Dumper;
Getopt::Long::Configure qw(pass_through);

$ModuleAutoloader::VERSION = "1.0";

my $debugLib = '';
my $libPath = $FindBin::Bin;
my $debugConfig = '';
my $configPath = $FindBin::Bin . '/moduleAutoloaderConfig';
GetOptions (
	"Autoload-DebugLib" => \$debugLib,
	"Autoload-LibPath=s" => \$libPath,
	"Autoload-DebugConfig" => \$debugConfig,
	"Autoload-ConfigPath=s" => \$configPath,
);

BEGIN
{
	push(@INC, "$FindBin::Bin/moduleAutoloaderLib");
	push(@INC, "$FindBin::Bin/moduleAutoloaderLib/Exception");
	push(@INC, "$FindBin::Bin/moduleAutoloaderLib/Explorer");
	push(@INC, "$FindBin::Bin/moduleAutoloaderLib/Hash-Merge-0.200/lib/");
}

use Explorer;
use YamlException;
use DirectoryException;
use autouse 'YAML' => qw(LoadFile);
use Hash::Merge qw(merge);
my $yamlLibEnable = 0;
my %configuration = ();
my @included = [];

INIT
{
	ModuleAutoloader::loadLibrary();
	ModuleAutoloader::loadConfiguration();
	ModuleAutoloader::processConfiguration();
}

sub loadLibrary
{
	my ($libInfo) = @_;
	my $explorer = Explorer->new();
	my @librariesDir;
	my $exception = undef;
	
	$libInfo->{"path"} = $libPath if (!defined $libInfo->{"path"});
	$libInfo->{"recursive"} = 1 if (!defined $libInfo->{"recursive"});
	$libInfo->{"error"} = "Autoloader unable to automatically discover itself libraries." if (!defined $libInfo->{"error"});
	
	try {
		@librariesDir = @{$explorer->searchDirectoriesContaining({
			directories => [$libInfo->{path}],
			pattern => "\.(pm|t|pl)\$",
			recursive => $libInfo->{recursive}
		})};
	} catch {
		my $exception = DirectoryException->new({
			message => $libInfo->{error},
			code => "980a50f41",
			previous => $_
		});
		print Dumper $exception;
		die $exception;
	};
	
	foreach my $library (@librariesDir){
		if ($library =~ /YAML/i ) {
			$yamlLibEnable = 1;
		}
		ModuleAutoloader::pushInc($library);
	}
}

sub loadConfiguration
{
	my $self = shift;
	my $explorer = Explorer->new();
	my @configFile;

	try {
		@configFile = @{$explorer->searchFiles({
			directories => [$configPath],
			pattern => "\.(yaml|yml)\$",
			recursive => 1
		})};
	} catch {
		my $exception = DirectoryException->new({
			message => "Autoloader unable to reach configuration directory.",
			code => "980a50f42",
			previous => $_
		});
		print Dumper $exception;
		die $exception;
	};
	
	my $merger = Hash::Merge->new('RIGHT_PRECEDENT');
	foreach my $yamlFile (@configFile){
		
		$yamlFile = $configPath . "/" . $yamlFile;
		
		print "Loading yaml file : " . $yamlFile . "\n" if ($debugConfig);
		my $fileContent;
		
		try {
			$fileContent = LoadFile($yamlFile);
		} catch {
			my $exception = YamlException->new({
				message => "Autoloader unable to load file $yamlFile.",
				code => "980a50f43",
				previous => $_
			});
			print Dumper $exception;
			die $exception;
		};
		
		if ($fileContent->{autoloader}) {
			print "Configuration data find. Loading \n" if ($debugConfig);
			%configuration = %{$merger->merge(\%configuration, $fileContent->{autoloader})};
		}
	}
}

sub processConfiguration
{
	my $default = ModuleAutoloader::searchDefault(\%configuration);
	ModuleAutoloader::includeConfigurationDirectories({
		configuration => \%configuration,
		defaults => $default,
	});
}

sub searchDefault
{
	my $configuration = shift;
	my $default;
	$default->{recursive} = "false";
	$default->{strict} = "false";
	
	if (!$configuration->{default}) {
		return $default;
	}
	
	$default->{recursive} = $configuration->{default}->{recursive} if (defined $configuration->{default}->{recursive});
	$default->{strict} = $configuration->{default}->{strict} if (defined $configuration->{default}->{strict});
	return $default;
}

sub includeConfigurationDirectories
{
	my ($args) = @_;
	my $configuration = $args->{configuration};
	my $defaults = $args->{defaults};
	
	if (!$configuration->{directories}) {
		return;
	}
	
	my $directories = $configuration->{directories};
	
	foreach my $dirKey (keys($directories)) {
		try {
			if ($directories->{$dirKey}->{dir}) {
				print "Include $dirKey \n" if ($debugConfig);
				
				my $recursive = 0;
				if (defined $directories->{$dirKey}->{recursive}) {
					my $recursiveValue = $directories->{$dirKey}->{recursive};
					$recursive = 1 if ($recursiveValue eq "true");
					$recursive = 0 if ($recursiveValue eq "false");
				} else {
					$recursive = 1 if ($defaults->{recursive} eq "true");
					$recursive = 0 if ($defaults->{recursive} eq "false");
				}
				
				my $strict = 0;
				if (defined $directories->{$dirKey}->{strict}) {
					my $strictValue = $directories->{$dirKey}->{strict};
					$strict = 1 if ($strictValue eq "true");
					$strict = 0 if ($strictValue eq "false");
				} else {
					$strict = 1 if ($defaults->{strict} eq "true");
					$strict = 0 if ($defaults->{strict} eq "false");
				}
				
				ModuleAutoloader::loadLibrary({
					"path" => $directories->{$dirKey}->{dir},
					"recursive" => $recursive,
					"error" => "Autoloader unable to load $dirKey",
				});
				ModuleAutoloader::pushInc($directories->{$dirKey}->{dir}) if $strict;
			} else {
				my $exception = YamlException->new({
					message => "Yaml format error for '$dirKey' element. Need 'dir' key with directory path",
					code => "980a50f44",
					previous => $_
				});
				print Dumper $exception;
				die $exception;
			}
		} catch {
			my $exception = YamlException->new({
				message => "Yaml format error for '$dirKey' element. Need 'dir' key with directory path",
				code => "980a50f44",
				previous => $_
			});
			print Dumper $exception;
			die $exception;
		};
	}
}

sub pushInc
{
	my $lib = shift;

	if(grep(/^$lib$/, @included)) {
		print "Library directory already added to INC : $lib\n" if $debugLib;
		return;
	}
	
	print "Library directory added to INC : $lib\n" if $debugLib;
	push(@included, $lib);
	push(@INC, $lib);
}

sub import {
    my $pkg = shift;
    my ($messages) = @_;

    if ( defined $messages ) {
    	if (ref($messages) eq "ARRAY"){
    		foreach my $message (@{$messages}) {
    			$pkg->applyMessage($message);
    		}
    	} else {
    		$pkg->applyMessage($messages);
    	}
    }
    return;
}

sub applyMessage
{
    my $pkg = shift;
	my $messages = shift;

	if ($messages =~ /DebugConfig=/){
		my ($state) = ($messages =~ /DebugConfig=([01])/);
		$debugConfig = ($state eq "0") ? 0 : 1;
	} elsif ($messages =~ /DebugLib=/){
		my ($state) = ($messages =~ /DebugLib=([01])/);
		$debugLib = ($state eq "0") ? 0 : 1;
	} elsif ($messages =~ /LibPath=/){
		($libPath) = ($messages =~ /LibPath=(.+)/);
	} elsif ($messages =~ /ConfigPath=/){
		($configPath) = ($messages =~ /ConfigPath=(.+)/);
	}
}

1;
__END__

=begin markdown

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
Module: [ModuleAutoloader](../../ModuleAutoloader.html)
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

=end markdown


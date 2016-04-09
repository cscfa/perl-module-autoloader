package ModuleAutoloader;
use strict;
use warnings;
use FindBin;
use Try::Tiny;
use Getopt::Long;

$ModuleAutoloader::VERSION = "1.0";

BEGIN
{
	push(@INC, "$FindBin::Bin/moduleAutoloaderLib");
	push(@INC, "$FindBin::Bin/moduleAutoloaderLib/Exception");
	push(@INC, "$FindBin::Bin/moduleAutoloaderLib/Explorer");
}

use Explorer;

INIT
{
	my $debugLib = '';
	GetOptions ("Autoload-DebugLib" => \$debugLib,);
	
	my $self = shift;
	my $explorer = Explorer->new();
	my @librariesDir;
	my $exception = undef;
	
	try {
		@librariesDir = @{$explorer->searchDirectoriesContaining({
			directories => [$FindBin::Bin],
			pattern => "\.(pm|t|pl)\$",
			recursive => 1
		})};
	} catch {
		use Data::Dumper;
		my $exception = DirectoryException->new({
			message => "Autoloader unable to automatically discover itself libraries.",
			code => "980a50f41",
			previous => $_
		});
		print Dumper $exception;
	};
	
	foreach my $library (@librariesDir){
		print "Library added to INC : $library\n" if $debugLib;
		push(@INC, qw($library));
	}
}

1;
__END__

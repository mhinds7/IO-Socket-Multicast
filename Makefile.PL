use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
	      NAME	=> 'IO::Socket::Multicast',
	      VERSION_FROM => 'Multicast.pm', # finds $VERSION
	      PREREQ_PM => {
			    'IO::Interface' => 0.94,
			   },
	      LIBS	=> [''],   # e.g., '-lm' 
	      DEFINE	=> '',     # e.g., '-DHAVE_SOMETHING' 
	      INC	=> '',     # e.g., '-I/usr/include/other' 
);

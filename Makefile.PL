use 5.010000;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Helios::App::ThumbnailGenerator',
    VERSION_FROM      => 'lib/Helios/App/ThumbnailGenerator.pm', # finds $VERSION
    PREREQ_PM         => {
                           Helios => 2.80,
                           Image::Magick => '6.6.9',
                           Image::Magick => 0.06,
                         }, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Helios/App/ThumbnailGenerator.pm', # retrieve abstract from module
       AUTHOR         => 'Andrew Johnson <lajandy at cpan dot org>') : ()),
	(ExtUtils::MakeMaker->VERSION >= 6.46 ? 
		(
			META_MERGE => 
			{
				'meta-spec' => { version => 1.4 },
				resources => 
				{
					repository => 'git://github.com/lajandy/helios-app-thumbnailgenerator.git',
				},
			},    	
    	) 
    	: ()
    ),
);


use ExtUtils::MakeMaker;

WriteMakefile( 
	'NAME'		=> 'Text::Wrap',
	'DISTNAME'	  => 'Text-Tabs+Wrap',
	'VERSION_FROM' => 'lib/Text/Wrap/Modern.pm',
	($] >= 5.005 ? 
		(
			ABSTRACT	=> 'Expand tabs and do simple line wrapping',
			AUTHOR		=> 'David Muir Sharnoff <muir@idiom.org>',
			META_MERGE	=> {
				resources  => {
					repository => 'http://github.com/muir/Text-Tabs-Wrap',
				}
			}
		) 
		: 
		()
	),
	'dist' => { COMPRESS=>"gzip", SUFFIX=>"gz" },
	);


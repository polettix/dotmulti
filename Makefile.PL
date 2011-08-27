use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'dotmulti',
    AUTHOR              => q{Flavio Poletti <flavio@polettix.it>},
    VERSION_FROM        => 'lib/dotmulti.pm',
    ABSTRACT            => 'One to rule them all',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
        'YAML'       => 0,
        'Dancer'     => 1.3070,
        'Plack::Request' => 0,
        'Template' => 0,
        'Dancer::Plugin::FlashNote' => 0,
        'JSON' => 0,
        'Redis' => 0,
        'Try::Tiny' => 0,
        'File::Slurp' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'whatever-*' },
);

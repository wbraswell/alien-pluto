#!/usr/bin/perl

use strict;
use warnings;
our $VERSION = 0.007_000;

use ExtUtils::MakeMaker;
use Alien::Build::MM;

BEGIN { 
    use Config;
    use English qw(-no_match_vars);  # for $OSNAME
}

# MS Windows OS, fix read-only blib/lib directory & enable GNU configure/make
my $configure_requires_windows = {};
if ( $OSNAME eq 'MSWin32' ) {
    push( @ExtUtils::MakeMaker::Overridable, qw(pm_to_blib) );
    $configure_requires_windows = {
        'Alien::MSYS'  => '0.08',
        'Alien::gmake' => '0.20',
    };
}

my $abmm = Alien::Build::MM->new;

WriteMakefile($abmm->mm_args(
    NAME         => 'Alien::Pluto',
    DISTNAME     => 'Alien-Pluto',
    ABSTRACT     => 'Find Or Download/Build/Install libpluto In Pluto',
    VERSION_FROM => 'lib/Alien/Pluto.pm',
    AUTHOR           => 'Will Braswell <wbraswell@cpan.org>',
    LICENSE          => 'perl_5',

    CONFIGURE_REQUIRES => {
        'IO::Socket::SSL'       => '2.043',
        'Alien::Build'          => '1.32',   # provides Alien::Build::MM
        # DEV NOTE, CORRELATION #ap020: must update Alien::Texinfo & Alien::bison & Alien::flex versions in BOTH alienfile & Makefile.PL
        'Alien::Texinfo'        => '0.005',  # Fix Candl Error, "makeinfo: command not found"
        'Alien::bison'          => '0.19',   # Fix Clan  Error, "configure: error: bison not found"
        'Alien::flex'           => '0.12',   # Fix Clan  Error, "configure: error: flex not found"
        %{$configure_requires_windows}
    },

    PREREQ_PM => {
        'Test2::Suite'          => '0.000072',  # provides Test2::V0
    },

    META_MERGE => {
        'meta-spec' => {
            version => '2',
            url     => 'https://metacpan.org/pod/CPAN::Meta::Spec'
        },

        release_status => 'stable',
        keywords       => [qw(alien pluto polycc candl cloog orio compiler parallel parallelization)],
        description    => 'Pluto PolyCC is a parallelizing compiler suite, written in C, compiled and installed via Alien',
        resources => {
            license    => ['http://dev.perl.org/licenses/'],
            homepage   => 'http://pluto-compiler.sourceforge.net/',
            bugtracker => { web => 'http://rt.cpan.org/Public/Dist/Display.html?Name=Alien-Pluto' },
            repository => {
                type => 'git',
                url  => 'git://github.com/wbraswell/alien-pluto.git',
                web  => 'https://github.com/wbraswell/alien-pluto',
            },
            x_IRC         => "irc://irc.perl.org/#native",
            x_mailinglist => "http://groups.google.com/group/pluto-development",
            x_wiki        => "https://en.wikipedia.org/wiki/Pluto_(disambiguation)",
        },
    },
));


package MY;
BEGIN { use English; }

sub postamble {
    $abmm->mm_postamble;
}

sub pm_to_blib {
    my $self = shift;
    my $blib = $self->SUPER::pm_to_blib(@_);

    # un-read-only blib/lib for tests to pass, files are modified at runtime there
    if ( $OSNAME eq 'MSWin32' ) {
        my ( $lastline, $start ) = qq{\t\$(NOECHO) \$(TOUCH) pm_to_blib\n};
        ( $start = index( $blib, $lastline ) ) == -1
            && die "Can't find replacement string for pm_to_blib target";
        substr( $blib, $start, 0, "\t" . 'attrib -R /S  blib/lib/*' . "\n" );
    }
    return $blib;
}

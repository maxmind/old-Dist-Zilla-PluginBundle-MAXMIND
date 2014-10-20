package Dist::Zilla::PluginBundle::MAXMIND;

use v5.10;

use strict;
use warnings;
use autodie;

use Dist::Zilla;

# Not used here, but we want it installed
use Pod::Weaver::Section::Contributors;

# For the benefit of AutoPrereqs
use Dist::Zilla::Plugin::Authority;
use Dist::Zilla::Plugin::AutoPrereqs;
use Dist::Zilla::Plugin::CPANFile;
use Dist::Zilla::Plugin::CheckPrereqsIndexed;
use Dist::Zilla::Plugin::CopyFilesFromBuild;
use Dist::Zilla::Plugin::EOLTests;
use Dist::Zilla::Plugin::Git::Check;
use Dist::Zilla::Plugin::Git::CheckFor::MergeConflicts;
use Dist::Zilla::Plugin::Git::Commit;
use Dist::Zilla::Plugin::Git::Contributors;
use Dist::Zilla::Plugin::Git::Describe;
use Dist::Zilla::Plugin::Git::Push;
use Dist::Zilla::Plugin::Git::Tag;
use Dist::Zilla::Plugin::GitHub::Meta;
use Dist::Zilla::Plugin::GitHub::Update;
use Dist::Zilla::Plugin::InstallGuide;
use Dist::Zilla::Plugin::MAXMIND::Contributors;
use Dist::Zilla::Plugin::Meta::Contributors;
use Dist::Zilla::Plugin::MetaConfig;
use Dist::Zilla::Plugin::MetaJSON;
use Dist::Zilla::Plugin::MetaProvides::Package;
use Dist::Zilla::Plugin::MetaResources;
use Dist::Zilla::Plugin::MinimumPerl;
use Dist::Zilla::Plugin::MojibakeTests;
use Dist::Zilla::Plugin::NextRelease;
use Dist::Zilla::Plugin::PkgVersion;
use Dist::Zilla::Plugin::PodCoverageTests;
use Dist::Zilla::Plugin::PodSyntaxTests;
use Dist::Zilla::Plugin::PromptIfStale;
use Dist::Zilla::Plugin::ReadmeAnyFromPod;
use Dist::Zilla::Plugin::SurgicalPodWeaver;
use Dist::Zilla::Plugin::Test::CPAN::Changes;
use Dist::Zilla::Plugin::Test::Compile;
use Dist::Zilla::Plugin::Test::NoTabs;
use Dist::Zilla::Plugin::Test::Pod::Coverage::Configurable;
use Dist::Zilla::Plugin::Test::Pod::LinkCheck;
use Dist::Zilla::Plugin::Test::Pod::No404s;
use Dist::Zilla::Plugin::Test::PodSpelling;
use Dist::Zilla::Plugin::Test::Portability;
use Dist::Zilla::Plugin::Test::ReportPrereqs;
use Dist::Zilla::Plugin::Test::Synopsis;

use Moose;

with 'Dist::Zilla::Role::PluginBundle::Easy',
    'Dist::Zilla::Role::PluginBundle::PluginRemover';

has dist => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has make_tool => (
    is      => 'ro',
    isa     => 'Str',
    default => 'MakeMaker',
);

has authority => (
    is      => 'ro',
    isa     => 'Str',
    default => 'MAXMIND',
);

has exclude_files => (
    is       => 'ro',
    isa      => 'ArrayRef[Str]',
    required => 1,
);

has prereqs_skip => (
    traits   => ['Array'],
    is       => 'ro',
    isa      => 'ArrayRef[Str]',
    required => 1,
    handles  => {
        _has_prereqs_skip => 'count',
    },
);

has pod_coverage_class => (
    is        => 'ro',
    isa       => 'Str',
    predicate => '_has_coverage_class',
);

has pod_coverage_skip => (
    traits   => ['Array'],
    is       => 'ro',
    isa      => 'ArrayRef[Str]',
    required => 1,
    handles  => {
        _has_coverage_skip => 'count',
    },
);

has pod_coverage_trustme => (
    traits   => ['Array'],
    is       => 'ro',
    isa      => 'ArrayRef[Str]',
    required => 1,
    handles  => {
        _has_coverage_trustme => 'count',
    },
);

has stopwords => (
    traits   => ['Array'],
    is       => 'ro',
    isa      => 'ArrayRef[Str]',
    required => 1,
);

has stopwords_file => (
    is        => 'ro',
    isa       => 'Str',
    predicate => '_has_stopwords_file',
);

has next_release_width => (
    is      => 'ro',
    isa     => 'Int',
    default => 8,
);

has _plugins => (
    is       => 'ro',
    isa      => 'ArrayRef',
    init_arg => undef,
    lazy     => 1,
    builder  => '_build_plugins',
);

{
    my @array_params = grep { !/^_/ } map { $_->name() }
        grep {
               $_->has_type_constraint()
            && $_->type_constraint()->is_a_type_of('ArrayRef')
        } __PACKAGE__->meta()->get_all_attributes();

    sub mvp_multivalue_args {
        return @array_params;
    }

    around BUILDARGS => sub {
        my $orig  = shift;
        my $class = shift;

        my $p = $class->$orig(@_);

        my %args = ( %{ $p->{payload} }, %{$p} );

        for my $key (@array_params) {
            if ( $args{$key} && !ref $args{$key} ) {
                $args{$key} = [ delete $args{$key} ];
            }
            $args{$key} //= [];
        }

        return \%args;
    };
}

sub _build_plugins {
    my $self = shift;

    my @allow_dirty = qw(
        Changes
        cpanfile
        CONTRIBUTING.md
        LICENSE
        Makefile.PL
        README.md
    );

    my %exclude_filename = map { $_ => 1 } qw(
        cpanfile
        LICENSE
        Makefile.PL
        README.md
    );

    my @exclude_match;
    for my $exclude ( @{ $self->exclude_files() } ) {
        if ( $exclude =~ m{^[\w\-\./]+$} ) {
            $exclude_filename{$exclude} = 1;
        }
        else {
            push @exclude_match, $exclude;
        }
    }

    my @plugins = (
        $self->make_tool(),
        [
            Authority => {
                authority  => 'cpan:' . $self->authority(),
                do_munging => 0,
            },
        ],
        [
            AutoPrereqs => {
                $self->_has_prereqs_skip() ? ( skip => $self->prereqs_skip() )
                : ()
            },
        ],
        [
            CopyFilesFromBuild => {
                copy => [qw( cpanfile LICENSE Makefile.PL )],
            },
        ],
        [
            GatherDir => {
                exclude_filename => [ keys %exclude_filename ],
                (
                    @exclude_match ? ( exclude_match => \@exclude_match ) : ()
                ),
            },
        ],
        [ 'GitHub::Meta'          => { bugs         => 1 }, ],
        [ 'GitHub::Update'        => { metacpan     => 1 }, ],
        [ 'MetaProvides::Package' => { meta_noindex => 1 }, ],
        [
            NextRelease => {
                      format => '%-'
                    . $self->next_release_width()
                    . 'v %{yyyy-MM-dd}d'
            },
        ],
        [
            'Test::Pod::Coverage::Configurable' => {
                (
                    $self->_has_coverage_skip()
                    ? ( skip => $self->pod_coverage_skip() )
                    : ()
                ),
                (
                    $self->_has_coverage_trustme()
                    ? ( trustme => $self->pod_coverage_trustme() )
                    : ()
                ),
                (
                    $self->_has_coverage_class()
                    ? ( class => $self->pod_coverage_class() )
                    : ()
                ),
            },
        ],
        [
            'Test::PodSpelling' => { stopwords => $self->_all_stopwords() },
        ],
        [ 'Test::ReportPrereqs' => { verify_prereqs => 1 }, ],
        [
            'Prereqs' => 'TestMoreDoneTesting' => {
                -phase       => 'test',
                -type        => 'requires',
                'Test::More' => '0.88',
            }
        ],
        [
            'PromptIfStale' => 'stale modules, release' => {
                phase             => 'release',
                check_all_plugins => 1,
                check_all_prereqs => 1,
            }
        ],
        [
            'ReadmeAnyFromPod' => 'ReadmeMarkdownInBuild' => {
                filename => 'README.md',
            },
        ],
        [
            'ReadmeAnyFromPod' => 'ReadmeMarkdownInRoot' => {
                filename => 'README.md',
            },
        ],
        [
            UploadToCPAN => { pause_cfg_file => '.pause-maxmind' },
        ],

        # from @Basic
        qw(
            PruneCruft
            ManifestSkip
            MetaYAML
            License
            ExtraTests
            ExecDir
            ShareDir
            Manifest
            TestRelease
            ConfirmRelease
            ),
        qw(
            CheckPrereqsIndexed
            CPANFile
            Git::CheckFor::CorrectBranch
            Git::CheckFor::MergeConflicts
            Git::Describe
            Git::Contributors
            InstallGuide
            MAXMIND::Contributors
            Meta::Contributors
            MetaConfig
            MetaJSON
            MinimumPerl
            PkgVersion
            SurgicalPodWeaver
            ),
        qw(
            EOLTests
            PodSyntaxTests
            Test::CPAN::Changes
            Test::Compile
            Test::NoTabs
            Test::Pod::LinkCheck
            Test::Pod::No404s
            Test::Portability
            Test::Synopsis
            ),

        # from @Git - note that the order here is important!
        [ 'Git::Check'  => { allow_dirty => \@allow_dirty }, ],
        [ 'Git::Commit' => { allow_dirty => \@allow_dirty }, ],
        qw(
            Git::Tag
            Git::Push
            ),
    );

    return \@plugins;
}

sub _all_stopwords {
    my $self = shift;

    my @stopwords = $self->_default_stopwords();
    push @stopwords, @{ $self->stopwords() };

    if ( $self->_has_stopwords_file() ) {
        open my $fh, '<:encoding(UTF-8)', $self->stopwords_file();
        push @stopwords, map { chomp; $_ } <$fh>;
        close $fh;
    }

    return \@stopwords;
}

sub _default_stopwords {
    qw(
        Alders
        Alders'
        Eilam
        Eilam's
        Oschwald
        Oschwald's
        Rolsky
        Rolsky's
    );
}

sub configure {
    my $self = shift;

    $self->add_plugins( @{ $self->_plugins } );

    return;
}

1;

# ABSTRACT: MaxMind's plugin bundle

__END__

=for Pod::Coverage .*

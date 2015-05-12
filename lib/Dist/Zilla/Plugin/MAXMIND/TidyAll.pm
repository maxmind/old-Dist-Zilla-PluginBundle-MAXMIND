package Dist::Zilla::Plugin::MAXMIND::TidyAll;

use v5.10;

use strict;
use warnings;
use autodie;
use namespace::autoclean;

our $VERSION = '0.10';

use Perl::Critic::Moose 1.01;

use Moose;

with qw(
    Dist::Zilla::Role::BeforeBuild
    Dist::Zilla::Role::TextTemplate
);

my $file_selection = <<'EOF';
select = **/*.{pl,pm,t,psgi}
ignore = t/00-*
ignore = t/author-*
ignore = t/release-*
ignore = blib/**/*
ignore = .build/**/*
ignore = {{$dist}}-*/**/*
EOF
chomp $file_selection;

my $tidyall_ini_template = <<"EOF";
[PerlTidy]
$file_selection
argv = --profile=\$ROOT/perltidyrc

[PerlCritic]
$file_selection
argv = --profile \$ROOT/perlcriticrc --program-extensions .pl  --program-extensions .t --program-extensions .psgi
EOF

my $perltidyrc = <<'EOF';
--blank-lines-before-packages=0
--iterations=2
--no-outdent-long-comments
-b
-bar
-boc
-ci=4
-i=4
-l=78
-nolq
-se
-wbb="% + - * / x != == >= <= =~ !~ < > | & >= < = **= += *= &= <<= &&= -= /= |= >>= ||= .= %= ^= x="
EOF

my $perlcriticrc = <<'EOF';
severity = 3
verbose = 11

theme = core + pbp + bugs + maintenance + cosmetic + complexity + security + tests + moose

exclude = Subroutines::ProhibitCallsToUndeclaredSubs

[BuiltinFunctions::ProhibitStringySplit]
severity = 3

[CodeLayout::RequireTrailingCommas]
severity = 3

[ControlStructures::ProhibitCStyleForLoops]
severity = 3

[InputOutput::RequireCheckedSyscalls]
functions = :builtins
exclude_functions = sleep
severity = 3

[Moose::RequireCleanNamespace]
modules = Moose Moose::Role MooseX::Role::Parameterized Moose::Util::TypeConstraints
cleaners = namespace::autoclean

[NamingConventions::Capitalization]
package_exemptions = [A-Z]\w+|minFraud
file_lexical_variables = [A-Z]\w+|[^A-Z]+
global_variables = :starts_with_upper
scoped_lexical_variables = [A-Z]\w+|[^A-Z]+
severity = 3

# Given our code base, leaving this at 5 would be a huge pain
[Subroutines::ProhibitManyArgs]
max_arguments = 10

[RegularExpressions::ProhibitComplexRegexes]
max_characters = 200

[RegularExpressions::ProhibitUnusualDelimiters]
severity = 3

[Subroutines::ProhibitUnusedPrivateSubroutines]
private_name_regex = _(?!build)\w+
skip_when_using = Moo::Role Moose::Role MooseX::Role::Parameterized Role::Tiny Test::Class::Moose::Role

[TestingAndDebugging::ProhibitNoWarnings]
allow = redefine

[ValuesAndExpressions::ProhibitEmptyQuotes]
severity = 3

[ValuesAndExpressions::ProhibitInterpolationOfLiterals]
severity = 3

[ValuesAndExpressions::RequireUpperCaseHeredocTerminator]
severity = 3

[Variables::ProhibitPackageVars]
add_packages = Test::Builder

[TestingAndDebugging::RequireUseStrict]

[TestingAndDebugging::RequireUseWarnings]

[-ControlStructures::ProhibitCascadingIfElse]

[-ErrorHandling::RequireCarping]
[-InputOutput::RequireBriefOpen]

[-ValuesAndExpressions::ProhibitConstantPragma]

# No need for /xsm everywhere
[-RegularExpressions::RequireDotMatchAnything]
[-RegularExpressions::RequireExtendedFormatting]
[-RegularExpressions::RequireLineBoundaryMatching]

[-Subroutines::ProhibitExplicitReturnUndef]

# http://stackoverflow.com/questions/2275317/why-does-perlcritic-dislike-using-shift-to-populate-subroutine-variables
[-Subroutines::RequireArgUnpacking]

[-Subroutines::RequireFinalReturn]

# "use v5.14" is more readable than "use 5.014"
[-ValuesAndExpressions::ProhibitVersionStrings]
EOF

sub before_build {
    my $self = shift;

    $self->_maybe_write_file(
        'tidyall.ini',
        $self->fill_in_string(
            $tidyall_ini_template,
            { dist => $self->zilla()->name() },
        ),
    );

    $self->_maybe_write_file( 'perlcriticrc', $perlcriticrc );
    $self->_maybe_write_file( 'perltidyrc',   $perltidyrc );

    return;
}

sub _maybe_write_file {
    my $self    = shift;
    my $file    = shift;
    my $content = shift;

    return if -e $file;

    open my $fh, '>', $file;
    print {$fh} $content
        or die "Cannot write to $file: $!";
    close $fh;

    return;
}

__PACKAGE__->meta->make_immutable;

1;

# ABSTRACT: Creates default tidyall.ini, perltidyrc, and perlcriticrc files if they don't yet exist

__END__

=for Pod::Coverage .*

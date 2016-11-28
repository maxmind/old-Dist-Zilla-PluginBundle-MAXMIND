package Dist::Zilla::Plugin::MAXMIND::Contributors;

use v5.10;

use strict;
use warnings;
use autodie;
use namespace::autoclean;

our $VERSION = '0.14';

use Dist::Zilla::File::InMemory;

use Moose;

with 'Dist::Zilla::Role::BeforeBuild', 'Dist::Zilla::Role::AfterBuild';

my $weaver_ini = <<'EOF';
[@CorePrep]

[Name]
[Version]

[Region  / prelude]

[Generic / SYNOPSIS]
[Generic / DESCRIPTION]

[Leftovers]

[Region  / postlude]

[Authors]
[Contributors]
[Legal]
EOF

my %mailmap = map { $_ => 1 } (
    'Dave Rolsky <drolsky@maxmind.com> <autarch@urth.org>',
    'Greg Oschwald <goschwald@maxmind.com> Gregory Oschwald <goschwald@maxmind.com>',
    'Greg Oschwald <goschwald@maxmind.com> <oschwald@gmail.com>',
    'Mateu X Hunter <mhunter@maxmind.com> <hunter@missoula.org>',
    'Olaf Alders <oalders@maxmind.com> <olaf@wundersolutions.com>',
    'Ran Eilam <reilam@maxmind.com> <ran.eilam@gmail.com>',
    'Ran Eilam <reilam@maxmind.com> <eilara@users.noreply.github.com>',
);

# These files need to actually exist on disk for the Pod::Weaver plugin to see
# them, so we can't simply add them as InMemory files via file injection.
sub before_build {
    my $self = shift;

    $self->_write_weaver_ini;
    $self->_write_mailmap;

    return;
}

sub _write_weaver_ini {
    my $self = shift;

    return if -f 'weaver.ini';

    open my $fh, '>', 'weaver.ini';
    print {$fh} $weaver_ini or die $!;
    close $fh;

    return;
}

sub _write_mailmap {
    my $self = shift;

    if ( -f '.mailmap' ) {
        open my $fh, '<:encoding(UTF-8)', '.mailmap';
        while (<$fh>) {
            chomp;
            $mailmap{$_} = 1;
        }
        close $fh;
    }

    open my $fh, '>:encoding(UTF-8)', '.mailmap';
    for ( sort keys %mailmap ) {
        print {$fh} $_, "\n" or die $!;
    }
    close $fh;

    return;
}

sub after_build {
    my $self = shift;

    unlink 'weaver.ini';

    return;
}

__PACKAGE__->meta->make_immutable;

1;

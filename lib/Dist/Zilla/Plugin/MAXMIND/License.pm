package Dist::Zilla::Plugin::MAXMIND::License;

use v5.10;

use strict;
use warnings;
use autodie;

use Software::License::Perl_5;

use Moose;

with 'Dist::Zilla::Role::LicenseProvider';

sub provide_license {
    my $self = shift;
    my $args = shift;

    my $year      = $args->{copyright_year};
    my $this_year = (localtime)[5] + 1900;
    my $years     = $year == $this_year ? $year : "$year - $this_year";

    return Software::License::Perl_5->new(
        {
            holder => 'MaxMind, Inc.',
            year => $years,
        },
    );
}

__PACKAGE__->meta->make_immutable;

1;

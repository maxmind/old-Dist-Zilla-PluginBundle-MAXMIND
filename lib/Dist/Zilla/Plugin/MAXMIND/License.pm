package Dist::Zilla::Plugin::MAXMIND::License;

use v5.10;

use strict;
use warnings;
use autodie;

use Module::Runtime qw( use_module );
use String::RewritePrefix;

use Moose;

with 'Dist::Zilla::Role::LicenseProvider';

sub provide_license {
    my $self = shift;
    my $args = shift;

    my $year      = $args->{copyright_year};
    my $this_year = (localtime)[5] + 1900;
    my $years     = $year == $this_year ? $year : "$year - $this_year";

    my $license_class = String::RewritePrefix->rewrite(
        {
            '=' => q{},
            q{} => 'Software::License::'
        },
        $self->zilla()->_license_class() // 'Artistic_2_0',
    );

    use_module($license_class);

    return $license_class->new(
        {
            holder => $args->{copyright_holder} || 'MaxMind, Inc.',
            year => $years,
        },
    );
}

__PACKAGE__->meta->make_immutable;

1;

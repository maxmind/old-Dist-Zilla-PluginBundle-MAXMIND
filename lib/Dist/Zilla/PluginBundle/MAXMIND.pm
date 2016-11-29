package Dist::Zilla::PluginBundle::MAXMIND;

use v5.10;

use strict;
use warnings;
use autodie;
use namespace::autoclean;

our $VERSION = '0.17';

use Dist::Zilla::PluginBundle::DROLSKY 0.78;

use Moose;

extends 'Dist::Zilla::PluginBundle::DROLSKY';

has '+authority' => (
    default => 'MAXMIND',
);

has '+use_github_issues' => (
    default => 1,
);

my %ReplacedPlugins
    = map { 'DROLSKY::' . $_ => 'MAXMIND::' . $_ } qw( Contributors License );
$ReplacedPlugins{UploadToCPAN}
    = [ UploadToCPAN => { pause_cfg_file => '.pause-maxmind' } ];

around _build_plugins => sub {
    my $orig = shift;
    my $self = shift;

    my $plugins = $self->$orig;

    return [ map { $ReplacedPlugins{$_} || $_ } @{$plugins} ];
};

around _default_stopwords => sub {
    my $orig = shift;
    my $self = shift;

    return (
        $self->$orig,
        qw(
            Alders
            Alders'
            Eilam
            Eilam's
            MaxMind
            MaxMind's
            Oschwald
            Oschwald's
            Rolsky
            Rolsky's
            )
    );
};

around _prompt_if_stale_plugin => sub {
    my $orig = shift;
    my $self = shift;

    my @plugin = $self->$orig();

    for my $p (@plugin) {
        next unless $p->[-1]{skip};
        $p->[-1]{skip}
            = [ map { _maybe_rename_skip($_) } @{ $p->[-1]{skip} } ];
    }

    return @plugin;
};

sub _maybe_rename_skip {
    my $plugin = shift;

    ( my $short = $plugin ) =~ s/.+(?=DROLSKY)//;
    return $plugin unless $ReplacedPlugins{$short};

    $plugin =~ s/DROLSKY/MAXMIND/;

    return $plugin;
}

# use BUILDARGS to add default pod_coverage_also_private to ignore special Moose
# subs.  Why isn't this just an additional default on the attribute? Because the
# config parser for dzil will always pass in an empty arrayref even if no value
# is set in the config file, meaning that a default attribute value will never
# be used
around BUILDARGS => sub {
    my $orig = shift;
    my $self = shift;

    my $args = $orig->( $self, @_ );
    $args->{pod_coverage_also_private} = [
        'qr/\\A (?: BUILD(?:ARGS)? | DEMOLISH ) \\z/x',
        @{ $args->{pod_coverage_also_private} || [] },
    ];

    return $args;
};

__PACKAGE__->meta->make_immutable;

1;

# ABSTRACT: MaxMind's plugin bundle

__END__

=for Pod::Coverage .*

#!/usr/bin/env perl

=head1 NAME

wnck-fix-panel.pl - Make sure that the top panel is on top

=head1 SYNOPSIS

wnck-fix-panel.pl [OPTION]...

    -v, --verbose          run in verbose mode            
    -h, --help             print this help message

=head1 DESCRIPTION

This script makes sure the the top panel (system dock) is always at the top of
the screen. Sometimes the panel is only at the top of my laptop's main screen.

=cut


use strict;
use warnings;

use Data::Dumper;
use File::Basename 'basename';
use Getopt::Long qw(:config auto_help);
use Pod::Usage;

use Gtk3 '-init';

use Glib::Object::Introspection;
Glib::Object::Introspection->setup(
  basename => 'Wnck',
  version  => '3.0',
  package  => 'Wnck'
);


sub main {
    GetOptions(
        'v|verbose' => \my $verbose,
    ) or pod2usage(1);

    my $screen = Wnck::Screen->get_default;
    $screen->force_update();

    my ($screen_width, $screen_height) = ($screen->get_width, $screen->get_height);
    printf "Screen: %sx%s\n", $screen_width, $screen_height if $verbose;

    my $windows = $screen->get_windows;
    foreach my $window (@$windows) {

        # Look for a panel
        my $type = $window->get_window_type;
        next unless $type eq 'dock';

        # With the right name (an horizontal panel)
        my $name = $window->get_name or next;
        next unless $name =~ /^(?:Top|Bottom) Expanded Edge Panel$/;

        my ($x, $y, $w, $h) = ($window->get_geometry);
        printf "%s\n %4s: %4d\n %4s: %4d\n %4s: %sx%s\n",
            $name,
            x => $x,
            y => $y,
            size => $w, $h,
            if $verbose;

        # Ignore the panel at the bottom or if already placed at the top
        next if $y + $h == $screen_height or $y == 0;

        print "Move $name to top (x: $x; y: $y)\n" if $verbose;
        $window->set_geometry(
            'current',
            ['y', , 'width', ],
            $x, 0, $screen_width, $h
        );
    }

    return 0;
}


exit main() unless caller;

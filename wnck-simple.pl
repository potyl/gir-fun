#!/usr/bin/env perl

=head1 NAME

wnck-simple.pl - Shows applications running

=head1 SYNOPSIS

wnck-simple.pl [OPTION]...

    -h, --help             print this help message

=head1 DESCRIPTION

This script list all GUI applications. It also tries to detect the text editor
used to edit the script's source file and maximizes it.

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
    GetOptions() or pod2usage(1);

    my $screen = Wnck::Screen->get_default;
    $screen->force_update();

    my ($width, $height) = ($screen->get_width, $screen->get_height);
    printf "Screen size: %s x %s\n", $width, $height;

    my $window_manager = $screen->get_window_manager_name;
    print "Window manager: $window_manager\n";

    # Regexp to match this script's name
    my $file_re = quotemeta(basename(__FILE__));
    $file_re = qr/$file_re/;

    my $windows = $screen->get_windows;
    foreach my $window (@$windows) {
        my $name = $window->get_name || 'No name';
        my $type = $window->get_window_type;


        # Find the editor that's editing this file and maximize it
        if ($name =~ /$file_re/) {
            $window->maximize();
        }


        printf "%4d - %s (%s)",
            $window->get_pid,
            $name,
            $type,
        ;

        my $state = $window->get_state;
        printf " [State: %s]", join(", ", @$state) if @$state;

        print "\n";
    }

    return 0;
}

exit main() unless caller;

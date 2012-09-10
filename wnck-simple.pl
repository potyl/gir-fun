#!/usr/bin/env perl

use strict;
use warnings;

use Data::Dumper;
use File::Basename 'basename';

use Gtk3;

use Glib::Object::Introspection;
Glib::Object::Introspection->setup(
  basename => 'Wnck',
  version  => '3.0',
  package  => 'Wnck'
);


sub main {

    Gtk3->init();

    my $screen = Wnck::Screen->get_default;
    $screen->force_update();

    my ($width, $height) = ($screen->get_width, $screen->get_height);
    printf "size: %s x %s\n", $width, $height; 

    my $window_manager = $screen->get_window_manager_name;
    print "Window manager: $window_manager\n";

    # Regexp to match this script's name
    my $file_re = quotemeta(basename(__FILE__));
    $file_re = qr/$file_re/;

    my $windows = $screen->get_windows;
    foreach my $window (@$windows) {
        next unless $window->has_name;
        my $name = $window->get_name;

        # Find the editor that's editing this file and maximize it
        if ($name =~ /$file_re/) {
            $window->maximize();
            last;
        }
    }

    return 0;
}

exit main() unless caller;

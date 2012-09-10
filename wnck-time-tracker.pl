#!/usr/bin/env perl

use strict;
use warnings;

use Data::Dumper;

use Glib ':constants';
use Gtk3 '-init';

use Glib::Object::Introspection;
Glib::Object::Introspection->setup(
  basename => 'Wnck',
  version  => '3.0',
  package  => 'Wnck'
);


my %APPS;
my $CURRENT = '';
my $CLOCK;
my $QUIT;

sub main {
    binmode STDOUT, ':utf8';

    my $screen = Wnck::Screen->get_default;

    # Find the current active window
    Glib::Idle->add(\&cb_find_current_window, $screen);

    # Detect each time that we focus a new window
    $screen->signal_connect("active-window-changed" => \&cb_active_window_changed);

    # Show the total times accumulated so far each second
    Glib::Timeout->add(1_000, \&cb_show_time_elapsed);

    local $SIG{INT}  = sub {
        $QUIT = 1;
        cb_show_time_elapsed();
    };
    local $SIG{TERM} = $SIG{INT};

    $CLOCK = time;
    Gtk3->main();

    return 0;
}


sub cb_find_current_window {
    my ($screen) = @_;

    my $window = $screen->get_active_window;
    my $app = $window->get_application or return;
    my $app_name = $app->get_name;
    $CURRENT = $app_name;
    $APPS{$CURRENT} = 0 if $CURRENT;
}


sub cb_show_time_elapsed {
    return 1 unless keys %APPS;

    print "-----------------\n";
    foreach my $app_name (sort keys %APPS) {
        my $marker = ' ';
        my $elapsed = $APPS{$app_name} || 0;
        if ($app_name eq $CURRENT) {
            $marker = '*';
            $elapsed += time - $CLOCK;
        }
        printf "%s%s: %s\n", $marker, $app_name, $elapsed;
    }
    print "\n";

    if ($QUIT) {
        Gtk3->main_quit();
        return 0;
    }

    return 1;
}


sub cb_active_window_changed {
    my ($screen, $previous_window) = @_;
    my $time = time;
    my $app_name;
    if (defined $previous_window) {
        my $app = $previous_window->get_application;
        $app_name = $app ? $app->get_name : $CURRENT;
    }
    else {
        $app_name = $CURRENT;
    }

    my $elapsed = $time - $CLOCK;
    $APPS{$app_name} += $elapsed if $app_name;

    my $active_window = $screen->get_active_window;
    if ($active_window) {
        if (! ($active_window->is_skip_pager or $active_window->is_skip_tasklist) ) {
            $CURRENT = $active_window->get_application->get_name;
            $APPS{$CURRENT} += 0;
            $CLOCK = $time;
        }
    }
}


exit main() unless caller;

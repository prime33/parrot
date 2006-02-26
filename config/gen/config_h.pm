# Copyright: 2001-2003 The Perl Foundation.  All Rights Reserved.
# $Id$

=head1 NAME

config/gen/config_h.pm - Configuration Header

=head1 DESCRIPTION

Generates F<include/parrot/config.h> with platform-specific configuration
values, F<include/parrot/has_header.h> with platform-specific header
information, and F<include/parrot/feature.h> with information on optional
features.

=cut

package gen::config_h;

use strict;
use vars qw($description @args);

use base qw(Parrot::Configure::Step::Base);

use Parrot::Configure::Step ':gen';

$description = 'Generating C headers';

@args = ('define');

sub runstep
{
    my ($self, $conf) = @_;

    genfile(
        'config/gen/config_h/config_h.in', 'include/parrot/config.h',
        commentType       => '/*',
        ignorePattern     => 'PARROT_CONFIG_DATE',
        conditioned_lines => 1
    );

    genfile(
        'config/gen/config_h/feature_h.in', 'include/parrot/feature.h',
        commentType   => '/*',
        ignorePattern => 'PARROT_CONFIG_DATE',
        feature_file  => 1
    );

    my $hh = "include/parrot/has_header.h";
    open(HH, ">$hh.tmp")
        or die "Can't open has_header.h: $!";

    print HH <<EOF;
/*
** !!!!!!!   DO NOT EDIT THIS FILE   !!!!!!!
**
** This file is generated automatically by Configure.pl
*/

/*
 * i_(\\w+) header includes
 */

EOF

    for (sort($conf->data->keys())) {
        next unless /i_(\w+)/;
        if ($conf->data->get($_)) {
            print HH "#define PARROT_HAS_HEADER_\U$1 1\n";
        } else {
            print HH "#undef  PARROT_HAS_HEADER_\U$1\n";
        }
    }

    print HH "\n#define BUILD_OS_NAME \"$^O\"\n";

    my $define = $conf->options->get('define');

    if ($define) {
        my @vals = split /,/, $define;
        print HH <<EOF;

/*
 * defines from commandline
 */

EOF
        for (@vals) {
            print HH "#define PARROT_DEF_" . uc($_), " 1\n";
        }

    }

    print HH <<EOF;

/*
 * HAS_(\\w+) config entries
 */

EOF
    for (sort($conf->data->keys())) {
        next unless /HAS_(\w+)/;
        if ($conf->data->get($_)) {
            print HH "#define PARROT_HAS_\U$1 1\n";
        }
    }
    print HH <<EOF;

/*
 * D_(\\w+) config entries
 */

EOF
    for (sort($conf->data->keys())) {
        next unless /D_(\w+)/;
        my $val;
        if ($val = $conf->data->get($_)) {
            print HH "#define PARROT_\U$1 $val\n";
        }
    }

    close HH;

    move_if_diff("$hh.tmp", $hh);

    return $self;
}

1;

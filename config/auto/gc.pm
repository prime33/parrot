# Copyright (C) 2001-2007, The Perl Foundation.
# $Id$

=head1 NAME

config/auto/gc.pm - Garbage Collection

=head1 DESCRIPTION

Checks whether the C<--gc> command-line option was passed to F<Configure.pl>
and sets the memory allocator accordingly.

C<--gc> can take the values:

=over

=item C<gc>

The default. Use the memory allocator in F<src/recources.c>.

=item C<libc>

Use the C library C<malloc> along with F<src/gc/res_lea.c>.
This doesn't work.  See [perl #42774].

=item C<malloc>

Use the malloc in F<src/malloc.c> along with F<src/gc/res_lea.c>.
Since this uses res_lea.c, it doesn't work either.  See [perl #42774].

=item C<malloc-trace>

Use the malloc in F<src/malloc-trace.c> with tracing enabled, along
with F<src/gc/res_lea.c>.
Since this uses res_lea.c, it doesn't work either.  See [perl #42774].

=back

=cut

package auto::gc;

use strict;
use warnings;

use base qw(Parrot::Configure::Step::Base);

use Parrot::Configure::Step ':auto';


# valid libc/malloc/malloc-trace/gc
sub _init {
    my $self = shift;
    my %data;
    $data{description} = q{Determining what allocator to use};
    $data{args}        = [ qw( gc verbose ) ];
    $data{result}      = q{};
    return \%data;
}

sub runstep {
    my ( $self, $conf ) = @_;

    my $gc = $conf->options->get('gc');

    if ( !defined($gc) ) {

        # default is GC in resources.c
        $gc = 'gc';
    }
    elsif ( $gc eq 'libc' ) {

        # tests mallinfo after allocation of 128 bytes
        if ( $conf->data->get('i_malloc') ) {
            $conf->data->set( malloc_header => 'malloc.h' );
        }
        else {
            $conf->data->set( malloc_header => 'stdlib.h' );
        }

=for nothing

    cc_gen('config/auto/gc/test_c.in');
    eval { cc_build(); };
    my $test = 0;
    unless ($@) {
      $test = cc_run();
    }
    cc_clean();
    # used size should be somewhere here
    unless ($test >= 128 && $test < 155) {
      # if not, use own copy of malloc
      $gc = 'malloc';
    }

=cut

    }

    if ( $gc =~ /^malloc(?:-trace)?$/ ) {
        $conf->data->set(
            TEMP_gc_c => <<"EOF",
\$(SRC_DIR)/$gc\$(O):	\$(GENERAL_H_FILES) \$(SRC_DIR)/$gc.c
\$(SRC_DIR)/gc/res_lea\$(O):	\$(GENERAL_H_FILES) \$(SRC_DIR)/gc/res_lea.c
EOF
            TEMP_gc_o => "\$(SRC_DIR)\/$gc\$(O) \$(SRC_DIR)/gc/res_lea\$(O)",
            gc_flag   => '-DGC_IS_MALLOC',
        );
    }
    elsif ( $gc eq 'libc' ) {
        $conf->data->set(
            TEMP_gc_c => <<"EOF",
\$(SRC_DIR)/gc/res_lea\$(O):	\$(GENERAL_H_FILES) \$(SRC_DIR)/gc/res_lea.c
EOF
            TEMP_gc_o => "\$(SRC_DIR)/gc/res_lea\$(O)",
            gc_flag   => '-DGC_IS_MALLOC',
        );
    }
    else {
        $gc = 'gc';
        $conf->data->set(
            TEMP_gc_c => <<"EOF",
\$(SRC_DIR)/gc/resources\$(O):	\$(GENERAL_H_FILES) \$(SRC_DIR)/gc/resources.c
EOF
            TEMP_gc_o => "\$(SRC_DIR)/gc/resources\$(O)",
            gc_flag   => '',
        );
    }
    print(" ($gc) ") if $conf->options->get('verbose');

    return 1;
}

1;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:

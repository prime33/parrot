## $Id$

=head1 NAME

src/classes/Junction.pir - Perl 6 Junction

=head1 Methods

=over 4

=cut

.namespace ['Junction']

# Constants for types of junctions.
.const int JUNCTION_TYPE_ALL  = 1
.const int JUNCTION_TYPE_ANY  = 2
.const int JUNCTION_TYPE_ONE  = 3
.const int JUNCTION_TYPE_NONE = 4

.sub 'onload' :anon :load :init
    $P0 = subclass 'Perl6Object', 'Junction'
    addattribute $P0, "@values"
    addattribute $P0, "$type"
    $P1 = get_hll_global ['Perl6Object'], 'make_proto'
    $P1($P0, 'Junction')
.end


=item values()

Get the values in the junction.

=cut

.sub 'values' :method
    $P0 = getattribute self, "@values"
    $P0 = clone $P0
    .return($P0)
.end


=item !values(...)

Private method to sets the values in the junction.

=cut

.sub '!values' :method
    .param pmc list
    setattribute self, "@values", list
.end


=item !type(...)

Private method to set the type of the junction.

=cut

.sub '!type' :method
    .param pmc type     :optional
    .param int got_type :optional
    if got_type goto ret_type
    setattribute self, "$type", type
    .return()
ret_type:
    type = getattribute self, "$type"
    .return(type)
.end


=item pick()

Gets a random value from the junction.

=cut

.sub 'pick' :method
    # Need to know the number of elements.
    .local pmc values
    values = getattribute self, "@values"
    .local int elems
    elems = elements values

    # Get random index.
    .local int idx
    idx = 'prefix:rand'(elems)

    # Return that value.
    $P0 = values[idx]
    .return($P0)
.end


=item clone

Clone v-table method.

=cut

.sub 'clone' :method :vtable
    .local pmc junc
    junc = new 'Junction'

    # Copy values and set type.
    $P0 = self.'values'()
    $P0 = clone $P0
    junc.'!values'($P0)
    $P0 = self.'!type'()
    junc.'!type'($P0)

    .return(junc)
.end


=item inc

Increment v-table method.

=cut

.sub 'increment' :method :vtable
    .local pmc values
    .local pmc elem
    .local int count
    .local int i

    # Get values array.
    values = getattribute self, "@values"

    # Loop over it and call inc on each element.
    count = elements values
    i = 0
loop:
    if i >= count goto loop_end
    elem = values[i]
    inc elem
    values[i] = elem
    inc i
    goto loop
loop_end:
.end


=item dec

Decrement v-table method.

=cut

.sub 'decrement' :method :vtable
    .local pmc values
    .local pmc elem
    .local int count
    .local int i

    # Get values array.
    values = getattribute self, "@values"

    # Loop over it and call dec on each element.
    count = elements values
    i = 0
loop:
    if i >= count goto loop_end
    elem = values[i]
    dec elem
    values[i] = elem
    inc i
    goto loop
loop_end:
.end


=back

=cut

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:

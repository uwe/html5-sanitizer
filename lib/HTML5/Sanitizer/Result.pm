package HTML5::Sanitizer::Result;
# ABSTRACT: capture interim results (mainly for debugging/testing)

use Moose;


has input         => (is => 'ro');
has preprocessed  => (is => 'ro');
has parsed_doc    => (is => 'ro');
has converted_doc => (is => 'ro');
has output        => (is => 'ro');

has specification => (is => 'ro');
has profile       => (is => 'ro');


sub debug_output {
    my ($self) = @_;

    return sprintf(<<EOF,
Input:
%s
Preprocessed:
%s
Parsed:
%s
Converted:
%s
Output:
%s
EOF
        $self->input,
        $self->preprocessed,
        $self->parsed_doc->toString,
        $self->converted_doc->toString,
        $self->output,
    );
}


no Moose;
__PACKAGE__->meta->make_immutable;

1;

=pod

=head1 DESCRIPTION

Capture the output of the different processing phases to aid debugging.

You activate this class by passing C<< {return_result => 1} >> to the
<HTML5::Sanitizer/process> call (as a second parameter). You could also set it
at construction time.

=head1 METHODS

=head2 new

Constructor. It takes the following parameters (each represet the input or the
result of the specific processing phases):

=over 4

=item input

=item preprocessed

=item parsed_doc

=item converted_doc

=item output

=item specification

=item profile

=back

=head2 debug_output

Returns a string representation of all data.

=cut

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

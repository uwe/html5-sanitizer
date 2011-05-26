package Converter;

# disable optimizer

use Moose;

extends 'HTML5::Sanitizer::Converter';


has no_optimizer => (is => 'rw', isa => 'Bool');


around optimize => sub {
    my ($orig, $self, $new_node) = @_;

    return $new_node if $self->no_optimizer;

    return $self->$orig($new_node);
};


no Moose;
__PACKAGE__->meta->make_immutable;

1;

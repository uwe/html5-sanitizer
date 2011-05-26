package HTML5::Sanitizer::Preprocessor;
# ABSTRACT: (optional) preprocessing of HTML

use Moose;


sub process {
    my ($self, $input) = @_;

    # do not change anything (use sub classes)

    return $input;
}


no Moose;
__PACKAGE__->meta->make_immutable;

1;

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

=pod

=head1 DESCRIPTION

Modifies the input string (before it is passed to the
L<HTML5::Sanitizer::Parser|parser>). This can be used for migration scenarios,
e. g. where you want to convert wiki syntax to HTML before sanitizing it.

This class is an empty place holder. You should built your own.

=head1 METHODS

=head2 new

Constructor. Doesn't take any parameters.

=head2 process

Given an input string it returns a HTML string.

Remember: This class does nothing, built your own class.

=cut

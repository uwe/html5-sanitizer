use strict;
use warnings;

use Test::Most;
use File::Slurp qw/read_file/; ###TODO###

use HTML5::Sanitizer;

use FindBin;
use lib "$FindBin::Bin/lib";
use Converter;
use Profile;


my %COMMAND = (
    CHOMP       => 'chomp',
    MULTILINE   => 'multiline',
    OPTIMIZE    => 'optimize',
    TEXTEXPORT  => 'textexport',
    TODO        => 'todo',
    TRIM        => 'trim',
);


my $sanitizer = HTML5::Sanitizer->new(
    converter     => Converter->new,
    profile       => Profile->new,
    return_result => 1,
);


oldstyle_diff;


# get list of files
my @files = glob("$FindBin::Bin/spec/c*.txt");

# read spec files and run test cases
foreach my $file (@files) {
    my %state = (
        chomp     => 0,
        expected  => '',
        file      => $file,
        input     => '',
        line_no   => 0,
        multiline => 0,
        optimize  => 0,
        todo      => 0,
        trim      => 0,
    );

    my @expected = ();
    foreach my $line (read_file $file) {
        chomp $line;
        $state{line_no}++;

        # commands start with ###
        if ($line =~ /^###([A-Z]+)/) {
            if (my $key = $COMMAND{$1}) {
                $state{$key} = 1;
                next;
            } else {
                die "Unknown command: $line ($file)";
            }
        }

        # comments start with #
        next if $line =~ /^#/;

        if ($state{multiline}) {
            # 1: read input
            if ($state{multiline} == 1) {
                # --- separates input and expected
                if ($line eq '---') {
                    $state{multiline} = 2;
                    chomp $state{input};
                }
                else {
                    $state{input} .= "$line\n";
                }
                next;
            }
            elsif ($state{multiline} == 2) {
                # === ends multiline input
                if ($line eq '===') {
                    chomp $state{expected};
                    # no next -> continue with test case

                    @expected = ($state{expected});
                }
                else {
                    $state{expected} .= $line;
                    $state{expected} .= "\n" unless $state{chomp};
                    next;
                }
            }
        }
        else {
            next unless $line;

            ($state{input}, @expected) = split / +:: /, $line;
        }

        # correct expected
        foreach (@expected) {
            $_ = '' if $_ eq '_EMPTY_';
            $_ =~ s/>\s+</></g if $state{trim};
        }
        $state{expected} = [@expected]; # do not use \@expected

        # run test
        $sanitizer->converter->no_optimizer(!$state{optimize});

        my $result = $sanitizer->process($state{input});
        my $got    = $result->output;

        if ($state{trim}) {
            $got =~ s/>\s+</></g;
        }

        # remove version tag
        ###TODO### $got =~ s|^<!--.+?-->||;

        # marked as TODO?
        if ($state{todo}) {
            TODO: {
                my $snippet = substr($state{input}, 0, 40);
                $snippet .= '...' if length($state{input}) > length($snippet);
                local $TODO = $snippet;
                is($got, $state{expected}[0]);
            }
        } else {
            eq_or_diff($got, $state{expected}[0], $state{file}.' line '.$state{line_no}) or do {
                diag $result->debug_output;
                diag sprintf("Exp:\n%s\n", $state{expected}[0]);
            }
        }

        # reset state
        $state{$_} = 0  foreach (qw/chomp multiline todo/);
        $state{$_} = '' foreach (qw/expected input/);
    }
}

done_testing;

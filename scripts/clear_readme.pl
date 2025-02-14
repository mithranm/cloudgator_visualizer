use strict;
use warnings;
use File::Path qw(rmtree);

# Remove the 'output' directory if it exists
if (-d 'r_output') {
    rmtree('r_output') or die "Failed to remove 'output' directory: $!";
}

# Remove README files if they exist
for my $file ('README.md', 'README.html', 'README.Rmd') {
    if (-e $file) {
        unlink $file or warn "Could not remove $file: $!";
    }
}

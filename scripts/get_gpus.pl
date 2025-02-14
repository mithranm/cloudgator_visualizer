#!/usr/bin/perl
use strict;
use warnings;
use File::Find;
use File::Path qw(make_path);
use Text::CSV;
use File::Basename;

# Define directories
my $raw_data_dir = "raw_data";
my $output_dir   = "output";
my $output_file  = "$output_dir/gpu_list.txt";

# Create output directory if it doesn't exist
unless (-d $output_dir) {
    make_path($output_dir) or die "Failed to create output directory: $!";
}

# Hash to store unique GPU models
my %gpu_models;

# Array to hold CSV file paths
my @csv_files;

# Find all CSV files in raw_data (case-insensitive match)
find(sub {
    push @csv_files, $File::Find::name if /\.csv$/i;
}, $raw_data_dir);

# Process each CSV file
foreach my $file (sort @csv_files) {
    open(my $fh, "<", $file) or do {
        warn "Could not open $file: $!";
        next;
    };
    my $csv = Text::CSV->new({ binary => 1, auto_diag => 1 });
    
    # Read header row to determine column indices
    my $header = $csv->getline($fh);
    unless ($header) {
        warn "File $file is empty or invalid.\n";
        next;
    }
    my %col_index;
    for (my $i = 0; $i < @$header; $i++) {
        my $col = $header->[$i];
        $col =~ s/^\s+|\s+$//g;  # trim whitespace
        $col_index{lc($col)} = $i;
    }
    
    # Check that a 'gpu_model' column exists
    unless (exists $col_index{'gpu_model'}) {
        warn "File $file does not contain a 'gpu_model' column.\n";
        next;
    }
    my $gpu_idx = $col_index{'gpu_model'};
    
    # Process data rows and collect non-empty gpu_model values
    while (my $row = $csv->getline($fh)) {
        my $gpu_value = $row->[$gpu_idx];
        next unless defined $gpu_value;
        $gpu_value =~ s/^\s+|\s+$//g;  # trim whitespace
        next if $gpu_value eq "";
        $gpu_models{$gpu_value} = 1;
    }
    close($fh);
}

# Write the unique GPU models to the output file
open(my $out_fh, ">", $output_file) or die "Cannot open $output_file: $!";
foreach my $gpu (sort keys %gpu_models) {
    print $out_fh "$gpu\n";
}
close($out_fh);

print "Extracted GPU models have been written to '$output_file'\n";

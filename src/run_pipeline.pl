#!/usr/bin/perl
use strict;
use warnings;
use File::Find;
use File::Basename;
use File::Path qw(rmtree make_path);
use Text::CSV;

# Set paths
my $data_dir = "raw_data";
my $output_dir = "pl_output";
my $output_csv = "$output_dir/merged_data.csv";
my $r_script = "src/analyze_data.R";
my $readme = "README.md";

# Clear and recreate output directory
if (-d $output_dir) {
    rmtree($output_dir) or die "Failed to clear $output_dir: $!";
}
make_path($output_dir) or die "Failed to create $output_dir: $!";

# Find all CSV files in raw_data
my @csv_files;
find(sub { push @csv_files, $File::Find::name if /\.csv$/ }, $data_dir);

# Open output file for writing
open(my $out_fh, ">", $output_csv) or die "Cannot open $output_csv: $!";
my $csv = Text::CSV->new({ binary => 1 });

# Process CSV files
my $header_written = 0;
foreach my $file (sort @csv_files) {
    # Extract timestamp from the parent folder name
    my $dir    = dirname($file);
    my $folder = basename($dir);
    my $ts     = "";
    if ($folder =~ m/^(\d{2})-(\d{2})-(\d{4})_(\d{2})-(\d{2})-(\d{2})$/) {
         $ts = "$3-$1-$2 $4:$5:$6";
    } else {
         warn "Folder name '$folder' does not match expected format\n";
    }
    
    open(my $fh, "<", $file) or die "Cannot open $file: $!";
    
    my $line_num = 0;
    while (my $row = $csv->getline($fh)) {
         $line_num++;
         if (!$header_written) {
              push @$row, "timestamp";
              $csv->print($out_fh, $row);
              print $out_fh "\n";
              $header_written = 1;
         } else {
              if ($line_num == 1) {
                  next;
              }
              push @$row, $ts;
              $csv->print($out_fh, $row);
              print $out_fh "\n";
         }
    }
    close $fh;
}
close $out_fh;
print "CSV files merged successfully into $output_csv\n";

# Run R script
print "Running R analysis...\n";
system("Rscript.exe $r_script") == 0 or die "Failed to run R script: $!";
print "Pipeline completed successfully!\n";
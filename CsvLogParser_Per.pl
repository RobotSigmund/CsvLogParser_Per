#!usr/bin/perl

use warnings;
use strict;
use utf8;

$| = 1;

print 'CsvLogParser_Per - SS 2023-01-06'."\n";
print '---'."\n\n";



#####   Process input file   #####

my($current_date) = '';
my(%data_sett,%data_sett_sum,%data_sett_sum_i,$line,$d_date,$d_volume,$de);
my($in_file_line_counter) = 0;

# Find sourcefile
print 'Searching for in-file...';
my($in_filename) = '';
opendir(DIR,'.');
foreach $de (readdir(DIR)) {
	if (($de =~ /\.csv$/i) && ($de ne 'result.csv')) {
		$in_filename = $de;
		last;
	}
}
closedir(DIR);
if ($in_filename eq '') {
	print 'ERROR, Did not find sourcefile'."\n";
	exit;
}
print 'found "'.$in_filename.'"'."\n";

# Process file
print 'Working...';
open(IN,'<'.$in_filename);
while ($line = <IN>) {
	
	$in_file_line_counter++;

	($d_date,undef,undef,$d_volume,undef) = split(/,/,$line);

	if ($data_sett{$d_date}) {

		$data_sett_sum{$d_date} += $d_volume;
		$data_sett_sum_i{$d_date}++;

	} else {
		
		# Check if something in the date-field looks like a year
		if ($d_date !~ /\d{4}/) {
			# Probably not a valid date
			next;
		}
		$data_sett{$d_date} = 1;
		$data_sett_sum{$d_date} = $d_volume;
		$data_sett_sum_i{$d_date} = 1;
		print '.';

	}	
}

close(IN);

print "\n\n".$in_file_line_counter.' lines processed'."\n\n";



#####   Write to screen   #####

print 'Data:'."\n\n";

my(@data_keys) = keys %data_sett;
@data_keys = sort @data_keys;
my($key);
foreach $key (@data_keys) {
	print 'Date: '.$key.'   Samples: '.$data_sett_sum_i{$key}.'   Average: '.(int($data_sett_sum{$key} / $data_sett_sum_i{$key} * 24 * 1000) / 1000).' m^3/24h'."\n";
}

print "\n";
print 'INFO: Each day shows average of all samples registered that day. Original values were m^3/h, so average for each day'."\n";
print '      has been multiplied by 24 to get total m^3 per day.'."\n";

print "\n";



#####   Write to file   #####

open(OUT,'>result.csv');
foreach $key (@data_keys) {
	print OUT $key.';'.(int($data_sett_sum{$key} / $data_sett_sum_i{$key} * 24 * 1000) / 1000).';'."\n";
}
close(OUT);

print 'Results are written to file "result.csv".'."\n";



#####   Done   #####

print "\n".'<ENTER> to exit!';
<STDIN>;
exit;

#!/usr/bin/perl
use strict;
use warnings;
use PostScript::XYChart;

my $xy = new PostScript::XYChart(
	);

$xy->line_from_file( "test.lines", "Current (mA)" );
#$xy->line_from_array( $data, "Testing" );

$xy->build_chart();
$xy->output("11xychart");


#!/usr/local/bin/perl -w

use strict;

my $TF_DATA_FOLDER = $ARGV[0];
my $TF_DQM_EXEC    = $ARGV[1];
my $TF_ROOT_MACRO  = $ARGV[2];
my $CADAVER          = undef;
#my $CADAVER          = "~kkotov/cadaver";
my $WEB              = "https://cms-csc.web.cern.ch:444/cms-csc/";

# Read content of the target derictory - analog of `/bin/find . -type f`
sub scan_dir {
	my ( $cwd ) = @_;
	my @file_list;
	my $pwd = `pwd`;
	opendir DIR, $cwd or die "Cannot read directory: $cwd ($pwd)";
	my @catalogue = grep { $_!~/^\.$/ && $_!~/^\.\.$/ } readdir DIR;
	closedir DIR;
	push @file_list, map ( -d $_ ? scan_dir($_) : $_ , grep { -f $_ || -s $_ || -d } map ( "$cwd/$_" , @catalogue ) );
	return @file_list;
}

# Make a list of all files that belong to the same run  (i.e. RunNumNNNEvs*)
sub combine_parts {
	my %runs;
	foreach my $file ( @_ ) {
		my $run = $file;
		$run =~ s/\.raw//g;
		$run =~ s/Evs.*//g;
		$run =~ s/Monitor_\d+/Monitor/g;
		$run =~ s/Monitor-\d+/Monitor/g;
		$run =~ s/Default_\d+/Default/g;
		$run =~ s/Default-\d+/Default/g;
		$runs{$run} .= " ".$file;
	}
	return %runs;
}

# Windows has problems with underscores
foreach my $file ( grep { $_=~/\.raw$/ } scan_dir($TF_DATA_FOLDER) ){
	my $top = "./";
	map {
		my $new_name = $_;
		$new_name =~ s/_/-/g;
		if( -e "$top/$_" && $_ ne $new_name ){
			rename $top."/".$_, $top."/".$new_name or die "Can't rename $top/$_ to $top/$new_name";
		}
		$top .= "/$new_name";
	} split(/\/*\.?\/+/,$file);
}

# Generate DQM plots
my %runs = combine_parts(grep { $_=~/\.raw$/ } scan_dir($TF_DATA_FOLDER));

# Generate and upload DQM plots
foreach my $run ( keys %runs ) {
	# Generate root file
	die "Can't run test" if system("$TF_DQM_EXEC $runs{$run} > qqq.log\n");
	# Prepare local files/folders
	$TF_DATA_FOLDER =~ s/\./\\./g;
	$run =~ s/$TF_DATA_FOLDER//g;
	$run =~ s/^\/*//g;
	my $basename = $run;
	my $dirname  = $run;
	$basename =~ s/.*\///g;
	$dirname  =~ s/$basename//g;
	unless( -d "./$dirname" ){
		mkdir "./$dirname" or die "Can't create directory";
	}
	rename "qqq.root", "$run.root" or die "Can't move qqq.root to $run.root";
	rename "qqq.log",  "$run.log"  or die "Can't move qqq.log to $run.log";
	# Converting to png plots
	die "Can't convert plots" if system("root.exe -b $TF_ROOT_MACRO'(\"$run.root\")' >> $run.log");
	#  Perform actual uploading (.png and .html files only)
	my %content;
	map {
		my $folder = $_;
		$folder =~ s/(.*\/).*/$1/g;
		my $file = $_;
		$file =~ s/.*\///g;
		$content{$folder} .= " $file";
	} grep { $_=~/\.png$/ || $_=~/\.html/ } scan_dir("plots/$run.plots");

	my $cadaver_script="";

	foreach my $folder ( sort keys %content ){
		#$cadaver_script .= "cd /test-emu-dqm/SliceTest/TrackFinder/\n";
		$cadaver_script .= "cd /cms-csc/DQM/TrackFinder/\n";
		my $depth;
		map { $cadaver_script.="mkdir $_\ncd $_\n"; $depth.="../"; } split(/\/*\.?\/+/,$folder);
		$cadaver_script .= "lcd $folder\n";
		$cadaver_script .= "mput *\n";
		$cadaver_script .= "lcd $depth\n";
	}
	#$cadaver_script .= "ls\nquit\n";

	if(defined $CADAVER){
		die "Can't upload plots" if system("echo -e \"$cadaver_script\" | $CADAVER $WEB >> $run.log");
	} else {
		#die "Can't create cadaver script" if system("echo -e \"$cadaver_script\" > $run.cadaver");
                open(CSFILE, ">>$run.cadaver");
                print CSFILE "$cadaver_script";
                close (CSFILE);
	}

	# Generate navigation
	my %layout;

	map {
		if( $_=~/SP\d+\/F\d+\/CSC\d+/ ){
			my $SP = $_;
			$SP =~ s/.*?\/(SP\d+)\/F\d+\/CSC\d+.*/$1/g;
			my $FA = $_;
			$FA =~ s/.*?\/SP\d+\/(F\d+)\/CSC\d+.*/$1/g;
			my $CSC = $_;
			$CSC =~ s/.*?\/SP\d+\/F\d+\/(CSC\d+).*/$1/g;
			unless( defined($layout{$SP}) ){ $layout{$SP} = {}; }
			unless( defined($layout{$SP}->{$FA}) ){ $layout{$SP}->{$FA} = ""; }
			if( $layout{$SP}->{$FA}!~/$CSC/ ){
				$layout{$SP}->{$FA} .="'$CSC',";
			}
		}
		if( $_=~/SP\d+\/F\d+/ ){
			my $SP = $_;
			$SP =~ s/.*?\/(SP\d+)\/F\d+.*/$1/g;
			my $FA = $_;
			$FA =~ s/.*?\/SP\d+\/(F\d+).*/$1/g;
			unless( defined($layout{$SP}) ){ $layout{$SP} = {}; }
			unless( defined($layout{$SP}->{$FA}) ){ $layout{$SP}->{$FA} = ""; }
		}
		if( $_=~/SP\d+/ ){
			my $SP = $_;
			$SP =~ s/.*?\/(SP\d+).*/$1/g;
			unless( defined($layout{$SP}) ){ $layout{$SP} = {}; }
		}
	} scan_dir("plots/$run.plots");

	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
	my $ctime = ($hour<10?"0".$hour:$hour).":".($min<10?"0".$min:$min)." ".($mon<9?"0".$mon+1:$mon+1)."/".($mday<10?"0".$mday:$mday)."/".($year+1900)	;

	my $entry = "['$run.plots ($ctime)'";
	foreach my $SP ( keys %layout ){
		$entry .= ",['$SP', [";
		my $sublayout = $layout{$SP};
		foreach my $FA ( keys %$sublayout ){
			$entry .= "['$FA', [$sublayout->{$FA}]],";
		}
		$entry .= "]],"
	}
	$entry .= "],";
	$entry =~ s/,\]/\]/g;
	$entry =~ s/,,/,/g; #cheap solution

	if(defined $CADAVER){
		die "Can't run cadaver" if system("echo -e \"cd /cms-csc/DQM/TrackFinder/plots/\nget tree_runs.js tree_runs.js\n\" | $CADAVER $WEB >> $run.log");
	}

	my @list;
	if( open (TREE_RUNS, "< tree_runs.js") ){
		@list = <TREE_RUNS>;
		close (TREE_RUNS);
	}

	open (TREE_RUNS, "> tree_runs.js") or die("Can't write to tree_runs.js");
	if( scalar(@list)==0 ){
		print TREE_RUNS "var RUNS = [\n";
		$entry =~ s/,$//g;
		print TREE_RUNS $entry."\n];";
	} else {
		for my $row (0..$#list){
			print TREE_RUNS $entry."\n" if( $row == 1 );
			print TREE_RUNS $list[$row];
		}
	}
	close (TREE_RUNS);

	if(defined $CADAVER){
		die "Can't run cadaver" if system("echo -e \"cd /cms-csc/DQM/TrackFinder/plots/\nput tree_runs.js\n\" | $CADAVER $WEB >> $run.log");
	}
}

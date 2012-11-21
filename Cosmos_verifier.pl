use strict;
use Term::ProgressBar;
use constant MAX => 2030;

my $progress = Term::ProgressBar->new({count => 100});



use Spreadsheet::ParseExcel::Simple;
my(@brand,@aliases,@category,@twitter,@facebook,@topic);
my $xls = Spreadsheet::ParseExcel::Simple->read('cosmos_brands.xls');
  foreach my $sheet ($xls->sheets) {

     while ($sheet->has_data) {
         my @data = $sheet->next_row;
         push(@brand,$data[0]);
         push(@aliases,$data[1]);
         push(@category,$data[2]);
         push(@twitter,$data[3]);
         push(@facebook,$data[4]);
         push(@topic,$data[5]);
     }
 }
open(RE,">>Status_output.txt");
print RE"Brand\tCategory\tBrand_status\tCategory_status\ttwitter\tfacebook\tTopic\n";
open(DF,"<input.txt");
my @lncnt=<DF>;
my $lns=scalar(@lncnt);
my $lin=1;
close(DF);
open(DF,"<input.txt");
while(my $line=<DF>){

	# print"$lin of $lns\n";
	my $cal=($lin/$lns)*100;
	$progress->update($cal);
	my @arr=split("\t",$line);
	my $flg=0;
	chomp $arr[1];
	for(my $i=0;$i<=$#brand;$i++){

		$brand[$i]=~s/\s+/\\s\*/igs; $aliases[$i]=~s/\s+/\\s\*/igs;
		$brand[$i]=~s/|//igs; $aliases[$i]=~s/|//igs;
		if($arr[0]=~m/^$brand[$i]$/is || $arr[0]=~m/^$aliases[$i]$/is){
			$flg=1;
			
			print RE"$arr[0]\t$arr[1]\tYES\t";
			$category[$i]=~s/\s+/\\s\*/igs;
			if($arr[1]=~m/\b$category[$i]\b/is){

				print RE"YES\t";

				&checkSocial($i);

			}else{

				print RE"NO\t";
				&checkSocial($i);
			}

		}


	}
	print RE"$arr[0]\t$arr[1]\tNO\tNO\tNO\tNO\tNO\n" if($flg == 0);
	
	$lin++;
}

close(DF);
close RE;

sub checkSocial(){

	my $i=shift;
	if($twitter[$i] ne ''){ print RE"YES\t" ; } else{print RE"NO\t" ; }
	
	if($facebook[$i] ne ''){ print RE"YES\t" ; } else{print RE"NO\t" ; }

	if($topic[$i] != 'NULL'){ print RE"YES\n" ; } else{print RE"NO\n" ; }
	
	
}

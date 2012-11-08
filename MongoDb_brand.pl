use strict;
# use warnings;
# use Data::Dumper;
use MongoDB;
use MongoDB::Collection;
use Spreadsheet::WriteExcel;

my $conn = new MongoDB::Connection;
my $db   = $conn->BrandList;
my $coll = $db->brands;

my $all = $coll->find();


my (@BrandId,@BrandName,@Source,@SOurceCount,@Category,@Categorycount,@InCosmos);
while(my $dts = $all->next)
{

	push(@BrandId,$dts->{BrandId});
	push(@BrandName,$dts->{BrandName});
	push(@Source,$dts->{Source});
	push(@SOurceCount,$dts->{SOurceCount});
	push(@Category,$dts->{Category});
	push(@Categorycount,$dts->{Categorycount});
	push(@InCosmos,$dts->{InCosmos});


}
my $count=$#BrandId;



open(CV,"<input.csv");


while(my $data=<CV>){

	my @arr=split(",",$data);
	my $bName=$arr[0];
	my $category=$arr[1];
	my $source=$arr[2];
	my $incosmos=$arr[3];
	print"***$bName***\n";

	my $catFlg=0;
	for(my $i=0;$i<=$#BrandName;$i++){
		# $bName=~s/\s+/\\s\*/igs;
		# print"***$BrandName[$i]***$bName***\n";<>;
		if(defined($BrandName[$i])&& ($BrandName[$i]=~m/^$bName\b/is)){


			print"******$BrandName[$i]*******\nBrand Matched\n";
			$catFlg=1;
			if($Category[$i]=~m/$category/is){

				
				print"Category Matched\n";
				
				print".................Matching--$Source[$i]<>$source\n";
				
				if($Source[$i]!~m/$source/is){

					my @SrcCount=split(",",$Source[$i]);
					print scalar(@SrcCount);<>;
					if(scalar(@SrcCount) > 0){
						print"inside sourcecount\n";
						push(@SrcCount,"$source");
						my $srcUp=join(",",@SrcCount);
						my $source_count=scalar(@SrcCount);
						$db->brands->update({"BrandId" => "$BrandId[$i]" }, {'$set' => {"Source" => "$srcUp","SOurceCount" => "$source_count"}});

					}
					else{
						print"Source Not Matched\n";
						$db->brands->update({"BrandId" => "$BrandId[$i]" }, {'$set' => {"Source" => "$source"}});
					}
					
					

				}
				else{

					print"Matched All-Dupe wit Master\n";
				}


			}

			else{

				my @catCount=split(",",$Category[$i]);
				
				if(scalar(@catCount) > 0){

					push(@catCount,"$category");
					my $catup=join(",",@catCount);
					my $category_count=scalar(@catCount);
					$db->brands->update({"BrandId" => "$BrandId[$i]" }, {'$set' => {"Category" => "$catup","Categorycount" => "$category_count"}});
					if($Source[$i]!~m/$source/is){

						my @SrcCount=split(",",$Source[$i]);
						print scalar(@SrcCount);
						if(scalar(@SrcCount) > 0){
							print"inside sourcecount\n";
							push(@SrcCount,"$source");
							my $srcUp=join(",",@SrcCount);
							my $source_count=scalar(@SrcCount);
							$db->brands->update({"BrandId" => "$BrandId[$i]" }, {'$set' => {"Source" => "$srcUp","SOurceCount" => "$source_count"}});
						}
						else{
							print"Source Not Matched\n";
							$db->brands->update({"BrandId" => "$BrandId[$i]" }, {'$set' => {"Source" => "$source"}});
						}
					
					}
				}
				else{
					
					$db->brands->update({"BrandId" => "$BrandId[$i]" }, {'$set' => {"Category" => "$category"}});

					if($Source[$i]!~m/$source/is){

						my @SrcCount=split(",",$Source[$i]);
						print scalar(@SrcCount);
						if(scalar(@SrcCount) > 0){
							print"inside sourcecount\n";
							push(@SrcCount,"$source");
							my $srcUp=join(",",@SrcCount);
							my $source_count=scalar(@SrcCount);
							$db->brands->update({"BrandId" => "$BrandId[$i]" }, {'$set' => {"Source" => "$srcUp","SOurceCount" => "$source_count"}});
						}
						else{
							print"Source Not Matched\n";
							$db->brands->update({"BrandId" => "$BrandId[$i]" }, {'$set' => {"Source" => "$source"}});
						}
					}
				}
			}
		}

	



	}

	if($catFlg == 0){

		print"Not Found \n inserting a record...\n";
		$count++;
		my $id="BR".$count;
		print"Last rec-$id\nincremented..\n";
		$id++;
		print"$id\n";
		$db->brands->insert({"BrandId" => "$id","BrandName" => "$bName","Source" => "$source","SOurceCount" => "1","Category" => "$category","Categorycount" => "1","InCosmos" => ""});
		print"Inserted\n";

	}

}

close(CV);
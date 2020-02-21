# Merge the CSVs in export\

$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition

$exportPath = "$scriptPath\export"
$mergeFile = "merge.csv"
$tempPath = "$scriptPath\temp"

# Cleanup artifacts
Remove-Item $mergeFile -force -verbose -erroraction silentlycontinue
Remove-Item "$tempPath\$mergeFile" -force -verbose -erroraction silentlycontinue
Remove-Item $tempPath -recurse -force -verbose -erroraction silentlycontinue
mkdir $tempPath -force

# Push stuff to working directory
write-host "copying files from $exportPath to $tempPath"
copy-Item -verbose $exportPath\* $tempPath

# In working directory
cd $tempPath
$files = gci | sort-object -descending # make sure we are chronologically in order
New-Item -ItemType File $mergeFile
$firstFile = $true
$linecount = 0

write-host "firstFile is $firstFile"

ForEach ($file in $files)
{
	$contents = Get-Content $file
	write-host "Getting contents of $file"
	
	If (-not $firstFile)
	{
		write-host "$file is subsequent"
		$firstLine = $true
		ForEach ($line in $contents)
		{
			If (-not $firstLine)
			{
				Add-Content $mergeFile $line
				$linecount = $linecount + 1
			}
			Else
			{
				$firstLine = $false
			}
		}
	}
	Else
	{
		write-host "$file is first"
		ForEach ($line in $contents)
		{
			Add-Content $mergeFile $line
			$linecount = $linecount + 1
		}
		$firstFile = $false
	}
} 

cd $scriptPath
move-item "$tempPath\$mergeFile" "$scriptPath\$mergeFile"
write-host "linecount=$linecount"
remove-item -recurse $tempPath
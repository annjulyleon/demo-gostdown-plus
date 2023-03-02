$mdpath = $args[0]
$template = $args[1]
$gdfilter = $args[2]
$outputdir = $args[3]
$outname = $args[4]

pandoc -s $(Get-Content $mdpath\html_include.txt) -f markdown --quiet --template=$template --lua-filter=$gdfilter\include_files.lua --lua-filter=$gdfilter\linebreaks.lua --lua-filter=$gdfilter\metadata_processor.lua --filter pandoc-crossref --citeproc -o $outputdir\$outname.html --toc
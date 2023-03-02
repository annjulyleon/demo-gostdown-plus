@echo off
python %~dp0\..\scripts\copy_img.py -s "." -d ".\_img" -c
@echo on

powershell.exe -command .\..\scripts\build.ps1 ^
-md $(Get-Content docx_include.txt) ^
-luafilter .\..\scripts ^
-template template-report.docx ^
-docx .\..\build\report.docx ^
-embedfonts ^
-counters

@echo off
python %~dp0\..\scripts\copy_img.py -r
@echo on
<#
.Description
	This script adds and updates .docx custom properties from .xml config
.Example
	.\UpdateDocxPropsConfig_v3.ps1 -dir D:\projects\myproject\ -conf D:\projects\myproject\config.xml -filename includethisfile.docx
.PARAMETER
 dir - path to docx folder. Default is current folder
 conf - path to xml with configuration. Default is config.xml in current folder
 filename - filename in $dir for script to apply. If filename is set script works in single file mode. If filename is not set, script will work with list of files in the folder
#>

param (
    [Parameter (Position = 1)][string]$dir = $(get-location),
    [Parameter (Position = 2)][string]$conf = $dir + '\config.xml',
    [Parameter (Position = 3)][string]$filename
)

Write-Host "If filename is set: " $PSBoundParameters.ContainsKey('filename')

$path = $dir.trim('\')
$exclude = "old|_old|source|_source"

write-host "Working directory: " $dir 
write-host "Config file: " $conf

# Read config file and load values.
# Example XML:
#<?xml version="1.0"?>
#<configuration>
#  <customProperties>
#   <add key="anyName" value="anyValue"/>
#  </customProperties>
#  <builtinProperties>
#	<add key="Title" value="builtin name"/>
#  </builtinProperties>
#</configuration>

if (Test-Path $conf) {
    Try {
        #Load config customProperties
        $global:customProperties = @{}
        $global:builtinProperties = @{}
        $config = [xml](get-content $conf)
        foreach ($addNode in $config.configuration.customProperties.add) {
            if ($addNode.Value.Contains(';')) {
                # Array case
                $value = $addNode.Value.Split(';')
                for ($i = 0; $i -lt $value.length; $i++) { 
                    $value[$i] = $value[$i].Trim() 
                }
            }
            else {
                # Scalar case
                $value = $addNode.Value
            }
            $global:customProperties[$addNode.Key] = $value
        }
		
        foreach ($addNode in $config.configuration.builtinProperties.add) {
            if ($addNode.Value.Contains(';')) {
                # Array case
                $value = $addNode.Value.Split(';')
                for ($i = 0; $i -lt $value.length; $i++) { 
                    $value[$i] = $value[$i].Trim() 
                }
            }
            else {
                # Scalar case
                $value = $addNode.Value
            }
            $global:builtinProperties[$addNode.Key] = $value
        }
    }
    Catch [system.exception] {
    }
}

write-host "Working directory: " $path
$application = New-Object -ComObject word.application
$application.Visible = $false

function AddOrUpdateCustomProperty ($CustomPropertyName, $CustomPropertyValue, $DocumentToChange) {
    $customProperties = $DocumentToChange.CustomDocumentProperties
    
    $binding = "System.Reflection.BindingFlags" -as [type]
    [array]$arrayArgs = $CustomPropertyName, $false, 4, $CustomPropertyValue
    Try {
        [System.__ComObject].InvokeMember("add", $binding::InvokeMethod, $null, $customProperties, $arrayArgs) | out-null
    } 
    Catch [system.exception] {
        $propertyObject = [System.__ComObject].InvokeMember("Item", $binding::GetProperty, $null, $customProperties, $CustomPropertyName)
        [System.__ComObject].InvokeMember("Delete", $binding::InvokeMethod, $null, $propertyObject, $null)
        [System.__ComObject].InvokeMember("add", $binding::InvokeMethod, $null, $customProperties, $arrayArgs) | Out-Null
    }
    Write-Host -ForegroundColor Green "Success! Custom Property:" $CustomPropertyName "set to value:" $CustomPropertyValue
}

If ($PSBoundParameters.ContainsKey('filename') -eq "True") {
    [array]$files = @(Get-ChildItem -Path $path -Filter $filename | Select-Object -expand fullname )
    Write-Host "Filename is set. Working with file: " $files
}
Else {
    [array]$files = @(Get-ChildItem -Path $path -Include *.doc, *.docx -Recurse -File | Select-Object -expand fullname | Where-Object { $_.PSParentPath -notmatch $exclude }) 
    Write-Host "Filename not set. Working with list of files: " $files
}
foreach ($file in $files) {
    $doc = $application.Documents.Open($file)      
		
    Write-Host "Processing $_"
		
    ForEach ($property in $customProperties.GetEnumerator()) {
        AddOrUpdateCustomProperty $($property.Name) $($property.Value) $doc			
    }
		
    ForEach ($builtinProperty in $builtinProperties.GetEnumerator()) {
        $doc.BuiltInDocumentProperties($builtinProperty.Name) = $builtinProperty.Value
        Write-Host "Property " $builtinProperty.Name "set to value " $builtinProperty.Value
    }

    Write-Host "Updating document fields."
    $doc.Fields.Update() | Out-Null
    foreach ($section in $doc.Sections) {
        ForEach ($header in $section.Headers) {
            $header.Range.Fields.Update() | Out-Null
        }
        ForEach ($footer in $section.Footers) {
            $footer.Range.Fields.Update() | Out-Null
        }
    }
    #Updating fields inside forms and labels		
    $doc.PrintPreview()
    $doc.ClosePrintPreview()
		
    Write-Host "Saving document."	
		
    $doc.Saved = $false
    $doc.save()
    $doc.close()
}
$application.Quit()
$application = $null
[gc]::collect()
[gc]::WaitForPendingFinalizers()
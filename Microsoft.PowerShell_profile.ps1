

Set-Alias ll "dir"
Set-Alias vi "vim"
Set-Alias ollama "ollama run deepseek-r1:14b" 

# Import the Chocolatey Profile that contains the necessary code to enable
# tab-completions to function for `choco`.
# Be aware that if you are missing these lines from your profile, tab completion
# for `choco` will not function.
# See https://ch0.co/tab-completion for details.
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

# needed to work with direnv
function Load-Envrc {
	$envrcFile = ".envrc"
	if (Test-Path $envrcFile) {
		Write-Debug "start reading $envrcFile" 
		$lines = Get-Content $envrcFile 
		Write-Debug "Done" 
		
		foreach ($line in $lines) {
			Write-Debug "Processing line: $line"
			if ($line -match '^export (\w+)=(.+)') {
				$varName = $matches[1]
				$varValue = $matches[2]
				Write-Host "Settting: $varName=$varValue"
				Set-Item -Path "Env:$($matches[1])" -Value $matches[2]
			}
			else{
				Write-Debug "NO MATCH $line"
			}
		}
	}
	else
	{
		Write-Debug "No .envrc found in $PWD" 
	}
}

Function Prompt {
    # Call Load-Envrc as a background process, otherwise Get-Content is blocking
    $host.UI.RawUI.WindowTitle = Get-Location
    "PS> "
    # do not autoload
    # Load-Envrc 
}

# set vi editing mode
Set-PSReadLineOption -EditMode Vi



#$env:UV_EXTRA_INDEX_URL="https://eelco@pypi.davelab.eu"
#$env:UV_INDEX_DAVEPYPI_USERNAME="eelco"
#$env:UV_INDEX_DAVEPYPI_PASSWORD="vliet123"
#$env:UV_INDEX_STRATEGY="unsafe-best-match"

Set-Alias ll "dir"
Set-Alias vi "nvim"
Set-Alias vim "nvim"
Set-Alias ollama "ollama run deepseek-r1:14b" 

# support UTF-8
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
$env:PYTHONUTF8=1


# Import the Chocolatey Profile that contains the necessary code to enable
# tab-completions to function for `choco`.
# Be aware that if you are missing these lines from your profile, tab completion
# for `choco` will not function.
# See https://ch0.co/tab-completion for details.
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

# set path's for direnv
# is now stored in user settings 
$env:DIRENV_CONFIG="$env:LOCALAPPDATA/direnv"
$env:XDG_ROOT="$env:LOCALAPPDATA/xdg"
$env:XDG_DATA_HOME="$env:XDG_ROOT/data"
$env:XDG_CACHE_HOME="$env:XDG_ROOT/cache"
$env:PATH += ";C:\Users\eelco\AppData\Local/xdg/bin"

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



function findexclusive {
    param (
        [string]$SearchPattern,  # Directly use this as the search pattern parameter
        [string]$Path = ".",
        [string[]]$ExcludeDirs = @(".git", ".tox", ".venv", "venv", ".cache", "__pycache__", "node_modules",
                                  ".mypy_cache", ".pytest_cache", ".ruff_cache", ".idea", ".vscode", "dist", "build")
    )

    # If no search pattern is provided, prompt for one
    if (-not $SearchPattern) {
        Write-Host "Please provide a search pattern."
        return
    }

    # Convert wildcard * to regex pattern
    $SearchPattern = $SearchPattern -replace '\*', '.*'

    # Get files excluding the specified directories
    Get-ChildItem -Path $Path -Recurse -ErrorAction SilentlyContinue |
        Where-Object {
            # Exclude files or directories in the ExcludeDirs list
            -not ($_.PSIsContainer -and ($ExcludeDirs | ForEach-Object { $_.Trim() } |
                                          Where-Object { $_ -eq $_.Name }))
        } |
        Where-Object { $_.Name -match $SearchPattern }
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


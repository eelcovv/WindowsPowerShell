
$clPath = "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\bin\Hostx64\x64"
$env:PATH = "$clPath;$env:PATH"


Set-Alias ll "dir"
Set-Alias vi "nvim"
Set-Alias vim "nvim"
Set-Alias ollama "ollama run deepseek-r1:14b" 

$env:NEXTCLOUD="C:\Nextcloud"

#$env:TEXMFHOME="$HOME\texmf"
$env:TEXMFHOME="$NEXTCLOUD\texmf"


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
$env:PATH += ";C:/Users/eelco/AppData/Local/xdg/bin"

$env:PATH += ";C:/Program Files/Blender Foundation/Blender 4.3"
$env:PATH += ";C:/Program Files/ODA/ODAFileConverter"

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
function Export-ChocoPackages {
    param(
        [string]$OutputPath = "$env:NEXTCLOUD\Documents\Backup\choco-packages.txt",
        [switch]$IncludeVersions
    )

    Write-Output "Exporting Chocolatey packages to: $OutputPath"

    try {
        if ($IncludeVersions) {
            $output = choco list --local-only --limit-output --no-color 2>$null
        } else {
            $output = choco list --local-only --limit-output --no-color 2>$null |
                      ForEach-Object { ($_ -split '\|')[0] }
        }

        if (-not $output -or $output.Count -eq 0) {
            throw "No output returned from choco. Check if Chocolatey is working correctly."
        }

        $output | Set-Content -Path $OutputPath -Encoding UTF8
        Write-Output "Package list saved to: $OutputPath"
    } catch {
        Write-Error "Failed to export packages: $_"
    }
}


function Install-ChocoPackagesFromFile {
    param(
        [string]$PackageListPath = "$env:NEXTCLOUD\Documents\Backup\choco-packages.txt",
        [switch]$IncludeVersions
    )

    if (-Not (Test-Path $PackageListPath)) {
        Write-Error "File not found: $PackageListPath"
        return
    }

    $lines = Get-Content $PackageListPath

    foreach ($line in $lines) {
        if ($line.Trim() -eq '') { continue }

        if ($IncludeVersions) {
            $parts = $line -split ' '
            $name = $parts[0]
            $version = if ($parts.Length -ge 2) { $parts[1] } else { $null }

            if ($version) {
                choco install $name --version=$version -y
            } else {
                choco install $name -y
            }
        } else {
            $name = ($line -split ' ')[0]
            choco install $name -y
        }
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
Function ActivateVimLineEditing {
	Set-PSReadLineOption -EditMode Vi
}
Function DeActivateVimLineEditing {
	Set-PSReadLineOption -EditMode Emacs
}

# default pick vim line editing. deactivate it with DeActivateVimLineEditinig
ActivateVimLineEditing

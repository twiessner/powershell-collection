<#
.Synopsis
   Shoer description

.DESCRIPTION
   Long description

.EXAMPLE
   ./execute-terraform-loop-workspaces.ps1 -upstream
#>

Param (
  [string] $log_dir = ".\tf_output_logs",
  [string[]] $tf_workspaces_ignore = @(""),
  [switch]$upstream = $false
)

mkdir -p $log_dir |Out-Null

Invoke-Expression ($upstream ? "terraform init -upgrade" : "terraform init")

terraform workspace list |
  ForEach-Object {
    $ws = $_.replace('*', '').replace(' ', '');

    if (-Not $tf_workspaces_ignore.contains($ws)) {
      terraform workspace select $ws;
      Write-Host "$ws";

      terraform apply -auto-approve 2>&1 > "$log_dir\apply_$ws.log"
    }
  }

<#
.SYNOPSIS
    Lit ou applique les règles de content exclusion Copilot via l'API GitHub.

.PARAMETER Org
    Nom de l'organisation GitHub.

.PARAMETER Token
    Personal Access Token avec le scope copilot.

.PARAMETER Action
    Get : affiche les règles actuelles dans l'org.
    Set : applique config.json dans l'org (défaut).

.PARAMETER DryRun
    (Set uniquement) Affiche ce qui serait envoyé sans appeler l'API.

.EXAMPLE
    .\Apply-ContentExclusion.ps1 -Org "Ch0wseth" -Token $env:GH_TOKEN -Action Get

.EXAMPLE
    .\Apply-ContentExclusion.ps1 -Org "Ch0wseth" -Token $env:GH_TOKEN -Action Set

.EXAMPLE
    .\Apply-ContentExclusion.ps1 -Org "Ch0wseth" -Token $env:GH_TOKEN -Action Set -DryRun
#>
param(
    [Parameter(Mandatory)]
    [string]$Org,

    [Parameter(Mandatory)]
    [string]$Token,

    [ValidateSet("Get", "Set")]
    [string]$Action = "Set",

    [switch]$DryRun
)

$Headers = @{
    "Accept"               = "application/vnd.github+json"
    "Authorization"        = "Bearer $Token"
    "X-GitHub-Api-Version" = "2026-03-10"
}
$Uri = "https://api.github.com/orgs/$Org/copilot/content_exclusion"

Write-Host "Org    : $Org"
Write-Host "Action : $Action"
Write-Host ""

if ($Action -eq "Get") {
    Write-Host "==> Règles actuelles dans l'org $Org" -ForegroundColor Cyan

    $Response = Invoke-WebRequest `
        -Method GET `
        -Uri $Uri `
        -Headers $Headers `
        -UseBasicParsing

    Write-Host "HTTP $($Response.StatusCode)"
    $Response.Content | ConvertFrom-Json | ConvertTo-Json -Depth 10
}
else {
    $ConfigFile = Join-Path $PSScriptRoot "config.json"
    $Config     = Get-Content $ConfigFile -Raw

    Write-Host "Config : $ConfigFile"
    Write-Host "DryRun : $DryRun"
    Write-Host ""

    if ($DryRun) {
        Write-Host "[DRY-RUN] PUT $Uri"
        Write-Host "[DRY-RUN] Body :"
        Write-Host $Config
        exit 0
    }

    $Response = Invoke-WebRequest `
        -Method PUT `
        -Uri $Uri `
        -Headers $Headers `
        -Body $Config `
        -ContentType "application/json" `
        -UseBasicParsing

    Write-Host "HTTP $($Response.StatusCode)"

    if ($Response.StatusCode -in 200, 204) {
        Write-Host "Content exclusion appliqué avec succès." -ForegroundColor Green
    } else {
        Write-Error "Échec : HTTP $($Response.StatusCode)`n$($Response.Content)"
    }
}

<#
.SYNOPSIS
    Lit les policies Copilot Business d'une organisation GitHub.

.DESCRIPTION
    Appelle GET /orgs/{org}/copilot/billing pour récupérer et afficher
    les paramètres actuels : plan, seat management, fonctionnalités activées.

    NOTE : Il n'existe pas d'API REST pour modifier ces policies.
    Les modifications doivent être effectuées via l'interface GitHub :
    Org Settings > Copilot > Policies

.PARAMETER Org
    Nom de l'organisation GitHub.

.PARAMETER Token
    Personal Access Token avec le scope manage_billing:copilot ou read:org.

.EXAMPLE
    .\Get-CopilotPolicies.ps1 -Org "my-org" -Token "ghp_..."
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$Org,

    [Parameter(Mandatory)]
    [string]$Token
)

$ErrorActionPreference = "Stop"

$headers = @{
    "Accept"               = "application/vnd.github+json"
    "Authorization"        = "Bearer $Token"
    "X-GitHub-Api-Version" = "2026-03-10"
}

$url = "https://api.github.com/orgs/$Org/copilot/billing"

Write-Host "`n==> Lecture des policies Copilot pour l'org : $Org" -ForegroundColor Cyan

try {
    $response = Invoke-WebRequest -Uri $url -Headers $headers -Method GET -UseBasicParsing
}
catch {
    $statusCode = $_.Exception.Response?.StatusCode.value__
    Write-Error "Erreur HTTP $statusCode lors de l'appel à $url`n$($_.Exception.Message)"
    exit 1
}

if ($response.StatusCode -ne 200) {
    Write-Error "Réponse inattendue HTTP $($response.StatusCode)"
    exit 1
}

$data = $response.Content | ConvertFrom-Json

Write-Host "`n--- Policies Copilot ---" -ForegroundColor Yellow
Write-Host ""
Write-Host ("Plan                 : {0}" -f $data.plan_type)
Write-Host ("Seat management      : {0}" -f $data.seat_management_setting)
Write-Host ""
Write-Host ("IDE Chat             : {0}" -f $data.ide_chat)
Write-Host ("Platform Chat        : {0}" -f $data.platform_chat)
Write-Host ("CLI                  : {0}" -f $data.cli)
Write-Host ("Code public          : {0}" -f $data.public_code_suggestions)
Write-Host ""

if ($data.seat_breakdown) {
    Write-Host "--- Sièges ---" -ForegroundColor Yellow
    Write-Host ("Total                : {0}" -f $data.seat_breakdown.total)
    Write-Host ("Actifs (ce cycle)    : {0}" -f $data.seat_breakdown.active_this_cycle)
    Write-Host ("Inactifs (ce cycle)  : {0}" -f $data.seat_breakdown.inactive_this_cycle)
    Write-Host ("En attente           : {0}" -f $data.seat_breakdown.pending_invitation)
    Write-Host ""
}

Write-Host "Réponse complète :" -ForegroundColor DarkGray
$data | ConvertTo-Json -Depth 5

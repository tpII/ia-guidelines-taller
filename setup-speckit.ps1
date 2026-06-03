# Setup-Speckit.ps1
# Script de PowerShell para inicializar Speckit en proyectos de alumnos

Clear-Host
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host "  🤖 IA Guidelines - Setup del Proyecto de Alumnos  " -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host ""

# Determinar si estamos corriendo de forma local o remota (vía irm | iex)
$ScriptPath = $MyInvocation.MyCommand.Path
$IsLocal = $false

if ($ScriptPath -and (Test-Path $ScriptPath)) {
    $ScriptDir = Split-Path -Parent $ScriptPath
    if ((Test-Path "$ScriptDir\stacks") -and (Test-Path "$ScriptDir\speckit")) {
        $IsLocal = $true
        $GuidelinesDir = $ScriptDir
    }
}

if (-not $IsLocal) {
    Write-Host "📥 Descargando archivos temporales de ia-guidelines-taller..." -ForegroundColor Cyan
    $TempClone = ".guidelines-temp"
    if (Test-Path $TempClone) {
        Remove-Item -Recurse -Force $TempClone -ErrorAction SilentlyContinue
    }
    
    # Clonar repo de pautas de forma temporal
    git clone --depth 1 https://github.com/tpII/ia-guidelines-taller.git $TempClone | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Error "❌ Error al clonar el repositorio de pautas (https://github.com/tpII/ia-guidelines-taller.git)."
        exit 1
    }
    $GuidelinesDir = Join-Path (Get-Location) $TempClone
}

$TargetDir = Get-Location
Write-Host "ℹ️ Se inicializará Speckit en: $TargetDir" -ForegroundColor Cyan
$Confirm = Read-Host "¿Continuar? (S/n)"
if ($Confirm -like "n*" -or $Confirm -like "N*") {
    Write-Host "Operación cancelada." -ForegroundColor Yellow
    if (-not $IsLocal) {
        Remove-Item -Recurse -Force $TempClone -ErrorAction SilentlyContinue
    }
    exit 0
}

Write-Host "`n🔍 Buscando stacks tecnológicos disponibles..." -ForegroundColor Cyan
$StacksDir = Join-Path $GuidelinesDir "stacks"
if (-not (Test-Path $StacksDir)) {
    Write-Error "❌ No se encontró la carpeta 'stacks' en $GuidelinesDir."
    if (-not $IsLocal) {
        Remove-Item -Recurse -Force $TempClone -ErrorAction SilentlyContinue
    }
    exit 1
}

# Obtener los directorios de stacks de forma dinámica
$Stacks = Get-ChildItem -Directory -Path $StacksDir | Select-Object -ExpandProperty Name

if ($Stacks.Count -eq 0) {
    Write-Error "❌ No se encontraron stacks en $StacksDir."
    if (-not $IsLocal) {
        Remove-Item -Recurse -Force $TempClone -ErrorAction SilentlyContinue
    }
    exit 1
}

Write-Host "Stacks disponibles:"
for ($i = 0; $i -lt $Stacks.Count; $i++) {
    Write-Host "  $($i+1)) $($Stacks[$i])"
}

Write-Host ""
$Selection = Read-Host "Seleccioná el número de tu stack principal"

$SelIndex = 0
if (-not [int]::TryParse($Selection, [ref]$SelIndex) -or $SelIndex -lt 1 -or $SelIndex -gt $Stacks.Count) {
    Write-Error "❌ Selección inválida."
    if (-not $IsLocal) {
        Remove-Item -Recurse -Force $TempClone -ErrorAction SilentlyContinue
    }
    exit 1
}

$SelectedStack = $Stacks[$SelIndex - 1]
Write-Host "✅ Stack seleccionado: $SelectedStack" -ForegroundColor Green
Write-Host ""

# Crear directorios en el destino
Write-Host "📁 Creando directorios en el proyecto de destino..." -ForegroundColor Cyan
$null = New-Item -ItemType Directory -Force -Path (Join-Path $TargetDir "speckit")
$null = New-Item -ItemType Directory -Force -Path (Join-Path $TargetDir "adr")
$null = New-Item -ItemType Directory -Force -Path (Join-Path $TargetDir ".github")

# Copiar archivos
Write-Host "📄 Copiando templates de Speckit..." -ForegroundColor Cyan
Copy-Item -Path (Join-Path $GuidelinesDir "speckit\*.md") -Destination (Join-Path $TargetDir "speckit\") -Force

Write-Host "📄 Copiando template de ADR..." -ForegroundColor Cyan
Copy-Item -Path (Join-Path $GuidelinesDir "adr\template.md") -Destination (Join-Path $TargetDir "adr\") -Force

# Copiar instrucciones del stack principal
Write-Host "🤖 Configurando instrucciones de Copilot..." -ForegroundColor Cyan
$CopilotInstPath = Join-Path $GuidelinesDir "stacks\$SelectedStack\copilot-instructions.md"
if (Test-Path $CopilotInstPath) {
    Copy-Item -Path $CopilotInstPath -Destination (Join-Path $TargetDir ".github\copilot-instructions.md") -Force
} else {
    Write-Host "⚠️ No se encontró copilot-instructions.md para el stack $SelectedStack. Se creó archivo vacío." -ForegroundColor Yellow
    $null = New-Item -ItemType File -Force -Path (Join-Path $TargetDir ".github\copilot-instructions.md")
}

# Copiar clean-code-python.md si corresponde
if ($SelectedStack -eq "python") {
    $CleanCodePath = Join-Path $GuidelinesDir "stacks\python\clean-code-python.md"
    if (Test-Path $CleanCodePath) {
        Write-Host "📄 Copiando guía de Clean Code para Python..." -ForegroundColor Cyan
        Copy-Item -Path $CleanCodePath -Destination $TargetDir -Force
    }
}

# Bucle para agregar stacks secundarios
$SelectedStacks = New-Object System.Collections.Generic.List[string]
$null = $SelectedStacks.Add($SelectedStack)

while ($true) {
    Write-Host ""
    $AddMore = Read-Host "¿Querés agregar otro stack tecnológico (secundario)? (s/N)"
    if ($AddMore -notlike "s*" -and $AddMore -notlike "S*") {
        break
    }
    
    Write-Host "`nStacks disponibles:" -ForegroundColor Cyan
    for ($i = 0; $i -lt $Stacks.Count; $i++) {
        if ($SelectedStacks.Contains($Stacks[$i])) {
            Write-Host "  $($i+1)) $($Stacks[$i]) (YA SELECCIONADO)"
        } else {
            Write-Host "  $($i+1)) $($Stacks[$i])"
        }
    }
    
    Write-Host ""
    $SecSelection = Read-Host "Seleccioná el número del stack secundario"
    
    $SecIndex = 0
    if (-not [int]::TryParse($SecSelection, [ref]$SecIndex) -or $SecIndex -lt 1 -or $SecIndex -gt $Stacks.Count) {
        Write-Error "❌ Selección inválida."
        continue
    }
    
    $SecStack = $Stacks[$SecIndex - 1]
    if ($SelectedStacks.Contains($SecStack)) {
        Write-Host "⚠️ El stack $SecStack ya fue seleccionado anteriormente." -ForegroundColor Yellow
        continue
    }
    
    $null = $SelectedStacks.Add($SecStack)
    Write-Host "✅ Stack secundario agregado: $SecStack" -ForegroundColor Green
    
    # Anexar instrucciones del stack secundario
    $CopilotInstPath = Join-Path $GuidelinesDir "stacks\$SecStack\copilot-instructions.md"
    if (Test-Path $CopilotInstPath) {
        Add-Content -Path (Join-Path $TargetDir ".github\copilot-instructions.md") -Value "`r`n`r`n---`r`n`r`n# 🛠️ Stack secundario: $SecStack`r`n"
        Get-Content $CopilotInstPath | Add-Content -Path (Join-Path $TargetDir ".github\copilot-instructions.md")
        Write-Host "➕ Instrucciones de $SecStack anexadas a .github\copilot-instructions.md" -ForegroundColor Cyan
    }
    
    # Copiar clean-code si es python
    if ($SecStack -eq "python") {
        $CleanCodePath = Join-Path $GuidelinesDir "stacks\python\clean-code-python.md"
        if (Test-Path $CleanCodePath) {
            Write-Host "📄 Copiando guía de Clean Code para Python..." -ForegroundColor Cyan
            Copy-Item -Path $CleanCodePath -Destination $TargetDir -Force
        }
    }
}

# Limpieza si clonamos temporalmente
if (-not $IsLocal) {
    Write-Host "🧹 Limpiando archivos temporales..." -ForegroundColor Cyan
    Remove-Item -Recurse -Force $TempClone -ErrorAction SilentlyContinue
}

Write-Host "`n====================================================" -ForegroundColor Green
Write-Host "🎉 ¡Setup completado con éxito!                     " -ForegroundColor Green
Write-Host "====================================================" -ForegroundColor Green
Write-Host "`nSiguientes pasos recomendados para tu grupo:"
Write-Host "  1. Abrí speckit/constitution.md en tu proyecto y configuralo con las convenciones de tu equipo."
Write-Host "  2. Si modificaron el stack o las reglas, actualicen .github/copilot-instructions.md."
Write-Host "  3. Hacé tu primer commit:"
Write-Host "     git add speckit/ adr/ .github/"
Write-Host "     git commit -m `"init: agregar specification kit y configuración de Copilot`""
Write-Host "     git push origin main"
Write-Host "  4. Empezá a definir los requerimientos de tu proyecto en speckit/specify.md."
Write-Host ""

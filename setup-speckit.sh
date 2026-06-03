#!/bin/bash

# Colores para la salida
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color
BOLD='\033[1m'

echo -e "${BLUE}${BOLD}====================================================${NC}"
echo -e "${BLUE}${BOLD}  🤖 IA Guidelines - Setup del Proyecto de Alumnos  ${NC}"
echo -e "${BLUE}${BOLD}====================================================${NC}"
echo ""

# Función para leer entrada de usuario compatible con terminal y pipes (curl | bash)
read_user() {
    local var_name=$1
    if [ -t 0 ]; then
        read -r "$var_name"
    elif ( true < /dev/tty ) 2>/dev/null; then
        read -r "$var_name" < /dev/tty
    else
        read -r "$var_name"
    fi
}

# Determinar si estamos corriendo localmente o desde curl (remoto)
LOCAL_DIR=""
if [ -n "${BASH_SOURCE[0]}" ]; then
    LOCAL_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd 2>/dev/null )"
fi

IS_LOCAL=false
if [ -n "$LOCAL_DIR" ] && [ -d "$LOCAL_DIR/stacks" ] && [ -d "$LOCAL_DIR/speckit" ]; then
    IS_LOCAL=true
    GUIDELINES_DIR="$LOCAL_DIR"
else
    # Corriendo vía curl - necesitamos clonar el repo de pautas de forma temporal
    echo -e "${BLUE}📥 Descargando archivos temporales de ia-guidelines-taller...${NC}"
    TEMP_CLONE=".guidelines-temp"
    rm -rf "$TEMP_CLONE"
    git clone --depth 1 https://github.com/tpII/ia-guidelines-taller.git "$TEMP_CLONE" &>/dev/null
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Error al clonar el repositorio de pautas (https://github.com/tpII/ia-guidelines-taller.git).${NC}"
        exit 1
    fi
    GUIDELINES_DIR="$(pwd)/$TEMP_CLONE"
fi

TARGET_DIR="$(pwd)"
echo -e "${BLUE}ℹ️ Se inicializará Speckit en: ${BOLD}$TARGET_DIR${NC}"
echo -n "¿Continuar? (S/n): "
read_user confirm
if [[ "$confirm" =~ ^[nN]$ ]]; then
    echo -e "${YELLOW}Operación cancelada.${NC}"
    [ "$IS_LOCAL" = false ] && [ -d "$TEMP_CLONE" ] && rm -rf "$TEMP_CLONE"
    exit 0
fi

echo -e "\n${BLUE}🔍 Buscando stacks tecnológicos disponibles...${NC}"
STACKS_DIR="$GUIDELINES_DIR/stacks"
if [ ! -d "$STACKS_DIR" ]; then
    echo -e "${RED}❌ No se encontró la carpeta 'stacks' en $GUIDELINES_DIR.${NC}"
    [ "$IS_LOCAL" = false ] && [ -d "$TEMP_CLONE" ] && rm -rf "$TEMP_CLONE"
    exit 1
fi

# Obtener los directorios de stacks de forma dinámica
stacks=()
for dir in "$STACKS_DIR"/*; do
    if [ -d "$dir" ]; then
        stacks+=("$(basename "$dir")")
    fi
done

if [ ${#stacks[@]} -eq 0 ]; then
    echo -e "${RED}❌ No se encontraron stacks en $STACKS_DIR.${NC}"
    [ "$IS_LOCAL" = false ] && [ -d "$TEMP_CLONE" ] && rm -rf "$TEMP_CLONE"
    exit 1
fi

echo -e "Stacks disponibles:"
for i in "${!stacks[@]}"; do
    echo -e "  $((i+1))) ${stacks[i]}"
done

echo ""
echo -n "Seleccioná el número de tu stack principal: "
read_user selection

if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt ${#stacks[@]} ]; then
    echo -e "${RED}❌ Selección inválida.${NC}"
    [ "$IS_LOCAL" = false ] && [ -d "$TEMP_CLONE" ] && rm -rf "$TEMP_CLONE"
    exit 1
fi

SELECTED_STACK="${stacks[$((selection-1))]}"
echo -e "${GREEN}✅ Stack seleccionado: $SELECTED_STACK${NC}\n"

# Crear estructura de directorios en el destino
echo -e "${BLUE}📁 Creando directorios en el proyecto de destino...${NC}"
mkdir -p "$TARGET_DIR/speckit"
mkdir -p "$TARGET_DIR/adr"
mkdir -p "$TARGET_DIR/.github"

# Copiar archivos de speckit
echo -e "${BLUE}📄 Copiando templates de Speckit...${NC}"
cp -v "$GUIDELINES_DIR"/speckit/*.md "$TARGET_DIR/speckit/"

# Copiar plantilla de ADR
echo -e "${BLUE}📄 Copiando template de ADR...${NC}"
cp -v "$GUIDELINES_DIR/adr/template.md" "$TARGET_DIR/adr/"

# Copiar instrucciones del stack principal
echo -e "${BLUE}🤖 Configurando instrucciones de Copilot...${NC}"
if [ -f "$GUIDELINES_DIR/stacks/$SELECTED_STACK/copilot-instructions.md" ]; then
    cp -v "$GUIDELINES_DIR/stacks/$SELECTED_STACK/copilot-instructions.md" "$TARGET_DIR/.github/copilot-instructions.md"
else
    echo -e "${YELLOW}⚠️ No se encontró copilot-instructions.md para el stack $SELECTED_STACK. Se creó archivo vacío.${NC}"
    touch "$TARGET_DIR/.github/copilot-instructions.md"
fi

# Copiar clean-code-python.md si corresponde
if [ "$SELECTED_STACK" = "python" ] && [ -f "$GUIDELINES_DIR/stacks/python/clean-code-python.md" ]; then
    echo -e "${BLUE}📄 Copiando guía de Clean Code para Python...${NC}"
    cp -v "$GUIDELINES_DIR/stacks/python/clean-code-python.md" "$TARGET_DIR/"
fi

# Bucle para agregar stacks secundarios
selected_stacks=",$SELECTED_STACK,"

while true; do
    echo ""
    echo -n "¿Querés agregar otro stack tecnológico (secundario)? (s/N): "
    read_user add_more
    if [[ ! "$add_more" =~ ^[sS]$ ]]; then
        break
    fi
    
    echo -e "\nStacks disponibles:"
    for i in "${!stacks[@]}"; do
        if [[ "$selected_stacks" =~ ",${stacks[i]}," ]]; then
            echo -e "  $((i+1))) ${stacks[i]} (YA SELECCIONADO)"
        else
            echo -e "  $((i+1))) ${stacks[i]}"
        fi
    done
    
    echo ""
    echo -n "Seleccioná el número del stack secundario: "
    read_user sec_selection
    
    if ! [[ "$sec_selection" =~ ^[0-9]+$ ]] || [ "$sec_selection" -lt 1 ] || [ "$sec_selection" -gt ${#stacks[@]} ]; then
        echo -e "${RED}❌ Selección inválida.${NC}"
        continue
    fi
    
    SEC_STACK="${stacks[$((sec_selection-1))]}"
    
    if [[ "$selected_stacks" =~ ",$SEC_STACK," ]]; then
        echo -e "${YELLOW}⚠️ El stack $SEC_STACK ya fue seleccionado anteriormente.${NC}"
        continue
    fi
    
    selected_stacks="$selected_stacks$SEC_STACK,"
    echo -e "${GREEN}✅ Stack secundario agregado: $SEC_STACK${NC}"
    
    # Anexar instrucciones del stack secundario
    if [ -f "$GUIDELINES_DIR/stacks/$SEC_STACK/copilot-instructions.md" ]; then
        echo -e "\n\n---\n\n# 🛠️ Stack secundario: $SEC_STACK\n" >> "$TARGET_DIR/.github/copilot-instructions.md"
        cat "$GUIDELINES_DIR/stacks/$SEC_STACK/copilot-instructions.md" >> "$TARGET_DIR/.github/copilot-instructions.md"
        echo -e "${BLUE}➕ Instrucciones de $SEC_STACK anexadas a .github/copilot-instructions.md${NC}"
    fi
    
    # Copiar clean-code si es python
    if [ "$SEC_STACK" = "python" ] && [ -f "$GUIDELINES_DIR/stacks/python/clean-code-python.md" ]; then
        echo -e "${BLUE}📄 Copiando guía de Clean Code para Python...${NC}"
        cp -v "$GUIDELINES_DIR/stacks/python/clean-code-python.md" "$TARGET_DIR/"
    fi
done

# Limpieza si clonamos temporalmente
if [ "$IS_LOCAL" = false ] && [ -d "$TEMP_CLONE" ]; then
    echo -e "${BLUE}🧹 Limpiando archivos temporales...${NC}"
    rm -rf "$TEMP_CLONE"
fi

echo -e "\n${GREEN}${BOLD}====================================================${NC}"
echo -e "${GREEN}${BOLD}🎉 ¡Setup completado con éxito!                     ${NC}"
echo -e "${GREEN}${BOLD}====================================================${NC}"
echo -e "\nSiguientes pasos recomendados para tu grupo:"
echo -e "  1. Abrí ${BOLD}speckit/constitution.md${NC} en tu proyecto y configuralo con las convenciones de tu equipo."
echo -e "  2. Si modificaron el stack o las reglas, actualicen ${BOLD}.github/copilot-instructions.md${NC}."
echo -e "  3. Hacé tu primer commit:"
echo -e "     ${YELLOW}git add speckit/ adr/ .github/${NC}"
echo -e "     ${YELLOW}git commit -m \"init: agregar specification kit y configuración de Copilot\"${NC}"
echo -e "     ${YELLOW}git push origin main${NC}"
echo -e "  4. Empezá a definir los requerimientos de tu proyecto en ${BOLD}speckit/specify.md${NC}."
echo ""

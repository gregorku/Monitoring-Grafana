#!/usr/bin/env bash

###############################################################################
#
# Monitoring-Grafana
#
# SNMP Module Generator
#
###############################################################################

set -Eeuo pipefail

###############################################################################
# Version
###############################################################################

readonly VERSION="0.1"

###############################################################################
# Directories
###############################################################################

readonly SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

readonly GENERATOR_DIR="${SCRIPT_DIR}/generator"

readonly MIB_DIR="${GENERATOR_DIR}/mibs"

readonly OUTPUT_DIR="${GENERATOR_DIR}/output"

readonly MODULE_DIR="${SCRIPT_DIR}/modules"

readonly GENERATOR_FILE="${GENERATOR_DIR}/generator.yml"

readonly GENERATED_FILE="${OUTPUT_DIR}/snmp.yml"

###############################################################################
# Temporary files
###############################################################################

TMP_FILE=""

###############################################################################
# Colors
###############################################################################

if [[ -t 1 ]]
then

    readonly CLR_RED=$'\033[31m'
    readonly CLR_GREEN=$'\033[32m'
    readonly CLR_YELLOW=$'\033[33m'
    readonly CLR_BLUE=$'\033[34m'
    readonly CLR_RESET=$'\033[0m'

else

    readonly CLR_RED=""
    readonly CLR_GREEN=""
    readonly CLR_YELLOW=""
    readonly CLR_BLUE=""
    readonly CLR_RESET=""

fi

###############################################################################
# Cleanup
###############################################################################

cleanup() {

    if [[ -n "${TMP_FILE}" && -f "${TMP_FILE}" ]]
    then

        rm -f "${TMP_FILE}"

    fi

}

trap cleanup EXIT

###############################################################################
# Logging
###############################################################################

log_info() {

    printf "%s==>%s %s\n" \
        "${CLR_BLUE}" \
        "${CLR_RESET}" \
        "$1"

}

log_ok() {

    printf "%s✔%s %s\n" \
        "${CLR_GREEN}" \
        "${CLR_RESET}" \
        "$1"

}

log_warn() {

    printf "%s!%s %s\n" \
        "${CLR_YELLOW}" \
        "${CLR_RESET}" \
        "$1"

}

die() {

    printf "%s✖%s %s\n" \
        "${CLR_RED}" \
        "${CLR_RESET}" \
        "$1" >&2

    exit 1

}

###############################################################################
# Require helpers
###############################################################################

require_file() {

    [[ -f "$1" ]] \
        || die "Soubor nenalezen: $1"

}

require_directory() {

    [[ -d "$1" ]] \
        || die "Adresář nenalezen: $1"

}

###############################################################################
# Check generated file
###############################################################################

check_generated_file() {

    [[ -s "${GENERATED_FILE}" ]] \
        || die "Generated snmp.yml je prázdný."

}

###############################################################################
# Banner
###############################################################################

print_banner() {

cat <<EOF

==============================================================

 Monitoring-Grafana

 SNMP Module Generator ${VERSION}

==============================================================

EOF

}

###############################################################################
# Usage
###############################################################################

usage() {

cat <<EOF

Usage:

    ./generate-modules.sh [OPTION]

Options

    --list
        List modules found in generated snmp.yml.

    --check
        Check environment.

    --split
        Split generated snmp.yml into modules.

    --help
        Show this help.

EOF

}

###############################################################################
# Check environment
###############################################################################

check_environment() {

    log_info "Kontroluji prostředí"

    require_directory "${GENERATOR_DIR}"
    log_ok "generator/"

    require_directory "${MIB_DIR}"
    log_ok "generator/mibs/"

    require_directory "${OUTPUT_DIR}"
    log_ok "generator/output/"

    require_directory "${MODULE_DIR}"
    log_ok "modules/"

    require_file "${GENERATOR_FILE}"
    log_ok "generator.yml"

}

###############################################################################
# Module name -> filename
###############################################################################

module_filename() {

    local module="$1"

    printf "%s.yml\n" "${module//_/-}"

}

###############################################################################
# List modules
###############################################################################

list_modules() {

    awk '

        /^modules:/ {

            inmodules=1

            next

        }

        inmodules && /^[[:space:]][[:space:]][A-Za-z0-9_]+:/ {

            line=$0

            sub(/^[[:space:]]+/, "", line)
            sub(/:.*/, "", line)

            print line

        }

    ' "${GENERATED_FILE}"

}

###############################################################################
# Extract one module
###############################################################################

extract_module() {

    local module="$1"

    local output

    output="${MODULE_DIR}/$(module_filename "${module}")"

    log_info "Vytvářím $(basename "${output}")"

    mkdir -p "${MODULE_DIR}"

    cat > "${output}" <<EOF

    [[ -s "${output}" ]] \
        || die "Nepodařilo se vytvořit ${output}"
###############################################################################
#
# Monitoring-Grafana
#
# AUTO GENERATED FILE
#
# Module : ${module}
#
# DO NOT EDIT
#
###############################################################################

modules:

EOF

    awk -v module="${module}" '

        BEGIN {

            inmodules=0
            copy=0

        }

        /^modules:/ {

            inmodules=1

            next

        }

        !inmodules {

            next

        }

        /^[[:space:]]+[A-Za-z0-9_]+:/ {

            line=$0

            sub(/^[[:space:]]+/, "", line)
            sub(/:.*/, "", line)

            if (line == module) {

                copy=1

            }
            else if (copy) {

                exit

            }

        }

        copy {

            print

        }

    ' "${GENERATED_FILE}" >> "${output}"

    [[ -s "${output}" ]] \
        || die "Nepodařilo se vytvořit ${output}"

    log_ok "$(basename "${output}")"

}

###############################################################################
# Split modules
###############################################################################

split_modules() {

    find "${MODULE_DIR}" \
        -maxdepth 1 \
        -type f \
        -name "*.yml" \
        -delete

    log_info "Rozděluji moduly"

    local count=0

    while IFS= read -r module
    do

        [[ -n "${module}" ]] || continue

        extract_module "${module}" \
            || die "Chyba při vytváření ${module}"

        ((++count))

    done < <(list_modules)

    ((count > 0)) \
        || die "Nebyl nalezen žádný modul."

    printf "\n"

    log_ok "Vytvořeno modulů: ${count}"

}

###############################################################################
# Summary
###############################################################################

summary() {

    local count

    count=$(find "${MODULE_DIR}" \
        -maxdepth 1 \
        -type f \
        -name "*.yml" \
        | wc -l | tr -d ' ')

    printf "\n"

    printf '%s\n' '--------------------------------------------------------------'

    printf " Moduly : %s\n" "${count}"
    printf " Výstup : %s\n" "${MODULE_DIR}"

    printf '%s\n' '--------------------------------------------------------------'

    printf "\n"

}

###############################################################################
# Main
###############################################################################

main() {

    local action="${1:---check}"

    if [[ -t 1 ]]
    then

        print_banner

    fi

    case "${action}" in

        --list)

            check_environment

            printf "\n"

            list_modules

            exit 0
            ;;

        --help|-h)

            usage
            exit 0
            ;;

        --check)

            check_environment

            printf "\n"

            summary

            log_ok "Hotovo."

            exit 0
            ;;

        --split)

            check_environment

            check_generated_file

            printf "\n"

            split_modules

            summary

            log_ok "Hotovo."

            exit 0
            ;;

        *)

            die "Neznámá volba: ${action}"

            ;;

    esac

}

###############################################################################
# Start
###############################################################################

main "$@"
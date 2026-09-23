#!/bin/bash

# Simula systemd y usa únicamente archivos temporales: no inicia tareas reales.
set -euo pipefail

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_DIR="$(mktemp -d)"
trap 'rm -rf -- "$TEST_DIR"' EXIT

# shellcheck source=../bin/fumetaos-nightly
source "$SOURCE_DIR/bin/fumetaos-nightly"

BASE_UNITS=(
    fumetaos-backup.service
    fumetaos-timecapsule-mac-backup.service
    fumetaos-recovery-backup.service
    fumetaos-mac-backup.service
    fumetaos-system-upgrade.service
)

fail() {
    echo "❌ $*" >&2
    exit 1
}

assert_status() {
    local case_name="$1" expected="$2" actual="$3"
    [ "$actual" -eq "$expected" ] ||
        fail "$case_name: código $actual; esperado $expected"
}

assert_units() {
    local case_name="$1"
    shift
    printf '%s\n' "$@" >"$TEST_DIR/$case_name/expected-units"
    diff -u "$TEST_DIR/$case_name/expected-units" "$TEST_DIR/$case_name/units" ||
        fail "$case_name: orden de servicios incorrecto"
}

assert_field() {
    local case_name="$1" field="$2" value="$3"
    grep -Fxq "$field=$value" "$TEST_DIR/$case_name/status" ||
        fail "$case_name: estado $field distinto de $value"
}

run_case() {
    local case_name="$1" day="$2" month="$3" day_of_month="$4" fail_unit="${5:-}"
    local result=0
    mkdir -p "$TEST_DIR/$case_name/stamps"

    (
        # Estas variables las consume nightly_run, definido en el archivo cargado.
        # shellcheck disable=SC2034
        VERIFY_STAMP="$TEST_DIR/$case_name/stamps/verify"
        # shellcheck disable=SC2034
        SMART_STAMP="$TEST_DIR/$case_name/stamps/smart"
        # shellcheck disable=SC2034
        STATUS_FILE="$TEST_DIR/$case_name/status"
        # shellcheck disable=SC2034
        LOCK_FILE="$TEST_DIR/$case_name/lock"
        TEST_LOG="$TEST_DIR/$case_name/units"
        FAIL_UNIT="$fail_unit"
        # shellcheck disable=SC2034
        START_DAY="$day"
        # shellcheck disable=SC2034
        START_MONTH="$month"
        # shellcheck disable=SC2034
        START_DAY_OF_MONTH="$day_of_month"

        systemctl() {
            [ "$1" = start ] || return 1
            printf '%s\n' "$2" >>"$TEST_LOG"
            [ "$2" != "$FAIL_UNIT" ]
        }

        nightly_run
    ) >"$TEST_DIR/$case_name/output" 2>&1 || result=$?

    printf '%s\n' "$result"
}

# Jueves anterior al primer sábado: solo los cinco pasos diarios.
result="$(run_case weekday 4 2026-10 1)"
assert_status weekday 0 "$result"
assert_units weekday "${BASE_UNITS[@]}"
assert_field weekday result success
assert_field weekday step Finalizada

# Un fallo se registra, pero los pasos posteriores siguen ejecutándose.
result="$(run_case failure 4 2026-10 1 fumetaos-recovery-backup.service)"
assert_status failure 20 "$result"
assert_units failure "${BASE_UNITS[@]}"
assert_field failure result failed
assert_field failure failed 'Copia de recuperación'

# El lunes se añade la verificación; SMART ya figura como intentado ese mes.
mkdir -p "$TEST_DIR/monday/stamps"
printf '%s\n' 2026-10 >"$TEST_DIR/monday/stamps/smart"
result="$(run_case monday 1 2026-10 5)"
assert_status monday 0 "$result"
assert_units monday "${BASE_UNITS[@]}" fumetaos-recovery-verify.service
assert_field monday result success
[ -f "$TEST_DIR/monday/stamps/verify" ] || fail 'monday: falta el registro de verificación'

# El primer sábado, SMART va al final y se registra un único intento mensual.
result="$(run_case saturday 6 2026-10 3)"
assert_status saturday 0 "$result"
assert_units saturday "${BASE_UNITS[@]}" fumetaos-smart-test.service
assert_field saturday result success
[ "$(<"$TEST_DIR/saturday/stamps/smart")" = 2026-10 ] ||
    fail 'saturday: falta el registro SMART'

# Si el primer sábado se perdió, se recupera una vez durante el mismo mes.
result="$(run_case missed_saturday 7 2026-10 4)"
assert_status missed_saturday 0 "$result"
assert_units missed_saturday "${BASE_UNITS[@]}" fumetaos-smart-test.service

# Si ya se intentó SMART en el mes, no se repite.
mkdir -p "$TEST_DIR/smart_done/stamps"
printf '%s\n' 2026-10 >"$TEST_DIR/smart_done/stamps/smart"
result="$(run_case smart_done 7 2026-10 4)"
assert_status smart_done 0 "$result"
assert_units smart_done "${BASE_UNITS[@]}"

# Una verificación fallida no se marca como exitosa.
mkdir -p "$TEST_DIR/verify_failure/stamps"
printf '%s\n' 2026-10 >"$TEST_DIR/verify_failure/stamps/smart"
result="$(run_case verify_failure 1 2026-10 5 fumetaos-recovery-verify.service)"
assert_status verify_failure 20 "$result"
assert_units verify_failure "${BASE_UNITS[@]}" fumetaos-recovery-verify.service
assert_field verify_failure failed 'Verificación cifrada semanal'
[ ! -e "$TEST_DIR/verify_failure/stamps/verify" ] ||
    fail 'verify_failure: se marcó una verificación fallida'

echo '✅ Cadena nocturna: siete escenarios simulados correctos; ninguna tarea real iniciada.'

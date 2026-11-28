#!/usr/bin/env bash

# Requires: acpi

charging=$(acpi -b | grep -c "Charging")
battery_level=$(acpi -b | cut -d',' -f2 | tr -d ' ',\%)
warning_level=15

if [[ $battery_level -lt $warning_level ]] && [[ $charging -eq 0 ]]; then
  notify-send "󱊡   Low battery: ${battery_level}%" -t 8000 -u critical
fi

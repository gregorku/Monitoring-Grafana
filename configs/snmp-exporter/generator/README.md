# SNMP Generator

Tento adresář obsahuje pracovní prostředí oficiálního SNMP Generatoru.

---

## Struktura

```
generator/

    generator.yml

    mibs/

    output/
```

---

## generator.yml

Vstupní konfigurace Generatoru.

---

## mibs/

Vendor MIB soubory.

Například

```
Cisco

MikroTik

Synology

APC

Juniper

RFC
```

---

## output/

Výstup Generatoru.

```
snmp.yml
```

Nikdy se neupravuje ručně.

---

## Workflow

```
generator.yml

↓

SNMP Generator

↓

output/snmp.yml

↓

generate-modules.sh

↓

modules/
```
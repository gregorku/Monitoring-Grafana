# SNMP Exporter

Konfigurace je rozdělena podle výrobců.

## Struktura

```
modules/

common.yml

mikrotik.yml

cisco-switch.yml

cisco-poe.yml

cisco-memory.yml

cisco-cpu.yml
```

---

## Přidání nového výrobce

Například APC

```
modules/

apc-ups.yml
```

---

## Přidání Synology

```
modules/

synology.yml
```

---

## Build

```
./build-snmp.sh
```

Výsledkem bude

```
snmp.yml
```

---

## Nikdy needituj

```
snmp.yml
```

Editují se pouze soubory v

```
modules/
```

# HPC-Server Setup und Konfiguration

## Hardware-Spezifikationen
- **CPU**: Intel Xeon E5-2699 v3 (36 Kerne)
- **GPU**: 2x NVIDIA Tesla P100 PCIe 16GB
- **RAM**: 128GB
- **OS**: Ubuntu 24.04.1 LTS

## Skript-Struktur

### 1. System (`scripts/system/`)
- `base_setup.sh`: Grundlegende Systemkonfiguration und Pakete

### 2. GPU (`scripts/gpu/`)
- `tesla_p100_setup.sh`: Tesla P100 Dual-GPU Optimierung
  - NVIDIA Treiber 560
  - CUDA-Toolkit
  - Performance-Optimierungen

### 3. CPU (`scripts/cpu/`)
- `xeon_e5_2699_setup.sh`: CPU-Optimierung
  - Intel OneAPI/HPC Kit
  - Performance Governor
  - NUMA-Optimierung

### 4. Monitoring (`scripts/monitoring/`)
- `hardware_monitor.sh`: Umfassendes Hardware-Monitoring
  - CPU/GPU-Status
  - Speicher/Festplatten
  - Performance-Metriken

### 5. Wartung (`scripts/maintenance/`)
- `system_maintenance.sh`: Automatische Systemwartung
  - Updates
  - Optimierungen
  - Reinigung

## Installation

1. Ausführungsrechte setzen:
```bash
chmod +x Setup/scripts/master_setup.sh
```

2. Master-Setup ausführen:
```bash
cd Setup/scripts
./master_setup.sh
```

3. System neu starten:
```bash
sudo reboot
```

## Automatisierung
- Hardware-Monitoring läuft alle 5 Minuten
- Systemwartung täglich um 3 Uhr morgens
- Permanente Performance-Optimierungen für CPU und GPU

## Performance-Optimierungen

### GPU
- Persistence Mode aktiviert
- Power Limit: 250W
- Memory Clock: 715 MHz
- Graphics Clock: 1328 MHz
- Exclusive Process Mode

### CPU
- Performance Governor
- Turbo Boost aktiviert
- C-States optimiert
- NUMA-Balancing deaktiviert
- MKL/OpenMP Optimierungen

## Monitoring

Status überprüfen:
```bash
# Hardware-Status
~/Setup/scripts/monitoring/hardware_monitor.sh

# GPU-Status
nvidia-smi

# CPU-Status
lscpu
```

## Wartung

Manuelle Wartung ausführen:
```bash
~/Setup/scripts/maintenance/system_maintenance.sh
```

## Logs
- System-Logs: `/var/log/system_maintenance.log`
- Hardware-Monitoring: `/var/log/hardware_monitor.log`
- Master-Setup: `/var/log/master_setup.log`

## Support
Bei Problemen bitte die Logs überprüfen und das entsprechende Skript im Debug-Modus ausführen:
```bash
bash -x [skript].sh
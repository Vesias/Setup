#!/bin/bash
# Intel Xeon E5-2699 v3 Optimierung

echo "=== Intel Xeon E5-2699 v3 Setup ==="

# Intel OneAPI Repository
echo "Füge Intel Repository hinzu..."
wget -O- https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB | \
    gpg --dearmor | sudo tee /usr/share/keyrings/oneapi-archive-keyring.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/oneapi-archive-keyring.gpg] https://apt.repos.intel.com/oneapi all main" | \
    sudo tee /etc/apt/sources.list.d/oneAPI.list

# System aktualisieren
sudo apt update

# Intel HPC Kit Installation
echo "Installiere Intel HPC Tools..."
sudo apt install -y \
    intel-basekit \
    intel-hpckit \
    intel-oneapi-compiler-dpcpp-cpp \
    intel-oneapi-compiler-fortran \
    intel-oneapi-mkl \
    intel-oneapi-mpi \
    intel-oneapi-tbb \
    intel-oneapi-advisor

# CPU Performance-Optimierungen
echo "Konfiguriere CPU-Performance..."

# Performance Governor für alle 36 Kerne
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    echo performance | sudo tee $cpu
done

# Turbo Boost aktivieren
echo 0 | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo

# C-States optimieren für HPC
echo "Optimiere C-States..."
for i in /sys/devices/system/cpu/cpu*/cpuidle/state*/disable; do
    echo 1 | sudo tee $i
done

# Intel MKL Optimierungen
echo "Konfiguriere MKL..."
cat << 'EOF' | sudo tee /etc/profile.d/intel_mkl.sh
# Intel MKL Optimierungen für Xeon E5-2699 v3
export MKL_DEBUG_CPU_TYPE=5
export MKL_NUM_THREADS=36
export OMP_NUM_THREADS=36
export KMP_AFFINITY=granularity=fine,compact,1,0
export MKL_DYNAMIC=FALSE
EOF

# NUMA Optimierungen
echo "Konfiguriere NUMA..."
cat << EOF | sudo tee /etc/sysctl.d/10-numa.conf
kernel.numa_balancing = 0
vm.zone_reclaim_mode = 0
kernel.sched_migration_cost_ns = 5000000
kernel.sched_min_granularity_ns = 10000000
EOF

# CPU Frequency Scaling
cat << EOF | sudo tee /etc/sysctl.d/11-cpu-performance.conf
# CPU Performance Optimierungen
kernel.sched_min_granularity_ns = 10000000
kernel.sched_wakeup_granularity_ns = 15000000
kernel.sched_migration_cost_ns = 5000000
kernel.sched_nr_migrate = 32
EOF

# Intel Compiler Umgebung
echo "Konfiguriere Intel Compiler..."
cat << 'EOF' | sudo tee /etc/profile.d/intel_compiler.sh
# Intel Compiler Setup
source /opt/intel/oneapi/setvars.sh > /dev/null 2>&1
export CPATH="/opt/intel/oneapi/compiler/latest/include:$CPATH"
export LIBRARY_PATH="/opt/intel/oneapi/compiler/latest/lib:$LIBRARY_PATH"
EOF

# Systemd Service für Performance
cat << 'EOF' | sudo tee /etc/systemd/system/cpu-performance.service
[Unit]
Description=CPU Performance Settings
After=network.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c 'for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do echo performance > $cpu; done'
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

# Service aktivieren
sudo systemctl enable cpu-performance
sudo systemctl start cpu-performance

echo "=== Intel Xeon E5-2699 v3 Setup abgeschlossen ==="
echo "Bitte System neu starten für vollständige Aktivierung"
#!/usr/bin/env bash

ARGS=(
	# CPU
	-accel "accel=${ACCEL:-kvm}"
	-smp "cores=${CPU_CORES:-8},threads=${CPU_THREADS:-1}"


	# Video
	-vga "${GPU:-qxl}"

	# Bibus
	-boot "order=dc,menu=on"
	-smbios "type=0,vendor=,version="

	# Memory
	-m "size=${MEMSIZE:-8G}"

	# Disks
	#-drive "file=./mydrive.img"
)

qemu-system-x86_64 "${ARGS[@]}" "$@"

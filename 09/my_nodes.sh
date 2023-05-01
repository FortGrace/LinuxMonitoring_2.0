#!/bin/bash
cpu="$(cat /proc/loadavg | awk '{print $1}')"
mem_free="$(free | grep Mem | awk '{print $2}')"
mem_used="$(free | grep Mem | awk '{print $3}')"
disk_used=`df / | tail -n1 | awk '{print $3}'`
disk_available=`df / | tail -n1 | awk '{print $4}'`
echo \# HELP s21_cpu_usage CPU usage.
echo \# TYPE s21_cpu_usage gauge
echo s21_cpu_usage $cpu
echo \# HELP s21_mem_free Free memory.
echo \# TYPE s21_mem_free gauge
echo s21_mem_free $mem_free
echo \# HELP s21_mem_used Used memory.
echo \# TYPE s21_mem_used gauge
echo s21_mem_used $mem_used
echo \# HELP s21_disk_used Used disk.
echo \# TYPE s21_disk_used gauge
echo s21_disk_used $disk_used
echo \# HELP s21_disk_available Available disk.
echo \# TYPE s21_disk_available gauge
echo s21_disk_available $disk_available

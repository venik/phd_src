#!/usr/bin/gnuplot -persist

#set terminal postscript eps enhanced
#set output "test_fft.ps"

set terminal jpeg 
set output "test_fft.jpeg"

set encoding koi8r

set xlabel "SNR, dB" font "Helvetica,18"
set ylabel "Probablility, %" font "Helvetica,18"
set style line 1 lt 1 pt 7

# grid ON
set grid xtics ytics mxtics mytics

#plot "test_fft.res" using 2 title "СКО" with linespoints linestyle 1
plot "test_fft.res" using 1:2 title "Parallel correlator" with linespoints linestyle 1

#!/usr/bin/env python

# Nikiforov Alex
# nikiforov.alex@rf-lab.org
# Volterra series generator
# GPLv3

import sys
#from datetime import datetime
#import string

head =	'function s_ode()\n' \
	'clc;'

ode_data =	'\nx0=[1;1];\n'				\
		'tspan=[0:0.01:150];\n'			\
		'[t,x]=ode45(@eq1,tspan,x0);\n'		\
		'clf; figure(1), plot(x(:,1),x(:,2)), grid on; % hold on, comet(x(:,1),x(:,2)) ;\n' \
		'fprintf(\'Variance duffing %f\\n\', var(x(:,1)));\n'

ode_func =	'\nfunction f = eq1(t,x)\n'		\
		'%s\n'					\
		'gamma = 1 ;\n'				\
		'w = 1 ;\n'				\
		'k = 0.5 ;\n'				\
		'f=[x(2);-k*x(2) + x(1) - x(1)^3 + gamma*cos(w*t) + %s] ;\n'


func_noise = 	'global noise\n'	\
		'noise = 1 * randn(1, length(50:2500)) ;\n'

our_func = 	'gamma = 1 ;\n'		\
		'f = gamma * cos(1*tspan) ;\n'	\
		'f = f(50:2500) + %s;\n'	\
		'y = x(50:2500,1) ;'

volt_cycle_st = '\nlen = size(f,2) ;\n'		\
		'X = zeros(len-%d, 18) ;\n'	\
		'for n=%d:len'

volt_cycle_body='  X(n-%d,%d) = 1 ;\n'

volt_cycle_body1='  X(n-%d,%d) = f(n-%d) ;\n'
volt_cycle_body2='  X(n-%d,%d) = f(n-%d)*f(n-%d) ;\n'
volt_cycle_body3='  X(n-%d,%d) = f(n-%d)*f(n-%d)*f(n-%d) ;\n'

volt_cycle_end = 'end\n\n'		\
		 'size(pinv(X))\n'	\
		 'size(y(%d:end))\n'	\
		 'h = pinv(X)*y(%d:end)'

name_mat = '\nsavefile = \'ode_h.mat\' ;\n'
save_mat = 'save(savefile, \'h\') ;\n'
load_mat = 'load(savefile, \'h\') ;\n'

figure = '\nfigure(2), hold off,plot(y), hold on,plot(r,\'r-\'), legend(\'duffing\', \'volterra\');'

volt_cycle2 = 'r = zeros(size(y)) ;\n'	\
	      'for n=%d:length(y)\n'
volt_cycle2_end = 'end\n' \
		  'fprintf(\'Variance volterra %f\\n\', var(r));\n'

volt_cycle2_body1 = 'h(%d)*f(n-%d) + '
volt_cycle2_body2 = 'h(%d)*f(n-%d)*f(n-%d) + '
volt_cycle2_body3 = 'h(%d)*f(n-%d)*f(n-%d)*f(n-%d) + '

def put_line(fd, data, new_line = True):
	if new_line:
		data = '\n' + data

	fd.write(data)
	
# Main program
#if len(sys.argv) < 3:
#	print("%s log_name output_name" % sys.argv[0])
#	sys.exit()

fd_m = open('volterra.m', 'w')
fd_test_m = open('volterra_test_noise.m', 'w')

# head of file for generating volterra series
put_line(fd_m, head, False)
put_line(fd_m, ode_data)
put_line(fd_m, our_func % ('0'))

put_line(fd_test_m, head, False)
put_line(fd_test_m, ode_data)
put_line(fd_test_m, func_noise)
put_line(fd_test_m, our_func % ('noise'), False)

# volterra
deep = 3 
eq_num = 1
put_line(fd_m, volt_cycle_st % (deep-1, deep))
put_line(fd_m, volt_cycle_body % (deep-1, eq_num))
eq_num += 1

# 1 order
for i in range(0, deep):
	put_line(fd_m, volt_cycle_body1 % (deep-1, eq_num, i), False)	
	eq_num += 1

put_line(fd_m, '')

# 2 order
for i in range(0, deep):
	for j in range(0, deep):
		if (j >= i):
			#print("i=%d j=%d" % (i,j))
			put_line(fd_m, volt_cycle_body2 % (deep-1, eq_num, i, j), False)
			eq_num += 1

put_line(fd_m, '')

# 3 order
for i in range(0, deep):
	for j in range(0, deep):
		for k in range(0, deep):
			if (k >= j) and (j >= i):
				#print("i=%d j=%d k=%d" % (i,j,k))
				put_line(fd_m, volt_cycle_body3 % (deep-1, eq_num, i, j, k), False)
				eq_num += 1

put_line(fd_m, volt_cycle_end % (deep, deep), False)

# save/load .mat file
put_line(fd_m, name_mat)
put_line(fd_m, save_mat, False)

put_line(fd_test_m, name_mat)
put_line(fd_test_m, load_mat, False)

# cycle for plotting
put_line(fd_m, volt_cycle2 % (deep))
put_line(fd_test_m, volt_cycle2 % (deep))

# end of cycle for calculation of the volterra series
eq_num = 2
put_line(fd_m, '  r(n) = h(1) + ', False)
put_line(fd_test_m, '  r(n) = h(1) + ', False)
# 1 order
for i in range(0, deep):
	put_line(fd_m, volt_cycle2_body1 % (eq_num, i), False)	
	put_line(fd_test_m, volt_cycle2_body1 % (eq_num, i), False)	
	eq_num += 1
	if (eq_num % 5) == 0:
		put_line(fd_m, " ...\n", False)
		put_line(fd_test_m, " ...\n", False)

# 2 order
put_line(fd_m, "  ...\n", False)
put_line(fd_m, '  ', False)
put_line(fd_test_m, "  ...\n", False)
put_line(fd_test_m, '  ', False)
for i in range(0, deep):
	for j in range(0, deep):
		if (j >= i):
			put_line(fd_m, volt_cycle2_body2 % (eq_num, i, j), False)	
			put_line(fd_test_m, volt_cycle2_body2 % (eq_num, i, j), False)	
			eq_num += 1
			if (eq_num % 5) == 0:
				put_line(fd_m, " ...\n", False)
				put_line(fd_m, '  ', False)
				put_line(fd_test_m, " ...\n", False)
				put_line(fd_test_m, '  ', False)

# 3 order
for i in range(0,3):
	for j in range(0,3):
		for k in range(0,3):
			if (k >= j) and (j >= i):
				put_line(fd_m, volt_cycle2_body3 % (eq_num, i, j, k), False)	
				put_line(fd_test_m, volt_cycle2_body3 % (eq_num, i, j, k), False)	
				eq_num += 1
				if (eq_num % 5) == 0:
					put_line(fd_m, " ...\n", False)
					put_line(fd_m, '  ', False)
					put_line(fd_test_m, " ...\n", False)
					put_line(fd_test_m, '  ', False)

put_line(fd_m, '0 ;', False)
put_line(fd_m, volt_cycle2_end)

put_line(fd_test_m, '0 ;', False)
put_line(fd_test_m, volt_cycle2_end)

# plot output from volterra and duffing 
put_line(fd_m, figure)
put_line(fd_test_m, figure)

# end of file
put_line(fd_m, ode_func % ('% nothing here', '0'))
put_line(fd_test_m, ode_func % ('global noise', 'noise(round(t) + 1)'))

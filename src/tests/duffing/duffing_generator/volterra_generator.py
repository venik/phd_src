#!/usr/bin/env python

# Nikiforov Alex
# nikiforov.alex@rf-lab.org
# Volterra series generator
# GPLv3

import sys
#from datetime import datetime
#import string

head =	'function s_ode()\n' \
	'clc;\n'

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

volt_rec_body1='  X(n-%d,%d) = y(n%d) ;\n'

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

volt_rec2_body1 = 'h(%d)*r(n%d) + '

def put_line(fd, fd_test, data, new_line = True):
	if new_line:
		data = '\n' + data

	if fd_test != None:
		fd_test.write(data)

	fd.write(data)
	
# Main program
Recursive = False

if len(sys.argv) < 2:
	print("%s deep of volterra series [deep of order 2] [deep of order 3] [deep of recursive part]" % sys.argv[0])
	sys.exit()
elif len(sys.argv) == 2:
	deep1 = int(sys.argv[1])
	deep2 = int(sys.argv[1])
	deep3 = int(sys.argv[1])
elif len(sys.argv) == 3:
	deep1 = int(sys.argv[1])
	deep2 = int(sys.argv[2])
	deep3 = int(sys.argv[2])
elif len(sys.argv) == 4:
	deep1 = int(sys.argv[1])
	deep2 = int(sys.argv[2])
	deep3 = int(sys.argv[3])
elif len(sys.argv) == 5:
	deep1 = int(sys.argv[1])
	deep2 = int(sys.argv[2])
	deep3 = int(sys.argv[3])
	rec_part = deep1 - int(sys.argv[4])
	Recursive = True

	# check for recursive part
	if rec_part < 0:
		print("[ERR] Recursive part cannot be deeper that linear part")
		sys.exit()

else:
	print("%s deep of volterra series [deep of order 2] [deep of order 3]" % sys.argv[0])
	sys.exit()



fd_m = open('volterra.m', 'w')
fd_test_m = open('volterra_test_noise.m', 'w')

# head of file for generating volterra series
put_line(fd_m, fd_test_m, head, False)
put_line(fd_test_m, None, func_noise)
put_line(fd_m, fd_test_m, ode_data, False)
put_line(fd_m, None, our_func % ('0'))
put_line(fd_test_m, None, our_func % ('noise'))

# volterra
eq_num = 1
put_line(fd_m, None, volt_cycle_st % (deep1-1, deep1))
put_line(fd_m, None, volt_cycle_body % (deep1-1, eq_num))
eq_num += 1

# 1 order
for i in range(0, deep1):
	if i < rec_part:
		put_line(fd_m, None, volt_cycle_body1 % (deep1-1, eq_num, i), False)	
	else:
		put_line(fd_m, None, volt_rec_body1 % (deep1-1, eq_num, rec_part - i - 1), False)	

	eq_num += 1

put_line(fd_m, None, '')

# 2 order
for i in range(0, deep2):
	for j in range(i, deep2):
		if (j >= i):
			#print("i=%d j=%d" % (i,j))
			put_line(fd_m, None, volt_cycle_body2 % (deep1-1, eq_num, i, j), False)
			eq_num += 1

put_line(fd_m, None, '')

# 3 order
for i in range(0, deep3):
	for j in range(i, deep3):
		for k in range(j, deep3):
			if (k >= j) and (j >= i):
				#print("i=%d j=%d k=%d" % (i,j,k))
				put_line(fd_m, None, volt_cycle_body3 % (deep1-1, eq_num, i, j, k), False)
				eq_num += 1

put_line(fd_m, None, volt_cycle_end % (deep1, deep1), False)

# save/load .mat file
put_line(fd_m, fd_test_m, name_mat)
put_line(fd_m, None, save_mat, False)
put_line(fd_test_m, None, load_mat, False)

# cycle for plotting
put_line(fd_m, fd_test_m, volt_cycle2 % (deep1))

# end of cycle for calculation of the volterra series
eq_num = 2
put_line(fd_m, fd_test_m, '  r(n) = h(1) + ', False)

# 1 order
for i in range(0, deep1):
	if i < rec_part:
		put_line(fd_m, fd_test_m, volt_cycle2_body1 % (eq_num, i), False)	
	else:
		put_line(fd_m, fd_test_m, volt_rec2_body1 % (eq_num, rec_part - i - 1), False)	

	eq_num += 1
	if (eq_num % 5) == 0:
		put_line(fd_m, fd_test_m, " ...\n", False)
		put_line(fd_m, fd_test_m, '  ', False)

put_line(fd_m, fd_test_m, " ...\n", False)
put_line(fd_m, fd_test_m, '  ', False)

# 2 order
for i in range(0, deep2):
	for j in range(0, deep2):
		if (j >= i):
			put_line(fd_m, fd_test_m, volt_cycle2_body2 % (eq_num, i, j), False)	
			eq_num += 1
			if (eq_num % 5) == 0:
				put_line(fd_m, fd_test_m, " ...\n", False)
				put_line(fd_m, fd_test_m, '  ', False)

put_line(fd_m, fd_test_m, " ...\n", False)
put_line(fd_m, fd_test_m, '  ', False)

# 3 order
for i in range(0,deep3):
	for j in range(0,deep3):
		for k in range(0,deep3):
			if (k >= j) and (j >= i):
				put_line(fd_m, fd_test_m, volt_cycle2_body3 % (eq_num, i, j, k), False)	
				eq_num += 1
				if (eq_num % 5) == 0:
					put_line(fd_m, fd_test_m, " ...\n", False)
					put_line(fd_m, fd_test_m, '  ', False)

put_line(fd_m, fd_test_m, '0 ;', False)
put_line(fd_m, fd_test_m, volt_cycle2_end)


# plot output from volterra and duffing 
put_line(fd_m, fd_test_m, figure)

# end of file
put_line(fd_m, None, ode_func % ('% nothing here', '0'))
put_line(fd_test_m, None, ode_func % ('global noise', 'noise(round(t) + 1)'))

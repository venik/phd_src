% generate ca and xcorr(ca)

addpath ("../../../../src/gnss/") ;

ca = ca_generate_bits(19, 0);

ca_corr = xcorr(ca);
length(ca_corr)
x = 0:2044;
plot(x, ca_corr), grid on; xlim([0,2044]), ylim([-100, 1050]);
figure (1, 'visible', 'on');
print -deps 'ca_xcorr.eps'

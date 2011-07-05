addpath('../../gnss/');

PRN = 19 ;
PRN_fake = 2 ;
tau = 10000;

ca_base = ca_get(PRN, 0) ;
ca_fake = ca_get(PRN_fake, 0) ;

ca_local = [ca_base] ;
ca_tmp = [ca_base; ca_base] ;
ca_tau = ca_tmp(tau:length(ca_local) + tau - 1);

ca_new = ca_local .* ca_tau;

ca_new_test = zeros(3, 16368*2-1);

%for k= -1:1
%	ca_new_tmp = ca_local .* ca_tmp(tau + 16*k:length(ca_local) + tau + 16*k -1);
%	ca_new_test(k+2,:) = xcorr(ca_new, ca_new_tmp);
%	fprintf('res = %15.5f\n', max(ca_new_test(k+2,:)));
%end

ca_new = ca_new * exp(2*j*pi*0.4*tau);
for k= -1:1
	ca_new_tmp = ca_local .* ca_tmp(tau + 16*k:length(ca_local) + tau + 16*k -1);
	ca_new_test(k+2,:) = sum(ca_new_tmp .* ca_new);
	fprintf('res = %15.5f\n', max(ca_new_test(k+2,:)));
end

rmpath('../../gnss/');

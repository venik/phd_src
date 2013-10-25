function ca_primo = get_ca_code_primo(N,PRN)
ca = get_ca_code(N+2,PRN) ; 
chip_width = 1/1.023e6 ;                % /* CA chip duration, sec */
ts = 1/5.456e6 ;                       % /* discretization period, sec */
%ts = 1/10.912e6 ;
M = ceil(N*chip_width/ts) ;
ca_primo = zeros(M,1) ;
for k=1:M
    ca_primo(k) = ca(ceil(ts*k/chip_width)) ;
end

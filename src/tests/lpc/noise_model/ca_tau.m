clc, clear all ;

code1 = get_ca_code16(1023,1) ;
code2 = get_ca_code16(1023,2) ;

%tau = 0 ;
tau = [0, 2, 4, 8] ;

res = zeros(37, numel(tau)) ;

for i=1:numel(tau)
    code_tst = circshift(code2, tau(i)) .* code1 ; 
    C21 = fft(code_tst) ;
    res_tmp = abs((ifft(C21 .* conj(C21)))) /16 / 1023 ;
    res(:, i) = [res_tmp(end-17 : end) ; res_tmp(1:19)] ;
    
end % for

% plot
figure(1)
    plot( ...
        [-18:18], res(:, 1), 'b*', ...
        [-18:18], res(:, 2), 'go', ...
        [-18:18], res(:, 3), 'r+', ...
        [-18:18], res(:, 4), 'mp' ...
    ),
    title('АКФ последовательности C(t)') ,
    
    h = legend('$\tau=0$', '$\tau=2$', '$\tau=4$', '$\tau=8$');
    set(h,'interpreter','latex')
    
    xlim([-18 18]),
    ylim([0 1.2])
    xlabel('\tau'),
    ylabel('R(\tau)'),
    grid on;
    %hold on;

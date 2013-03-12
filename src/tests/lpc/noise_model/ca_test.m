clc, clear all ;

code1 = get_ca_code16(1023,1) ;
code2 = get_ca_code16(1023,2) ;

tau = 8 ;
code21 = circshift(code2, tau) ;

C1 = fft(code1) ;
C2 = fft(code2) ;

%code for test
%code_tst = code21; fprintf('good\n')        % Gold code
code_tst = code21 .* code1 ; fprintf('baad\n');       % Broken code

C21 = fft(code_tst) ;

CN = C21 ;
res = abs((ifft(C21 .* conj(C21)))) ;

% check for pseudo noise
c21_tmp = (code_tst + 1) / 2 ; 

% 1 - balanced number of zeros = number of ones
fprintf('Check for balance\n')
fprintf('\tones=%.1f\t\thalf length=%.1f\n', sum(c21_tmp)/16, length(c21_tmp) / 2/16) ;
if(round(sum(c21_tmp)/16) == round(length(c21_tmp) / 2/16))
    fprintf('\tPassed\n')
else
    fprintf('\tNOT Passed\n')
end

% 2 - balanced number of zeros = number of ones
fprintf('Check for cyclic\n')
i = 1;
array = zeros(length(c21_tmp), 2) ;
while(1)
    base_val = c21_tmp(i) ;
    len = 0 ;
    while(i <= numel(c21_tmp) && base_val == c21_tmp(i))
        i = i + 1 ;
        len = len + 1 ;
    end % if
    array(round(len/16) + 1, base_val + 1) = array(round(len/16) + 1, base_val + 1) + 1;
    if (i >= numel(c21_tmp))
        break;
    end % if
end % while

prob_0 = array(1:10, 1) ./ 1023 * 100 ;
fprintf('For zeros: ');
for i=1:10
    fprintf('%d:%.2f ', i, prob_0(i))
end
fprintf('\n');

prob_1(1:10) = array(1:10, 2) ./ 1023 * 100 ;
fprintf('For ones : ');
for i=1:10
    fprintf('%d:%.2f ', i, prob_1(i))
end
fprintf('\n');

figure(1)
    subplot(2, 1, 1), barh(0:14, array(1:15, 1)), title('Циклы нулей') ;
    subplot(2, 1, 2), barh(0:14, array(1:15, 2)), title('Циклы единиц') ;

% 3 - correlation
fprintf('Check for correlation\n')
tmp_res = res/16 ;
for i=17:numel(tmp_res)-17
        if(tmp_res(i) > 16)
            fprintf('\t NOT passed, bcoz ACF too high, must be around zero ACF(%d)=%d\n', i, tmp_res(i)) ;
            break ;
        end % if
end %for
    
% plot
figure(2)
%plot(res(1:20), 'b*'),
plot(res/16, 'b*'),
legend(sprintf('tau=%d', tau));
hold on;

figure(3) ;
psd = fftshift(C21) ;
plot((0:1023)/1024*16368/2,abs(psd(1:1024)),'LineWidth',2) ;
grid on ;
xlabel('Частота') ;
title('СПМ')
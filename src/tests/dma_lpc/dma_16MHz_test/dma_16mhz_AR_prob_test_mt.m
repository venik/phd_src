clear all; clc;

path_gnss = '../../../gnss/' ;
path_model = '../../tsim/model/' ;
addpath(path_gnss);
addpath(path_model);

ms = 32 ;
N = 16368 ;

sat = 30 ;
fd = 16.368e6 ;
base_freq = 4.093920e6 ;

step = 100 ;
base_point = 100 ;
fourier_length = 4 * N ;
power = 8 ;

tau = 16;
iteration = 8 ;

prb = zeros(4, 1) ;
prb_detected = zeros(4, 1) ;
variance = zeros(4, 1) ;

%%%%%%
% prepare data
% sig_from_file = readdump_txt('../data/flush.txt', 32*N);	% create data vector
% save('../data/flush.txt.mat', 'sig_from_file') ;

% load sig_from_file array
load('../data/flush.txt.mat') ;
array_size = length(sig_from_file) ;

%matlabpool open 4 ;

% k - window function
for k =1:4
    
    % Main satellite
    x_ca16 = ca_get(sat, 0) ;
    x_ca16 = repmat(x_ca16, ms + 1, 1) ;
    
    for kk = 0:5000

        point = base_point + kk * step ;
        if (point + iteration * N > array_size)
            fprintf('end of array, iteration: %d\n', kk) ;
            break ;
        end;

        sig = sig_from_file(point : ms*N) ;

        sig_dma = zeros(N,1);
        for kkk=1:iteration
            sig_dma = sig_dma + ... 
                   sig((kkk-1)*N + 1: kkk*N) .* sig((kkk-1)*N + 1 + tau: kkk*N + tau);
        end

        sig_dma = sig_dma ./ iteration;

        %Fnyq = fd/2 ;       % Nyquist freq
        %Fc=Fnyq/2 ;             % cut-off freq [Hz]
        %[b, a]=butter(2, Fc/Fnyq);

        %sig_filt_dma = filter(b, a, sig_dma) ;
        sig_filt_dma = sig_dma ;

        %plot([sig_dma(1:100), sig_filt_dma(1:100)])

        SIG_FILT_DMA = fft(sig_filt_dma);

        % generate local replica of the new code
        ca_new_tmp = x_ca16(1:N) .* x_ca16(1+tau : N+tau);
        CA_NEW_TMP = fft(ca_new_tmp);

        % correlate
        acx = ifft(CA_NEW_TMP .* conj(SIG_FILT_DMA));
        acx = sqrt(acx .* conj(acx));

        % [acx, ca_phase]
        [peak, pos] = max(acx) ;
        %fprintf('sat: %02d\tE = %.2f\t pos=%d\n', sat, peak, pos) ;
        %plot(acx); return ;

        sig_cos = real(sig(1:N) .* x_ca16(pos : N + pos - 1)) ;
        %plot(sig_cos(1:100)); return;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Make me quadruple
        if k == 1
            sig_ar = sig_cos(1:N) ;
            else if k == 2
                sig_ar = sig_cos(1:N) .* hann(N, 'periodic') ;
                else if k == 3
                    sig_ar = sig_cos(1:N) .* hamming(length(N)) ;
                    else if k ==4
                            sig_ar = sig_cos(1:N) .* blackman(length(N)) ;
                        else
                            assert();
                        end ; % 4
                    end ; %3
                end ; %2
        end ; % 1

        X = fft(sig_ar, fourier_length) ;
        XX(1, :) = X.*conj(X) ;
        XX8 = XX .^ power ./ 10e50 ;
        rxx = ifft(XX8) ;
        %plot(rxx(1:100)); return ;
        %plot(abs(XX8)); return ;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % AR model
        b = ar_model([rxx(1); rxx(2); rxx(3)]) ;
        [poles, omega0, Hjw0] = get_ar_pole(b) ;
        freq = fd * omega0 / (2*pi) ;

        %fprintf('sat: %02d freq: %03.05f pos=%d\n', sats, freq, pos) ;

        if (abs(freq - base_freq) < 40)
            fprintf('k: %d\tsat: %02d freq: %03.05f pos=%d\n', k, sat, freq, pos) ;
            prb_detected(k) = prb_detected(k) + 1 ;
            variance(k) = variance(k) + (freq - base_freq)^2 ;
        else
            %fprintf('sat: %02d freq: %03.05f pos=%d\n', sats(1), freq, pos) ;
            %pause;
        end;

        prb(k) = prb(k) + 1;

    end ; % for (kk)
    
end ; % for (k) 

%matlabpool close ;

variance = variance / prb_detected ;

fprintf('sat: %02d fourier_length: %d power: %d\n', sat, fourier_length / N, power); 
fprintf('RECT: probability:%.02f var:%.02f\n', 100 * prb_detected(1) / prb(1), variance(1)) ;
fprintf('HANN: probability:%.02f var:%.02f\n', 100 * prb_detected(2) / prb(2), variance(2)) ;
fprintf('HAMMING: probability:%.02f var:%.02f\n', 100 * prb_detected(3) / prb(3), variance(3)) ;
fprintf('BLACKMAN probability:%.02f var:%.02f\n', 100 * prb_detected(4) / prb(4), variance(4)) ;


%semilogy(abs(fft(rxx(1:N))))
%    title(sprintf('ms: %d, ACF iteration: %d estimated freq: %.0f \n', ...
%        length(sig_after_dma) / N, acf_iteration, freq)) ;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% END
rmpath(path_gnss) ;
rmpath(path_model) ;
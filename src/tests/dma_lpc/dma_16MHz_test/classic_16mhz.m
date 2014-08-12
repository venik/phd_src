%    Top module for the parralel correaltor acuisition method
%    Copyright (C) 2010 - 2011 Alex Nikiforov  nikiforov.alex@rf-lab.org
%			 2010 - 2011 Alexey Melnikov melnikov.aleksey@rf-lab.org
%
%    This program is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.

%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.

%    You should have received a copy of the GNU General Public License
%    along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
% Reference: 	Tsui "Fundamentals of Global Positioning System Receivers" 2nd edition
% 			chapter 7

clc; clear all; clf;

gnss_lib = '../../../gnss';
path_model = '../../tsim/model/' ;
addpath(path_model);
addpath(gnss_lib);

DumpSize = 16368*6 ;
N = 16368 ;
ts = 1/16.368e6 ;
fd= 16.368e6;		% 16.368 MHz

debug_me = 0;
time_offs = 100;

fs = 4.092e6-5e3 : 1e0 : 4.092e6+5e3 ;		% sampling rate 4.092 MHz
PRN = 1:32 ;
%fs = 4.09193734691e6;
%PRN = 31 ;

model = 0;				% is it the model?

matlabpool open 4 ;

% ========= generate =======================
if model
	PRN_mod = 1:5;
	freq_deltas = [1, 1, 1, 1, 1];
	ca_deltas = [1, 1, 1, 1, 1 ];
	SNRs = [10, 10, 10, 10, 10];
	x = signal_generate(	PRN_mod,	...  %PRN
			freq_deltas,	...  % freq delta in Hz
			ca_deltas,	...  % CA phase
			SNRs,	...  % SNR
			DumpSize, ...
			debug_me);
	fprintf('Generated\n');
else
	%sig_from_file = readdump_txt('../tests/dma_lpc/data/flush.txt', DumpSize);	% create data vector
    load('../data/flush.txt.mat') ;
    x = sig_from_file(2000:DumpSize) ;
	%x = readdump_bin_2bsm('./data/flush.bin', DumpSize);
	fprintf('Real\n');
end
% ========= generate =======================

x = x(1:N);
X = fft(x);

acx = zeros(length(PRN), 1) ;
ca_phase = zeros(length(PRN), 1) ;
freq_z = zeros(length(PRN), 1) ;

res = zeros(N, 1) ;

parfor jj=1:length(PRN)
    ca_base = ca_get(PRN(jj), debug_me) ;		% generate C/A code
    %ca_base = repmat(ca_base, 1, length(x)) ;

    fprintf('PRN: %d\n', PRN(jj)) ;
    
    for k = 1:length(fs)
        lo_sig = exp(1i*2*pi * (fs(k)/fd)*(0:N-1)).';
        CA = fft(lo_sig .* ca_base);
        %CA = fft(real(lo_sig) .* ca_base);

        %ca = ifft(conj(CA) .* X);
        ca = ifft(CA .* conj(X));		% equal to circular correlation
        ca = ca .* conj(ca);

        [value_x, index_x] = max(ca) ;

        if (value_x > acx(jj))
            res = ca ;
            acx(jj) = value_x ;
            ca_phase(jj) = index_x ;
            freq_z(jj) = fs(k) ;
        end;
    end % for k = 1:length(FR)
    
    %fprintf('PRN: %02d\tCA phase: %d\tfreq: %.2f\tE/sigma: %.2f dB\n', ...
     %   PRN(jj), ca_phase(jj), freq_z(jj), 10*log10(acx(jj) / std(res)));
end

matlabpool close ;

for jj=1:length(PRN)
      fprintf('PRN: %02d\tCA phase: %d\tfreq: %.2f\n', ...
        PRN(jj), ca_phase(jj), freq_z(jj));
end

barh(acx((1:32),1), 'k'),
    ylim([0 33]),
    xlabel('Энергия'),
    ylabel('Источник сигнала'),
    grid on,
    phd_figure_style(gcf) ;
	
%%%%%%%
% END
rmpath(path_model);
rmpath(gnss_lib);
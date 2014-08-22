%$URL: svn://hsrv.dyndns-ip.com/serg/MatLab_Collection/GPSRxTest/branches/ProcedureSeparation/main.m $

clc, clear;
settings = initSettings();
% carrNco = CarrierNCO();
% codeNco = CodeNCO(1);
% 
% tmp = carrNco.Execute(4.092E6, 5456) .* codeNco.Execute(1.023E6, 5456);
% 
% return;
isTrack = true;

rx = Receiver();
rx.Run(isTrack);

dtct_res = [rx.channels.detector];
prn = [dtct_res.PRN]';
rssi = [dtct_res.RSSI]';

figure;
bar(prn, rssi);
barXRange = [0, size(prn, 1) + 1];
line(barXRange, [settings.acqThreshold, settings.acqThreshold], ...
	[0 0], 'Color', 'red');
set(gca, 'XLim', barXRange);
grid on;

act_ch_count = 0;
l_count = 8;
r = rem(rx.channelsCount, l_count);
for i = 0:rx.channelsCount - 1
	ch_idx = i + 1;
	if strcmp(rx.channels(ch_idx).State, 'active')
		s_idx = mod(act_ch_count, l_count);
		data = [ rx.channels(ch_idx).PRN, ...
			rx.channels(ch_idx).detector.RSSI, ...
			rx.channels(ch_idx).detector.Frequency];
		
		fprintf('prn: %4i, rssi: %30.15f, freq: %10i Hz\n', data);
		
		if isTrack
			if s_idx == 0
				figure;
			end
			subplot(l_count, 1, s_idx + 1);
			plot(0:settings.processTime-1, rx.channels(ch_idx).I);
			set(gca, 'YLim', [-2000 2000]);
			title(['PRN: ' int2str(rx.channels(ch_idx).PRN)]);
			grid on;
		end
		act_ch_count = act_ch_count + 1;
	end
end
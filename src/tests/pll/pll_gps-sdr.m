% loop from gps-sdr
%  aPLL.PLLBW = _bwpll;
%  aPLL.FLLBW = 4.0;
%
%  aPLL.b3 = 2.40;
%  aPLL.a3 = 1.10;
%  aPLL.a2 = 1.414;
%  aPLL.w0p = aPLL.PLLBW/0.7845;
%  aPLL.w0p2 = aPLL.w0p*aPLL.w0p;
%  aPLL.w0p3 = aPLL.w0p2*aPLL.w0p;
%  aPLL.w0f = aPLL.FLLBW/0.53;
%  aPLL.w0f2 = aPLL.w0f*aPLL.w0f;
%  aPLL.gain = 1.0;
%  aPLL.t = .001*(float)len;

%  /* Lock indicators */
%  aPLL.pll_lock += (dp - aPLL.pll_lock) * .1;
%  aPLL.pll_lock = dp;
%  aPLL.fll_lock += (cross/P_avg - aPLL.fll_lock) * .1;

%  /* 3rd order PLL wioth 2nd order FLL assist */
%  aPLL.w += aPLL.t * (aPLL.w0p3 * dp + aPLL.w0f2 * df);
%  aPLL.x += aPLL.t * (0.5*aPLL.w + aPLL.a2 * aPLL.w0f * df + aPLL.a3 * aPLL.w0p2 * dp);
%  aPLL.z  = 0.5*aPLL.x + aPLL.b3 * aPLL.w0p * dp;

%  //  carrier_nco = IF_FREQUENCY + aPLL.z;
%  carrier_nco = aPLL.z;

% http://cms.cttc.es/trac/gnss-sdr/browser/trunk/gnss-sdr_0_1/src/algorithms/tracking/gnuradio_blocks/gps_l1_ca_dll_pll_tracking_cc.cc

Wn = lbw * 8 * dzeta / (4 * dzeta*dzeta + 1)

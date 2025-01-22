clear all;
close all;

% insert the the MNPBEM directory if you havn't added
addpath(genpath('C:\Users\katsuya2\OneDrive - University of Illinois - Urbana\Documents\MATLAB\MNPBEM_GUI\MNPBEM17'))  

%% options for BEM simulation
op = bemoptions('sim', 'stat');

% set dielectric environment
epstab = {epsconst(1), epstable('gold_olmon.dat')};

% initialize nanosphere
radius = 14.5;
p = trisphere(722, 2*radius);

% set up COMPARTICLE object
p = comparticle(epstab, {p}, [2, 1], 1, op);

% set up BEM solver
bem = bemsolver(p, op);

% plane wave excitation
exc = planewave([1, 0, 0], [0, 0, 1], op);  % x-axis polarization

%% surface charge for plane wave excitation with wavelength of interest
% wavelength of interest
enei = 520;

sig = bem \ exc(p, enei);
%  plot surface charge SIG2 at particle outside
figure(1);
plot(p, sig.sig);
colormap('whitejet');  % need to install the colormap 
% clim([-0.1 0.1])
colorbar

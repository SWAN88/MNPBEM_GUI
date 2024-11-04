clear all;
close all;

% insert the the MNPBEM directory if you havn't added
addpath(genpath('C:\Users\katsuya2\OneDrive - University of Illinois - Urbana\Documents\MATLAB\MNPBEM_GUI\MNPBEM17'))  

%%  options for BEM simulation
op = bemoptions('sim', 'ret');

% set dielectric environment
epstab = {epsconst(1), epstable('gold_olmon.dat'), epstable('gold_olmon.dat')};

% initialize nanosphere dimer
radius = 14.5;
gap = 5;
p1 = shift(trisphere(722, 2*radius), [  radius + gap/2, 0, radius + gap]);
p2 = shift(trisphere(722, 2*radius), [- radius - gap/2, 0, radius + gap]);

% another way to describe
% p1 = trisphere(144, 2*a);
% p2 = shift(p1, [2*a, 0, 0]);

% set up COMPARTICLE object
p = comparticle(epstab, {p1, p2}, [2, 1; 3, 1], 1, 2, op);

% set up BEM solver
bem = bemsolver(p, op);

% plane wave excitation with polarization along with dimer axis
exc = planewave([1, 0, 0], [0, 0, 1], op);  % x-axis polarization

%% surface charge for plane wave excitation with wavelength of interest
% wavelength of interest
enei = 520;

sig = bem \ exc(p, enei);

%  plot surface charge SIG2 at particle outside
plot(p, sig.sig2);
colormap('whitejet');  % need to install the colormap 
clim([-0.1 0.1])
colorbar

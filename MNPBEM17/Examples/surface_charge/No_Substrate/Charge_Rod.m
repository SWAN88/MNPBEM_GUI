clear all;
close all;

% insert the the MNPBEM directory if you havn't added
addpath(genpath('C:\Users\katsuya2\OneDrive - University of Illinois - Urbana\Documents\MATLAB\MNPBEM_GUI\MNPBEM17'))  

%% options for BEM simulation
op = bemoptions('sim', 'ret');

% set dielectric environment
epstab = {epsconst(1), epstable('gold.dat')};

% initialize nanorod
length_rod = 60;
width_rod = 20;

p = trirod(width_rod, length_rod, [20, 10, length_rod / 2]);

% set up COMPARTICLE object
p = comparticle(epstab, {p}, [2, 1], 1, op);

% set up BEM solver
bem = bemsolver(p, op);

% plane wave excitation
% exc = planewave([0, 0, 1], [1, 0, 0], op);  % y-axis polarization
exc = planewave([1, 0, 0], [0, 0, 1], op);  % x-axis polarization

%% surface charge for plane wave excitation with wavelength of 500 nm
sig = bem \ exc(p, 500);
%  plot surface charge SIG2 at particle outside
figure(1);
plot(p, sig.sig2);
colormap('whitejet');  % need to install the colormap 
clim([-0.1 0.1])
colorbar

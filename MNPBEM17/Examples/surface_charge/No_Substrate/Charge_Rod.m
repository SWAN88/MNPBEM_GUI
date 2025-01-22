clear all;
close all;

% insert the the MNPBEM directory if you havn't added
addpath(genpath('C:\Users\katsuya2\OneDrive - University of Illinois - Urbana\Documents\MATLAB\MNPBEM_GUI\MNPBEM17'))  

%% options for BEM simulation
op = bemoptions('sim', 'stat');

% set dielectric environment
epstab = {epsconst(1), epstable('gold_olmon.dat')};

% initialize nanorod
width_rod = 20;
length_rod = 60;
nphi = 3;
ntheta = 3;
nz = 3;

% p = trirod(width_rod, length_rod, [20, 10, length_rod / 2]);
p = trirod(width_rod, length_rod, [(width_rod+1)*(pi/nphi), (width_rod+1)/ntheta, (length_rod-width_rod+1)/nz], 'triangles');

% set up COMPARTICLE object
p = comparticle(epstab, {p}, [2, 1], 1, op);
p = rot(p, 90, [0, 1, 0]);

% set up BEM solver
bem = bemsolver(p, op);

% plane wave excitation
exc = planewave([1, 0, 0], [0, 0, 1], op);  % x-axis polarization

%% surface charge for plane wave excitation with wavelength of interest
% wavelength of interest
enei = 600;

sig = bem \ exc(p, enei);
%  plot surface charge SIG2 at particle outside
figure(1);
plot(p, sig.sig);
colormap('whitejet');  % need to install the colormap 
% clim([-0.1 0.1])
colorbar

clear all;
close all;

% insert the the MNPBEM directory if you havn't added
addpath(genpath('C:\Users\katsuya2\OneDrive - University of Illinois - Urbana\Documents\MATLAB\MNPBEM_GUI\MNPBEM17'))  

%% options for BEM simulation
op = bemoptions('sim', 'stat', 'interp', 'curv');

% set dielectric environment
epstab = {epsconst(1.0), epstable('gold_olmon.dat'), epsconst(1.42^2)};

% initialize nanorod
% initialize nanorod
width_rod = 20;
length_rod = 60;
nphi = 3;
ntheta = 3;
nz = 3;
core = trirod(width_rod, length_rod, [(width_rod+1)*(pi/nphi), (width_rod+1)/ntheta, (length_rod-width_rod+1)/nz], 'triangles');

% initialize shell
shellthickness = 3.5;
shell = trirod(width_rod+shellthickness*2, length_rod+shellthickness*2, [20, 10, length_rod / 2], 'triangles');
% array of dielectrics with first row as [in,out] for core and second row as [in,out] for shell, eg. [1,2;2,3]
p = comparticle(epstab, {core, shell}, [2, 3; 3, 1], 1, 2, op); 
p = rot(p, 90, [0, 1, 0]);

% visualize object
figure(1)
plot(p, 'EdgeColor', 'b');

% set up BEM solver
bem = bemsolver(p, op);

% plane wave excitation
exc = planewave([1, 0, 0], [0, 0, 1], op);

%% surface charge for plane wave excitation with wavelength of 500 nm
% wavelength of interest
enei = 600;

sig = bem \ exc(p, enei);
%  plot surface charge SIG2 at particle outside
figure(2);
plot(p, sig.sig);
colormap('whitejet');  % need to install the colormap 
clim([-0.1 0.1])
colorbar
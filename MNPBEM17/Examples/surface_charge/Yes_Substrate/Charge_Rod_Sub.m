clear all;
close all;

% insert the the MNPBEM directory if you havn't added
addpath(genpath('C:\Users\katsuya2\OneDrive - University of Illinois - Urbana\Documents\MATLAB\MNPBEM_GUI\MNPBEM17'))  

% set dielectric environment
epstab = {epsconst(1.0), epstable('gold_olmon.dat'), epsconst(1.52^2)};

% location of interface of substrate
ztab = 0;

% default options for layer structure
op = layerstructure.options;

% set up layer structure
layer = layerstructure(epstab, [1, 3], ztab, op);

% options for BEM simulation
op = bemoptions('sim', 'stat', 'layer', layer);

% initialize nanorod
width_rod = 20;
length_rod = 60;
nphi = 3;
ntheta = 3;
nz = 3;

p = trirod(width_rod, length_rod, [(width_rod+1)*(pi/nphi), (width_rod+1)/ntheta, (length_rod-width_rod+1)/nz], 'triangles');

% set up COMPARTICLE object
p = comparticle(epstab, {p}, [2, 1], 1, op);
p = rot(p, 90, [0, 1, 0]);

%  shift nanosphere 1 nm above layer
p = shift(p, [0, 0, - min(p.pos(:, 3)) + 1 + ztab]); 

% set up BEM solver
bem = bemsolver(p, op);

% plane wave excitation
exc = planewave([1, 0, 0], [0, 0, 1], op);  % x-axis polarization
enei = 400:10:1000;

%% tabulated Green functions
if ~exist('greentab', 'var') || ~greentab.ismember(layer, enei, p)
  % automatic grid for tabulation
  tab = tabspace(layer, p);
  % Green function table
  greentab = compgreentablayer(layer, tab);
  % precompute Green function table
  greentab = set(greentab, enei, op);
end
op.greentab = greentab;

%% surface charge for plane wave excitation with wavelength of interest
% wavelength of interest
enei = 600;
sig = bem \ exc(p, enei);
%  plot surface charge SIG at particle outside
figure(1);
plot(p, sig.sig);
colormap('whitejet');  % need to install the colormap 
% clim([-0.1 0.1])
colorbar

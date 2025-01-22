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

% initialize nanosphere dimer
radius = 14.5;
gap = 5;
p1 = shift(trisphere(722, 2*radius), [  radius + gap/2, 0, radius + gap]);
p2 = shift(trisphere(722, 2*radius), [- radius - gap/2, 0, radius + gap]);

% set up COMPARTICLE object
p = comparticle(epstab, {p1, p2}, [2, 1; 2, 1], 1, 2, op);

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
enei = 520;
sig = bem \ exc(p, enei);
%  plot surface charge SIG at particle outside
figure(1);
plot(p, sig.sig);
colormap('whitejet');  % need to install the colormap 
% clim([-0.1 0.1])
colorbar

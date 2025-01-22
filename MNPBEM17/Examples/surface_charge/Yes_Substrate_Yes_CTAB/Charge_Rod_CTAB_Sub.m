clear all;
close all;

% insert the the MNPBEM directory if you havn't added
addpath(genpath('C:\Users\katsuya2\OneDrive - University of Illinois - Urbana\Documents\MATLAB\MNPBEM_GUI\MNPBEM17'))  

%% options for BEM simulation
enei=400:10:1000;

% set dielectric environment
epstab = {epsconst(1^2), epstable('gold_olmon.dat'), epsconst(1.52^2), epsconst(1.33^2), epsconst(1.44^2)};

ztab = 0;
op = layerstructure.options;
layer = layerstructure(epstab, [1, 3], ztab, op);
op = bemoptions('sim', 'stat', 'interp', 'curv', 'waitbar', 0, 'layer', layer);

% initialize nanorod
width_rod = 20;
length_rod = 60;
nphi = 3;
ntheta = 3;
nz = 3;
core = trirod(width_rod, length_rod, [(width_rod+1)*(pi/nphi), (width_rod+1)/ntheta, (length_rod-width_rod+1)/nz], 'triangles');

% initialize shell
shellthickness = 3.5;
shell = trirod(width_rod+shellthickness*2, length_rod+shellthickness*2, [(width_rod+1)*(pi/nphi), (width_rod+1)/ntheta, (length_rod-width_rod+1)/nz], 'triangles');
% array of dielectrics with first row as [in,out] for core and second row as [in,out] for shell, eg. [1,2;2,3]
p = comparticle(epstab, {core, shell}, [2, 5; 5, 1], 1, 2, op); 
p = rot(p, 90, [0, 1, 0]);
p = shift(p, [0, 0, -min(p.pos(:, 3)) + 1]);

% visualize object
figure(1)
plot(p, 'EdgeColor', 'b');

if ~exist( 'greentab', 'var' ) || ~greentab.ismember( layer, enei, p )
  %  automatic grid for tabulation
  %    we use a rather small number NZ for tabulation to speed up the
  %    simulations
  tab = tabspace( layer, p, 'nz', 5 );
  %  Green function table
  greentab = compgreentablayer( layer, tab );
  %  precompute Green function table
  greentab = set( greentab, enei, op, 'waitbar', 0 );
end
op.greentab = greentab;

% plane wave excitation
exc = planewave([1, 0, 0], [0, 0, 1], op);

% set up BEM solver
bem = bemsolver(p, op);

%% surface charge for plane wave excitation with wavelength of interest
% wavelength of interest
enei = 600;
sig = bem \ exc(p, enei);
%  plot surface charge SIG at particle outside
figure(2);
plot(p, sig.sig);
colormap('whitejet');  % need to install the colormap 
% clim([-0.1 0.1])
colorbar


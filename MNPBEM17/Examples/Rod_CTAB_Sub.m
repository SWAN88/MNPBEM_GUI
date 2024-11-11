clear all;
close all;

% insert the the MNPBEM directory if you havn't added
addpath(genpath('C:\Users\katsuya2\OneDrive - University of Illinois - Urbana\Documents\MATLAB\MNPBEM_GUI\MNPBEM17'))  

%% dielectric properties
epstab = {epsconst(1^2), epstable('gold_olmon.dat'), epsconst(1.52^2), epsconst(1.33^2), epsconst(1.44^2)};

%% initialization for BEM options and layer
ztab = 0;
op = layerstructure.options;
layer = layerstructure(epstab, [1, 3], ztab, op);
op = bemoptions('sim', 'stat', 'interp', 'curv', 'waitbar', 0, 'layer', layer);

%% simulation parameters
% plane wave excitation
exc = planewave([1, 0, 0], [0, 0, 1], op);
enei = 400:1:1000;

%% nanoparticle geometry
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
p = comparticle(epstab, {core, shell}, [2, 5; 5, 1], 1, 2, op); 
p = rot(p, 90, [0, 1, 0]);
p = shift(p, [0, 0, -min(p.pos(:, 3)) + 1]);

% initialize layer structure
if ~exist( 'greentab', 'var' ) || ~greentab.ismember( layer, enei, p )
  %  automatic grid for tabulation
  tab = tabspace( layer, p, 'nz', 5 );
  %  Green function table
  greentab = compgreentablayer( layer, tab );
  %  precompute Green function table
  greentab = set( greentab, enei, op, 'waitbar', 0 );
end
op.greentab = greentab;

% visualize object
figure(1)
plot(p, 'EdgeColor', 'b');

%% initialization for BEM solver
bem = bemsolver(p, op);

%%  far-field simulaiton
sca = zeros(length(enei), 2);
ext = zeros(length(enei), 2);
multiWaitbar('BEM solver', 0, 'Color', 'g', 'CanCancel', 'on');
% loop over wavelengths
for ien = 1 : length(enei)
  % surface charge
  sig = bem \ exc(p, enei(ien));
  % scattering and extinction cross sections
  sca(ien, :) = exc.sca(sig);
  ext(ien, :) = exc.ext(sig);
  multiWaitbar('BEM solver', ien / numel(enei));
end
multiWaitbar('CloseAll');

fig1 = figure('visible','on');
abs = ext - sca;
plot(enei, sum(abs, 2), '-','LineWidth', 1);  
xlabel('Wavelength (nm)', 'FontSize', 20);
ylabel('Absorption cross section (nm^2)', 'FontSize', 20);

fig2 = figure('visible','on');
plot(enei, sum(sca, 2), '-', 'LineWidth', 1);  
xlabel('Wavelength (nm)', 'FontSize', 20);
ylabel('Scattering cross section (nm^2)', 'FontSize', 20);
%% near-field simulation
% wavelength of interest
enei = 600;

% surface charge
sig = bem \ exc(p, enei);
% scattering and extinction cross sections
sca(1, :) = exc.sca(sig);
ext(1, :) = exc.ext(sig);

[x, y] = meshgrid(linspace(-70, 70, 284), linspace(-35, 35, 142));

% particle boundary at z = 10 nm
emesh = meshfield(p, x, y, 10, op, 'mindist', 0.15, 'nmax', 2000);
% induced and incoming electric field
e = emesh(sig) + emesh(exc.field(emesh.pt, enei));
% norm of electric field
ee = sqrt(dot(e, e, 3));

% plot electric field
figure(2)
imagesc(x(:), y(:), ee);
% clim([1 15]);

colormap('whitejet');  % need to install the colormap
colorbar;

xlabel('x (nm)');
ylabel('y (nm)');

set(gca,'YDir','norm');
axis equal tight
%% surface charge simulation
% plot surface charge SIG at particle outside
figure(3);
plot(p, sig.sig);
colormap('whitejet');
clim([-0.1 0.1])
colorbar
clear all;
close all;

% insert the the MNPBEM directory if you havn't added
addpath(genpath('C:\Users\katsuya2\OneDrive - University of Illinois - Urbana\Documents\MATLAB\MNPBEM_GUI\MNPBEM17'))  

%% options for BEM simulation
op = bemoptions('sim', 'ret', 'interp', 'curv');

% set dielectric environment
epstab = {epsconst(1.0), epstable('gold.dat')};

% initialize nanorod
length_rod = 60;
width_rod = 20;
p = trirod(width_rod, length_rod, [20, 10, length_rod / 2]);

% set up COMPARTICLE object
p = comparticle(epstab, {p}, [2, 1], 1, op);

% % visualize object
% figure(1)
% plot(p, 'EdgeColor', 'b');

% set up BEM solver
bem = bemsolver(p, op);

% plane wave excitation with x-axis polarization and z-axis propagation
exc = planewave([1, 0, 0], [0, 0, 1], op);

% wavelength of interest
enei = 600;

% surface charge
sig = bem \ exc(p, enei);
% scattering and extinction cross sections
sca(1, :) = exc.sca(sig);
ext(1, :) = exc.ext(sig);

% [x, y] = meshgrid(linspace(-90, 90, 181), linspace(-35, 35, 71));
[x, z] = meshgrid(linspace(-35, 35, 71), linspace(-60, 60, 121));

% particle boundary
% emesh = meshfield(p, x, y, 0, op, 'mindist', 0.15, 'nmax', 2000);
emesh = meshfield(p, x, 0, z, op, 'mindist', 0.15, 'nmax', 2000);
% induced and incoming electric field
e = emesh(sig) + emesh(exc.field(emesh.pt, enei));
% norm of electric field
ee = sqrt(dot(e, e, 3));

%% final plots
figure(2)
imagesc(x(:), z(:), ee);
% clim([1 25]);

colormap('whitejet');  % need to install the colormap
colorbar;

xlabel('x (nm)');
ylabel('z (nm)');

set(gca,'YDir','norm');
axis equal tight

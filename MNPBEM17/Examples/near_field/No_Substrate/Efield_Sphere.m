clear all;
close all;

% insert the the MNPBEM directory if you havn't added
addpath(genpath('C:\Users\katsuya2\OneDrive - University of Illinois - Urbana\Documents\MATLAB\MNPBEM_GUI\MNPBEM17'))  

%% options for BEM simulation
op = bemoptions('sim', 'stat', 'interp', 'curv');

% set dielectric environment
epstab = {epsconst(1.0), epstable('gold.dat')};

% initialize nanosphere
radius = 14.5;
p = trisphere(722, 2*radius);

% set up COMPARTICLE object
p = comparticle(epstab, {p}, [2, 1], 1, op);

% visualize object
% figure(1)
% plot(p, 'EdgeColor', 'b');

% set up BEM solver
bem = bemsolver(p, op);

% plane wave excitation with x-axis polarization and z-axis propagation
exc = planewave([1, 0, 0], [0, 0, 1], op);

% wavelength of interest
enei = 520;

% surface charge
sig = bem \ exc(p, enei);
% scattering and extinction cross sections
sca(1, :) = exc.sca(sig);
ext(1, :) = exc.ext(sig);

[x, y] = meshgrid(linspace(-40, 40, 181), linspace(-40, 40, 181));

% particle boundary
emesh = meshfield(p, x, y, 0, op, 'mindist', 0.15, 'nmax', 2000);
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

%% save the data
% Specify the folder path where you want to save the file
folder_path = 'C:\Users\katsuya2\OneDrive - University of Illinois - Urbana\Documents\MATLAB\MNPBEM_GUI\MNPBEM17\Examples\near_field\No_Substrate';

% Create the file name with variable
file_name = ['sphere_efield_at_' num2str(enei) '.mat'];

% Combine the folder path with the file name
file_path = fullfile(folder_path, file_name);

% Save the data
save(file_path, 'x', 'y', 'ee');

clear all;
close all;

% insert the the MNPBEM directory if you havn't added
addpath(genpath('C:\Users\katsuya2\OneDrive - University of Illinois - Urbana\Documents\MATLAB\MNPBEM_GUI\MNPBEM17'))  

%% options for BEM simulation
op = bemoptions('sim', 'ret', 'interp', 'curv');

% set dielectric environment
epstab = {epsconst(1.0), epstable('gold.dat'), epsconst(1.42^2)};

% initialize nanorod
length_rod = 60;
width_rod = 20;
core = trirod(width_rod, length_rod, [20, 10, length_rod / 2]);

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

% wavelength of interest
enei = 600;

% surface charge
sig = bem \ exc(p, enei);
% scattering and extinction cross sections
sca(1, :) = exc.sca(sig);
ext(1, :) = exc.ext(sig);

[x, y] = meshgrid(linspace(-90, 90, 181), linspace(-35, 35, 71));

% particle boundary
emesh = meshfield(p, x, y, 0, op, 'mindist', 0.15, 'nmax', 2000);
% induced and incoming electric field
e = emesh(sig) + emesh(exc.field(emesh.pt, enei));
% norm of electric field
ee = sqrt(dot(e, e, 3));

%% final plots
figure(2)
imagesc(x(:), y(:), ee);
% clim([1 25]);

colormap('whitejet');  % need to install the colormap
colorbar;

xlabel('x (nm)');
ylabel('y (nm)');

set(gca,'YDir','norm');
axis equal tight

%% save data
particle_name = ['length_' num2str(length_rod) '_width_' num2str(width_rod)];

filepath = "C:\Users\katsuya2\OneDrive - University of Illinois - Urbana\Documents\MATLAB\MNPBEM_GUI\MNPBEM17\Examples\near_field\No_Substrate_Yes_CTAB";

efield_file = [x, y];

% Define file paths with the desired directory and filenames
efield_filepath = fullfile(filepath, [particle_name '_efield.txt']);

% Save data
save(efield_filepath, 'efield_file', '-ascii');




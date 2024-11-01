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
enei = 400:1:1000;

%%  allocate scattering and extinction cross sections
sca = zeros(length(enei), 2);
ext = zeros(length(enei), 2);
ienrand = randperm(length(enei));
multiWaitbar('BEM solver', 0, 'Color', 'g', 'CanCancel', 'on');
%  loop over wavelengths
for ien = 1 : length(enei)
  % surface charge
  sig = bem \ exc(p, enei(ienrand(ien)));
  % scattering and extinction cross sections
  sca(ienrand(ien), :) = exc.sca(sig);
  ext(ienrand(ien), :) = exc.ext(sig);
  multiWaitbar('BEM solver', ien / numel(enei));
end
multiWaitbar('CloseAll');

%% final plots
fig1 = figure('visible','on');
abs = ext - sca;
plot(enei, sum(abs, 2), '-','LineWidth', 1);  
% ylim([0  3000]);
xlabel('Wavelength (nm)', 'FontSize', 20);
ylabel('Absorption cross section (nm^2)', 'FontSize', 20);

fig2 = figure('visible','on');
plot(enei, sum(sca, 2), '-', 'LineWidth', 1);  
% ylim([0  3000]);
xlabel('Wavelength (nm)', 'FontSize', 20);
ylabel('Scattering cross section (nm^2)', 'FontSize', 20);

%% save data
particle_name = ['length_' num2str(length_rod) '_width_' num2str(width_rod)];
filepath = "C:\Users\katsuya2\OneDrive - University of Illinois - Urbana\Documents\MATLAB\MNPBEM_GUI\MNPBEM17\Examples\far_field\No_Substrate_Yes_CTAB";

abs_file = [enei', abs, sum(abs, 2)];
sca_file = [enei', sca, sum(sca, 2)];

% Define file paths with the desired directory and filenames
abs_filepath = fullfile(filepath, [particle_name '_abs.txt']);
sca_filepath = fullfile(filepath, [particle_name '_sca.txt']);

% Save data
save(abs_filepath, 'abs_file', '-ascii');
save(sca_filepath, 'sca_file', '-ascii');




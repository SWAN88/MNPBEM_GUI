clear all;
close all;

% insert the the MNPBEM directory if you havn't added
addpath(genpath('C:\Users\katsuya2\OneDrive - University of Illinois - Urbana\Documents\MATLAB\MNPBEM_GUI\MNPBEM17'))  

%% options for BEM simulation

% set dielectric environment
epstab = {epsconst(1), epstable('gold.dat'), epsconst(1.52^2), epsconst(1.44^2)};

ztab = 0;
op = layerstructure.options;
layer = layerstructure(epstab, [1, 3], ztab, op);
op = bemoptions('sim', 'ret', 'interp', 'curv', 'waitbar', 0, 'layer', layer);

% initialize nanorod
length_rod = 60;
width_rod = 20;
core = trirod(width_rod, length_rod, [20, 10, length_rod / 2]);

% initialize shell
shellthickness = 3.5;
shell = trirod(width_rod+shellthickness*2, length_rod+shellthickness*2, [20, 10, length_rod / 2], 'triangles');
% array of dielectrics with first row as [in,out] for core and second row as [in,out] for shell, eg. [1,2;2,3]
p = comparticle(epstab, {core, shell}, [2, 4; 4, 1], 1, 2, op); 
p = rot(p, 90, [0, 1, 0]);

% visualize object
figure(1)
plot(p, 'EdgeColor', 'b');

enei = 400:10:1000;

% 
if ~exist('greentab', 'var') || ~greentab.ismember(layer, enei, p)
  tab = tabspace(layer, p, 'nz', 5);
  % Green function table
  greentab = compgreentablayer(layer, tab);
  % precompute Green function table
  greentab = set(greentab, enei, op, 'waitbar', 0);
end
op.greentab = greentab;

% set up BEM solver
bem = bemsolver(p, op);

% plane wave excitation
exc = planewave([1, 0, 0], [0, 0, 1], op);

%%  allocate scattering and extinction cross sections
sca = zeros(length(enei), 2);
ext = zeros(length(enei), 2);
multiWaitbar('BEM solver', 0, 'Color', 'g', 'CanCancel', 'on');
%  loop over wavelengths
for ien = 1 : length(enei)
  % surface charge
  sig = bem \ exc(p, enei(ien));
  % scattering and extinction cross sections
  sca(ien, :) = exc.sca(sig);
  ext(ien, :) = exc.ext(sig);
  multiWaitbar('BEM solver', ien / numel(enei));
end
multiWaitbar('CloseAll');

%% final plots
particle_name = ['length_' num2str(length_rod) '_width_' num2str(width_rod)];

fig1 = figure('visible','on');
abs = ext - sca;
plot(enei, sum(abs, 2), '-','LineWidth', 1);  
xlabel('Wavelength (nm)', 'FontSize', 20);
ylabel('Absorption cross section (nm^2)', 'FontSize', 20);

fig2 = figure('visible','on');
plot(enei, sum(sca, 2), '-', 'LineWidth', 1);  
xlabel('Wavelength (nm)', 'FontSize', 20);
ylabel('Scattering cross section (nm^2)', 'FontSize', 20);

% %% save data
% filepath = "C:\Users\katsuya2\OneDrive - University of Illinois - Urbana\Documents\MATLAB\MNPBEM_GUI\MNPBEM17\Examples\far_field\Yes_Substrate_Yes_CTAB";
% 
% abs_file = [enei', abs, sum(abs, 2)];
% sca_file = [enei', sca, sum(sca, 2)];
% 
% % Define file paths with the desired directory and filenames
% abs_filepath = fullfile(filepath, [particle_name '_abs.txt']);
% sca_filepath = fullfile(filepath, [particle_name '_sca.txt']);
% 
% % Save data
% save(abs_filepath, 'abs_file', '-ascii');
% save(sca_filepath, 'sca_file', '-ascii');


clear all;
close all;

% insert the the MNPBEM directory if you havn't added
addpath(genpath('C:\Users\katsuya2\OneDrive - University of Illinois - Urbana\Documents\MATLAB\MNPBEM_GUI\MNPBEM17'))  

%% initialization

% set dielectric environment
epstab = {epsconst(1.0), epstable('gold_olmon.dat'), epsconst(1.52^2)};

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

p = comparticle(epstab, {core}, [2, 1], 1, op); 
p = rot(p, 90, [0, 1, 0]);
p = shift(p, [0, 0, -min(p.pos(:, 3)) + 1]);

% visualize object
figure(1)
plot(p, 'EdgeColor', 'b');

% plane wave excitation
exc = planewave([1, 0, 0], [0, 0, 1], op);
enei = 400:1:1000;

%% tabulated Green functions
if ~exist('greentab', 'var') || ~greentab.ismember(layer, enei, p)
  % automatic grid for tabulation
  tab = tabspace(layer, p);
  % Green function table
  greentab = compgreentablayer(layer, tab);
  % precompute Green function table
  greentab = set(greentab, linspace(400, 1000, 1), op);
end
op.greentab = greentab;

%%  allocate scattering and extinction cross sections
% set up BEM solver
bem = bemsolver(p, op);

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
fig1 = figure('visible','on');
abs = ext - sca;
plot(enei, sum(abs, 2), '-','LineWidth', 1);  
xlabel('Wavelength (nm)', 'FontSize', 20);
ylabel('Absorption cross section (nm^2)', 'FontSize', 20);

fig2 = figure('visible','on');
plot(enei, sum(sca, 2), '-', 'LineWidth', 1);  
xlabel('Wavelength (nm)', 'FontSize', 20);
ylabel('Scattering cross section (nm^2)', 'FontSize', 20);

%% save data
particle_name = ['length_' num2str(length_rod) '_width_' num2str(width_rod)];
filepath = "C:\Users\katsuya2\OneDrive - University of Illinois - Urbana\Documents\MATLAB\MNPBEM_GUI\MNPBEM17\Examples\far_field\Yes_Substrate";

spec_file = [enei', sum(sca, 2)*1e-18, sum(abs, 2)*1e-18];

% Define file paths with the desired directory and filenames
spec_filepath = fullfile(filepath, [particle_name '_spec_sub.csv']);

% Open the file for writing
fid = fopen(spec_filepath, 'w');

% Write the header
fprintf(fid, 'wav,scat,abs');

% Close and save data
fclose(fid);

% Save data as a CSV file
writematrix(spec_file, spec_filepath, 'WriteMode', 'append');









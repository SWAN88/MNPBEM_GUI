clear all;
close all;

% insert the the MNPBEM directory if you havn't added
addpath(genpath('C:\Users\katsuya2\OneDrive - University of Illinois - Urbana\Documents\MATLAB\MNPBEM_GUI\MNPBEM17'))  

%% initialization

% set dielectric environment
epstab = {epsconst(1.0), epstable('gold_olmon.dat'), epsconst(1.52^2)};

% location of interface of substrate
ztab = 0;

% default options for layer structure
op = layerstructure.options;

% set up layer structure
layer = layerstructure(epstab, [1, 3], ztab, op);

% options for BEM simulation
op = bemoptions('sim', 'stat', 'interp', 'curv', 'layer', layer);

% initialize nanosphere dimer
radius = 14.5;
gap = 5;
p1 = shift(trisphere(722, 2*radius), [  radius + gap/2, 0, radius + gap]);
p2 = shift(trisphere(722, 2*radius), [- radius - gap/2, 0, radius + gap]);

% set up COMPARTICLE object
p = comparticle(epstab, {p1, p2}, [2, 1; 3, 1], 1, 2, op);

%  shift nanosphere 1 nm above layer
p = shift(p, [0, 0, - min(p.pos(:, 3)) + 1 + ztab]); 

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
particle_name = ['radius_' num2str(radius) '_gap_' num2str(gap)];

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









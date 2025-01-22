clear all;
close all;

% insert the the MNPBEM directory if you havn't added
addpath(genpath('C:\Users\katsuya2\OneDrive - University of Illinois - Urbana\Documents\MATLAB\MNPBEM_GUI\MNPBEM17'))  

%% options for BEM simulation
op = bemoptions('sim', 'stat', 'interp', 'curv');

% set dielectric environment
epstab = {epsconst(1.0), epstable('gold_olmon.dat')};

% initialize nanosphere
radius = 14.5;
p = trisphere(144, 2*radius);

% set up COMPARTICLE object
p = comparticle(epstab, {p}, [2, 1], 1, op);

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
particle_name = ['radius_' num2str(radius)];

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
filepath = "C:\Users\katsuya2\OneDrive - University of Illinois - Urbana\Documents\MATLAB\MNPBEM_GUI\MNPBEM17\Examples\far_field\No_Substrate";

spec_file = [enei', sum(sca, 2)*1e-18, sum(abs, 2)*1e-18];

% Define file paths with the desired directory and filenames
spec_filepath = fullfile(filepath, [particle_name '_spec.csv']);

% Open the file for writing
fid = fopen(spec_filepath, 'w');

% Write the header
fprintf(fid, 'wav,scat,abs');

% Close and save data
fclose(fid);

% Save data as a CSV file
writematrix(spec_file, spec_filepath, 'WriteMode', 'append');








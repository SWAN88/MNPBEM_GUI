clear all;
close all;

% insert the the MNPBEM directory if you havn't added
addpath(genpath('C:\Users\katsuya2\OneDrive - University of Illinois - Urbana\Documents\MATLAB\MNPBEM_GUI\MNPBEM17'))  

%% options for BEM simulation
op = bemoptions('sim', 'ret', 'interp', 'curv');

% set dielectric environment
epstab = {epsconst(1.0), epstable('gold_olmon.dat')};

% initialize nanorod
width_rod = 20;
length_rod = 60;
nphi = 2;
ntheta = 2;
nz = 2;

% p = trirod(width_rod, length_rod, [20, 10, length_rod / 2]);
p = trirod(width_rod, length_rod, [(width_rod+1)*(pi/nphi), (width_rod+1)/ntheta, (length_rod-width_rod+1)/nz], 'triangles');

% set up COMPARTICLE object
p = comparticle(epstab, {p}, [2, 1], 1, op);
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

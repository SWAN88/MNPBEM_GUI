clear all;
close all;

% insert the the MNPBEM directory if you havn't added
addpath(genpath('C:\Users\katsuya2\OneDrive - University of Illinois - Urbana\Documents\MATLAB\MNPBEM_GUI\MNPBEM17'))  

%% options for BEM simulation
op = bemoptions('sim', 'ret', 'interp', 'curv');

% set dielectric environment
epstab = {epsconst(1.0), epstable('gold.dat')};

% initialize nanosphere
radius = 14.5;
p = trisphere(361, 2*radius);

% set up COMPARTICLE object
p = comparticle(epstab, {p}, [2, 1], 1, op);

% visualize object
figure(1)
plot(p, 'EdgeColor', 'b');

% set up BEM solver
bem = bemsolver(p, op);

% plane wave excitation
exc = planewave([1, 0, 0; 0, 0, 1], [0, 0, 1; 0, 1, 0], op);
enei = 400:10:1000;

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
% ylim([0  3000]);
xlabel('Wavelength (nm)', 'FontSize', 20);
ylabel('Absorption cross section (nm^2)', 'FontSize', 20);
% saveas(fig1, [particle_name '_abs'], 'png');

fig2 = figure('visible','on');
plot(enei, sum(sca, 2), '-', 'LineWidth', 1);  
% ylim([0  3000]);
xlabel('Wavelength (nm)', 'FontSize', 20);
ylabel('Scattering cross section (nm^2)', 'FontSize', 20);
% saveas(fig2, [particle_name '_scat'], 'png');

%% save data
% abs_file = [enei', abs, sum(abs, 2)];
% sca_file = [enei', sca, sum(sca, 2)];
% save ([particle_name '_abs.txt'], 'abs_file', '-ascii');
% save ([particle_name '_sca.txt'], 'sca_file', '-ascii');









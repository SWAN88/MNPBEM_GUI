rodwidth = 20;
rodlength = 60;
nphi = 3;
ntheta = 3;
nz = 3;

enei = 400:10:1000;

epstab = {epsconst(1), epstable('gold_olmon.dat'), epsconst(1.52^2), epsconst(1.33^2), epsconst(1.44^2)};
ztab = 0;
op = layerstructure.options;
layer = layerstructure(epstab, [1, 3], ztab, op);

op = bemoptions('sim', 'ret', 'interp', 'curv', 'waitbar', 0, 'layer', layer);

core = trirod(rodwidth, rodlength,[(rodwidth+1)*(pi/nphi), (rodwidth+1)/ntheta, (rodlength-rodwidth+1)/nz], 'triangles');

% initialize shell
shellthickness = 3.5;
shell = trirod(rodwidth+shellthickness*2, rodlength+shellthickness*2, [(rodwidth+1)*(pi/nphi), (rodwidth+1)/ntheta, (rodlength-rodwidth+1)/nz], 'triangles');
% array of dielectrics with first row as [in,out] for core and second row as [in,out] for shell, eg. [1,2;2,3]
p = comparticle(epstab, {core, shell}, [2, 5; 5, 1], 1, 2, op); 
p = rot(p, 90, [0, 1, 0]);
p = shift(p, [0, 0, -min(p.pos(:, 3)) + 1]);

% visualize object
figure(1)
plot(p, 'EdgeColor', 'b');

% 
if ~exist('greentab', 'var') || ~greentab.ismember(layer, enei, p)
  tab = tabspace(layer, p, 'nz', 5);
  % Green function table
  greentab = compgreentablayer(layer, tab);
  % precompute Green function table
  greentab = set(greentab, enei, op, 'waitbar', 0);
end
op.greentab = greentab;

%% set up BEM solver
bem = bemsolver(p, op);

exc = planewave([1, 0, 0], [0, 0, 1], op);
sca = zeros(length(enei), 2);
ext = zeros(length(enei), 2);

multiWaitbar('BEM solver', 0, 'Color', 'g', 'CanCancel', 'on');
%  loop over wavelengths
figure(1)
for ien = 1 : length(enei)
%  surface charge
  sig = bem \ exc(p, enei(ien));
  %  scattering and extinction cross sections
  sca(ien, :) = exc.sca(sig);
  abs(ien, :) = exc.abs(sig);
  multiWaitbar('BEM solver', ien / numel(enei));
end
multiWaitbar('CloseAll');


%% final plot
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
filepath = "C:\Users\katsuya2\OneDrive - University of Illinois - Urbana\Documents\MATLAB\MNPBEM_GUI\MNPBEM17\Examples\far_field\Yes_Substrate_Yes_CTAB";

spec_file = [enei', sum(sca, 2)*1e-18, sum(abs, 2)*1e-18];

% Define file paths with the desired directory and filenames
spec_filepath = fullfile(filepath, [particle_name 'ctab_sub_spec.csv']);

% Open the file for writing
fid = fopen(spec_filepath, 'w');

% Write the header
fprintf(fid, 'wav,scat,abs');

% Close and save data
fclose(fid);

% Save data as a CSV file
writematrix(spec_file, spec_filepath, 'WriteMode', 'append');
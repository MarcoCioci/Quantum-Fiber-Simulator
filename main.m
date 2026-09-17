% MAIN  Run selected thesis experiments on Quantum Fiber Simulator.

clear;
clc;
close all;


% =========================
% Project path
% =========================

project_root = ...
    fileparts(mfilename('fullpath'));

addpath(project_root);
addpath(genpath(fullfile(project_root, 'src')));


% =========================
% Experiment selection
% =========================

actives = [3];


% =========================
% Plot and save options
% =========================

do_plot = true;
do_save = true;


% =========================
% Run experiments
% =========================

for experiment_id = actives

    switch experiment_id

        case 1

            results_experiment_1 = ...
                experiment_01_effective_models_bbm92( ...
                    do_plot, ...
                    do_save);

        case 2

            results_experiment_2 = ...
                experiment_02_single_arm_pmd_operating_region( ...
                    do_plot, ...
                    do_save);

        case 3

            results_experiment_3 = ...
                experiment_03_two_arm_pmd_spectral_operating_regions( ...
                    do_plot, ...
                    do_save);

        otherwise

            error( ...
                'main:UnknownExperiment', ...
                'Unknown thesis experiment identifier: %d.', ...
                experiment_id);
    end

end
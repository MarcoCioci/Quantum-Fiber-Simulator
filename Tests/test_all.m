% TEST_ALL  Run all tests in sequence

clc;

% Ensure all folders are in path
project_root = fileparts(fileparts(mfilename('fullpath'))); % All folders from Project Root `Quantum-Fiber-Simulator`
addpath(genpath(project_root));

disp('======================================');
disp('Running all tests...');
disp('======================================');

test_bell_state();
test_density_matrix();
test_partial_trace();
test_correlations();
test_bloch_vector();

disp('======================================');
disp('All tests passed successfully.');
disp('======================================');
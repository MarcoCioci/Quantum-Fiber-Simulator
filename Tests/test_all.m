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
test_arbitrary_axis_correlations();
test_chsh();
test_bloch_vector();
test_purity();
test_fidelity();
test_concurrence();
test_depolarizing_channel_two_qubits();


disp('======================================');
disp('All tests passed successfully.');
disp('======================================');
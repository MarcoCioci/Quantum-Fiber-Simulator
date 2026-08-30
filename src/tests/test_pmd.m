function test_pmd()
% TEST_PMD  Verify the segmented frequency-resolved PMD model.
%
% Objective:
%   Test the mathematical consistency of the PMD functions:
%
%       pmd_frequency_grid
%       pmd_segment_unitary
%       pmd_fiber_unitary
%       pmd_joint_spectral_weights
%       pmd_frequency_resolved_states
%       pmd_spectral_average_state
%
% Notes:
%   The tests cover unitary propagation, segment concatenation, spectral
%   normalization, state physicality, and the full PMD pipeline.

    % =========================
    % Test configuration
    % =========================

    tolerance = 1e-12;

    fprintf('Running test_pmd...\n');


    % =========================
    % Test pmd_frequency_grid
    % =========================

    num_points = 5;
    max_offset = 4e12;

    [omega_offsets, delta_omega] = pmd_frequency_grid( ...
        num_points, max_offset);

    expected_offsets = [-4e12; -2e12; 0; 2e12; 4e12];

    assert(isequal(size(omega_offsets), [num_points, 1]), ...
        'test_pmd:FrequencyGridSize', ...
        'The frequency grid must be a num_points-by-1 vector.');

    assert(norm(omega_offsets - expected_offsets) < tolerance, ...
        'test_pmd:FrequencyGridValues', ...
        'The frequency grid has incorrect values.');

    assert(abs(delta_omega - 2e12) < tolerance, ...
        'test_pmd:FrequencyGridSpacing', ...
        'The frequency-grid spacing is incorrect.');

    assert(any(abs(omega_offsets) < tolerance), ...
        'test_pmd:FrequencyGridCentralFrequency', ...
        'The frequency grid must contain omega_offset = 0.');


    % =========================
    % Test pmd_segment_unitary
    % =========================

    omega_offset = 3e12;
    phase = 0.4;
    dgd = 2e-12;
    axis_z = [0, 0, 1];

    U_segment = pmd_segment_unitary(omega_offset, phase, dgd, axis_z);

    alpha = phase + dgd * omega_offset;

    U_expected = [exp(-1i * alpha / 2), 0; ...
                  0, exp(1i * alpha / 2)];

    assert(norm(U_segment - U_expected, 'fro') < tolerance, ...
        'test_pmd:SegmentUnitaryZAxis', ...
        'The z-axis segment unitary is incorrect.');

    assert(is_unitary(U_segment), ...
        'test_pmd:SegmentUnitarity', ...
        'The PMD segment transformation must be unitary.');

    U_scaled_axis = pmd_segment_unitary( ...
        omega_offset, phase, dgd, 4 * axis_z);

    assert(norm(U_segment - U_scaled_axis, 'fro') < tolerance, ...
        'test_pmd:SegmentAxisNormalization', ...
        'The PMD segment must internally normalize its axis.');

    U_no_dgd_1 = pmd_segment_unitary(-5e12, phase, 0, axis_z);
    U_no_dgd_2 = pmd_segment_unitary(7e12, phase, 0, axis_z);

    assert(norm(U_no_dgd_1 - U_no_dgd_2, 'fro') < tolerance, ...
        'test_pmd:ZeroDGDLimit', ...
        'A segment with zero DGD must be frequency independent.');


    % =========================
    % Test pmd_fiber_unitary
    % =========================

    phase_1 = 0.2;
    dgd_1 = 1e-12;
    axis_1 = [1, 0, 0];

    U_single_segment = pmd_segment_unitary( ...
        omega_offset, phase_1, dgd_1, axis_1);

    U_single_fiber = pmd_fiber_unitary( ...
        omega_offset, phase_1, dgd_1, axis_1);

    assert(norm(U_single_fiber - U_single_segment, 'fro') < tolerance, ...
        'test_pmd:SingleSegmentFiber', ...
        'A one-segment fiber must coincide with its segment unitary.');

    phases = [0.2; -0.5];
    dgds = [1e-12; 2e-12];
    axes = [1, 0, 0; 0, 1, 0];

    U_1 = pmd_segment_unitary( ...
        omega_offset, phases(1), dgds(1), axes(1, :));

    U_2 = pmd_segment_unitary( ...
        omega_offset, phases(2), dgds(2), axes(2, :));

    U_fiber = pmd_fiber_unitary(omega_offset, phases, dgds, axes);

    assert(norm(U_fiber - U_2 * U_1, 'fro') < tolerance, ...
        'test_pmd:FiberConcatenationOrder', ...
        'The PMD fiber does not concatenate segments in propagation order.');

    assert(is_unitary(U_fiber), ...
        'test_pmd:FiberUnitarity', ...
        'The full PMD fiber transformation must be unitary.');


    % =========================
    % Test pmd_joint_spectral_weights
    % =========================

    omega_offsets_A = [-2e12; 0; 2e12];
    omega_offsets_B = [-3e12; -1e12; 1e12; 3e12];

    sigma_sum = 2e12;
    sigma_difference = 5e12;

    spectral_weights = pmd_joint_spectral_weights( ...
        omega_offsets_A, omega_offsets_B, sigma_sum, sigma_difference);

    assert(isequal(size(spectral_weights), [3, 4]), ...
        'test_pmd:SpectralWeightsSize', ...
        'The spectral-weight matrix has incorrect dimensions.');

    assert(isreal(spectral_weights), ...
        'test_pmd:SpectralWeightsReality', ...
        'Spectral weights must be real.');

    assert(all(spectral_weights >= 0, 'all'), ...
        'test_pmd:SpectralWeightsPositivity', ...
        'Spectral weights must be non-negative.');

    assert(abs(sum(spectral_weights, 'all') - 1) < tolerance, ...
        'test_pmd:SpectralWeightsNormalization', ...
        'Spectral weights must sum to one.');


    % =========================
    % Test pmd_frequency_resolved_states
    % =========================

    psi_input = bell_state('psi_plus');
    rho_input = state_to_density_matrix(psi_input);

    phases_A = 0;
    dgds_A = 0;
    axes_A = [0, 0, 1];

    phases_B = 0;
    dgds_B = 0;
    axes_B = [0, 0, 1];

    frequency_states = pmd_frequency_resolved_states( ...
        rho_input, omega_offsets_A, omega_offsets_B, ...
        phases_A, dgds_A, axes_A, ...
        phases_B, dgds_B, axes_B);

    assert(isequal(size(frequency_states), [4, 4, 3, 4]), ...
        'test_pmd:FrequencyResolvedStateSize', ...
        'The frequency-resolved state array has incorrect dimensions.');

    for k = 1:numel(omega_offsets_A)
        for l = 1:numel(omega_offsets_B)
            rho_k_l = frequency_states(:, :, k, l);

            assert(norm(rho_k_l - rho_input, 'fro') < tolerance, ...
                'test_pmd:ZeroPMDPropagation', ...
                'Zero phase and zero DGD must preserve the input state.');

            assert(abs(trace(rho_k_l) - 1) < tolerance, ...
                'test_pmd:FrequencyResolvedTrace', ...
                'Each frequency-resolved state must have unit trace.');

            assert(norm(rho_k_l - rho_k_l', 'fro') < tolerance, ...
                'test_pmd:FrequencyResolvedHermiticity', ...
                'Each frequency-resolved state must be Hermitian.');
        end
    end


    % =========================
    % Test pmd_spectral_average_state
    % =========================

    rho_average = pmd_spectral_average_state( ...
        frequency_states, spectral_weights);

    assert(norm(rho_average - rho_input, 'fro') < tolerance, ...
        'test_pmd:ZeroPMDSpectralAverage', ...
        'Spectral averaging must preserve the state in the zero-PMD limit.');

    assert(abs(trace(rho_average) - 1) < tolerance, ...
        'test_pmd:SpectralAverageTrace', ...
        'The spectrally averaged state must have unit trace.');

    assert(norm(rho_average - rho_average', 'fro') < tolerance, ...
        'test_pmd:SpectralAverageHermiticity', ...
        'The spectrally averaged state must be Hermitian.');

    eigenvalues = eig(rho_average);

    assert(all(real(eigenvalues) >= -tolerance), ...
        'test_pmd:SpectralAveragePositivity', ...
        'The spectrally averaged state must be positive semidefinite.');


    % =========================
    % Test complete PMD pipeline
    % =========================

    phases_A = 0.3;
    dgds_A = 1e-12;
    axes_A = [1, 0, 0];

    phases_B = -0.6;
    dgds_B = 2e-12;
    axes_B = [0, 1, 0];

    frequency_states = pmd_frequency_resolved_states( ...
        rho_input, omega_offsets_A, omega_offsets_B, ...
        phases_A, dgds_A, axes_A, ...
        phases_B, dgds_B, axes_B);

    rho_average = pmd_spectral_average_state( ...
        frequency_states, spectral_weights);

    assert(abs(trace(rho_average) - 1) < tolerance, ...
        'test_pmd:CompletePipelineTrace', ...
        'The complete PMD pipeline must preserve unit trace.');

    assert(norm(rho_average - rho_average', 'fro') < tolerance, ...
        'test_pmd:CompletePipelineHermiticity', ...
        'The complete PMD pipeline must preserve Hermiticity.');

    eigenvalues = eig(rho_average);

    assert(all(real(eigenvalues) >= -tolerance), ...
        'test_pmd:CompletePipelinePositivity', ...
        'The complete PMD pipeline must return a positive semidefinite state.');


    fprintf('test_pmd passed.\n');

end
function results_experiment_6 = run_experiment_6_single_arm_pmd( ...
        dgd_values, num_frequency_points, max_frequency_offset, ...
        sigma_sum, sigma_difference, ...
        do_summary_plot, do_tensor_plot, do_save)
% RUN_EXPERIMENT_6_SINGLE_ARM_PMD  Study single-arm PMD-induced decoherence.
%
% Objective:
%   Propagate |Psi+> through a single frequency-dependent PMD segment in
%   arm A, trace out the two-photon frequency degree of freedom, and compare
%   the resulting polarization state with the continuous Gaussian benchmark.
%
%   The modeled channel is
%
%       rho_out(tau) =
%       sum_k sum_l W(k,l)
%       [U_A(Omega_A,k; tau) tensor I] rho_0
%       [U_A(Omega_A,k; tau) tensor I]^\dagger.
%
% Input:
%   dgd_values           - optional real non-negative vector of DGD values
%                          tau [s]. Default: linspace(0, 4/sigma_A, 81).
%   num_frequency_points - optional odd number of points per frequency axis.
%                          Default: 101.
%   max_frequency_offset - optional positive maximum offset [rad/s].
%                          Default: 6 * sigma_A.
%   sigma_sum            - optional JSA width along Omega_A + Omega_B [rad/s].
%                          Default: 2*pi*10e9.
%   sigma_difference     - optional JSA width along Omega_A - Omega_B [rad/s].
%                          Default: 2*pi*50e9.
%   do_summary_plot      - optional logical scalar. Default: false.
%   do_tensor_plot       - optional logical scalar. Default: false.
%   do_save              - optional logical scalar. Default: false.
%
% Output:
%   results_experiment_6 - structure containing numerical states, metrics,
%                          analytical predictions, and validation errors.
%
% Notes:
%   A z-axis PMD segment is used in arm A. Therefore the two polarization
%   components acquire a frequency-dependent relative phase but no static
%   polarization rotation. Arm B is ideal.

    % =========================
    % Default input handling
    % =========================

    if nargin < 4 || isempty(sigma_sum)
        sigma_sum = 2 * pi * 10e9;
    end

    if nargin < 5 || isempty(sigma_difference)
        sigma_difference = 2 * pi * 50e9;
    end

    sigma_A = sqrt((sigma_sum^2 + sigma_difference^2) / 4);

    if nargin < 1 || isempty(dgd_values)
        dgd_values = linspace(0, 4 / sigma_A, 81);
    end

    if nargin < 2 || isempty(num_frequency_points)
        num_frequency_points = 101;
    end

    if nargin < 3 || isempty(max_frequency_offset)
        max_frequency_offset = 6 * sigma_A;
    end

    if nargin < 6 || isempty(do_summary_plot)
        do_summary_plot = false;
    end

    if nargin < 7 || isempty(do_tensor_plot)
        do_tensor_plot = false;
    end

    if nargin < 8 || isempty(do_save)
        do_save = false;
    end


    % =========================
    % Robustness checks
    % =========================

    if ~isnumeric(dgd_values) || ~isreal(dgd_values) || ...
            ~isvector(dgd_values) || isempty(dgd_values)
        error('run_experiment_6_single_arm_pmd:InvalidDGDValues', ...
            'dgd_values must be a non-empty real numeric vector.');
    end

    if any(~isfinite(dgd_values), 'all') || any(dgd_values < 0, 'all')
        error('run_experiment_6_single_arm_pmd:InvalidDGDValues', ...
            'dgd_values must contain finite non-negative values.');
    end

    if ~isnumeric(num_frequency_points) || ~isscalar(num_frequency_points) || ...
            ~isreal(num_frequency_points) || ~isfinite(num_frequency_points) || ...
            num_frequency_points < 3 || ...
            num_frequency_points ~= floor(num_frequency_points) || ...
            mod(num_frequency_points, 2) == 0
        error('run_experiment_6_single_arm_pmd:InvalidNumFrequencyPoints', ...
            'num_frequency_points must be an odd integer greater than or equal to 3.');
    end

    if ~isnumeric(max_frequency_offset) || ~isscalar(max_frequency_offset) || ...
            ~isreal(max_frequency_offset) || ~isfinite(max_frequency_offset) || ...
            max_frequency_offset <= 0
        error('run_experiment_6_single_arm_pmd:InvalidMaxFrequencyOffset', ...
            'max_frequency_offset must be a positive finite real scalar.');
    end

    if ~isnumeric(sigma_sum) || ~isscalar(sigma_sum) || ...
            ~isreal(sigma_sum) || ~isfinite(sigma_sum) || sigma_sum <= 0
        error('run_experiment_6_single_arm_pmd:InvalidSigmaSum', ...
            'sigma_sum must be a positive finite real scalar.');
    end

    if ~isnumeric(sigma_difference) || ~isscalar(sigma_difference) || ...
            ~isreal(sigma_difference) || ~isfinite(sigma_difference) || ...
            sigma_difference <= 0
        error('run_experiment_6_single_arm_pmd:InvalidSigmaDifference', ...
            'sigma_difference must be a positive finite real scalar.');
    end

    if ~islogical(do_summary_plot) || ~isscalar(do_summary_plot)
        error('run_experiment_6_single_arm_pmd:InvalidSummaryPlotFlag', ...
            'do_summary_plot must be a logical scalar.');
    end

    if ~islogical(do_tensor_plot) || ~isscalar(do_tensor_plot)
        error('run_experiment_6_single_arm_pmd:InvalidTensorPlotFlag', ...
            'do_tensor_plot must be a logical scalar.');
    end

    if ~islogical(do_save) || ~isscalar(do_save)
        error('run_experiment_6_single_arm_pmd:InvalidSaveFlag', ...
            'do_save must be a logical scalar.');
    end


    % =========================
    % Initialization
    % =========================

    fprintf('\n\n==========================================\n');
    fprintf('Experiment 6 - Single-Arm PMD\n');
    fprintf('Frequency-resolved decoherence benchmark\n');
    fprintf('==========================================\n');

    dgd_values = dgd_values(:).';
    num_dgd_values = numel(dgd_values);

    [omega_offsets_A, delta_omega_A] = pmd_frequency_grid( ...
        num_frequency_points, max_frequency_offset);

    [omega_offsets_B, delta_omega_B] = pmd_frequency_grid( ...
        num_frequency_points, max_frequency_offset);

    spectral_weights = pmd_joint_spectral_weights( ...
        omega_offsets_A, omega_offsets_B, sigma_sum, sigma_difference);

    psi_plus = bell_state('psi_plus');
    rho_0 = state_to_density_matrix(psi_plus);

    phases_A = 0;
    axes_A = [0, 0, 1];

    phases_B = 0;
    dgds_B = 0;
    axes_B = [0, 0, 1];

    analytics = analytical_values_experiment_6( ...
        dgd_values, sigma_sum, sigma_difference);

    results_experiment_6 = struct();

    results_experiment_6.experiment_name = 'Experiment 6 - Single-Arm PMD';
    results_experiment_6.reference_state_label = 'psi_plus';
    results_experiment_6.model_name = 'single_segment_single_arm_pmd';

    results_experiment_6.rho_0 = rho_0;

    results_experiment_6.dgd_values = dgd_values;

    results_experiment_6.num_frequency_points = num_frequency_points;
    results_experiment_6.max_frequency_offset = max_frequency_offset;

    results_experiment_6.omega_offsets_A = omega_offsets_A;
    results_experiment_6.omega_offsets_B = omega_offsets_B;

    results_experiment_6.delta_omega_A = delta_omega_A;
    results_experiment_6.delta_omega_B = delta_omega_B;

    results_experiment_6.sigma_sum = sigma_sum;
    results_experiment_6.sigma_difference = sigma_difference;
    results_experiment_6.sigma_A = analytics.sigma_A;

    results_experiment_6.spectral_weights = spectral_weights;

    results_experiment_6.rho = cell(1, num_dgd_values);
    results_experiment_6.rho_A = cell(1, num_dgd_values);
    results_experiment_6.rho_B = cell(1, num_dgd_values);

    results_experiment_6.correlation_tensor = zeros(3, 3, num_dgd_values);

    results_experiment_6.c_xx = zeros(1, num_dgd_values);
    results_experiment_6.c_yy = zeros(1, num_dgd_values);
    results_experiment_6.c_zz = zeros(1, num_dgd_values);

    results_experiment_6.purity_global = zeros(1, num_dgd_values);
    results_experiment_6.purity_A = zeros(1, num_dgd_values);
    results_experiment_6.purity_B = zeros(1, num_dgd_values);

    results_experiment_6.fidelity_psi_plus = zeros(1, num_dgd_values);
    results_experiment_6.concurrence = zeros(1, num_dgd_values);
    results_experiment_6.S_max = zeros(1, num_dgd_values);


    % =========================
    % Main sweep
    % =========================

    for dgd_idx = 1:num_dgd_values

        dgd_A = dgd_values(dgd_idx);

        frequency_states = pmd_frequency_resolved_states( ...
            rho_0, ...
            omega_offsets_A, omega_offsets_B, ...
            phases_A, dgd_A, axes_A, ...
            phases_B, dgds_B, axes_B);

        rho_output = pmd_spectral_average_state( ...
            frequency_states, spectral_weights);

        rho_output = (rho_output + rho_output') / 2;

        rho_A = partial_trace_B(rho_output);
        rho_B = partial_trace_A(rho_output);

        correlation_tensor = compute_correlation_tensor(rho_output);
        correlations = compute_diagonal_correlations(rho_output);

        results_experiment_6.rho{dgd_idx} = rho_output;
        results_experiment_6.rho_A{dgd_idx} = rho_A;
        results_experiment_6.rho_B{dgd_idx} = rho_B;

        results_experiment_6.correlation_tensor(:, :, dgd_idx) = ...
            real(correlation_tensor);

        results_experiment_6.c_xx(dgd_idx) = real(correlations.c_xx);
        results_experiment_6.c_yy(dgd_idx) = real(correlations.c_yy);
        results_experiment_6.c_zz(dgd_idx) = real(correlations.c_zz);

        results_experiment_6.purity_global(dgd_idx) = ...
            real(compute_purity(rho_output));

        results_experiment_6.purity_A(dgd_idx) = ...
            real(compute_purity(rho_A));

        results_experiment_6.purity_B(dgd_idx) = ...
            real(compute_purity(rho_B));

        results_experiment_6.fidelity_psi_plus(dgd_idx) = ...
            real(compute_fidelity(rho_output, psi_plus));

        results_experiment_6.concurrence(dgd_idx) = ...
            real(compute_concurrence(rho_output));

        results_experiment_6.S_max(dgd_idx) = ...
            real(compute_chsh_max_from_tensor(correlation_tensor));

    end


    % =========================
    % Analytical validation
    % =========================

    results_experiment_6.analytical = analytics;

    results_experiment_6.errors = struct();

    results_experiment_6.errors.c_xx = ...
        results_experiment_6.c_xx - analytics.c_xx;

    results_experiment_6.errors.c_yy = ...
        results_experiment_6.c_yy - analytics.c_yy;

    results_experiment_6.errors.c_zz = ...
        results_experiment_6.c_zz - analytics.c_zz;

    results_experiment_6.errors.correlation_tensor_frobenius = zeros( ...
        1, num_dgd_values);

    for dgd_idx = 1:num_dgd_values

        results_experiment_6.errors.correlation_tensor_frobenius(dgd_idx) = ...
            norm(results_experiment_6.correlation_tensor(:, :, dgd_idx) - ...
                 analytics.correlation_tensor(:, :, dgd_idx), 'fro');

    end

    results_experiment_6.errors.purity_global = ...
        results_experiment_6.purity_global - analytics.purity_global;

    results_experiment_6.errors.purity_A = ...
        results_experiment_6.purity_A - analytics.purity_A;

    results_experiment_6.errors.purity_B = ...
        results_experiment_6.purity_B - analytics.purity_B;

    results_experiment_6.errors.fidelity_psi_plus = ...
        results_experiment_6.fidelity_psi_plus - analytics.fidelity_psi_plus;

    results_experiment_6.errors.concurrence = ...
        results_experiment_6.concurrence - analytics.concurrence;

    results_experiment_6.errors.S_max = ...
        results_experiment_6.S_max - analytics.S_max;


    % =========================
    % Console monitoring
    % =========================

    fprintf('Frequency points per arm : %d\n', num_frequency_points);
    fprintf('Frequency range          : [%.3e, %.3e] rad/s\n', ...
        -max_frequency_offset, max_frequency_offset);
    fprintf('sigma_A                 : %.3e rad/s\n', analytics.sigma_A);

    fprintf('max |c_xx error|        : %.3e\n', ...
        max(abs(results_experiment_6.errors.c_xx)));

    fprintf('max |c_yy error|        : %.3e\n', ...
        max(abs(results_experiment_6.errors.c_yy)));

    fprintf('max |c_zz error|        : %.3e\n', ...
        max(abs(results_experiment_6.errors.c_zz)));

    fprintf('max tensor ||error||_F  : %.3e\n', ...
        max(results_experiment_6.errors.correlation_tensor_frobenius));

    fprintf('max |gamma_AB error|    : %.3e\n', ...
        max(abs(results_experiment_6.errors.purity_global)));

    fprintf('max |F_psi+ error|      : %.3e\n', ...
        max(abs(results_experiment_6.errors.fidelity_psi_plus)));

    fprintf('max |C error|           : %.3e\n', ...
        max(abs(results_experiment_6.errors.concurrence)));

    fprintf('max |S_max error|       : %.3e\n', ...
        max(abs(results_experiment_6.errors.S_max)));


    % =========================
    % Plotting (conditional)
    % =========================

    if do_summary_plot
        plot_single_arm_pmd_summary(results_experiment_6, do_save);
    end

    if do_tensor_plot
        plot_single_arm_pmd_tensor_snapshot(results_experiment_6, do_save);
    end

end
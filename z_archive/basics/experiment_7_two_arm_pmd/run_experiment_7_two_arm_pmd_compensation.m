function results_experiment_7 = run_experiment_7_two_arm_pmd_compensation( ...
        dgd_values_A, dgd_values_B, ...
        num_frequency_points, max_frequency_offset, ...
        sigma_sum, sigma_difference, ...
        do_summary_plot, do_section_plot, do_save)
% RUN_EXPERIMENT_7_TWO_ARM_PMD_COMPENSATION
% Study two-arm PMD-induced decoherence and nonlocal compensation.
%
% Objective:
%   Propagate |Psi+> through two frequency-dependent PMD segments, trace out
%   the two-photon frequency degree of freedom, and compare the resulting
%   polarization state with the continuous Gaussian benchmark.
%
%   The modeled channel is
%
%       rho_out(tau_A, tau_B) =
%       sum_k sum_l W(k,l)
%       [U_A(Omega_A,k; tau_A) tensor U_B(Omega_B,l; tau_B)]
%       rho_0
%       [U_A(Omega_A,k; tau_A) tensor U_B(Omega_B,l; tau_B)]^\dagger.
%
% Input:
%   dgd_values_A         - optional real non-negative vector of DGD values
%                          tau_A [s]. Default: linspace(0, 4/sigma_A, 31).
%   dgd_values_B         - optional real non-negative vector of DGD values
%                          tau_B [s]. Default: dgd_values_A.
%   num_frequency_points - optional odd number of points per frequency axis.
%                          Default: 81.
%   max_frequency_offset - optional positive maximum offset [rad/s].
%                          Default: 6 * sigma_A.
%   sigma_sum            - optional JSA width along Omega_A + Omega_B [rad/s].
%                          Default: 2*pi*10e9.
%   sigma_difference     - optional JSA width along Omega_A - Omega_B [rad/s].
%                          Default: 2*pi*50e9.
%   do_summary_plot      - optional logical scalar. Default: false.
%   do_section_plot      - optional logical scalar. Default: false.
%   do_save              - optional logical scalar. Default: false.
%
% Output:
%   results_experiment_7 - structure containing numerical states, metrics,
%                          analytical predictions, and validation errors.
%
% Notes:
%   The PMD axis is z in arm A and -z in arm B. With an anticorrelated joint
%   spectrum, this convention produces a compensation ridge close to
%   tau_B = tau_A. The finite-width Gaussian benchmark is computed by
%   analytical_values_experiment_7.

    % =========================
    % Default input handling
    % =========================

    if nargin < 5 || isempty(sigma_sum)
        sigma_sum = 2 * pi * 10e9;
    end

    if nargin < 6 || isempty(sigma_difference)
        sigma_difference = 2 * pi * 50e9;
    end

    sigma_A = sqrt((sigma_sum^2 + sigma_difference^2) / 4);

    if nargin < 1 || isempty(dgd_values_A)
        dgd_values_A = linspace(0, 4 / sigma_A, 31);
    end

    if nargin < 2 || isempty(dgd_values_B)
        dgd_values_B = dgd_values_A;
    end

    if nargin < 3 || isempty(num_frequency_points)
        num_frequency_points = 81;
    end

    if nargin < 4 || isempty(max_frequency_offset)
        max_frequency_offset = 6 * sigma_A;
    end

    if nargin < 7 || isempty(do_summary_plot)
        do_summary_plot = false;
    end

    if nargin < 8 || isempty(do_section_plot)
        do_section_plot = false;
    end

    if nargin < 9 || isempty(do_save)
        do_save = false;
    end


    % =========================
    % Robustness checks
    % =========================

    if ~isnumeric(dgd_values_A) || ~isreal(dgd_values_A) || ...
            ~isvector(dgd_values_A) || isempty(dgd_values_A)
        error('run_experiment_7_two_arm_pmd_compensation:InvalidDGDValuesA', ...
            'dgd_values_A must be a non-empty real numeric vector.');
    end

    if any(~isfinite(dgd_values_A), 'all') || ...
            any(dgd_values_A < 0, 'all')
        error('run_experiment_7_two_arm_pmd_compensation:InvalidDGDValuesA', ...
            'dgd_values_A must contain finite non-negative values.');
    end

    if ~isnumeric(dgd_values_B) || ~isreal(dgd_values_B) || ...
            ~isvector(dgd_values_B) || isempty(dgd_values_B)
        error('run_experiment_7_two_arm_pmd_compensation:InvalidDGDValuesB', ...
            'dgd_values_B must be a non-empty real numeric vector.');
    end

    if any(~isfinite(dgd_values_B), 'all') || ...
            any(dgd_values_B < 0, 'all')
        error('run_experiment_7_two_arm_pmd_compensation:InvalidDGDValuesB', ...
            'dgd_values_B must contain finite non-negative values.');
    end

    if ~isnumeric(num_frequency_points) || ~isscalar(num_frequency_points) || ...
            ~isreal(num_frequency_points) || ~isfinite(num_frequency_points) || ...
            num_frequency_points < 3 || ...
            num_frequency_points ~= floor(num_frequency_points) || ...
            mod(num_frequency_points, 2) == 0
        error(['run_experiment_7_two_arm_pmd_compensation:', ...
               'InvalidNumFrequencyPoints'], ...
            'num_frequency_points must be an odd integer greater than or equal to 3.');
    end

    if ~isnumeric(max_frequency_offset) || ~isscalar(max_frequency_offset) || ...
            ~isreal(max_frequency_offset) || ~isfinite(max_frequency_offset) || ...
            max_frequency_offset <= 0
        error('run_experiment_7_two_arm_pmd_compensation:InvalidMaxFrequencyOffset', ...
            'max_frequency_offset must be a positive finite real scalar.');
    end

    if ~isnumeric(sigma_sum) || ~isscalar(sigma_sum) || ...
            ~isreal(sigma_sum) || ~isfinite(sigma_sum) || sigma_sum <= 0
        error('run_experiment_7_two_arm_pmd_compensation:InvalidSigmaSum', ...
            'sigma_sum must be a positive finite real scalar.');
    end

    if ~isnumeric(sigma_difference) || ~isscalar(sigma_difference) || ...
            ~isreal(sigma_difference) || ~isfinite(sigma_difference) || ...
            sigma_difference <= 0
        error('run_experiment_7_two_arm_pmd_compensation:InvalidSigmaDifference', ...
            'sigma_difference must be a positive finite real scalar.');
    end

    if ~islogical(do_summary_plot) || ~isscalar(do_summary_plot)
        error('run_experiment_7_two_arm_pmd_compensation:InvalidSummaryPlotFlag', ...
            'do_summary_plot must be a logical scalar.');
    end

    if ~islogical(do_section_plot) || ~isscalar(do_section_plot)
        error('run_experiment_7_two_arm_pmd_compensation:InvalidSectionPlotFlag', ...
            'do_section_plot must be a logical scalar.');
    end

    if ~islogical(do_save) || ~isscalar(do_save)
        error('run_experiment_7_two_arm_pmd_compensation:InvalidSaveFlag', ...
            'do_save must be a logical scalar.');
    end


    % =========================
    % Initialization
    % =========================

    fprintf('\n\n==========================================\n');
    fprintf('Experiment 7 - Two-Arm PMD Compensation\n');
    fprintf('Spectrally correlated nonlocal recovery benchmark\n');
    fprintf('==========================================\n');

    dgd_values_A = dgd_values_A(:).';
    dgd_values_B = dgd_values_B(:).';

    num_dgd_values_A = numel(dgd_values_A);
    num_dgd_values_B = numel(dgd_values_B);

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
    axes_B = [0, 0, -1];

    analytics = analytical_values_experiment_7( ...
        dgd_values_A, dgd_values_B, sigma_sum, sigma_difference);

    results_experiment_7 = struct();

    results_experiment_7.experiment_name = ...
        'Experiment 7 - Two-Arm PMD Compensation';

    results_experiment_7.reference_state_label = 'psi_plus';
    results_experiment_7.model_name = ...
        'two_segment_two_arm_pmd_nonlocal_compensation';

    results_experiment_7.rho_0 = rho_0;

    results_experiment_7.dgd_values_A = dgd_values_A;
    results_experiment_7.dgd_values_B = dgd_values_B;

    results_experiment_7.num_frequency_points = num_frequency_points;
    results_experiment_7.max_frequency_offset = max_frequency_offset;

    results_experiment_7.omega_offsets_A = omega_offsets_A;
    results_experiment_7.omega_offsets_B = omega_offsets_B;

    results_experiment_7.delta_omega_A = delta_omega_A;
    results_experiment_7.delta_omega_B = delta_omega_B;

    results_experiment_7.sigma_sum = sigma_sum;
    results_experiment_7.sigma_difference = sigma_difference;
    results_experiment_7.sigma_A = analytics.sigma_A;
    results_experiment_7.sigma_B = analytics.sigma_B;
    results_experiment_7.covariance_AB = analytics.covariance_AB;
    results_experiment_7.correlation_AB = analytics.correlation_AB;

    results_experiment_7.spectral_weights = spectral_weights;

    results_experiment_7.phases_A = phases_A;
    results_experiment_7.phases_B = phases_B;
    results_experiment_7.axes_A = axes_A;
    results_experiment_7.axes_B = axes_B;

    results_experiment_7.rho = cell(num_dgd_values_A, num_dgd_values_B);
    results_experiment_7.rho_A = cell(num_dgd_values_A, num_dgd_values_B);
    results_experiment_7.rho_B = cell(num_dgd_values_A, num_dgd_values_B);

    results_experiment_7.correlation_tensor = zeros( ...
        3, 3, num_dgd_values_A, num_dgd_values_B);

    results_experiment_7.c_xx = zeros(num_dgd_values_A, num_dgd_values_B);
    results_experiment_7.c_yy = zeros(num_dgd_values_A, num_dgd_values_B);
    results_experiment_7.c_zz = zeros(num_dgd_values_A, num_dgd_values_B);

    results_experiment_7.purity_global = zeros( ...
        num_dgd_values_A, num_dgd_values_B);

    results_experiment_7.purity_A = zeros(num_dgd_values_A, num_dgd_values_B);
    results_experiment_7.purity_B = zeros(num_dgd_values_A, num_dgd_values_B);

    results_experiment_7.fidelity_psi_plus = zeros( ...
        num_dgd_values_A, num_dgd_values_B);

    results_experiment_7.concurrence = zeros( ...
        num_dgd_values_A, num_dgd_values_B);

    results_experiment_7.S_max = zeros(num_dgd_values_A, num_dgd_values_B);


    % =========================
    % Main sweep
    % =========================

    for dgd_idx_A = 1:num_dgd_values_A
        for dgd_idx_B = 1:num_dgd_values_B

            dgd_A = dgd_values_A(dgd_idx_A);
            dgd_B = dgd_values_B(dgd_idx_B);

            frequency_states = pmd_frequency_resolved_states( ...
                rho_0, ...
                omega_offsets_A, omega_offsets_B, ...
                phases_A, dgd_A, axes_A, ...
                phases_B, dgd_B, axes_B);

            rho_output = pmd_spectral_average_state( ...
                frequency_states, spectral_weights);

            rho_output = (rho_output + rho_output') / 2;

            rho_A = partial_trace_B(rho_output);
            rho_B = partial_trace_A(rho_output);

            correlation_tensor = compute_correlation_tensor(rho_output);
            correlations = compute_diagonal_correlations(rho_output);

            results_experiment_7.rho{dgd_idx_A, dgd_idx_B} = rho_output;
            results_experiment_7.rho_A{dgd_idx_A, dgd_idx_B} = rho_A;
            results_experiment_7.rho_B{dgd_idx_A, dgd_idx_B} = rho_B;

            results_experiment_7.correlation_tensor( ...
                :, :, dgd_idx_A, dgd_idx_B) = real(correlation_tensor);

            results_experiment_7.c_xx(dgd_idx_A, dgd_idx_B) = ...
                real(correlations.c_xx);

            results_experiment_7.c_yy(dgd_idx_A, dgd_idx_B) = ...
                real(correlations.c_yy);

            results_experiment_7.c_zz(dgd_idx_A, dgd_idx_B) = ...
                real(correlations.c_zz);

            results_experiment_7.purity_global(dgd_idx_A, dgd_idx_B) = ...
                real(compute_purity(rho_output));

            results_experiment_7.purity_A(dgd_idx_A, dgd_idx_B) = ...
                real(compute_purity(rho_A));

            results_experiment_7.purity_B(dgd_idx_A, dgd_idx_B) = ...
                real(compute_purity(rho_B));

            results_experiment_7.fidelity_psi_plus(dgd_idx_A, dgd_idx_B) = ...
                real(compute_fidelity(rho_output, psi_plus));

            results_experiment_7.concurrence(dgd_idx_A, dgd_idx_B) = ...
                real(compute_concurrence(rho_output));

            results_experiment_7.S_max(dgd_idx_A, dgd_idx_B) = ...
                real(compute_chsh_max_from_tensor(correlation_tensor));

        end
    end


    % =========================
    % Analytical validation
    % =========================

    results_experiment_7.analytical = analytics;

    results_experiment_7.errors = struct();

    results_experiment_7.errors.c_xx = ...
        results_experiment_7.c_xx - analytics.c_xx;

    results_experiment_7.errors.c_yy = ...
        results_experiment_7.c_yy - analytics.c_yy;

    results_experiment_7.errors.c_zz = ...
        results_experiment_7.c_zz - analytics.c_zz;

    results_experiment_7.errors.correlation_tensor_frobenius = zeros( ...
        num_dgd_values_A, num_dgd_values_B);

    for dgd_idx_A = 1:num_dgd_values_A
        for dgd_idx_B = 1:num_dgd_values_B

            results_experiment_7.errors.correlation_tensor_frobenius( ...
                dgd_idx_A, dgd_idx_B) = norm( ...
                results_experiment_7.correlation_tensor( ...
                    :, :, dgd_idx_A, dgd_idx_B) - ...
                analytics.correlation_tensor(:, :, dgd_idx_A, dgd_idx_B), ...
                'fro');

        end
    end

    results_experiment_7.errors.purity_global = ...
        results_experiment_7.purity_global - analytics.purity_global;

    results_experiment_7.errors.purity_A = ...
        results_experiment_7.purity_A - analytics.purity_A;

    results_experiment_7.errors.purity_B = ...
        results_experiment_7.purity_B - analytics.purity_B;

    results_experiment_7.errors.fidelity_psi_plus = ...
        results_experiment_7.fidelity_psi_plus - analytics.fidelity_psi_plus;

    results_experiment_7.errors.concurrence = ...
        results_experiment_7.concurrence - analytics.concurrence;

    results_experiment_7.errors.S_max = ...
        results_experiment_7.S_max - analytics.S_max;


    % =========================
    % Console monitoring
    % =========================

    fprintf('Frequency points per arm : %d\n', num_frequency_points);
    fprintf('DGD grid size            : %d x %d\n', ...
        num_dgd_values_A, num_dgd_values_B);
    fprintf('Frequency range          : [%.3e, %.3e] rad/s\n', ...
        -max_frequency_offset, max_frequency_offset);
    fprintf('sigma_A                 : %.3e rad/s\n', analytics.sigma_A);
    fprintf('sigma_B                 : %.3e rad/s\n', analytics.sigma_B);
    fprintf('spectral correlation r  : %.6f\n', analytics.correlation_AB);

    fprintf('max |c_xx error|        : %.3e\n', ...
        max(abs(results_experiment_7.errors.c_xx), [], 'all'));

    fprintf('max |c_yy error|        : %.3e\n', ...
        max(abs(results_experiment_7.errors.c_yy), [], 'all'));

    fprintf('max |c_zz error|        : %.3e\n', ...
        max(abs(results_experiment_7.errors.c_zz), [], 'all'));

    fprintf('max tensor ||error||_F  : %.3e\n', ...
        max(results_experiment_7.errors.correlation_tensor_frobenius, ...
        [], 'all'));

    fprintf('max |gamma_AB error|    : %.3e\n', ...
        max(abs(results_experiment_7.errors.purity_global), [], 'all'));

    fprintf('max |F_psi+ error|      : %.3e\n', ...
        max(abs(results_experiment_7.errors.fidelity_psi_plus), [], 'all'));

    fprintf('max |C error|           : %.3e\n', ...
        max(abs(results_experiment_7.errors.concurrence), [], 'all'));

    fprintf('max |S_max error|       : %.3e\n', ...
        max(abs(results_experiment_7.errors.S_max), [], 'all'));


    % =========================
    % Plotting (conditional)
    % =========================

    if do_summary_plot
        plot_two_arm_pmd_compensation_summary(results_experiment_7, do_save);
    end

    if do_section_plot
        plot_two_arm_pmd_compensation_sections(results_experiment_7, do_save);
    end

end

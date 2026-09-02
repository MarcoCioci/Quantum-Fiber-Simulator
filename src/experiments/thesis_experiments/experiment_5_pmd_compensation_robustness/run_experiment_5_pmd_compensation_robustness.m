function results_experiment_5 = ...
        run_experiment_5_pmd_compensation_robustness(do_plot, do_save)
% RUN_EXPERIMENT_5_PMD_COMPENSATION_ROBUSTNESS
% Study the robustness of nonlocal PMD compensation.
%
% Objective:
%   Quantify how imperfect compensation settings reduce the polarization
%   entanglement recovered from a spectrally correlated photon pair.
%
%   The input polarization state is
%
%       |Psi+> = (|01> + |10>) / sqrt(2).
%
%   Arm A contains one PMD element with fixed DGD and axis +z.
%   Arm B contains a controlled PMD element whose nominal axis is -z.
%
%   The experiment perturbs two compensation parameters:
%
%       1. relative DGD error
%
%              epsilon_tau = (tau_B - tau_B,opt) / tau_B,opt,
%
%       2. angular misalignment alpha between the actual compensator axis
%          and the ideal axis -z.
%
%   For every pair (epsilon_tau, alpha), the complete frequency-resolved
%   polarization state is propagated and frequency is traced out.
%
%   The central quality criterion is
%
%       C >= C_threshold,
%
%   where C is the concurrence. This criterion is an operational
%   entanglement-quality threshold and must not be confused with the
%   mathematical entanglement condition C > 0.
%
% Input:
%   do_plot - Logical scalar controlling the summary figure.
%   do_save - Logical scalar controlling figure export.
%
% Output:
%   results_experiment_5 - Structure containing:
%       .parameters
%       .spectral
%       .rho_output
%       .purity
%       .fidelity
%       .concurrence
%       .chsh_max
%       .analytical
%       .errors
%       .quality
%       .diagnostics
%
% Notes:
%   All physical and numerical parameter selections are intentionally kept
%   inside this runner. main.m only selects whether the experiment is run
%   and whether plotting/export are enabled.
%
%   The joint spectral probability distribution is
%
%       W(Omega_A, Omega_B) proportional to
%
%       exp[-(Omega_A + Omega_B)^2 / (2 sigma_sum^2)
%           -(Omega_A - Omega_B)^2 / (2 sigma_difference^2)].
%
%   With sigma_difference > sigma_sum, the two frequency offsets are
%   anticorrelated. For the aligned PMD axes used here, the continuous
%   Gaussian optimum is
%
%       tau_B,opt = -r tau_A,
%
%   where r is the spectral correlation coefficient.
%
%   The numerical propagation reuses the validated PMD pipeline:
%
%       pmd_frequency_resolved_states
%               ->
%       pmd_spectral_average_state.
%
%   No experiment-specific PMD propagation model is introduced.

    % =========================
    % Robustness checks
    % =========================

    if nargin ~= 2
        error( ...
            ['run_experiment_5_pmd_compensation_robustness:', ...
             'InvalidNumInputs'], ...
            ['Expected exactly 2 input arguments: ', ...
             'do_plot and do_save.']);
    end

    if ~(islogical(do_plot) && isscalar(do_plot))
        error( ...
            ['run_experiment_5_pmd_compensation_robustness:', ...
             'InvalidDoPlot'], ...
            'do_plot must be a logical scalar.');
    end

    if ~(islogical(do_save) && isscalar(do_save))
        error( ...
            ['run_experiment_5_pmd_compensation_robustness:', ...
             'InvalidDoSave'], ...
            'do_save must be a logical scalar.');
    end


    % =========================
    % Experiment parameters
    % =========================
    %
    % IMPORTANT:
    % These are the only lines that should be edited when changing the
    % physical/numerical setup of Experiment 5. They intentionally do not
    % appear in main.m.

    % Operational entanglement-quality threshold.
    %
    % This is NOT the separability threshold. A state is entangled whenever
    % C > 0. Here C_threshold defines the stricter quality level adopted for
    % this numerical robustness analysis.
    concurrence_threshold = 0.80;

    % Gaussian two-photon spectral widths [rad/s].
    sigma_sum = 2 * pi * 10e9;
    sigma_difference = 2 * pi * 50e9;

    % PMD strength in arm A expressed through the dimensionless quantity
    %
    %     xi_A = sigma_omega * tau_A.
    normalized_dgd_A = 1.25;

    % Relative error around the analytically optimal compensation DGD.
    relative_dgd_error_values = linspace(-0.60, 0.60, 41);

    % Angular departure from the ideal compensator axis -z.
    misalignment_angle_values = ...
        deg2rad(linspace(0, 60, 31));

    % Spectral discretization.
    num_frequency_points = 41;
    max_offset_factor = 6.0;

    % Physical-state numerical tolerance.
    state_tolerance = 1e-8;


    % =========================
    % Parameter consistency
    % =========================

    if concurrence_threshold <= 0 || concurrence_threshold >= 1
        error( ...
            ['run_experiment_5_pmd_compensation_robustness:', ...
             'InvalidConcurrenceThreshold'], ...
            'concurrence_threshold must satisfy 0 < C_threshold < 1.');
    end

    if sigma_sum <= 0 || sigma_difference <= 0
        error( ...
            ['run_experiment_5_pmd_compensation_robustness:', ...
             'InvalidSpectralWidths'], ...
            'sigma_sum and sigma_difference must be positive.');
    end

    if sigma_difference <= sigma_sum
        error( ...
            ['run_experiment_5_pmd_compensation_robustness:', ...
             'NonAnticorrelatedSpectrum'], ...
            ['This experiment assumes sigma_difference > sigma_sum so ', ...
             'that the photon frequency offsets are anticorrelated.']);
    end

    if normalized_dgd_A <= 0
        error( ...
            ['run_experiment_5_pmd_compensation_robustness:', ...
             'InvalidNormalizedDGD'], ...
            'normalized_dgd_A must be positive.');
    end

    if any(~isfinite(relative_dgd_error_values), 'all') || ...
            ~isvector(relative_dgd_error_values) || ...
            isempty(relative_dgd_error_values)
        error( ...
            ['run_experiment_5_pmd_compensation_robustness:', ...
             'InvalidDGDErrorGrid'], ...
            ['relative_dgd_error_values must be a non-empty finite ', ...
             'numeric vector.']);
    end

    if any(relative_dgd_error_values <= -1)
        error( ...
            ['run_experiment_5_pmd_compensation_robustness:', ...
             'InvalidDGDErrorRange'], ...
            ['relative_dgd_error_values must be greater than -1 so ', ...
             'that tau_B remains non-negative.']);
    end

    if any(diff(relative_dgd_error_values) <= 0)
        error( ...
            ['run_experiment_5_pmd_compensation_robustness:', ...
             'UnsortedDGDErrorGrid'], ...
            'relative_dgd_error_values must be strictly increasing.');
    end

    if min(abs(relative_dgd_error_values)) > 1e-12
        error( ...
            ['run_experiment_5_pmd_compensation_robustness:', ...
             'MissingNominalDGDPoint'], ...
            ['relative_dgd_error_values must contain epsilon_tau = 0 ', ...
             'for the nominal compensation section.']);
    end

    if any(~isfinite(misalignment_angle_values), 'all') || ...
            ~isvector(misalignment_angle_values) || ...
            isempty(misalignment_angle_values)
        error( ...
            ['run_experiment_5_pmd_compensation_robustness:', ...
             'InvalidAngleGrid'], ...
            ['misalignment_angle_values must be a non-empty finite ', ...
             'numeric vector.']);
    end

    if any(misalignment_angle_values < 0) || ...
            any(misalignment_angle_values > pi)
        error( ...
            ['run_experiment_5_pmd_compensation_robustness:', ...
             'InvalidAngleRange'], ...
            'misalignment angles must satisfy 0 <= alpha <= pi.');
    end

    if any(diff(misalignment_angle_values) <= 0)
        error( ...
            ['run_experiment_5_pmd_compensation_robustness:', ...
             'UnsortedAngleGrid'], ...
            'misalignment_angle_values must be strictly increasing.');
    end

    if abs(misalignment_angle_values(1)) > 1e-12
        error( ...
            ['run_experiment_5_pmd_compensation_robustness:', ...
             'MissingAlignedCase'], ...
            ['misalignment_angle_values must start at alpha = 0 ', ...
             'for analytical validation.']);
    end

    if num_frequency_points < 3 || ...
            num_frequency_points ~= floor(num_frequency_points) || ...
            mod(num_frequency_points, 2) == 0
        error( ...
            ['run_experiment_5_pmd_compensation_robustness:', ...
             'InvalidNumFrequencyPoints'], ...
            ['num_frequency_points must be an odd integer greater than ', ...
             'or equal to 3.']);
    end

    if max_offset_factor <= 0 || ~isfinite(max_offset_factor)
        error( ...
            ['run_experiment_5_pmd_compensation_robustness:', ...
             'InvalidMaxOffsetFactor'], ...
            'max_offset_factor must be positive and finite.');
    end

    if state_tolerance <= 0 || ~isfinite(state_tolerance)
        error( ...
            ['run_experiment_5_pmd_compensation_robustness:', ...
             'InvalidStateTolerance'], ...
            'state_tolerance must be positive and finite.');
    end


    % =========================
    % Spectral parameters
    % =========================

    sigma_omega = ...
        sqrt((sigma_sum^2 + sigma_difference^2) / 4);

    covariance_AB = ...
        (sigma_sum^2 - sigma_difference^2) / 4;

    spectral_correlation = ...
        covariance_AB / sigma_omega^2;

    if spectral_correlation >= 0
        error( ...
            ['run_experiment_5_pmd_compensation_robustness:', ...
             'InvalidSpectralCorrelation'], ...
            ['The selected spectrum must produce negative frequency ', ...
             'correlation for the present compensation convention.']);
    end

    dgd_A = ...
        normalized_dgd_A / sigma_omega;

    dgd_B_optimal = ...
        -spectral_correlation * dgd_A;

    dgd_values_B = ...
        dgd_B_optimal .* ...
        (1 + relative_dgd_error_values);

    max_frequency_offset = ...
        max_offset_factor * sigma_omega;


    % =========================
    % Frequency grid and spectrum
    % =========================

    [omega_offsets, delta_omega] = ...
        pmd_frequency_grid( ...
            num_frequency_points, ...
            max_frequency_offset);

    spectral_weights = ...
        pmd_joint_spectral_weights( ...
            omega_offsets, ...
            omega_offsets, ...
            sigma_sum, ...
            sigma_difference);


    % =========================
    % Input state
    % =========================

    psi_input = ...
        bell_state('psi_plus');

    rho_input = ...
        state_to_density_matrix(psi_input);


    % =========================
    % Fixed PMD element: arm A
    % =========================

    phases_A = 0;
    dgds_A = dgd_A;
    axes_A = [0, 0, 1];


    % =========================
    % Controlled PMD element: arm B
    % =========================

    phases_B = 0;


    % =========================
    % Analytical aligned benchmark
    % =========================

    analytics = ...
        analytical_values_experiment_5_pmd_compensation_robustness( ...
            dgd_A, ...
            dgd_values_B, ...
            sigma_sum, ...
            sigma_difference);


    % =========================
    % Preallocation
    % =========================

    num_angles = ...
        numel(misalignment_angle_values);

    num_dgd_errors = ...
        numel(relative_dgd_error_values);

    rho_output = ...
        complex(zeros(4, 4, num_angles, num_dgd_errors));

    purity = ...
        zeros(num_angles, num_dgd_errors);

    fidelity = ...
        zeros(num_angles, num_dgd_errors);

    concurrence = ...
        zeros(num_angles, num_dgd_errors);

    chsh_max = ...
        zeros(num_angles, num_dgd_errors);

    trace_error = ...
        zeros(num_angles, num_dgd_errors);

    hermiticity_error = ...
        zeros(num_angles, num_dgd_errors);

    minimum_eigenvalue = ...
        zeros(num_angles, num_dgd_errors);


    % =========================
    % Console header
    % =========================

    fprintf('\n');
    fprintf('============================================\n');
    fprintf(' Experiment 5 - PMD Compensation Robustness\n');
    fprintf('============================================\n');

    fprintf('Concurrence threshold:      %.3f\n', ...
        concurrence_threshold);

    fprintf('Frequency nodes / arm:      %d\n', ...
        num_frequency_points);

    fprintf('Marginal sigma_omega:       %.3e rad/s\n', ...
        sigma_omega);

    fprintf('Spectral correlation r:     %.6f\n', ...
        spectral_correlation);

    fprintf('Normalized PMD xi_A:        %.3f\n', ...
        normalized_dgd_A);

    fprintf('DGD arm A:                  %.3f ps\n', ...
        dgd_A * 1e12);

    fprintf('Optimal DGD arm B:          %.3f ps\n', ...
        dgd_B_optimal * 1e12);

    fprintf('DGD error range:            [%+.1f, %+.1f] %%\n', ...
        100 * min(relative_dgd_error_values), ...
        100 * max(relative_dgd_error_values));

    fprintf('Misalignment range:         [%.1f, %.1f] deg\n', ...
        rad2deg(min(misalignment_angle_values)), ...
        rad2deg(max(misalignment_angle_values)));

    fprintf('Spectral window:            +/- %.1f sigma_omega\n', ...
        max_offset_factor);


    % =========================
    % Robustness sweep
    % =========================

    for i_angle = 1:num_angles

        alpha = ...
            misalignment_angle_values(i_angle);

        % Rotate the compensator away from its ideal -z direction in the
        % x-z plane. Therefore:
        %
        %   alpha = 0      -> axis_B = -z
        %   alpha = pi/2   -> axis_B = +x
        axes_B = [ ...
            sin(alpha), ...
            0, ...
            -cos(alpha)];

        fprintf( ...
            'Angle %2d/%2d: alpha = %6.2f deg\n', ...
            i_angle, ...
            num_angles, ...
            rad2deg(alpha));


        for i_dgd = 1:num_dgd_errors

            dgds_B = ...
                dgd_values_B(i_dgd);


            % =========================
            % Frequency-resolved propagation
            % =========================

            frequency_states = ...
                pmd_frequency_resolved_states( ...
                    rho_input, ...
                    omega_offsets, ...
                    omega_offsets, ...
                    phases_A, ...
                    dgds_A, ...
                    axes_A, ...
                    phases_B, ...
                    dgds_B, ...
                    axes_B);


            % =========================
            % Spectral trace
            % =========================

            rho_raw = ...
                pmd_spectral_average_state( ...
                    frequency_states, ...
                    spectral_weights);


            % =========================
            % Physical-state diagnostics
            % =========================

            trace_error(i_angle, i_dgd) = ...
                abs(trace(rho_raw) - 1);

            hermiticity_error(i_angle, i_dgd) = ...
                norm(rho_raw - rho_raw', 'fro');

            rho_current = ...
                (rho_raw + rho_raw') / 2;

            eigenvalues_current = ...
                eig(rho_current);

            minimum_eigenvalue(i_angle, i_dgd) = ...
                min(real(eigenvalues_current));

            if trace_error(i_angle, i_dgd) > state_tolerance
                error( ...
                    ['run_experiment_5_pmd_compensation_robustness:', ...
                     'TraceFailure'], ...
                    ['Reduced-state trace error exceeded tolerance at ', ...
                     'alpha = %.3f deg, epsilon_tau = %.4f.'], ...
                    rad2deg(alpha), ...
                    relative_dgd_error_values(i_dgd));
            end

            if hermiticity_error(i_angle, i_dgd) > state_tolerance
                error( ...
                    ['run_experiment_5_pmd_compensation_robustness:', ...
                     'HermiticityFailure'], ...
                    ['Reduced-state Hermiticity error exceeded tolerance ', ...
                     'at alpha = %.3f deg, epsilon_tau = %.4f.'], ...
                    rad2deg(alpha), ...
                    relative_dgd_error_values(i_dgd));
            end

            if minimum_eigenvalue(i_angle, i_dgd) < -state_tolerance
                error( ...
                    ['run_experiment_5_pmd_compensation_robustness:', ...
                     'PositivityFailure'], ...
                    ['Reduced state is not positive semidefinite within ', ...
                     'tolerance at alpha = %.3f deg, epsilon_tau = %.4f.'], ...
                    rad2deg(alpha), ...
                    relative_dgd_error_values(i_dgd));
            end


            % =========================
            % State characterization
            % =========================

            correlation_tensor_current = ...
                compute_correlation_tensor(rho_current);

            rho_output(:, :, i_angle, i_dgd) = ...
                rho_current;

            purity(i_angle, i_dgd) = ...
                real(compute_purity(rho_current));

            fidelity(i_angle, i_dgd) = ...
                real(compute_fidelity( ...
                    rho_current, ...
                    psi_input));

            concurrence(i_angle, i_dgd) = ...
                real(compute_concurrence(rho_current));

            chsh_max(i_angle, i_dgd) = ...
                real(compute_chsh_max_from_tensor( ...
                    correlation_tensor_current));

        end
    end


    % =========================
    % Analytical validation
    % =========================

    aligned_concurrence = ...
        concurrence(1, :);

    aligned_purity = ...
        purity(1, :);

    aligned_fidelity = ...
        fidelity(1, :);

    aligned_chsh_max = ...
        chsh_max(1, :);

    errors = struct();

    errors.aligned_concurrence = ...
        aligned_concurrence - analytics.concurrence;

    errors.aligned_purity = ...
        aligned_purity - analytics.purity;

    errors.aligned_fidelity = ...
        aligned_fidelity - analytics.fidelity;

    errors.aligned_chsh_max = ...
        aligned_chsh_max - analytics.chsh_max;

    errors.max_abs_aligned_concurrence = ...
        max(abs(errors.aligned_concurrence), [], 'all');

    errors.max_abs_aligned_purity = ...
        max(abs(errors.aligned_purity), [], 'all');

    errors.max_abs_aligned_fidelity = ...
        max(abs(errors.aligned_fidelity), [], 'all');

    errors.max_abs_aligned_chsh_max = ...
        max(abs(errors.aligned_chsh_max), [], 'all');


    % =========================
    % Entanglement-quality analysis
    % =========================

    quality = ...
        analyze_experiment_5_pmd_compensation_quality( ...
            relative_dgd_error_values, ...
            misalignment_angle_values, ...
            concurrence, ...
            concurrence_threshold);


    % =========================
    % Results structure
    % =========================

    results_experiment_5 = struct();

    results_experiment_5.experiment_name = ...
        'Experiment 5 - PMD Compensation Robustness';

    results_experiment_5.reference_state_label = ...
        'Psi+';

    results_experiment_5.model_name = ...
        'two_arm_single_segment_pmd_compensation_robustness';

    results_experiment_5.parameters = struct();

    results_experiment_5.parameters.concurrence_threshold = ...
        concurrence_threshold;

    results_experiment_5.parameters.normalized_dgd_A = ...
        normalized_dgd_A;

    results_experiment_5.parameters.dgd_A = ...
        dgd_A;

    results_experiment_5.parameters.dgd_B_optimal = ...
        dgd_B_optimal;

    results_experiment_5.parameters.dgd_values_B = ...
        dgd_values_B;

    results_experiment_5.parameters.relative_dgd_error_values = ...
        relative_dgd_error_values;

    results_experiment_5.parameters.misalignment_angle_values = ...
        misalignment_angle_values;

    results_experiment_5.parameters.num_frequency_points = ...
        num_frequency_points;

    results_experiment_5.parameters.max_offset_factor = ...
        max_offset_factor;

    results_experiment_5.parameters.state_tolerance = ...
        state_tolerance;

    results_experiment_5.spectral = struct();

    results_experiment_5.spectral.sigma_sum = ...
        sigma_sum;

    results_experiment_5.spectral.sigma_difference = ...
        sigma_difference;

    results_experiment_5.spectral.sigma_omega = ...
        sigma_omega;

    results_experiment_5.spectral.covariance_AB = ...
        covariance_AB;

    results_experiment_5.spectral.correlation_AB = ...
        spectral_correlation;

    results_experiment_5.spectral.omega_offsets = ...
        omega_offsets;

    results_experiment_5.spectral.delta_omega = ...
        delta_omega;

    results_experiment_5.spectral.spectral_weights = ...
        spectral_weights;

    results_experiment_5.rho_input = ...
        rho_input;

    results_experiment_5.rho_output = ...
        rho_output;

    results_experiment_5.purity = ...
        purity;

    results_experiment_5.fidelity = ...
        fidelity;

    results_experiment_5.concurrence = ...
        concurrence;

    results_experiment_5.chsh_max = ...
        chsh_max;

    results_experiment_5.analytical = ...
        analytics;

    results_experiment_5.errors = ...
        errors;

    results_experiment_5.quality = ...
        quality;

    results_experiment_5.diagnostics = struct();

    results_experiment_5.diagnostics.trace_error = ...
        trace_error;

    results_experiment_5.diagnostics.hermiticity_error = ...
        hermiticity_error;

    results_experiment_5.diagnostics.minimum_eigenvalue = ...
        minimum_eigenvalue;


    % =========================
    % Console summary
    % =========================

    fprintf('\nValidation against aligned Gaussian benchmark\n');
    fprintf('max |C error|:              %.3e\n', ...
        errors.max_abs_aligned_concurrence);

    fprintf('max |purity error|:         %.3e\n', ...
        errors.max_abs_aligned_purity);

    fprintf('max |fidelity error|:       %.3e\n', ...
        errors.max_abs_aligned_fidelity);

    fprintf('max |S_max error|:          %.3e\n', ...
        errors.max_abs_aligned_chsh_max);

    fprintf('\nEntanglement-quality analysis\n');
    fprintf('C threshold:                %.3f\n', ...
        concurrence_threshold);

    fprintf('Nominal concurrence:        %.6f\n', ...
        quality.nominal_concurrence);

    fprintf('Best concurrence in scan:   %.6f\n', ...
        quality.best_concurrence);

    fprintf('Best DGD error:             %+.2f %%\n', ...
        100 * quality.best_relative_dgd_error);

    fprintf('Best axis misalignment:     %.2f deg\n', ...
        rad2deg(quality.best_misalignment_angle));

    if quality.nominal_passes_threshold

        fprintf('Allowed DGD-error interval: [%+.2f, %+.2f] %%\n', ...
            100 * quality.dgd_error_threshold_interval(1), ...
            100 * quality.dgd_error_threshold_interval(2));

        fprintf('Allowed axis misalignment:  <= %.2f deg\n', ...
            rad2deg(quality.max_misalignment_angle));

    else

        fprintf(['Nominal compensation does not satisfy the selected ', ...
                 'concurrence threshold.\n']);

    end

    fprintf('Quality-region grid fraction: %.3f\n', ...
        quality.quality_grid_fraction);


    % =========================
    % Plotting
    % =========================

    if do_plot
        plot_experiment_5_pmd_compensation_robustness( ...
            results_experiment_5, ...
            do_save);
    end

end

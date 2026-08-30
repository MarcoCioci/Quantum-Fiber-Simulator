function results_experiment_1 = run_experiment_1_single_segment_pmd( ...
        do_summary_plot, do_regime_map, do_save)
% RUN_EXPERIMENT_1_SINGLE_SEGMENT_PMD
% Study single-segment PMD-induced degradation of polarization entanglement.
%
% Objective:
%   Numerically investigate the competition between photon spectral
%   bandwidth and differential group delay (DGD) for a polarization-
%   entangled photon pair.
%
%   The experiment considers the input Bell state
%
%       |Psi+> = (|01> + |10>) / sqrt(2),
%
%   with a single birefringent PMD segment acting on photon A and ideal
%   propagation in arm B.
%
%   Introducing the angular-frequency offset
%
%       Omega_A = omega_A - omega_0,A,
%
%   the carrier-compensated single-segment transformation is
%
%       U_A^res(omega_0,A + Omega_A)
%       =
%       exp[
%           +i/2 * Omega_A * delta_tau_A * sigma_z
%       ].
%
%   The segment parameters are
%
%       delta_phase_A = 0,
%       axis_A         = z_hat,
%       delta_tau_A    = DGD >= 0.
%
%   Arm B undergoes the identity transformation.
%
%   For each pair (sigma_omega, DGD), the simulator:
%
%       1) constructs the spectral offset grid,
%       2) constructs the Gaussian joint spectral probabilities,
%       3) evaluates the frequency-resolved local propagation,
%       4) traces over the unresolved spectrum,
%       5) evaluates state metrics and polarization correlations,
%       6) compares the numerical state with the analytical solution.
%
%   The natural dimensionless PMD parameter is
%
%       xi = sigma_omega * DGD.
%
%   For the Gaussian marginal spectrum used here, the analytical coherence
%   factor is
%
%       g(xi) = exp(-xi^2 / 2).
%
% Input:
%   do_summary_plot - Logical scalar. Generate the one-dimensional summary
%                     plots when true.
%
%   do_regime_map   - Logical scalar. Generate the two-dimensional
%                     bandwidth--DGD regime maps when true.
%
%   do_save         - Logical scalar. Export enabled plots when true.
%
% Output:
%   results_experiment_1 - Structure containing experiment parameters,
%                          numerical states and metrics, analytical
%                          predictions, and numerical errors.
%
% Notes:
%   All physical and numerical parameters defining Experiment 1 are kept
%   inside this runner. main.m controls only experiment execution, plotting,
%   and figure saving.
%
%   The source JSI is chosen as a symmetric uncorrelated Gaussian:
%
%       sigma_sum = sigma_difference
%                 = sqrt(2) * sigma_omega.
%
%   With this convention, each photon has marginal angular-frequency
%   standard deviation sigma_omega.
%
%   The numerical implementation works with frequency offsets Omega rather
%   than absolute optical frequencies omega. Thus, a call to
%   pmd_fiber_unitary(Omega, ...) evaluates the physical transformation
%   U(omega_0 + Omega).
%
%   The explicit frequency-resolved-state pipeline is retained in this
%   first experiment because it provides a transparent numerical reference
%   for the analytical single-segment model.

    % =========================
    % Robustness checks
    % =========================

    if nargin ~= 3
        error( ...
            'run_experiment_1_single_segment_pmd:InvalidNumInputs', ...
            ['Expected exactly 3 input arguments: do_summary_plot, ', ...
             'do_regime_map, do_save.']);
    end

    if ~islogical(do_summary_plot) || ~isscalar(do_summary_plot)
        error( ...
            'run_experiment_1_single_segment_pmd:InvalidDoSummaryPlot', ...
            'do_summary_plot must be a logical scalar.');
    end

    if ~islogical(do_regime_map) || ~isscalar(do_regime_map)
        error( ...
            'run_experiment_1_single_segment_pmd:InvalidDoRegimeMap', ...
            'do_regime_map must be a logical scalar.');
    end

    if ~islogical(do_save) || ~isscalar(do_save)
        error( ...
            'run_experiment_1_single_segment_pmd:InvalidDoSave', ...
            'do_save must be a logical scalar.');
    end


    % =========================
    % Experiment configuration
    % =========================

    % Physical differential group delay.
    %
    % Range:
    %
    %   0 ps <= DGD <= 20 ps.

    dgd_values = ...
        linspace(0, 20e-12, 61);


    % Marginal angular-frequency standard deviation.
    %
    % Range:
    %
    %   0.25e11 rad/s <= sigma_omega <= 2.00e11 rad/s.
    %
    % In ordinary-frequency units:
    %
    %   sigma_f = sigma_omega / (2*pi),
    %
    % corresponding approximately to 4--32 GHz.

    sigma_omega_values = ...
        linspace(0.25e11, 2.00e11, 21).';


    % Number of frequency-offset nodes per arm.
    %
    % An odd number ensures that Omega = 0, corresponding to the carrier
    % frequency, is sampled exactly.

    num_frequency_points = 81;


    % Finite spectral integration interval:
    %
    %   Omega in
    %   [-K sigma_omega, +K sigma_omega].

    max_offset_factor = 6;


    % =========================
    % Fixed physical model
    % =========================

    % Reference input polarization state.

    psi_input = ...
        bell_state('psi_plus');

    rho_input = ...
        state_to_density_matrix(psi_input);


    % Arm A:
    %
    % Carrier-compensated single birefringent segment.

    delta_phase_A = 0;
    axis_A = [0, 0, 1];


    % Arm B:
    %
    % Identity transformation represented through a zero-phase,
    % zero-differential-delay segment.

    delta_phase_B = 0;
    delta_tau_B = 0;
    axis_B = [0, 0, 1];


    % =========================
    % Derived experiment parameters
    % =========================

    dgd_values = ...
        dgd_values(:).';

    sigma_omega_values = ...
        sigma_omega_values(:);

    num_dgd_values = ...
        numel(dgd_values);

    num_sigma_values = ...
        numel(sigma_omega_values);


    % Dimensionless PMD strength:
    %
    %   xi = sigma_omega * DGD.

    normalized_pmd_strength = ...
        sigma_omega_values * dgd_values;


    % Gaussian JSI parameters.
    %
    % For
    %
    %   sigma_sum = sigma_difference = sqrt(2) sigma_omega,
    %
    % the two photon frequencies are uncorrelated and each marginal
    % distribution has standard deviation sigma_omega.

    sigma_sum_values = ...
        sqrt(2) * sigma_omega_values;

    sigma_difference_values = ...
        sqrt(2) * sigma_omega_values;


    % Spectral integration windows.

    max_offset_values = ...
        max_offset_factor * sigma_omega_values;

    delta_omega_values = ...
        zeros(num_sigma_values, 1);


    % =========================
    % Preallocation
    % =========================

    rho_output = ...
        complex(zeros( ...
            4, ...
            4, ...
            num_sigma_values, ...
            num_dgd_values));

    purity = ...
        zeros(num_sigma_values, num_dgd_values);

    fidelity = ...
        zeros(num_sigma_values, num_dgd_values);

    concurrence = ...
        zeros(num_sigma_values, num_dgd_values);

    tangle = ...
        zeros(num_sigma_values, num_dgd_values);

    entanglement_of_formation = ...
        zeros(num_sigma_values, num_dgd_values);

    chsh_max = ...
        zeros(num_sigma_values, num_dgd_values);

    correlation_tensor = ...
        zeros( ...
            3, ...
            3, ...
            num_sigma_values, ...
            num_dgd_values);

    correlation_xx = ...
        zeros(num_sigma_values, num_dgd_values);

    correlation_yy = ...
        zeros(num_sigma_values, num_dgd_values);

    correlation_zz = ...
        zeros(num_sigma_values, num_dgd_values);


    % =========================
    % Experiment information
    % =========================

    fprintf('\n');
    fprintf('============================================\n');
    fprintf(' Experiment 1 — Single-Segment PMD\n');
    fprintf('============================================\n');

    fprintf( ...
        'DGD points:              %d\n', ...
        num_dgd_values);

    fprintf( ...
        'Bandwidth points:        %d\n', ...
        num_sigma_values);

    fprintf( ...
        'Frequency nodes / arm:   %d\n', ...
        num_frequency_points);

    fprintf( ...
        'Spectral window:         +/- %.1f sigma_omega\n', ...
        max_offset_factor);

    fprintf( ...
        'Maximum xi:              %.3f\n\n', ...
        max(normalized_pmd_strength, [], 'all'));


    % =========================
    % Numerical parameter sweep
    % =========================

    for i_sigma = 1:num_sigma_values

        sigma_omega = ...
            sigma_omega_values(i_sigma);

        sigma_sum = ...
            sigma_sum_values(i_sigma);

        sigma_difference = ...
            sigma_difference_values(i_sigma);

        max_offset = ...
            max_offset_values(i_sigma);


        fprintf( ...
            'Bandwidth %2d/%2d: sigma_omega = %.3e rad/s\n', ...
            i_sigma, ...
            num_sigma_values, ...
            sigma_omega);


        % =========================
        % Frequency-offset grid
        % =========================

        [omega_offsets, delta_omega] = ...
            pmd_frequency_grid( ...
                num_frequency_points, ...
                max_offset);

        delta_omega_values(i_sigma) = ...
            delta_omega;


        % =========================
        % Joint spectral weights
        % =========================

        spectral_weights = ...
            pmd_joint_spectral_weights( ...
                omega_offsets, ...
                omega_offsets, ...
                sigma_sum, ...
                sigma_difference);


        % =========================
        % DGD sweep
        % =========================

        for i_dgd = 1:num_dgd_values

            dgd = ...
                dgd_values(i_dgd);


            % With the fixed oriented z axis adopted here, the positive
            % physical DGD is represented directly by
            %
            %   delta_tau_A = DGD.

            delta_tau_A = ...
                dgd;


            % =========================
            % Frequency-resolved state
            % =========================

            frequency_states = ...
                pmd_frequency_resolved_states( ...
                    rho_input, ...
                    omega_offsets, ...
                    omega_offsets, ...
                    delta_phase_A, ...
                    delta_tau_A, ...
                    axis_A, ...
                    delta_phase_B, ...
                    delta_tau_B, ...
                    axis_B);


            % =========================
            % Spectral partial trace
            % =========================

            rho_current = ...
                pmd_spectral_average_state( ...
                    frequency_states, ...
                    spectral_weights);

            rho_output(:, :, i_sigma, i_dgd) = ...
                rho_current;


            % =========================
            % State metrics
            % =========================

            purity(i_sigma, i_dgd) = ...
                compute_purity(rho_current);

            fidelity(i_sigma, i_dgd) = ...
                compute_fidelity( ...
                    rho_current, ...
                    rho_input);

            concurrence(i_sigma, i_dgd) = ...
                compute_concurrence(rho_current);

            tangle(i_sigma, i_dgd) = ...
                compute_tangle(rho_current);

            entanglement_of_formation(i_sigma, i_dgd) = ...
                compute_entanglement_of_formation( ...
                    rho_current);


            % =========================
            % Polarization correlations
            % =========================

            T_current = ...
                compute_correlation_tensor( ...
                    rho_current);

            correlation_tensor(:, :, i_sigma, i_dgd) = ...
                T_current;

            correlation_xx(i_sigma, i_dgd) = ...
                T_current(1, 1);

            correlation_yy(i_sigma, i_dgd) = ...
                T_current(2, 2);

            correlation_zz(i_sigma, i_dgd) = ...
                T_current(3, 3);


            % =========================
            % Maximal CHSH parameter
            % =========================

            chsh_max(i_sigma, i_dgd) = ...
                compute_chsh_max_from_tensor( ...
                    T_current);

        end

    end


    % =========================
    % Analytical reference
    % =========================

    analytics = ...
        analytical_values_experiment_1_single_segment_pmd( ...
            dgd_values, ...
            sigma_omega_values);


    % =========================
    % Numerical errors
    % =========================

    error_struct = struct();

    error_struct.purity = ...
        abs( ...
            purity ...
            - analytics.purity);

    error_struct.fidelity = ...
        abs( ...
            fidelity ...
            - analytics.fidelity);

    error_struct.concurrence = ...
        abs( ...
            concurrence ...
            - analytics.concurrence);

    error_struct.tangle = ...
        abs( ...
            tangle ...
            - analytics.tangle);

    error_struct.entanglement_of_formation = ...
        abs( ...
            entanglement_of_formation ...
            - analytics.entanglement_of_formation);

    error_struct.chsh_max = ...
        abs( ...
            chsh_max ...
            - analytics.chsh_max);

    error_struct.correlation_xx = ...
        abs( ...
            correlation_xx ...
            - analytics.correlations.xx);

    error_struct.correlation_yy = ...
        abs( ...
            correlation_yy ...
            - analytics.correlations.yy);

    error_struct.correlation_zz = ...
        abs( ...
            correlation_zz ...
            - analytics.correlations.zz);


    % =========================
    % Maximum absolute errors
    % =========================

    max_abs_error = struct();

    max_abs_error.purity = ...
        max( ...
            error_struct.purity, ...
            [], ...
            'all');

    max_abs_error.fidelity = ...
        max( ...
            error_struct.fidelity, ...
            [], ...
            'all');

    max_abs_error.concurrence = ...
        max( ...
            error_struct.concurrence, ...
            [], ...
            'all');

    max_abs_error.tangle = ...
        max( ...
            error_struct.tangle, ...
            [], ...
            'all');

    max_abs_error.entanglement_of_formation = ...
        max( ...
            error_struct.entanglement_of_formation, ...
            [], ...
            'all');

    max_abs_error.chsh_max = ...
        max( ...
            error_struct.chsh_max, ...
            [], ...
            'all');

    max_abs_error.correlation_xx = ...
        max( ...
            error_struct.correlation_xx, ...
            [], ...
            'all');

    max_abs_error.correlation_yy = ...
        max( ...
            error_struct.correlation_yy, ...
            [], ...
            'all');

    max_abs_error.correlation_zz = ...
        max( ...
            error_struct.correlation_zz, ...
            [], ...
            'all');


    % =========================
    % Output structure
    % =========================

    results_experiment_1 = struct();


    % -------------------------
    % Parameters
    % -------------------------

    results_experiment_1.parameters = struct();

    results_experiment_1.parameters.dgd_values = ...
        dgd_values;

    results_experiment_1.parameters.sigma_omega_values = ...
        sigma_omega_values;

    results_experiment_1.parameters.sigma_sum_values = ...
        sigma_sum_values;

    results_experiment_1.parameters.sigma_difference_values = ...
        sigma_difference_values;

    results_experiment_1.parameters.normalized_pmd_strength = ...
        normalized_pmd_strength;

    results_experiment_1.parameters.num_frequency_points = ...
        num_frequency_points;

    results_experiment_1.parameters.max_offset_factor = ...
        max_offset_factor;

    results_experiment_1.parameters.max_offset_values = ...
        max_offset_values;

    results_experiment_1.parameters.delta_omega_values = ...
        delta_omega_values;

    results_experiment_1.parameters.delta_phase_A = ...
        delta_phase_A;

    results_experiment_1.parameters.axis_A = ...
        axis_A;

    results_experiment_1.parameters.delta_phase_B = ...
        delta_phase_B;

    results_experiment_1.parameters.delta_tau_B = ...
        delta_tau_B;

    results_experiment_1.parameters.axis_B = ...
        axis_B;


    % -------------------------
    % Input state
    % -------------------------

    results_experiment_1.input = struct();

    results_experiment_1.input.psi = ...
        psi_input;

    results_experiment_1.input.rho = ...
        rho_input;


    % -------------------------
    % Numerical results
    % -------------------------

    results_experiment_1.numerical = struct();

    results_experiment_1.numerical.rho_output = ...
        rho_output;

    results_experiment_1.numerical.purity = ...
        purity;

    results_experiment_1.numerical.fidelity = ...
        fidelity;

    results_experiment_1.numerical.concurrence = ...
        concurrence;

    results_experiment_1.numerical.tangle = ...
        tangle;

    results_experiment_1.numerical.entanglement_of_formation = ...
        entanglement_of_formation;

    results_experiment_1.numerical.chsh_max = ...
        chsh_max;

    results_experiment_1.numerical.correlation_tensor = ...
        correlation_tensor;

    results_experiment_1.numerical.correlations = ...
        struct();

    results_experiment_1.numerical.correlations.xx = ...
        correlation_xx;

    results_experiment_1.numerical.correlations.yy = ...
        correlation_yy;

    results_experiment_1.numerical.correlations.zz = ...
        correlation_zz;


    % -------------------------
    % Analytical reference
    % -------------------------

    results_experiment_1.analytical = ...
        analytics;


    % -------------------------
    % Numerical errors
    % -------------------------

    results_experiment_1.error = ...
        error_struct;

    results_experiment_1.max_abs_error = ...
        max_abs_error;


    % =========================
    % Numerical diagnostics
    % =========================

    fprintf('\nMaximum numerical vs analytical errors:\n');

    fprintf( ...
        '  Purity:                    %.3e\n', ...
        max_abs_error.purity);

    fprintf( ...
        '  Fidelity:                  %.3e\n', ...
        max_abs_error.fidelity);

    fprintf( ...
        '  Concurrence:               %.3e\n', ...
        max_abs_error.concurrence);

    fprintf( ...
        '  Tangle:                    %.3e\n', ...
        max_abs_error.tangle);

    fprintf( ...
        '  Entanglement of formation: %.3e\n', ...
        max_abs_error.entanglement_of_formation);

    fprintf( ...
        '  S_max:                     %.3e\n', ...
        max_abs_error.chsh_max);

    fprintf( ...
        '  T_xx:                      %.3e\n', ...
        max_abs_error.correlation_xx);

    fprintf( ...
        '  T_yy:                      %.3e\n', ...
        max_abs_error.correlation_yy);

    fprintf( ...
        '  T_zz:                      %.3e\n', ...
        max_abs_error.correlation_zz);


    % =========================
    % Plots
    % =========================

    if do_summary_plot

        plot_experiment_1_single_segment_pmd_summary( ...
            results_experiment_1, ...
            do_save);

    end

    if do_regime_map

        plot_experiment_1_single_segment_pmd_regime_map( ...
            results_experiment_1, ...
            do_save);

    end


    % =========================
    % Completion
    % =========================

    fprintf('\nExperiment 1 completed.\n');

end
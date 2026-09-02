function results_experiment_6 = ...
        run_experiment_6_effective_model_comparison( ...
            do_summary_plot, do_regime_map, do_save)
% RUN_EXPERIMENT_6_EFFECTIVE_MODEL_COMPARISON
% Compare frequency-resolved PMD with polarization-only effective models.
%
% Objective:
%   Compare three descriptions of the same canonical one-arm PMD problem:
%
%       1) frequency-resolved physical PMD,
%       2) coherence-matched effective dephasing,
%       3) correlation-matched isotropic local depolarization.
%
%   The input polarization state is
%
%       |Ψ+⟩ = (|01⟩ + |10⟩) / sqrt(2).
%
%   A single birefringent PMD segment acts on arm A with axis z_hat and
%   differential group delay τ, while arm B is ideal. For a Gaussian
%   marginal spectrum with standard deviation σ_ω, the exact residual
%   polarization coherence is
%
%       g(ξ) = exp(-ξ^2 / 2),
%
%   where
%
%       ξ = σ_ω τ.
%
%   The effective dephasing model is calibrated with μ = g and therefore
%   reproduces exactly the reduced polarization state for this canonical
%   configuration.
%
%   The isotropic local-depolarization model is calibrated instead so that
%
%       η = (1-p_A)(1-p_B) = g.
%
%   A symmetric choice is used:
%
%       p_A = p_B = 1 - sqrt(g).
%
%   This makes the isotropic model reproduce the transverse correlation
%   decay c_xx = c_yy = g, while testing whether it reproduces the complete
%   state, especially c_zz, purity, CHSH nonlocality, and concurrence.
%
% Input:
%   do_summary_plot - Logical scalar. If true, generate the Experiment 6
%                     model-comparison summary figure.
%
%   do_regime_map   - Logical scalar. If true, generate the Experiment 6
%                     model/quality regime map.
%
%   do_save         - Logical scalar. If true, save generated figures.
%
% Output:
%   results_experiment_6 - Structure containing:
%
%       .parameters
%       .spectrum
%       .input
%       .analytical
%       .physical_pmd
%       .effective_dephasing
%       .effective_depolarizing
%       .comparison
%       .error
%
% Notes:
%   All physical, numerical, and operational-quality parameters defining
%   Experiment 6 are intentionally selected inside this runner. The
%   top-level main.m therefore controls only experiment selection, plotting,
%   and saving.
%
%   The concurrence threshold C_th is an operational engineering criterion,
%   not a universal entanglement boundary. The fundamental separability
%   boundary remains C = 0.
%
%   Keep concurrence_threshold synchronized with the thesis-wide value used
%   in the other entanglement-quality experiments.


    % =========================
    % Robustness checks
    % =========================

    if nargin ~= 3
        error( ...
            'run_experiment_6_effective_model_comparison:InvalidNumInputs', ...
            ['Expected exactly 3 input arguments: do_summary_plot, ', ...
             'do_regime_map, do_save.']);
    end

    if ~islogical(do_summary_plot) || ~isscalar(do_summary_plot)
        error( ...
            ['run_experiment_6_effective_model_comparison:', ...
             'InvalidDoSummaryPlot'], ...
            'do_summary_plot must be a logical scalar.');
    end

    if ~islogical(do_regime_map) || ~isscalar(do_regime_map)
        error( ...
            ['run_experiment_6_effective_model_comparison:', ...
             'InvalidDoRegimeMap'], ...
            'do_regime_map must be a logical scalar.');
    end

    if ~islogical(do_save) || ~isscalar(do_save)
        error( ...
            'run_experiment_6_effective_model_comparison:InvalidDoSave', ...
            'do_save must be a logical scalar.');
    end


    % =========================
    % Experiment configuration
    % =========================

    % Marginal angular-frequency standard deviation of each photon.
    sigma_omega = ...
        1.0e11;  % rad/s

    % Dimensionless PMD strength:
    %
    %   xi = sigma_omega * DGD.
    %
    % xi = 4 reaches a regime where the exact Gaussian coherence is already
    % strongly suppressed.
    xi_values = ...
        linspace(0, 4, 61);

    dgd_values = ...
        xi_values / sigma_omega;

    % Spectral discretization.
    %
    % An odd node count samples Omega = 0 exactly.
    num_frequency_points = ...
        81;

    max_offset_factor = ...
        6.0;

    % Operational entanglement-quality threshold.
    %
    % IMPORTANT:
    %   This value is a thesis-level engineering criterion and should be
    %   kept identical in all experiments that use concurrence quality
    %   classification.
    concurrence_threshold = ...
        0.90;


    % =========================
    % Input normalization
    % =========================

    xi_values = ...
        xi_values(:).';

    dgd_values = ...
        dgd_values(:).';

    num_dgd_values = ...
        numel(dgd_values);


    % =========================
    % Input polarization state
    % =========================

    psi_input = ...
        bell_state('psi_plus');

    rho_input = ...
        state_to_density_matrix(psi_input);


    % =========================
    % Physical PMD configuration
    % =========================

    % Arm A contains one z-oriented birefringent segment.
    delta_phase_A = ...
        0;

    axis_A = ...
        [0, 0, 1];

    % Arm B is ideal.
    delta_phase_B = ...
        0;

    delta_tau_B = ...
        0;

    axis_B = ...
        [0, 0, 1];


    % =========================
    % Frequency grid
    % =========================

    max_frequency_offset = ...
        max_offset_factor * sigma_omega;

    [omega_offsets, delta_omega] = ...
        pmd_frequency_grid( ...
            num_frequency_points, ...
            max_frequency_offset);


    % =========================
    % Factorized Gaussian spectrum
    % =========================

    % For equal marginal standard deviations sigma_omega and zero spectral
    % correlation:
    %
    %   sigma_sum        = sqrt(2) * sigma_omega,
    %   sigma_difference = sqrt(2) * sigma_omega.

    sigma_sum = ...
        sqrt(2) * sigma_omega;

    sigma_difference = ...
        sqrt(2) * sigma_omega;

    spectral_weights = ...
        pmd_joint_spectral_weights( ...
            omega_offsets, ...
            omega_offsets, ...
            sigma_sum, ...
            sigma_difference);


    % =========================
    % Analytical reference
    % =========================

    analytics = ...
        analytical_values_experiment_6_effective_model_comparison( ...
            xi_values, ...
            dgd_values, ...
            sigma_omega, ...
            concurrence_threshold);


    % =========================
    % Preallocation
    % =========================

    physical_pmd = ...
        initialize_model_results(num_dgd_values);

    effective_dephasing = ...
        initialize_model_results(num_dgd_values);

    effective_depolarizing = ...
        initialize_model_results(num_dgd_values);

    effective_depolarizing.p_A = ...
        analytics.effective_depolarizing.p_symmetric;

    effective_depolarizing.p_B = ...
        analytics.effective_depolarizing.p_symmetric;

    effective_depolarizing.eta = ...
        analytics.coherence;


    % =========================
    % Console experiment header
    % =========================

    fprintf('\n');
    fprintf('============================================\n');
    fprintf(' Experiment 6 — Effective Model Comparison\n');
    fprintf(' Physical PMD vs effective channels\n');
    fprintf('============================================\n');

    fprintf('DGD points:              %d\n', ...
        num_dgd_values);

    fprintf('Frequency nodes / arm:   %d\n', ...
        num_frequency_points);

    fprintf('Marginal sigma_omega:    %.3e rad/s\n', ...
        sigma_omega);

    fprintf('Spectral window:         +/- %.1f sigma_omega\n', ...
        max_offset_factor);

    fprintf('Maximum xi:              %.3f\n', ...
        max(xi_values));

    fprintf('Concurrence threshold:   %.3f\n', ...
        concurrence_threshold);

    fprintf('\n');


    % =========================
    % Numerical model sweep
    % =========================

    for i_dgd = 1:num_dgd_values

        dgd = ...
            dgd_values(i_dgd);

        g = ...
            analytics.coherence(i_dgd);

        p_symmetric = ...
            analytics.effective_depolarizing.p_symmetric(i_dgd);


        % =========================
        % Progress monitoring
        % =========================

        fprintf( ...
            'Point %2d/%2d: DGD = %.3e s, xi = %.3f, g = %.6f\n', ...
            i_dgd, ...
            num_dgd_values, ...
            dgd, ...
            xi_values(i_dgd), ...
            g);


        % =========================
        % Model 1: physical PMD
        % =========================

        frequency_states = ...
            pmd_frequency_resolved_states( ...
                rho_input, ...
                omega_offsets, ...
                omega_offsets, ...
                delta_phase_A, ...
                dgd, ...
                axis_A, ...
                delta_phase_B, ...
                delta_tau_B, ...
                axis_B);

        rho_physical = ...
            pmd_spectral_average_state( ...
                frequency_states, ...
                spectral_weights);

        rho_physical = ...
            (rho_physical + rho_physical') / 2;

        diagnostics = ...
            evaluate_state(rho_physical, rho_input);

        physical_pmd = ...
            store_state_diagnostics( ...
                physical_pmd, ...
                i_dgd, ...
                rho_physical, ...
                diagnostics);


        % =========================
        % Model 2: matched dephasing
        % =========================

        % The canonical one-arm PMD state has populations fixed in |01> and
        % |10>, while its coherence is multiplied by g.

        rho_dephasing = ...
            build_matched_dephasing_state( ...
                rho_input, ...
                g);

        diagnostics = ...
            evaluate_state(rho_dephasing, rho_input);

        effective_dephasing = ...
            store_state_diagnostics( ...
                effective_dephasing, ...
                i_dgd, ...
                rho_dephasing, ...
                diagnostics);


        % =========================
        % Model 3: isotropic depolarization
        % =========================

        % Match the two-body correlation-survival factor:
        %
        %   eta = (1-p_A)(1-p_B) = g.
        %
        % The symmetric calibration gives
        %
        %   p_A = p_B = 1 - sqrt(g).

        rho_depolarizing = ...
            two_arm_depolarizing_channel( ...
                rho_input, ...
                p_symmetric, ...
                p_symmetric);

        diagnostics = ...
            evaluate_state(rho_depolarizing, rho_input);

        effective_depolarizing = ...
            store_state_diagnostics( ...
                effective_depolarizing, ...
                i_dgd, ...
                rho_depolarizing, ...
                diagnostics);

    end


    % =========================
    % Concurrence quality analysis
    % =========================

    physical_pmd.quality = ...
        build_quality_analysis( ...
            physical_pmd.concurrence, ...
            xi_values, ...
            dgd_values, ...
            concurrence_threshold);

    effective_dephasing.quality = ...
        build_quality_analysis( ...
            effective_dephasing.concurrence, ...
            xi_values, ...
            dgd_values, ...
            concurrence_threshold);

    effective_depolarizing.quality = ...
        build_quality_analysis( ...
            effective_depolarizing.concurrence, ...
            xi_values, ...
            dgd_values, ...
            concurrence_threshold);


    % =========================
    % Analytical errors
    % =========================

    error_struct = struct();

    error_struct.physical_pmd = ...
        compare_model_to_analytics( ...
            physical_pmd, ...
            analytics.physical_pmd);

    error_struct.effective_dephasing = ...
        compare_model_to_analytics( ...
            effective_dephasing, ...
            analytics.effective_dephasing);

    error_struct.effective_depolarizing = ...
        compare_model_to_analytics( ...
            effective_depolarizing, ...
            analytics.effective_depolarizing);


    % =========================
    % Inter-model comparison
    % =========================

    comparison = struct();

    comparison.physical_vs_dephasing = ...
        compare_models( ...
            physical_pmd, ...
            effective_dephasing);

    comparison.physical_vs_depolarizing = ...
        compare_models( ...
            physical_pmd, ...
            effective_depolarizing);


    % =========================
    % Results structure
    % =========================

    results_experiment_6 = struct();

    results_experiment_6.experiment_name = ...
        'Experiment 6 — Effective Model Comparison';

    results_experiment_6.model_name = ...
        'physical_pmd_vs_effective_polarization_channels';

    results_experiment_6.parameters = struct();

    results_experiment_6.parameters.sigma_omega = ...
        sigma_omega;

    results_experiment_6.parameters.xi_values = ...
        xi_values;

    results_experiment_6.parameters.dgd_values = ...
        dgd_values;

    results_experiment_6.parameters.num_frequency_points = ...
        num_frequency_points;

    results_experiment_6.parameters.max_offset_factor = ...
        max_offset_factor;

    results_experiment_6.parameters.concurrence_threshold = ...
        concurrence_threshold;

    results_experiment_6.parameters.xi_threshold_physical = ...
        analytics.thresholds.xi_physical;

    results_experiment_6.parameters.xi_threshold_dephasing = ...
        analytics.thresholds.xi_dephasing;

    results_experiment_6.parameters.xi_threshold_depolarizing = ...
        analytics.thresholds.xi_depolarizing;

    results_experiment_6.parameters.xi_entanglement_death_depolarizing = ...
        analytics.thresholds.xi_entanglement_death_depolarizing;

    results_experiment_6.parameters.dgd_threshold_physical = ...
        analytics.thresholds.dgd_physical;

    results_experiment_6.parameters.dgd_threshold_dephasing = ...
        analytics.thresholds.dgd_dephasing;

    results_experiment_6.parameters.dgd_threshold_depolarizing = ...
        analytics.thresholds.dgd_depolarizing;

    results_experiment_6.spectrum = struct();

    results_experiment_6.spectrum.omega_offsets = ...
        omega_offsets;

    results_experiment_6.spectrum.delta_omega = ...
        delta_omega;

    results_experiment_6.spectrum.sigma_sum = ...
        sigma_sum;

    results_experiment_6.spectrum.sigma_difference = ...
        sigma_difference;

    results_experiment_6.spectrum.spectral_weights = ...
        spectral_weights;

    results_experiment_6.input = struct();

    results_experiment_6.input.psi = ...
        psi_input;

    results_experiment_6.input.rho = ...
        rho_input;

    results_experiment_6.analytical = ...
        analytics;

    results_experiment_6.physical_pmd = ...
        physical_pmd;

    results_experiment_6.effective_dephasing = ...
        effective_dephasing;

    results_experiment_6.effective_depolarizing = ...
        effective_depolarizing;

    results_experiment_6.comparison = ...
        comparison;

    results_experiment_6.error = ...
        error_struct;


    % =========================
    % Console summary
    % =========================

    fprintf('\n');
    fprintf('Concurrence-quality crossings\n');
    fprintf('-----------------------------\n');

    fprintf('Physical PMD:             xi = %.6f, DGD = %.3f ps\n', ...
        analytics.thresholds.xi_physical, ...
        analytics.thresholds.dgd_physical * 1e12);

    fprintf('Matched dephasing:        xi = %.6f, DGD = %.3f ps\n', ...
        analytics.thresholds.xi_dephasing, ...
        analytics.thresholds.dgd_dephasing * 1e12);

    fprintf('Isotropic depolarization: xi = %.6f, DGD = %.3f ps\n', ...
        analytics.thresholds.xi_depolarizing, ...
        analytics.thresholds.dgd_depolarizing * 1e12);

    fprintf('Depolarizing C = 0:       xi = %.6f, DGD = %.3f ps\n', ...
        analytics.thresholds.xi_entanglement_death_depolarizing, ...
        analytics.thresholds.dgd_entanglement_death_depolarizing * 1e12);

    fprintf('\n');
    fprintf('Maximum model discrepancies\n');
    fprintf('---------------------------\n');

    fprintf('Physical vs dephasing, rho Frobenius:    %.3e\n', ...
        comparison.physical_vs_dephasing.max_state_frobenius);

    fprintf('Physical vs depolarizing, rho Frobenius: %.3e\n', ...
        comparison.physical_vs_depolarizing.max_state_frobenius);

    fprintf('Physical vs dephasing, concurrence:      %.3e\n', ...
        comparison.physical_vs_dephasing.max_concurrence);

    fprintf('Physical vs depolarizing, concurrence:   %.3e\n', ...
        comparison.physical_vs_depolarizing.max_concurrence);

    fprintf('\n');


    % =========================
    % Plotting
    % =========================

    if do_summary_plot

        plot_experiment_6_effective_model_comparison_summary( ...
            results_experiment_6, ...
            do_save);

    end

    if do_regime_map

        plot_experiment_6_effective_model_comparison_regime_map( ...
            results_experiment_6, ...
            do_save);

    end

end


% ========================================================
% Local helper: initialize model result storage
% ========================================================

function model = initialize_model_results(num_points)
% INITIALIZE_MODEL_RESULTS  Allocate one Experiment 6 model result structure.

    model = struct();

    model.rho = ...
        complex(zeros(4, 4, num_points));

    model.purity = ...
        zeros(1, num_points);

    model.fidelity = ...
        zeros(1, num_points);

    model.concurrence = ...
        zeros(1, num_points);

    model.tangle = ...
        zeros(1, num_points);

    model.entanglement_of_formation = ...
        zeros(1, num_points);

    model.chsh_max = ...
        zeros(1, num_points);

    model.correlation_tensor = ...
        zeros(3, 3, num_points);

    model.c_xx = ...
        zeros(1, num_points);

    model.c_yy = ...
        zeros(1, num_points);

    model.c_zz = ...
        zeros(1, num_points);

end


% ========================================================
% Local helper: evaluate one density operator
% ========================================================

function diagnostics = evaluate_state(rho, rho_reference)
% EVALUATE_STATE  Compute the Experiment 6 diagnostics for one state.

    diagnostics = struct();

    diagnostics.purity = ...
        compute_purity(rho);

    diagnostics.fidelity = ...
        compute_fidelity( ...
            rho, ...
            rho_reference);

    diagnostics.concurrence = ...
        compute_concurrence(rho);

    diagnostics.tangle = ...
        compute_tangle(rho);

    diagnostics.entanglement_of_formation = ...
        compute_entanglement_of_formation(rho);

    diagnostics.correlation_tensor = ...
        compute_correlation_tensor(rho);

    diagnostics.chsh_max = ...
        compute_chsh_max_from_tensor( ...
            diagnostics.correlation_tensor);

end


% ========================================================
% Local helper: store one state
% ========================================================

function model = store_state_diagnostics( ...
        model, index, rho, diagnostics)
% STORE_STATE_DIAGNOSTICS  Store one state and all associated diagnostics.

    model.rho(:, :, index) = ...
        rho;

    model.purity(index) = ...
        diagnostics.purity;

    model.fidelity(index) = ...
        diagnostics.fidelity;

    model.concurrence(index) = ...
        diagnostics.concurrence;

    model.tangle(index) = ...
        diagnostics.tangle;

    model.entanglement_of_formation(index) = ...
        diagnostics.entanglement_of_formation;

    model.chsh_max(index) = ...
        diagnostics.chsh_max;

    model.correlation_tensor(:, :, index) = ...
        diagnostics.correlation_tensor;

    model.c_xx(index) = ...
        diagnostics.correlation_tensor(1, 1);

    model.c_yy(index) = ...
        diagnostics.correlation_tensor(2, 2);

    model.c_zz(index) = ...
        diagnostics.correlation_tensor(3, 3);

end


% ========================================================
% Local helper: matched dephasing state
% ========================================================

function rho_out = build_matched_dephasing_state(rho_input, coherence)
% BUILD_MATCHED_DEPHASING_STATE
% Build the canonical |Ψ+⟩ dephased state with real coherence g.
%
% Objective:
%   Retain the |01⟩ and |10⟩ populations of the input Bell state while
%   multiplying the corresponding off-diagonal coherences by g.
%
% Input:
%   rho_input - 4x4 |Ψ+⟩ density operator
%   coherence - Real scalar g in [0,1]
%
% Output:
%   rho_out   - 4x4 coherence-matched effective state

    rho_out = ...
        rho_input;

    rho_out(2, 3) = ...
        coherence * rho_input(2, 3);

    rho_out(3, 2) = ...
        coherence * rho_input(3, 2);

    rho_out = ...
        (rho_out + rho_out') / 2;

end


% ========================================================
% Local helper: concurrence quality
% ========================================================

function quality = build_quality_analysis( ...
        concurrence, xi_values, dgd_values, threshold)
% BUILD_QUALITY_ANALYSIS  Classify concurrence against an operational threshold.
%
% Objective:
%   Identify where a model satisfies
%
%       C >= C_th
%
%   and record the first sampled point below the selected threshold.
%
% Input:
%   concurrence - Concurrence values
%   xi_values   - Dimensionless PMD values
%   dgd_values  - Physical DGD values [s]
%   threshold   - Operational concurrence threshold
%
% Output:
%   quality     - Structure containing pass mask, margin, and first sampled
%                 threshold failure

    quality = struct();

    quality.threshold = ...
        threshold;

    quality.margin = ...
        concurrence - threshold;

    quality.meets_threshold = ...
        concurrence >= threshold;

    first_below_index = ...
        find(~quality.meets_threshold, 1, 'first');

    quality.first_below_index = ...
        first_below_index;

    if isempty(first_below_index)

        quality.first_below_xi = ...
            NaN;

        quality.first_below_dgd = ...
            NaN;

    else

        quality.first_below_xi = ...
            xi_values(first_below_index);

        quality.first_below_dgd = ...
            dgd_values(first_below_index);

    end

end


% ========================================================
% Local helper: analytical error
% ========================================================

function error_model = compare_model_to_analytics( ...
        numerical_model, analytical_model)
% COMPARE_MODEL_TO_ANALYTICS  Compute scalar diagnostic errors.

    error_model = struct();

    fields = { ...
        'purity', ...
        'fidelity', ...
        'concurrence', ...
        'chsh_max', ...
        'c_xx', ...
        'c_yy', ...
        'c_zz' ...
    };

    for i_field = 1:numel(fields)

        field_name = ...
            fields{i_field};

        values = ...
            abs( ...
                numerical_model.(field_name) ...
                - analytical_model.(field_name));

        error_model.(field_name) = ...
            values;

        error_model.(['max_', field_name]) = ...
            max(values, [], 'all');

    end

end


% ========================================================
% Local helper: inter-model comparison
% ========================================================

function comparison = compare_models(model_A, model_B)
% COMPARE_MODELS  Quantify discrepancies between two state descriptions.

    num_points = ...
        size(model_A.rho, 3);

    state_frobenius = ...
        zeros(1, num_points);

    for i_point = 1:num_points

        state_frobenius(i_point) = ...
            norm( ...
                model_A.rho(:, :, i_point) ...
                - model_B.rho(:, :, i_point), ...
                'fro');

    end

    comparison = struct();

    comparison.state_frobenius = ...
        state_frobenius;

    comparison.concurrence = ...
        abs(model_A.concurrence - model_B.concurrence);

    comparison.purity = ...
        abs(model_A.purity - model_B.purity);

    comparison.fidelity = ...
        abs(model_A.fidelity - model_B.fidelity);

    comparison.chsh_max = ...
        abs(model_A.chsh_max - model_B.chsh_max);

    comparison.c_zz = ...
        abs(model_A.c_zz - model_B.c_zz);

    comparison.max_state_frobenius = ...
        max(comparison.state_frobenius, [], 'all');

    comparison.max_concurrence = ...
        max(comparison.concurrence, [], 'all');

    comparison.max_purity = ...
        max(comparison.purity, [], 'all');

    comparison.max_fidelity = ...
        max(comparison.fidelity, [], 'all');

    comparison.max_chsh_max = ...
        max(comparison.chsh_max, [], 'all');

    comparison.max_c_zz = ...
        max(comparison.c_zz, [], 'all');

end

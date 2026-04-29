function results_experiment_4 = run_experiment_4_chsh_nonlocality(theta_values, p_values, do_plot_summary, do_plot_bloch, chsh_axes)
% RUN_EXPERIMENT_4_CHSH_NONLOCALITY  Study CHSH nonlocality under phase evolution and depolarization.
%
% Objective:
%   Run Experiment 4 by evaluating the CHSH parameter for two state families:
%
%       1. Phase-evolved Bell states:
%
%              |psi(θ)> = (|01> + exp(i * θ) |10>) / sqrt(2)
%
%       2. Depolarized Bell states:
%
%              rho(p) = (1 - p) rho_0 + (p / 4) I_4
%
%   The experiment compares:
%
%       S_fixed - CHSH value for fixed user-defined measurement axes
%       S_max   - maximal CHSH value obtained from the correlation tensor
%
% Input:
%   theta_values    - optional real numeric vector containing θ values in radians.
%                     If omitted or empty, a default uniform grid with N = 361
%                     samples in [0, 2π] is used.
%
%   p_values        - optional real numeric vector containing depolarizing
%                     probabilities. If omitted or empty, a default uniform
%                     grid with N = 201 samples in [0, 1] is used.
%
%   do_plot_summary - optional logical scalar controlling the CHSH summary plot.
%                     Default value: false.
%
%   do_plot_bloch   - optional logical scalar controlling the Bloch axes plot.
%                     Default value: false.
%
%   chsh_axes       - optional structure containing fixed CHSH measurement axes:
%
%                         .a1, .a2, .b1, .b2
%
%                     Each field must be a real numeric 3x1 or 1x3 vector.
%                     The vectors are normalized internally.
%
% Output:
%   results_experiment_4 - structure containing:
%
%       .experiment_name
%       .reference_state_label
%       .model_name
%       .chsh_axes
%       .phase
%       .depolarization
%
% Notes:
%   Supported calls:
%
%       run_experiment_4_chsh_nonlocality()
%       run_experiment_4_chsh_nonlocality(do_plot_summary)
%       run_experiment_4_chsh_nonlocality(theta_values, p_values)
%       run_experiment_4_chsh_nonlocality(theta_values, p_values, do_plot_summary)
%       run_experiment_4_chsh_nonlocality(theta_values, p_values, do_plot_summary, do_plot_bloch)
%       run_experiment_4_chsh_nonlocality(theta_values, p_values, do_plot_summary, do_plot_bloch, chsh_axes)
%
%   Empty inputs [] trigger default values.
%
%   If chsh_axes is omitted or empty, the default axes are optimal for |psi+>
%   at θ = 0, where T = diag(1, 1, -1).

    % =========================
    % Default input handling
    % =========================

    default_theta_values = linspace(0, 2*pi, 361);
    default_p_values = linspace(0, 1, 201);

    if nargin == 0
        theta_values = default_theta_values;
        p_values = default_p_values;
        do_plot_summary = false;
        do_plot_bloch = false;
        chsh_axes = default_chsh_axes_psi_plus();

        fprintf('No inputs provided, sampling θ with N = 361 uniformly in [0,2π].\n');
        fprintf('No inputs provided, sampling p with N = 201 uniformly in [0,1].\n');
        fprintf('No CHSH axes provided, using default axes optimal for |psi+> at θ = 0.\n');

    elseif nargin == 1
        if islogical(theta_values) && isscalar(theta_values)
            do_plot_summary = theta_values;
            theta_values = default_theta_values;
            p_values = default_p_values;
            do_plot_bloch = false;
            chsh_axes = default_chsh_axes_psi_plus();

            fprintf('No θ values provided, sampling θ with N = 361 uniformly in [0,2π].\n');
            fprintf('No p values provided, sampling p with N = 201 uniformly in [0,1].\n');
            fprintf('No CHSH axes provided, using default axes optimal for |psi+> at θ = 0.\n');
        else
            p_values = default_p_values;
            do_plot_summary = false;
            do_plot_bloch = false;
            chsh_axes = default_chsh_axes_psi_plus();

            fprintf('No p values provided, sampling p with N = 201 uniformly in [0,1].\n');
            fprintf('No CHSH axes provided, using default axes optimal for |psi+> at θ = 0.\n');
        end

    elseif nargin == 2
        do_plot_summary = false;
        do_plot_bloch = false;
        chsh_axes = default_chsh_axes_psi_plus();

        fprintf('No CHSH axes provided, using default axes optimal for |psi+> at θ = 0.\n');

    elseif nargin == 3
        do_plot_bloch = false;
        chsh_axes = default_chsh_axes_psi_plus();

        fprintf('No CHSH axes provided, using default axes optimal for |psi+> at θ = 0.\n');

    elseif nargin == 4
        chsh_axes = default_chsh_axes_psi_plus();

        fprintf('No CHSH axes provided, using default axes optimal for |psi+> at θ = 0.\n');

    elseif nargin == 5
        % keep provided inputs

    else
        error('run_experiment_4_chsh_nonlocality:InvalidNumInputs', ...
              'Expected zero, one, two, three, four, or five input arguments.');
    end

    if isempty(theta_values)
        theta_values = default_theta_values;
        fprintf('Empty θ values provided, sampling θ with N = 361 uniformly in [0,2π].\n');
    end

    if isempty(p_values)
        p_values = default_p_values;
        fprintf('Empty p values provided, sampling p with N = 201 uniformly in [0,1].\n');
    end

    if isempty(do_plot_summary)
        do_plot_summary = false;
        fprintf('Empty do_plot_summary provided, using false.\n');
    end

    if isempty(do_plot_bloch)
        do_plot_bloch = false;
        fprintf('Empty do_plot_bloch provided, using false.\n');
    end

    if isempty(chsh_axes)
        chsh_axes = default_chsh_axes_psi_plus();
        fprintf('Empty CHSH axes provided, using default axes optimal for |psi+> at θ = 0.\n');
    end


    % =========================
    % Robustness checks
    % =========================

    if ~isnumeric(theta_values) || ~isvector(theta_values) || ~isreal(theta_values)
        error('run_experiment_4_chsh_nonlocality:InvalidThetaValues', ...
              'theta_values must be a real numeric vector.');
    end

    if any(~isfinite(theta_values))
        error('run_experiment_4_chsh_nonlocality:NonFiniteThetaValues', ...
              'theta_values must contain only finite values.');
    end

    if ~isnumeric(p_values) || ~isvector(p_values) || ~isreal(p_values)
        error('run_experiment_4_chsh_nonlocality:InvalidPValues', ...
              'p_values must be a real numeric vector.');
    end

    if any(~isfinite(p_values))
        error('run_experiment_4_chsh_nonlocality:NonFinitePValues', ...
              'p_values must contain only finite values.');
    end

    if any(p_values < 0 | p_values > 1)
        error('run_experiment_4_chsh_nonlocality:PValuesOutOfRange', ...
              'All p_values entries must satisfy 0 <= p <= 1.');
    end

    if ~islogical(do_plot_summary) || ~isscalar(do_plot_summary)
        error('run_experiment_4_chsh_nonlocality:InvalidSummaryPlotFlag', ...
              'do_plot_summary must be a logical scalar.');
    end

    if ~islogical(do_plot_bloch) || ~isscalar(do_plot_bloch)
        error('run_experiment_4_chsh_nonlocality:InvalidBlochPlotFlag', ...
              'do_plot_bloch must be a logical scalar.');
    end

    chsh_axes = validate_and_normalize_chsh_axes(chsh_axes);

    theta_values = theta_values(:).';
    p_values = p_values(:).';


    % =========================
    % Main computation
    % =========================

    psi_ref = bell_state('psi_plus');
    rho_ref = state_to_density_matrix(psi_ref);

    results_experiment_4.experiment_name = 'Experiment 4 - CHSH Nonlocality';
    results_experiment_4.reference_state_label = 'psi_plus';
    results_experiment_4.model_name = 'phase_and_depolarization_chsh_diagnostic';
    results_experiment_4.chsh_axes = chsh_axes;

    a1 = chsh_axes.a1;
    a2 = chsh_axes.a2;
    b1 = chsh_axes.b1;
    b2 = chsh_axes.b2;

    S_classical_bound = 2;
    S_tsirelson_bound = 2 * sqrt(2);


    % =========================
    % Phase sweep
    % =========================

    N_theta = numel(theta_values);

    results_experiment_4.phase.theta_values = theta_values;
    results_experiment_4.phase.S_fixed = zeros(1, N_theta);
    results_experiment_4.phase.S_max = zeros(1, N_theta);

    for idx = 1:N_theta
        theta = theta_values(idx);

        U_A = phase_unitary(theta);
        U_B = eye(2);

        psi_theta = apply_unitary(U_A, U_B, psi_ref);
        rho_theta = state_to_density_matrix(psi_theta);

        T_theta = compute_correlation_tensor(rho_theta);

        results_experiment_4.phase.S_fixed(idx) = real( ...
            compute_chsh_from_tensor(T_theta, a1, a2, b1, b2));

        results_experiment_4.phase.S_max(idx) = real( ...
            compute_chsh_max_from_tensor(T_theta));
    end

    results_experiment_4.phase.S_classical_bound = S_classical_bound;
    results_experiment_4.phase.S_tsirelson_bound = S_tsirelson_bound;

    results_experiment_4.phase.analytical.S_max = ...
        S_tsirelson_bound * ones(1, N_theta);


    % =========================
    % Depolarization sweep
    % =========================

    N_p = numel(p_values);

    results_experiment_4.depolarization.p_values = p_values;
    results_experiment_4.depolarization.S_fixed = zeros(1, N_p);
    results_experiment_4.depolarization.S_max = zeros(1, N_p);

    for idx = 1:N_p
        p = p_values(idx);

        rho_p = global_depolarizing_channel(rho_ref, p);
        T_p = compute_correlation_tensor(rho_p);

        results_experiment_4.depolarization.S_fixed(idx) = real( ...
            compute_chsh_from_tensor(T_p, a1, a2, b1, b2));

        results_experiment_4.depolarization.S_max(idx) = real( ...
            compute_chsh_max_from_tensor(T_p));
    end

    results_experiment_4.depolarization.S_classical_bound = S_classical_bound;
    results_experiment_4.depolarization.S_tsirelson_bound = S_tsirelson_bound;
    results_experiment_4.depolarization.p_chsh_threshold = 1 - 1 / sqrt(2);

    results_experiment_4.depolarization.analytical.S_max = ...
        S_tsirelson_bound * (1 - p_values);


    % =========================
    % Console monitoring
    % =========================

    phase_Smax_error = abs( ...
        results_experiment_4.phase.S_max - ...
        results_experiment_4.phase.analytical.S_max);

    depol_Smax_error = abs( ...
        results_experiment_4.depolarization.S_max - ...
        results_experiment_4.depolarization.analytical.S_max);

    fprintf('\n');
    fprintf('==========================================\n');
    fprintf('Experiment 4 - CHSH Nonlocality Summary\n');
    fprintf('Monitoring summary\n');
    fprintf('==========================================\n');

    fprintf('theta sweep       : N = %d, min = %.6f, max = %.6f\n', ...
        N_theta, min(theta_values), max(theta_values));

    fprintf('p sweep           : N = %d, min = %.6f, max = %.6f\n', ...
        N_p, min(p_values), max(p_values));

    fprintf('a1 axis           : [%.6f, %.6f, %.6f]\n', a1(1), a1(2), a1(3));
    fprintf('a2 axis           : [%.6f, %.6f, %.6f]\n', a2(1), a2(2), a2(3));
    fprintf('b1 axis           : [%.6f, %.6f, %.6f]\n', b1(1), b1(2), b1(3));
    fprintf('b2 axis           : [%.6f, %.6f, %.6f]\n', b2(1), b2(2), b2(3));

    fprintf('S_fixed phase min : %.6f\n', min(results_experiment_4.phase.S_fixed));
    fprintf('S_fixed phase max : %.6f\n', max(results_experiment_4.phase.S_fixed));
    fprintf('S_max phase |err| : %.3e\n', max(phase_Smax_error));

    fprintf('S_fixed depol min : %.6f\n', min(results_experiment_4.depolarization.S_fixed));
    fprintf('S_fixed depol max : %.6f\n', max(results_experiment_4.depolarization.S_fixed));
    fprintf('S_max depol |err| : %.3e\n', max(depol_Smax_error));

    fprintf('classical bound   : %.6f\n', S_classical_bound);
    fprintf('Tsirelson bound   : %.6f\n', S_tsirelson_bound);
    fprintf('p_CHSH threshold  : %.6f\n', ...
        results_experiment_4.depolarization.p_chsh_threshold);

    fprintf('summary plot      : %s\n', logical_to_status(do_plot_summary));
    fprintf('Bloch axes plot   : %s\n', logical_to_status(do_plot_bloch));


    % =========================
    % Optional plotting
    % =========================

    if do_plot_summary
        plot_chsh_nonlocality_summary(results_experiment_4);
    end

    if do_plot_bloch
        plot_chsh_axes_bloch(results_experiment_4);
    end

end


function chsh_axes = default_chsh_axes_psi_plus()
% DEFAULT_CHSH_AXES_PSI_PLUS  Return CHSH axes optimal for |psi+> at θ = 0.

    x_axis = [1; 0; 0];
    y_axis = [0; 1; 0];

    chsh_axes.a1 = x_axis;
    chsh_axes.a2 = y_axis;
    chsh_axes.b1 = (x_axis + y_axis) / sqrt(2);
    chsh_axes.b2 = (x_axis - y_axis) / sqrt(2);

end


function chsh_axes = validate_and_normalize_chsh_axes(chsh_axes)
% VALIDATE_AND_NORMALIZE_CHSH_AXES  Validate and normalize fixed CHSH axes.

    if ~isstruct(chsh_axes)
        error('run_experiment_4_chsh_nonlocality:InvalidAxesType', ...
              'chsh_axes must be a structure.');
    end

    required_fields = {'a1', 'a2', 'b1', 'b2'};

    for idx = 1:numel(required_fields)
        field_name = required_fields{idx};

        if ~isfield(chsh_axes, field_name)
            error('run_experiment_4_chsh_nonlocality:MissingAxisField', ...
                  'chsh_axes must contain the field "%s".', field_name);
        end

        axis_value = chsh_axes.(field_name);

        if ~isnumeric(axis_value) || ~isvector(axis_value) || ~isreal(axis_value)
            error('run_experiment_4_chsh_nonlocality:InvalidAxisValue', ...
                  'chsh_axes.%s must be a real numeric vector.', field_name);
        end

        if numel(axis_value) ~= 3
            error('run_experiment_4_chsh_nonlocality:InvalidAxisLength', ...
                  'chsh_axes.%s must contain exactly 3 entries.', field_name);
        end

        if any(~isfinite(axis_value))
            error('run_experiment_4_chsh_nonlocality:NonFiniteAxisValue', ...
                  'chsh_axes.%s must contain only finite values.', field_name);
        end

        axis_value = axis_value(:);
        axis_norm = norm(axis_value);

        if axis_norm == 0
            error('run_experiment_4_chsh_nonlocality:ZeroAxisVector', ...
                  'chsh_axes.%s must not be the zero vector.', field_name);
        end

        chsh_axes.(field_name) = axis_value / axis_norm;
    end

end


function status_text = logical_to_status(flag)
% LOGICAL_TO_STATUS  Convert logical flag to compact console text.

    if flag
        status_text = 'enabled';
    else
        status_text = 'disabled';
    end

end
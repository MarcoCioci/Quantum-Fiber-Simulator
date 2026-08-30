function plot_single_arm_pmd_tensor_snapshot(results_experiment_6, do_save)
% PLOT_SINGLE_ARM_PMD_TENSOR_SNAPSHOT
% Plot numerical correlation tensors and absolute validation errors.

    if nargin < 1 || nargin > 2
        error('plot_single_arm_pmd_tensor_snapshot:InvalidNumInputs', ...
            'Expected 1 or 2 input arguments.');
    end

    if nargin < 2 || isempty(do_save)
        do_save = false;
    end

    if ~islogical(do_save) || ~isscalar(do_save)
        error('plot_single_arm_pmd_tensor_snapshot:InvalidDoSave', ...
            'do_save must be a logical scalar.');
    end

    required_fields = { ...
        'dgd_values', 'sigma_A', 'correlation_tensor', 'analytical' ...
    };

    check_required_fields(results_experiment_6, required_fields, ...
        'plot_single_arm_pmd_tensor_snapshot:MissingField');

    check_required_fields(results_experiment_6.analytical, ...
        {'correlation_tensor'}, ...
        'plot_single_arm_pmd_tensor_snapshot:MissingAnalyticalField');


    % =========================
    % Extract data
    % =========================

    dgd_values = results_experiment_6.dgd_values(:).';
    normalized_dgd = real(results_experiment_6.sigma_A) * dgd_values;

    tensor_num = real(results_experiment_6.correlation_tensor);
    tensor_analytical = real(results_experiment_6.analytical.correlation_tensor);

    tensor_error = abs(tensor_num - tensor_analytical);
    max_tensor_error = max(tensor_error, [], 'all');

    if max_tensor_error == 0
        max_tensor_error = eps;
    end

    num_dgd_values = numel(dgd_values);

    snapshot_indices = unique(round(linspace(1, num_dgd_values, 3)));
    num_snapshots = numel(snapshot_indices);

    style = get_plot_style();


    % =========================
    % Figure and tab
    % =========================

    [fig, tab] = get_experiment_figure_tab( ...
        style.figure.experiment_6_id, ...
        'Correlation tensor snapshots', ...
        'Experiment 6 — Single-Arm PMD', ...
        style);

    build_plot(tab);

    set(fig, 'Visible', style.figure.visible_after_build);


    % =========================
    % Save (conditional)
    % =========================

    if do_save

        output_folder = [ ...
            '/home/marcocioci/HPC/THESIS-Quantum-Communications/', ...
            'Quantum-Fiber-Simulator/images/experiment_6' ...
        ];

        output_path = fullfile(output_folder, ...
            'experiment_6_single_arm_pmd_tensor_snapshots.png');

        export_plot(output_path, @build_plot, style);

    end


    % =========================
    % Local plot builder
    % =========================

    function layout = build_plot(parent_container)

        layout = tiledlayout(parent_container, 2, num_snapshots, ...
            'TileSpacing', 'compact', ...
            'Padding', 'compact');

        for snapshot_idx = 1:num_snapshots

            dgd_idx = snapshot_indices(snapshot_idx);

            ax = nexttile(layout, snapshot_idx);
            plot_tensor_heatmap(ax, tensor_num(:, :, dgd_idx), ...
                sprintf('Numerical, $\\sigma_A\\tau = %.2f$', ...
                normalized_dgd(dgd_idx)), ...
                [-1, 1], '%.3f', parula);

            ax = nexttile(layout, snapshot_idx + num_snapshots);
            plot_tensor_heatmap(ax, tensor_error(:, :, dgd_idx), ...
                sprintf('Absolute error, $\\sigma_A\\tau = %.2f$', ...
                normalized_dgd(dgd_idx)), ...
                [0, max_tensor_error], '%.2e', ...
                validation_error_colormap());

        end

        title(layout, ...
            'Single-arm PMD correlation tensor and absolute validation error', ...
            'Interpreter', 'none');

    end

end


function plot_tensor_heatmap(ax, tensor, plot_title, color_limits, ...
        value_format, color_map)

    imagesc(ax, tensor);
    axis(ax, 'image');

    colormap(ax, color_map);
    clim(ax, color_limits);
    colorbar(ax);

    xticks(ax, 1:3);
    yticks(ax, 1:3);

    xticklabels(ax, {'x', 'y', 'z'});
    yticklabels(ax, {'x', 'y', 'z'});

    xlabel(ax, '$j$', 'Interpreter', 'latex');
    ylabel(ax, '$i$', 'Interpreter', 'latex');
    title(ax, plot_title, 'Interpreter', 'latex');

    is_signed_tensor = color_limits(1) < 0;

    for row_idx = 1:3
        for column_idx = 1:3

            value = tensor(row_idx, column_idx);

            if is_signed_tensor && abs(value) > 0.5
                text_color = 'w';
            else
                text_color = 'k';
            end

            text(ax, column_idx, row_idx, sprintf(value_format, value), ...
                'HorizontalAlignment', 'center', ...
                'Color', text_color, ...
                'FontSize', 11);

        end
    end

end


function color_map = validation_error_colormap()
% VALIDATION_ERROR_COLORMAP  Restrained blue palette for validation errors.

    anchor_colors = [ ...
        0.96, 0.98, 1.00; ...
        0.78, 0.88, 0.96; ...
        0.43, 0.67, 0.84; ...
        0.14, 0.36, 0.60 ...
    ];

    anchor_positions = linspace(0, 1, size(anchor_colors, 1));
    color_positions = linspace(0, 1, 256);

    color_map = interp1(anchor_positions, anchor_colors, ...
        color_positions, 'linear');

end


function check_required_fields(input_struct, required_fields, error_id)
% CHECK_REQUIRED_FIELDS  Verify that all required fields are present.

    for field_idx = 1:numel(required_fields)

        field_name = required_fields{field_idx};

        if ~isfield(input_struct, field_name)
            error(error_id, 'Field "%s" not found.', field_name);
        end

    end

end
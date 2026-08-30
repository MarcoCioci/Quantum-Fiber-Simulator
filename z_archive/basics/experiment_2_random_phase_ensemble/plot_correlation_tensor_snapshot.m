function plot_correlation_tensor_snapshot(results_current, do_save)
% PLOT_CORRELATION_TENSOR_SNAPSHOT  Visualize the numerical Pauli correlation tensor for one experiment case.
%
% Objective:
%   Plot only the numerical 3x3 two-qubit Pauli correlation tensor.
%
%   Each tensor entry is the expectation value of a local Pauli-product
%   observable:
%
%       T(i,j) = ⟨σ_i ⊗ σ_j⟩
%
%   where i,j belong to {x,y,z}.
%
% Input:
%   results_current - structure containing:
%       .correlation_tensor  - numerical 3x3 correlation tensor
%       .case_label          - case label used in the tab title and filename [optional]
%
%   do_save (optional) - logical flag to enable figure saving (default: false)
%
% Output:
%   None

    % =========================
    % Robustness checks
    % =========================

    if nargin < 1 || nargin > 2
        error('plot_correlation_tensor_snapshot:InvalidNumInputs', ...
              'Expected 1 or 2 input arguments.');
    end

    if nargin < 2 || isempty(do_save)
        do_save = false;
    end

    if ~islogical(do_save) || ~isscalar(do_save)
        error('plot_correlation_tensor_snapshot:InvalidDoSave', ...
              'do_save must be a logical scalar.');
    end

    if ~isstruct(results_current)
        error('plot_correlation_tensor_snapshot:InvalidInputType', ...
              'results_current must be a structure.');
    end

    if ~isfield(results_current, 'correlation_tensor')
        error('plot_correlation_tensor_snapshot:MissingField', ...
              'Field "correlation_tensor" not found.');
    end

    T_num = real(results_current.correlation_tensor);

    if ~isnumeric(T_num) || ~isequal(size(T_num), [3, 3])
        error('plot_correlation_tensor_snapshot:InvalidTensorSize', ...
              'correlation_tensor must be a numeric 3x3 matrix.');
    end

    if any(~isfinite(T_num(:)))
        error('plot_correlation_tensor_snapshot:InvalidTensorValues', ...
              'correlation_tensor must contain only finite values.');
    end


    % =========================
    % Plot style
    % =========================

    palette = get_plot_palette();
    style   = get_plot_style();


    % =========================
    % Square export geometry
    % =========================

    if isfield(style.export, 'figure_position_square')
        style.export.figure_position_current = style.export.figure_position_square;
    else
        style.export.figure_position_current = [100, 100, 1200, 1200];
    end


    % =========================
    % Labels and filename
    % =========================

    axis_labels = {'x', 'y', 'z'};

    if isfield(results_current, 'case_label')
        case_label = char(results_current.case_label);
    else
        case_label = 'case';
    end

    if isfield(results_current, 'distribution_type')
        distribution_type = char(results_current.distribution_type);
    else
        distribution_type = case_label;
    end

    distribution_label_file = lower(distribution_type);
    distribution_label_file = regexprep(distribution_label_file, '\s+', '_');
    distribution_label_file = regexprep(distribution_label_file, '[^a-z0-9_]', '');
    distribution_label_file = regexprep(distribution_label_file, '_+', '_');
    distribution_label_file = regexprep(distribution_label_file, '^_|_$', '');

    output_folder = [ ...
        '/home/marcocioci/HPC/THESIS-Quantum-Communications/', ...
        'Quantum-Fiber-Simulator/images/experiment_2'];

    output_path = fullfile(output_folder, ...
        sprintf('experiment_2_correlation_tensor_%s.png', distribution_label_file));


    % =========================
    % Figure and tab
    % =========================

    [fig, tab] = get_experiment_figure_tab( ...
        style.figure.experiment_2_id, ...
        sprintf('Tensor %s', case_label), ...
        'Experiment 2 — Random Phase Ensemble', ...
        style);

    build_plot(tab, false);

    set(fig, 'Visible', style.figure.visible_after_build);


    % =========================
    % Save (conditional)
    % =========================

    if do_save
        export_plot(output_path, ...
            @(parent) build_plot(parent, false), ...
            style);
    end


    % =========================
    % Local plot builder
    % =========================

    function tl = build_plot(parent_container, show_title)

        if nargin < 2
            show_title = false;
        end

        tl = tiledlayout(parent_container, 1, 1, ...
            'TileSpacing', 'compact', ...
            'Padding', 'compact');

        ax = nexttile(tl);

        plot_single_tensor_heatmap( ...
            ax, ...
            T_num, ...
            axis_labels, ...
            [-1, 1], ...
            palette, ...
            style);

        if show_title
            title(tl, ...
                sprintf('Experiment 2 — Numerical Correlation Tensor | %s', case_label), ...
                'FontSize', style.title.font_size, ...
                'FontWeight', style.title.font_weight, ...
                'Interpreter', style.title.interpreter);
        end

    end

end


function plot_single_tensor_heatmap(ax, T, axis_labels, color_limits, palette, style)
% PLOT_SINGLE_TENSOR_HEATMAP  Plot one 3x3 correlation tensor heatmap.

    imagesc(ax, T);

    axis(ax, 'square');
    colormap(ax, style.heatmap.colormap);
    clim(ax, color_limits);

    cb = colorbar(ax);
    cb.TickLabelInterpreter = style.axes.tick_label_interpreter;
    cb.FontSize = style.axes.font_size;

    set(ax, ...
        'XTick', 1:3, ...
        'XTickLabel', axis_labels, ...
        'YTick', 1:3, ...
        'YTickLabel', axis_labels, ...
        'XColor', palette.gray_dark, ...
        'YColor', palette.gray_dark, ...
        'FontSize', style.axes.font_size, ...
        'LineWidth', style.axes.line_width, ...
        'TickLabelInterpreter', style.axes.tick_label_interpreter, ...
        'Layer', style.axes.layer);

    xlabel(ax, 'Measurement axis on subsystem B', ...
        'Interpreter', style.labels.interpreter, ...
        'FontSize', style.labels.font_size_axis);

    ylabel(ax, 'Measurement axis on subsystem A', ...
        'Interpreter', style.labels.interpreter, ...
        'FontSize', style.labels.font_size_axis);

    for row_idx = 1:3
        for col_idx = 1:3

            value = T(row_idx, col_idx);

            if abs(value) > 0.5 * max(abs(color_limits))
                text_color = 'w';
            else
                text_color = palette.gray_dark;
            end

            text(ax, col_idx, row_idx, sprintf('%+.3f', value), ...
                 'HorizontalAlignment', 'center', ...
                 'Color', text_color, ...
                 'FontWeight', 'bold', ...
                 'FontSize', style.labels.font_size_title);

        end
    end

end
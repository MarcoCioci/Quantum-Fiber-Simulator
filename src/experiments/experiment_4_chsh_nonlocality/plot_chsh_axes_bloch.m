function fig = plot_chsh_axes_bloch(results_experiment_4, do_save)
% PLOT_CHSH_AXES_BLOCH  Plot fixed CHSH axes on local Bloch spheres.
%
% Objective:
%   Display the fixed local measurement axes used to compute S_fixed in
%   Experiment 4. The plot provides a geometrical diagnostic of the CHSH
%   analyzer settings stored in:
%
%       results_experiment_4.chsh_axes
%
%   The function shows:
%
%       1) subsystem-A axes: a₁, a₂
%       2) subsystem-B axes: b₁, b₂
%
% Input:
%   results_experiment_4 - structure produced by
%                          run_experiment_4_chsh_nonlocality.
%
%   do_save (optional)  - logical flag to enable figure saving
%                         (default: false)
%
% Output:
%   fig - handle to the experiment figure window
%
% Notes:
%   This function does not recompute CHSH values. It only visualizes the
%   Bloch-sphere geometry of the fixed measurement axes used for S_fixed.
%
%   A two-qubit Bell state cannot be represented by a single Bloch vector.
%   Its local reduced states are maximally mixed, while its nonlocal
%   structure is encoded in the correlation tensor T.

    % =========================
    % Robustness checks
    % =========================

    if nargin < 1 || nargin > 2
        error('plot_chsh_axes_bloch:InvalidNumInputs', ...
              'Expected 1 or 2 input arguments.');
    end

    if nargin < 2 || isempty(do_save)
        do_save = false;
    end

    if ~islogical(do_save) || ~isscalar(do_save)
        error('plot_chsh_axes_bloch:InvalidDoSave', ...
              'do_save must be a logical scalar.');
    end

    if ~isstruct(results_experiment_4)
        error('plot_chsh_axes_bloch:InvalidInputType', ...
              'results_experiment_4 must be a structure.');
    end

    if ~isfield(results_experiment_4, 'chsh_axes')
        error('plot_chsh_axes_bloch:MissingAxesField', ...
              'results_experiment_4 must contain the field chsh_axes.');
    end

    chsh_axes = results_experiment_4.chsh_axes;
    required_axis_fields = {'a1', 'a2', 'b1', 'b2'};

    for field_idx = 1:numel(required_axis_fields)
        field_name = required_axis_fields{field_idx};

        if ~isfield(chsh_axes, field_name)
            error('plot_chsh_axes_bloch:MissingAxisField', ...
                  'chsh_axes must contain the field "%s".', field_name);
        end

        axis_vector = chsh_axes.(field_name);

        if ~isnumeric(axis_vector) || ~isvector(axis_vector) || ~isreal(axis_vector)
            error('plot_chsh_axes_bloch:InvalidAxisType', ...
                  'chsh_axes.%s must be a real numeric vector.', field_name);
        end

        if numel(axis_vector) ~= 3
            error('plot_chsh_axes_bloch:InvalidAxisLength', ...
                  'chsh_axes.%s must contain exactly 3 entries.', field_name);
        end

        if any(~isfinite(axis_vector))
            error('plot_chsh_axes_bloch:NonFiniteAxisValue', ...
                  'chsh_axes.%s must contain only finite values.', field_name);
        end

        if norm(axis_vector(:)) == 0
            error('plot_chsh_axes_bloch:ZeroAxisVector', ...
                  'chsh_axes.%s must not be the zero vector.', field_name);
        end
    end


    % =========================
    % Plot style
    % =========================

    palette = get_plot_palette();
    style   = get_plot_style();

    a1 = normalize_axis(chsh_axes.a1);
    a2 = normalize_axis(chsh_axes.a2);
    b1 = normalize_axis(chsh_axes.b1);
    b2 = normalize_axis(chsh_axes.b2);


    % =========================
    % Figure and tab
    % =========================

    [fig, tab] = get_experiment_figure_tab( ...
        style.figure.experiment_4_id, ...
        'Bloch axes', ...
        'Experiment 4 — CHSH Nonlocality', ...
        style);

    build_plot(tab, false);

    set(fig, 'Visible', style.figure.visible_after_build);


    % =========================
    % Save (conditional)
    % =========================

    if do_save
        output_folder = [ ...
            '/home/marcocioci/HPC/THESIS-Quantum-Communications/', ...
            'Quantum-Fiber-Simulator/images/experiment_4'];

        output_path = fullfile(output_folder, ...
            'experiment_4_bloch_axes.png');

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

        tl = tiledlayout(parent_container, 1, 2, ...
            'TileSpacing', style.layout.tile_spacing, ...
            'Padding', style.layout.padding);


        % =====================================================
        % Panel 1: subsystem A
        % =====================================================

        ax = nexttile(tl);
        hold(ax, 'on');
        grid(ax, style.axes.grid);
        box(ax, style.axes.box);
        axis(ax, 'equal');

        draw_bloch_sphere(ax, palette);
        draw_cartesian_axes(ax, palette);

        h_a1 = draw_bloch_axis(ax, a1, '$a_1$', palette.blue);
        h_a2 = draw_bloch_axis(ax, a2, '$a_2$', palette.orange);

        draw_axis_arc(ax, a1, a2, palette.blue, palette.orange);

        title(ax, 'Subsystem A measurement axes', ...
            'FontSize', style.title.font_size_small, ...
            'FontWeight', style.title.font_weight, ...
            'Interpreter', style.title.interpreter);

        xlabel(ax, '$x$', ...
            'Interpreter', style.labels.interpreter, ...
            'FontSize', style.labels.font_size_axis);

        ylabel(ax, '$y$', ...
            'Interpreter', style.labels.interpreter, ...
            'FontSize', style.labels.font_size_axis);

        zlabel(ax, '$z$', ...
            'Interpreter', style.labels.interpreter, ...
            'FontSize', style.labels.font_size_axis);

        configure_bloch_axes(ax, style);

        view(ax, 38, 24);

        legend(ax, [h_a1, h_a2], {'$a_1$', '$a_2$'}, ...
            'Location', 'southoutside', ...
            'Orientation', 'horizontal', ...
            'Interpreter', style.legend.interpreter, ...
            'FontSize', style.legend.font_size);


        % =====================================================
        % Panel 2: subsystem B
        % =====================================================

        ax = nexttile(tl);
        hold(ax, 'on');
        grid(ax, style.axes.grid);
        box(ax, style.axes.box);
        axis(ax, 'equal');

        draw_bloch_sphere(ax, palette);
        draw_cartesian_axes(ax, palette);

        h_b1 = draw_bloch_axis(ax, b1, '$b_1$', palette.green);
        h_b2 = draw_bloch_axis(ax, b2, '$b_2$', palette.red);

        draw_axis_arc(ax, b1, b2, palette.green, palette.red);

        title(ax, 'Subsystem B measurement axes', ...
            'FontSize', style.title.font_size_small, ...
            'FontWeight', style.title.font_weight, ...
            'Interpreter', style.title.interpreter);

        xlabel(ax, '$x$', ...
            'Interpreter', style.labels.interpreter, ...
            'FontSize', style.labels.font_size_axis);

        ylabel(ax, '$y$', ...
            'Interpreter', style.labels.interpreter, ...
            'FontSize', style.labels.font_size_axis);

        zlabel(ax, '$z$', ...
            'Interpreter', style.labels.interpreter, ...
            'FontSize', style.labels.font_size_axis);

        configure_bloch_axes(ax, style);

        view(ax, 38, 24);

        legend(ax, [h_b1, h_b2], {'$b_1$', '$b_2$'}, ...
            'Location', 'southoutside', ...
            'Orientation', 'horizontal', ...
            'Interpreter', style.legend.interpreter, ...
            'FontSize', style.legend.font_size);


        % =========================
        % Global title
        % =========================

        if show_title
            title(tl, ...
                'Experiment 4 — Fixed Local CHSH Measurement Axes', ...
                'FontSize', style.title.font_size, ...
                'FontWeight', style.title.font_weight, ...
                'Interpreter', style.title.interpreter);
        end

    end

end


function axis_vector = normalize_axis(axis_vector)
% NORMALIZE_AXIS  Return a 3x1 normalized Bloch vector.

    axis_vector = axis_vector(:);
    axis_vector = axis_vector / norm(axis_vector);

end


function configure_bloch_axes(ax, style)
% CONFIGURE_BLOCH_AXES  Apply common Bloch-sphere axes formatting.

    xlim(ax, [-1.25, 1.25]);
    ylim(ax, [-1.25, 1.25]);
    zlim(ax, [-1.25, 1.25]);

    pbaspect(ax, [1, 1, 1]);
    daspect(ax, [1, 1, 1]);

    set(ax, ...
        'FontSize', style.axes.font_size, ...
        'LineWidth', style.axes.line_width, ...
        'TickLabelInterpreter', style.axes.tick_label_interpreter, ...
        'Layer', style.axes.layer);

end


function draw_bloch_sphere(ax, palette)
% DRAW_BLOCH_SPHERE  Draw a transparent Bloch sphere.

    [X, Y, Z] = sphere(80);

    surf(ax, X, Y, Z, ...
        'FaceColor', palette.gray_light, ...
        'FaceAlpha', 0.08, ...
        'EdgeColor', palette.gray_mid, ...
        'EdgeAlpha', 0.12, ...
        'LineWidth', 0.3);

end


function draw_cartesian_axes(ax, palette)
% DRAW_CARTESIAN_AXES  Draw Bloch reference axes x, y, z.

    axis_limit = 1.15;

    plot3(ax, [-axis_limit, axis_limit], [0, 0], [0, 0], ':', ...
        'LineWidth', 1.0, ...
        'Color', palette.gray_dark);

    plot3(ax, [0, 0], [-axis_limit, axis_limit], [0, 0], ':', ...
        'LineWidth', 1.0, ...
        'Color', palette.gray_dark);

    plot3(ax, [0, 0], [0, 0], [-axis_limit, axis_limit], ':', ...
        'LineWidth', 1.0, ...
        'Color', palette.gray_dark);

    text(ax, 1.20, 0, 0, '$x$', ...
        'Interpreter', 'latex', ...
        'FontWeight', 'bold', ...
        'Color', palette.gray_dark);

    text(ax, 0, 1.20, 0, '$y$', ...
        'Interpreter', 'latex', ...
        'FontWeight', 'bold', ...
        'Color', palette.gray_dark);

    text(ax, 0, 0, 1.20, '$z$', ...
        'Interpreter', 'latex', ...
        'FontWeight', 'bold', ...
        'Color', palette.gray_dark);

end


function h_axis = draw_bloch_axis(ax, axis_vector, label_text, color_value)
% DRAW_BLOCH_AXIS  Draw one Bloch measurement axis as an arrow.

    h_axis = quiver3(ax, 0, 0, 0, ...
        axis_vector(1), axis_vector(2), axis_vector(3), ...
        0, ...
        'LineWidth', 2.4, ...
        'Color', color_value, ...
        'MaxHeadSize', 0.35);

    plot3(ax, axis_vector(1), axis_vector(2), axis_vector(3), 'o', ...
        'MarkerSize', 6, ...
        'MarkerFaceColor', color_value, ...
        'MarkerEdgeColor', color_value);

    text(ax, ...
        1.10 * axis_vector(1), ...
        1.10 * axis_vector(2), ...
        1.10 * axis_vector(3), ...
        label_text, ...
        'Interpreter', 'latex', ...
        'Color', color_value, ...
        'FontWeight', 'bold', ...
        'FontSize', 11);

end


function draw_axis_arc(ax, axis_1, axis_2, color_1, color_2)
% DRAW_AXIS_ARC  Draw the normalized arc connecting two Bloch axes.

    t_values = linspace(0, 1, 80);
    arc_points = zeros(3, numel(t_values));

    for idx = 1:numel(t_values)
        candidate = (1 - t_values(idx)) * axis_1 + t_values(idx) * axis_2;

        if norm(candidate) > 0
            arc_points(:, idx) = candidate / norm(candidate);
        end
    end

    arc_color = 0.5 * (color_1 + color_2);

    plot3(ax, arc_points(1, :), arc_points(2, :), arc_points(3, :), '--', ...
        'LineWidth', 1.2, ...
        'Color', arc_color);

end
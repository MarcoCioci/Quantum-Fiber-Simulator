function plot_chsh_axes_bloch(results_experiment_4)
% PLOT_CHSH_AXES_BLOCH  Plot fixed CHSH axes on Bloch spheres.
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
%       1) subsystem-A axes: a_1, a_2
%       2) subsystem-B axes: b_1, b_2
%       3) all CHSH axes together
%
% Input:
%   results_experiment_4 - structure produced by
%                          run_experiment_4_chsh_nonlocality.
%
% Output:
%   None
%
% Notes:
%   This function does not recompute CHSH values. It only visualizes the
%   Bloch-sphere geometry of the fixed measurement axes used for S_fixed.

    % =========================
    % Robustness checks
    % =========================

    if nargin ~= 1
        error('plot_chsh_axes_bloch_summary:InvalidNumInputs', ...
              'Expected 1 input argument.');
    end

    if ~isstruct(results_experiment_4)
        error('plot_chsh_axes_bloch_summary:InvalidInputType', ...
              'results_experiment_4 must be a structure.');
    end

    if ~isfield(results_experiment_4, 'chsh_axes')
        error('plot_chsh_axes_bloch_summary:MissingAxesField', ...
              'results_experiment_4 must contain the field chsh_axes.');
    end

    chsh_axes = results_experiment_4.chsh_axes;

    required_axis_fields = {'a1', 'a2', 'b1', 'b2'};

    for field_idx = 1:numel(required_axis_fields)
        field_name = required_axis_fields{field_idx};

        if ~isfield(chsh_axes, field_name)
            error('plot_chsh_axes_bloch_summary:MissingAxisField', ...
                  'chsh_axes must contain the field "%s".', field_name);
        end

        axis_vector = chsh_axes.(field_name);

        if ~isnumeric(axis_vector) || ~isvector(axis_vector) || ~isreal(axis_vector)
            error('plot_chsh_axes_bloch_summary:InvalidAxisType', ...
                  'chsh_axes.%s must be a real numeric vector.', field_name);
        end

        if numel(axis_vector) ~= 3
            error('plot_chsh_axes_bloch_summary:InvalidAxisLength', ...
                  'chsh_axes.%s must contain exactly 3 entries.', field_name);
        end

        if any(~isfinite(axis_vector))
            error('plot_chsh_axes_bloch_summary:NonFiniteAxisValue', ...
                  'chsh_axes.%s must contain only finite values.', field_name);
        end

        if norm(axis_vector(:)) == 0
            error('plot_chsh_axes_bloch_summary:ZeroAxisVector', ...
                  'chsh_axes.%s must not be the zero vector.', field_name);
        end
    end


    % =========================
    % Main computation
    % =========================

    palette = get_plot_palette();

    a1 = normalize_axis(chsh_axes.a1);
    a2 = normalize_axis(chsh_axes.a2);
    b1 = normalize_axis(chsh_axes.b1);
    b2 = normalize_axis(chsh_axes.b2);

    figure('Name', 'Experiment 4 — CHSH Axes on Bloch Spheres', ...
           'Color', 'w');

    tiledlayout(1, 3, ...
        'TileSpacing', 'compact', ...
        'Padding', 'compact');


    % =====================================================
    % Panel 1: subsystem A
    % =====================================================

    nexttile;
    hold on;
    grid on;
    box on;
    axis equal;

    draw_bloch_sphere(palette);
    draw_cartesian_axes(palette);

    h_a1 = draw_bloch_axis(a1, 'a_1', palette.blue);
    h_a2 = draw_bloch_axis(a2, 'a_2', palette.orange);

    title('Subsystem A axes');
    xlabel('x');
    ylabel('y');
    zlabel('z');

    xlim([-1.25, 1.25]);
    ylim([-1.25, 1.25]);
    zlim([-1.25, 1.25]);

    view(38, 24);

    legend([h_a1, h_a2], {'a_1', 'a_2'}, ...
        'Location', 'southoutside', ...
        'Orientation', 'horizontal');


    % =====================================================
    % Panel 2: subsystem B
    % =====================================================

    nexttile;
    hold on;
    grid on;
    box on;
    axis equal;

    draw_bloch_sphere(palette);
    draw_cartesian_axes(palette);

    h_b1 = draw_bloch_axis(b1, 'b_1', palette.green);
    h_b2 = draw_bloch_axis(b2, 'b_2', palette.red);

    title('Subsystem B axes');
    xlabel('x');
    ylabel('y');
    zlabel('z');

    xlim([-1.25, 1.25]);
    ylim([-1.25, 1.25]);
    zlim([-1.25, 1.25]);

    view(38, 24);

    legend([h_b1, h_b2], {'b_1', 'b_2'}, ...
        'Location', 'southoutside', ...
        'Orientation', 'horizontal');


    % =====================================================
    % Panel 3: combined CHSH geometry
    % =====================================================

    nexttile;
    hold on;
    grid on;
    box on;
    axis equal;

    draw_bloch_sphere(palette);
    draw_cartesian_axes(palette);

    h_a1 = draw_bloch_axis(a1, 'a_1', palette.blue);
    h_a2 = draw_bloch_axis(a2, 'a_2', palette.orange);
    h_b1 = draw_bloch_axis(b1, 'b_1', palette.green);
    h_b2 = draw_bloch_axis(b2, 'b_2', palette.red);

    draw_axis_plane(a1, a2, palette.blue, palette.orange);
    draw_axis_plane(b1, b2, palette.green, palette.red);

    title('Combined CHSH axes');
    xlabel('x');
    ylabel('y');
    zlabel('z');

    xlim([-1.25, 1.25]);
    ylim([-1.25, 1.25]);
    zlim([-1.25, 1.25]);

    view(38, 24);

    legend([h_a1, h_a2, h_b1, h_b2], ...
        {'a_1', 'a_2', 'b_1', 'b_2'}, ...
        'Location', 'southoutside', ...
        'Orientation', 'horizontal');


    % =========================
    % Global title
    % =========================

    sgtitle('Experiment 4 — Fixed CHSH Measurement Axes', ...
        'FontWeight', 'bold');

end


function axis_vector = normalize_axis(axis_vector)
% NORMALIZE_AXIS  Return a 3x1 normalized Bloch vector.

    axis_vector = axis_vector(:);
    axis_vector = axis_vector / norm(axis_vector);

end


function draw_bloch_sphere(palette)
% DRAW_BLOCH_SPHERE  Draw a transparent Bloch sphere.

    [X, Y, Z] = sphere(80);

    surf(X, Y, Z, ...
        'FaceColor', palette.gray_light, ...
        'FaceAlpha', 0.08, ...
        'EdgeColor', palette.gray_mid, ...
        'EdgeAlpha', 0.12, ...
        'LineWidth', 0.3);

end


function draw_cartesian_axes(palette)
% DRAW_CARTESIAN_AXES  Draw Bloch reference axes x, y, z.

    axis_limit = 1.15;

    plot3([-axis_limit, axis_limit], [0, 0], [0, 0], ':', ...
        'LineWidth', 1.0, ...
        'Color', palette.gray_dark);

    plot3([0, 0], [-axis_limit, axis_limit], [0, 0], ':', ...
        'LineWidth', 1.0, ...
        'Color', palette.gray_dark);

    plot3([0, 0], [0, 0], [-axis_limit, axis_limit], ':', ...
        'LineWidth', 1.0, ...
        'Color', palette.gray_dark);

    text(1.20, 0, 0, 'x', ...
        'FontWeight', 'bold', ...
        'Color', palette.gray_dark);

    text(0, 1.20, 0, 'y', ...
        'FontWeight', 'bold', ...
        'Color', palette.gray_dark);

    text(0, 0, 1.20, 'z', ...
        'FontWeight', 'bold', ...
        'Color', palette.gray_dark);

end


function h_axis = draw_bloch_axis(axis_vector, label_text, color_value)
% DRAW_BLOCH_AXIS  Draw one Bloch measurement axis as an arrow.

    h_axis = quiver3(0, 0, 0, ...
        axis_vector(1), axis_vector(2), axis_vector(3), ...
        0, ...
        'LineWidth', 2.4, ...
        'Color', color_value, ...
        'MaxHeadSize', 0.35);

    plot3(axis_vector(1), axis_vector(2), axis_vector(3), 'o', ...
        'MarkerSize', 6, ...
        'MarkerFaceColor', color_value, ...
        'MarkerEdgeColor', color_value);

    text(1.10 * axis_vector(1), ...
         1.10 * axis_vector(2), ...
         1.10 * axis_vector(3), ...
         label_text, ...
         'Color', color_value, ...
         'FontWeight', 'bold', ...
         'FontSize', 11);

end


function draw_axis_plane(axis_1, axis_2, color_1, color_2)
% DRAW_AXIS_PLANE  Draw the arc connecting two Bloch axes.

    t_values = linspace(0, 1, 80);

    arc_points = zeros(3, numel(t_values));

    for idx = 1:numel(t_values)
        candidate = (1 - t_values(idx)) * axis_1 + t_values(idx) * axis_2;

        if norm(candidate) > 0
            arc_points(:, idx) = candidate / norm(candidate);
        end
    end

    arc_color = 0.5 * (color_1 + color_2);

    plot3(arc_points(1, :), arc_points(2, :), arc_points(3, :), '--', ...
        'LineWidth', 1.2, ...
        'Color', arc_color);

end
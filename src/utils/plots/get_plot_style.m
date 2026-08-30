function style = get_plot_style()
% GET_PLOT_STYLE  Centralized graphical parameters for all figures.
%
% Objective:
%   Provide a consistent visual style for thesis figures and simulator plots.
%
% Output:
%   style - structure containing figure, axes, layout, line, marker,
%           legend, title, label, and export settings

    % =========================
    % Figure settings
    % =========================

    style.figure.position = [100, 100, 1600, 900];

    style.figure.renderer = 'opengl';

    % One figure window per experiment.
    % Each figure can contain multiple tabs.
    style.figure.experiment_1_id = 101;
    style.figure.experiment_2_id = 102;
    style.figure.experiment_3_id = 103;
    style.figure.experiment_4_id = 104;
    style.figure.experiment_5_id = 105;
    style.figure.experiment_6_id = 106;

    % Hidden during construction, shown after the plot is complete.
    style.figure.visible_during_build = 'off';
    style.figure.visible_after_build = 'on';

    % =========================
    % Layout settings
    % =========================

    style.layout.tile_spacing = 'loose';
    style.layout.padding = 'loose';

    % =========================
    % Axes settings
    % =========================

    style.axes.font_size = 17;
    style.axes.line_width = 1.0;
    style.axes.box = 'on';
    style.axes.grid = 'on';
    style.axes.layer = 'top';
    style.axes.tick_label_interpreter = 'latex';

    style.axes.correlation_limits = [-1.2, 1.2];
    style.axes.metric_limits = [-0.2, 1.2];

    % =========================
    % Labels and titles
    % =========================

    style.labels.font_size = 13;          % tick / small labels
    style.labels.font_size_axis = 22;     % θ, c_xx, γ, etc.
    style.labels.font_size_title = 16;    % optional (subplot titles)
    style.labels.interpreter = 'latex';

    style.title.font_size = 16;
    style.title.font_size_small = 13;
    style.title.font_weight = 'bold';
    style.title.interpreter = 'none';
    style.title.interpreter_latex = 'latex';

    % =========================
    % Lines and markers
    % =========================

    style.lines.width_main = 1.8;
    style.lines.width_secondary = 1.4;

    style.markers.size = 4;
    style.markers.edge_width = 0.8;

    % =========================
    % Legend settings
    % =========================

    style.legend.font_size = 12;
    style.legend.location = 'best';
    style.legend.location_south = 'southoutside';
    style.legend.interpreter = 'latex';

    % =========================
    % Heatmap (tensor) settings
    % =========================

    style.heatmap.colormap = parula;
    style.heatmap.color_limits = [-1, 1];

    style.heatmap.text_threshold = 0.5;   % for white/black switch
    style.heatmap.text_font_size = 12;

    % =========================
    % Export settings
    % =========================

    style.export.resolution = 300;
    style.export.format = 'png';
    
    style.export.figure_position = [100, 100, 1600, 900];
    style.export.figure_position_square = [100, 100, 1200, 1200];
    style.export.background_color = 'white';

end
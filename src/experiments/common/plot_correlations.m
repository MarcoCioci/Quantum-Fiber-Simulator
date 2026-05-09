function plot_correlations(results_struct, correlations_to_plot)
% PLOT_CORRELATIONS  Plot selected correlation fields from an experiment result struct.
%
% Styling:
%   - Fixed color order: blue, red, green, yellow, black
%   - No markers
%   - Different line styles to resolve overlaps

    % =========================
    % Robustness checks
    % =========================

    if nargin ~= 2
        error('plot_correlations:InvalidNumInputs', ...
            'Expected 2 input arguments.');
    end

    if ~isstruct(results_struct)
        error('plot_correlations:InvalidResultsStruct', ...
            'results_struct must be a struct.');
    end

    if ~iscell(correlations_to_plot) || isempty(correlations_to_plot)
        error('plot_correlations:InvalidCorrelationList', ...
            'correlations_to_plot must be a non-empty cell array.');
    end

    if ~isfield(results_struct, 'theta_values')
        error('plot_correlations:MissingTheta', ...
            'results_struct must contain ''theta''.');
    end

    theta_values = results_struct.theta_values(:);
    n = numel(theta_values);


    % =========================
    % Collect data
    % =========================

    y_data = cell(1, numel(correlations_to_plot));

    for k = 1:numel(correlations_to_plot)
        field_name = char(correlations_to_plot{k});

        if ~isfield(results_struct, field_name)
            error('Missing field: %s', field_name);
        end

        y = results_struct.(field_name);

        if numel(y) ~= n
            error('Size mismatch for field: %s', field_name);
        end

        y_data{k} = real(y(:));
        correlations_to_plot{k} = field_name;
    end

    % =========================
    % Styling setup
    % =========================

    colors = [
        0 0 1;      % blue
        1 0 0;      % red
        0 0.6 0;    % green (slightly darker for visibility)
        1 0.8 0;    % yellow (adjusted to be visible)
        0 0 0       % black
    ];

    line_styles = {'-', '--', ':', '-.'};

    % =========================
    % Plot
    % =========================

    figure;
    hold on;

    for k = 1:numel(y_data)

        color = colors(mod(k-1, size(colors,1)) + 1, :);
        style = line_styles{mod(k-1, numel(line_styles)) + 1};

        y_plot = y_data{k};

        % Minimal offset ONLY if identical curves
        if k > 1
            if norm(y_plot - y_data{1}) < 1e-12
                y_plot = y_plot + 1e-6 * k;
            end
        end

        plot(theta_values, y_plot, ...
            'Color', color, ...
            'LineStyle', style, ...
            'LineWidth', 1.5, ...
            'DisplayName', correlations_to_plot{k});
    end

    hold off;
    grid on;
    box on;

    xlabel('\theta');
    ylabel('Correlation value');
    title('Correlation observables vs \theta');
    legend('Location', 'best', 'Interpreter', 'none');

end
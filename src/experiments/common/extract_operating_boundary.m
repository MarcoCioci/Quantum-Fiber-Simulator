function boundary = extract_operating_boundary(parameter_values, metric_values, threshold)
% EXTRACT_OPERATING_BOUNDARY
% Extract threshold crossings from a one-dimensional parameter sweep.
%
% The function locates all intervals in which
%
%   metric(parameter) - threshold
%
% changes sign and estimates the crossing position by linear interpolation.
%
% Inputs:
%   parameter_values - Monotonically increasing parameter vector.
%   metric_values    - Metric evaluated at each parameter value.
%   threshold        - Threshold defining the operating boundary.
%
% Output:
%   boundary - Structure containing:
%              .crossing_values
%              .num_crossings
%              .first_crossing
%              .last_crossing
%              .threshold
%              .operating_mask
%
% The operating mask is defined by
%
%   metric_values < threshold.
%
% For BBM92 applications, metric_values can be chosen as
%
%   max(Q_Z, Q_X).

    parameter_values = parameter_values(:);
    metric_values = metric_values(:);

    if numel(parameter_values) ~= numel(metric_values)

        error( ...
            'extract_operating_boundary:SizeMismatch', ...
            'Parameter and metric vectors must have the same length.');

    end

    if numel(parameter_values) < 2

        error( ...
            'extract_operating_boundary:InsufficientPoints', ...
            'At least two parameter points are required.');

    end

    if any(~isfinite(parameter_values)) || ...
       any(~isfinite(metric_values)) || ...
       ~isscalar(threshold) || ...
       ~isfinite(threshold)

        error( ...
            'extract_operating_boundary:InvalidInput', ...
            'Inputs must contain finite numerical values.');

    end

    if any(diff(parameter_values) <= 0)

        error( ...
            'extract_operating_boundary:NonMonotonicParameter', ...
            'Parameter values must be strictly increasing.');

    end

    difference = metric_values - threshold;

    operating_mask = metric_values < threshold;

    crossing_values = [];

    for k = 1:(numel(parameter_values) - 1)

        x_1 = parameter_values(k);
        x_2 = parameter_values(k + 1);

        y_1 = difference(k);
        y_2 = difference(k + 1);

        if y_1 == 0

            crossing_values(end + 1, 1) = x_1; %#ok<AGROW>

        elseif y_1 * y_2 < 0

            crossing = ...
                x_1 ...
                - y_1 * (x_2 - x_1) / (y_2 - y_1);

            crossing_values(end + 1, 1) = crossing; %#ok<AGROW>

        end

    end

    if difference(end) == 0

        crossing_values(end + 1, 1) = parameter_values(end);

    end

    crossing_values = unique(crossing_values, 'stable');

    boundary = struct();

    boundary.crossing_values = crossing_values;
    boundary.num_crossings = numel(crossing_values);

    boundary.threshold = threshold;
    boundary.operating_mask = operating_mask;

    if isempty(crossing_values)

        boundary.first_crossing = NaN;
        boundary.last_crossing = NaN;

    else

        boundary.first_crossing = crossing_values(1);
        boundary.last_crossing = crossing_values(end);

    end

end
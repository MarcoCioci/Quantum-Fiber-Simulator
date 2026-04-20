function theta_samples = generate_theta_samples(distribution_type, num_samples, varargin)
% GENERATE_THETA_SAMPLES  Generate random phase samples according to a
% specified distribution.
%
% Objective:
%   Produce a vector of sampled relative phases theta to be used in the
%   random-phase ensemble model of Experiment 2.
%
% Input:
%   distribution_type - string specifying the distribution:
%                       'constant'
%                       'uniform'
%                       'gaussian'
%
%   num_samples       - number of samples to generate (positive integer)
%
%   varargin          - additional parameters depending on distribution:
%
%       'constant' → (theta_value)
%       'uniform'  → (a, b)
%       'gaussian' → (mu, sigma)
%
% Output:
%   theta_samples - 1 x num_samples vector of sampled phase values
%
% Notes:
%   This function isolates randomness generation from experiment logic.
%
%   It is intentionally explicit:
%       - no default parameters
%       - no silent assumptions
%
%   All distributions must be fully specified via input arguments.
%
%   The output is always returned as a row vector.
%
%   No wrapping to [0, 2π] is enforced here; that decision is left to the user.

    % =========================
    % Robustness checks
    % =========================

    if nargin < 2
        error('generate_theta_samples:InvalidNumInputs', ...
              'At least 2 inputs required: distribution_type and num_samples.');
    end

    if ~ischar(distribution_type) && ~isstring(distribution_type)
        error('generate_theta_samples:InvalidTypeDistribution', ...
              'distribution_type must be a string.');
    end

    if ~isnumeric(num_samples) || ~isscalar(num_samples) || ...
            num_samples <= 0 || floor(num_samples) ~= num_samples
        error('generate_theta_samples:InvalidNumSamples', ...
              'num_samples must be a positive integer scalar.');
    end

    distribution_type = lower(string(distribution_type));


    % =========================
    % Main computation
    % =========================

    switch distribution_type

        case "constant"

            % Expected: varargin{1} = theta_value
            if numel(varargin) ~= 1
                error('generate_theta_samples:InvalidConstantParameters', ...
                      'Constant distribution requires exactly 1 parameter: theta_value.');
            end

            theta_value = varargin{1};

            if ~isnumeric(theta_value) || ~isscalar(theta_value) || ~isfinite(theta_value)
                error('generate_theta_samples:InvalidThetaValue', ...
                      'theta_value must be a finite numeric scalar.');
            end

            theta_samples = theta_value * ones(1, num_samples);


        case "uniform"

            % Expected: varargin{1} = a, varargin{2} = b
            if numel(varargin) ~= 2
                error('generate_theta_samples:InvalidUniformParameters', ...
                      'Uniform distribution requires exactly 2 parameters: a and b.');
            end

            a = varargin{1};
            b = varargin{2};

            if ~isnumeric(a) || ~isscalar(a) || ~isfinite(a)
                error('generate_theta_samples:InvalidUniformLowerBound', ...
                      'a must be a finite numeric scalar.');
            end

            if ~isnumeric(b) || ~isscalar(b) || ~isfinite(b)
                error('generate_theta_samples:InvalidUniformUpperBound', ...
                      'b must be a finite numeric scalar.');
            end

            if a > b
                error('generate_theta_samples:InvalidUniformBounds', ...
                      'Uniform bounds must satisfy a <= b.');
            end

            theta_samples = a + (b - a) * rand(1, num_samples);


        case "gaussian"

            % Expected: varargin{1} = mu, varargin{2} = sigma
            if numel(varargin) ~= 2
                error('generate_theta_samples:InvalidGaussianParameters', ...
                      'Gaussian distribution requires exactly 2 parameters: mu and sigma.');
            end

            mu = varargin{1};
            sigma = varargin{2};

            if ~isnumeric(mu) || ~isscalar(mu) || ~isfinite(mu)
                error('generate_theta_samples:InvalidGaussianMean', ...
                      'mu must be a finite numeric scalar.');
            end

            if ~isnumeric(sigma) || ~isscalar(sigma) || ~isfinite(sigma)
                error('generate_theta_samples:InvalidGaussianSigma', ...
                      'sigma must be a finite numeric scalar.');
            end

            if sigma < 0
                error('generate_theta_samples:NegativeGaussianSigma', ...
                      'sigma must be non-negative.');
            end

            theta_samples = mu + sigma * randn(1, num_samples);


        otherwise
            error('generate_theta_samples:UnknownDistribution', ...
                  'Unsupported distribution type: %s', distribution_type);
    end

end
% MATLAB Code for Weather Prediction Using Linear Regression
% Corrected version with proper header handling

% Step 1: Load the weather data with preserved headers
try
    data = readtable('weather_data.csv', 'VariableNamingRule', 'preserve');
catch
    error('Failed to load weather_data.csv. Ensure the file is in the current directory.');
end

% Display available column names for debugging
disp('Available columns in the data:');
disp(data.Properties.VariableNames);

% Step 2: Extract relevant columns
try
    years = data.Year;
    months = data.Month;
    
    % Try to access temperature column with different possible names
    if ismember('Maximum temperature [°C]', data.Properties.VariableNames)
        max_temps = data.("Maximum temperature [°C]");
    elseif ismember('Maximum_temperature___C', data.Properties.VariableNames)
        max_temps = data.Maximum_temperature___C;
    elseif ismember('Maximumtemperature_C', data.Properties.VariableNames)
        max_temps = data.Maximumtemperature_C;
    else
        error('Could not find maximum temperature column in the data');
    end
catch ME
    error('Error accessing data columns: %s', ME.message);
end

% Step 3: Filter data for April (Month = 4)
april_indices = months == 4;
april_years = years(april_indices);
april_max_temps = max_temps(april_indices);

% Step 4: Calculate average max temperature for each April
unique_years = unique(april_years);
avg_april_max_temps = zeros(size(unique_years));

for i = 1:length(unique_years)
    year = unique_years(i);
    indices = april_years == year;
    avg_april_max_temps(i) = mean(april_max_temps(indices), 'omitnan');
end

% Step 5: Prepare input (X) and output (Y) for linear regression
X = unique_years;
Y = avg_april_max_temps;

% Step 6: Perform linear regression
model = fitlm(X, Y);

% Step 7: Display model summary
disp('Linear Regression Model Summary:');
disp(model);

% Step 8: Extract coefficients (slope and intercept)
coefficients = model.Coefficients.Estimate;
slope = coefficients(2);
intercept = coefficients(1);

% Step 9: Predict max temperature for April 2024
year_to_predict = 2024;
predicted_max_temp = slope * year_to_predict + intercept;

% Step 10: Display the prediction
fprintf('\nPredicted max temperature for April 2024: %.2f°C\n', predicted_max_temp);

% Step 11: Plot historical data and regression line
figure;
scatter(X, Y, 'b', 'filled');
hold on;
regression_line = slope * X + intercept;
plot(X, regression_line, 'r', 'LineWidth', 2);
xlabel('Year');
ylabel('Average Max Temperature (°C)');
title('Linear Regression for April Max Temperature');
grid on;

% Step 12: Highlight the prediction for 2024
scatter(year_to_predict, predicted_max_temp, 100, 'g', 'filled', 'MarkerEdgeColor', 'k');
legend('Historical Data', 'Regression Line', 'Prediction for 2024', 'Location', 'best');

% Step 13: Calculate predicted values for all years
predicted_values = slope * X + intercept;

% Step 14: Calculate Mean Squared Error (MSE)
mse = mean((Y - predicted_values).^2);
fprintf('Mean Squared Error (MSE): %.2f\n', mse);

% Step 15: Add additional quality checks
valid_data_points = sum(~isnan(april_max_temps));
fprintf('Number of valid data points: %d\n', valid_data_points);

if length(unique_years) < 5
    warning('Limited data available (only %d years). Results may not be reliable.', length(unique_years));
end
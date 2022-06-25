clc; clear;close all;

% Simulation parameters
population = 1000;
initial_balance = 100;
iterations = 500;
no_spenders = 15;
max_spending = 1; % 1 for 100%
equality = true;

% Initial conditions
results = ones(iterations,population)*initial_balance; % matrix to store balance history
out_of_game_ids = []; % these id's have had their balances drop to 0 and no longer participate
for i=1:iterations
    curr_state = results(i,:);

    % Divide the population in groups
    % Array of ID's for people
    id_set = linspace(1,population,population);
    id_set = setdiff(id_set,out_of_game_ids);
    while numel(id_set) > 0
        msize = numel(id_set);

        if msize>no_spenders
            group_ids = id_set(randperm(msize, no_spenders));
        else
            % if there are less remaining people than the number of spenders,
            % create a smaller group with all remainders instead
            group_ids = id_set;
        end

        group_balances = curr_state(group_ids);
        pot = 0;
        if equality
            max_spending_balance = max_spending * min(group_balances);
            spending = rand()*max_spending_balance;
            for j=1:numel(group_ids)
                group_balances(j) = group_balances(j)-spending;
                pot = pot+spending;
            end
        else
            for j=1:numel(group_ids)
                max_spending_balance = max_spending * group_balances(j);
                spending = rand()*max_spending_balance;
                group_balances(j) = group_balances(j)-spending;
                pot = pot+spending;
            end
        end

        % Select winner
        winner_id = group_ids(randperm(numel(group_ids),1));
        % Reassign balances for next iteration
        for k=1:numel(group_ids)
            id=group_ids(k);

            if id == winner_id
                results(i+1,id) = group_balances(k) + pot;
            else
                results(i+1,id) = group_balances(k);
            end

            if results(i+1,id) == 0
                out_of_game_ids(end+1) = id;
            end

        end
        id_set = setdiff(id_set,group_ids); % so that next groups won't draft the people in current group
    end

end
strExcel = num2str(population)+"_"+num2str(initial_balance)+"_"+num2str(iterations)+"_"+num2str(no_spenders)+"_"+num2str(max_spending)+"_"+num2str(equality);
writematrix(results,strExcel+'.xlsx',"WriteMode","replacefile");

% Plotting parameters
y_lim = population;
x_lim = population*initial_balance/200; 
no_bins = 50;

fig = figure();
% hold on
set(fig,'WindowStyle','docked');

hist = histogram(results(1,:),linspace(0,x_lim,no_bins));
xlabel("Balance")
ylabel("Count")
ylim([0 y_lim]);
for i = 1:iterations+1
    set(fig,"Name","i="+num2str(i))
    hist.Data = results(i,:);
    pause(0.01);
end
%% Case Study for Life Tables Analysis  
% This first part of the code is adapted from MATLAB's life table analysis
% toolbox. It is used to estimate the hazard function (qx) from US 2009 
% life table data.

% Copyright 2015 The MathWorks, Inc.


%% Build life expectancy data based on MATLAB script
% Load the life table data file. 
load us_lifetable_2009  

%% 
% Calibrate life table from survival data with the default |heligman-pollard|
% parametric model. 
[a,elx] = lifetablefit(x, lx);  

%% 
% Generate life table series from the calibrated mortality model. 
[qx,lx] = lifetablegen((0:100), a);
display(qx(1:40,:))  

%% 
% Plot the |qx| series and display the legend. The series |qx| is the conditional
% probability that a person at age $x$ will die between age $x$ and the
% next age in the series 
% plot((0:100), log(qx));
% legend(series, 'location', 'southeast');
% title('Conditional Probability of Dying within One Year of Current Age');
% xlabel('Age');
% ylabel('Log Probability');      


%%  Convert qx to lx

debug_mode = 0;

% % Variables
% x - original year of death
% y - new year of death given x-risk

% Title
fprintf('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ \n');
fprintf('~~~~~~~~~~~~~~~~~~~MORBID App ~~~~~~~~~~~~~~~~~~~~~~~ \n');
fprintf('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ \n');
fprintf('\n');

% Choose age
current_age = 0;
current_age = input('Choose age in years: ');
if isempty(current_age); current_age = 0; end

% Choose gender
i = 3; % 1-both; 2-male; 3-female
gender = input('Choose gender (M/F): ','s');
gender = upper(gender);
switch gender
    case 'M'
        i=1;
    case 'F'
        i=2;
    otherwise
        i=1;
        warning('unknown gender');
end

fprintf('\n');
fprintf('\n');
fprintf('Choices for x-risk estimate. \n');
fprintf('1 - FHI estimate, 19%% chance of extinction by 2100 \n');
fprintf('2 - Stern review, 0.1%% chance per year \n');
fprintf('3 - Martin Rees estimate, 50%% chance of complete extinction by 2100 \n');
lee = input('Enter options 1-3: ');

fprintf('\n');
fprintf('\n');

% Set up qx - hazard functions
qx;                       %  Original hazard function; assumed known
switch lee
    case 1
        shift = 19/100/100;       %  FHI number - assume there is a total of 19% chance per 100 years = 0.19 
    case 2
        shift = 0.1/100;          %  0.1% chance per year. Atlantic article, taken from The Stern Review - https://www.theatlantic.com/technology/archive/2016/04/a-human-extinction-isnt-that-unlikely/480444/                        
    case 3
        shift = 50/100/100;       % Martin Rees number http://thebulletin.org/how-likely-existential-catastrophe9866
end

qy = qx + shift;
qy(end,:) = 1;            %  Hazard level at the end must equal 1 (everybody dies, so far!)

radix =  100000;          % This is just the estimated population size

% Set up lx - survival function
lx;                                 % Value calculated by lifetablegen
lx2 = qx_to_lx(qx,radix,current_age);          % Dave's estimator from qx
ly2 = qx_to_lx(qy,radix,current_age);          % Dave's estimator from qy


percent_error = abs(lx - lx2) ./ lx * 100;
% if any( percent_error > 0.01); warning('Mismatch in lx calculation'); end

if debug_mode; figure; subplot(211); plot(x,lx); hold on; legend('All','male','female'); plot(x,lx2,'.'); ylabel('# survivors'); title('Original vs calculated lx'); subplot(212); plot(x,percent_error); title('Percent error in estimation'); ylabel('% error'); xlabel('age (years)'); legend('All','male','female'); end
    
% PDF of X / Y (year of death)
x_pdf = lx_to_pdf(lx,radix);
x_pdf2 = lx_to_pdf(lx2,radix);
y_pdf2 = lx_to_pdf(ly2,radix);
xd = x(2:end);



%% Plot of hazard function
figure;
plot(x,([qx(:,i), qy(:,i)]));
title('Yearly odds of death');
xlabel('Age');
ylabel('Probability');
legend('Original','Est post x-risk');
ylim([0 0.3])

%% Plot of hazard function
figure;
plot(x,log([qx(:,i), qy(:,i)]));
title('Yearly odds of death');
xlabel('Age');
ylabel('log(Probability)');
legend('Original','Est post x-risk');
% ylim([0 0.5])

%% Plot survival functions
figure;
plot(x,[lx2(:,i), ly2(:,i)]/radix);
legend('Original','Est post x-risk');
title('Odds of surviving past a given age');
xlabel('Age');
ylabel('Probability');
legend('Original','Est post x-risk');

%% Plot PDF of death year

figure; 
plot(xd,[x_pdf2(:,i), y_pdf2(:,i)]); legend('Original','Est post x-risk');
title('PDF of death year');
xlabel('Age');
ylabel('Probability');

%% Expectation
pre_exp = sum(x_pdf2(:,i).*xd);
post_exp = sum(y_pdf2(:,i).*xd);

fprintf(['Your life expectency is ' num2str(pre_exp) ' prior to taking into account x-risks.\n']);
fprintf(['After taking into account x-risks, it is now ' num2str(post_exp) '.\n']);
fprintf(['You just lost ' num2str(pre_exp - post_exp) ' years!\n']);


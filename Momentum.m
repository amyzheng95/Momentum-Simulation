clear all
clc
% Program: Momentum
% Author: David Fetherstonhaugh, Amy Zheng, Shuming Chen, Lauryn Peng,Yueqi Mao 
% Laste Modified: 2015-10-12
% Course: Topics in Finance 1: Quantitative Methods in Finance
% Project: Momentum strategy
% Purpose:
%       Calculates the returns on a long-short momentum pofolio
%       Make a decision on wheher we should invest in the srategy or not
% Inputs:
%       momentum - a 283332x9 vector of monthly data          
% Parameters and variables:
%       thisYear - the year of the momentum.year column 
%       thisMonth - the month of the momentum.month column
%       thisPermno - the permenant code of securities 
%       lag12mYear - the year from 12 months ago
%       lag12mMonth - the month from 12 months ago
%       lag1mYear - the year from 1 month ago
%       lag1mMonth -  the month from 1 month ago
%       thisMomentum - the calculation of the adjustedReturn from a month
%                       ago divided by the adjusedRetun price 12 months ago
%       lag12mPrice - the adjustedPrice 12 months ago
%       lag1mPrice - the adjustedPrice 1 month ago
%       momentumQuantiles -  the dividsion of the securities into 10 quantiles by ranking
%                           their returns 
% Outputs:
%       output - 60x7 dataset
%       output.date - the date from the momenum.dateOfObservation column
%       output.year - the year
%       output.month - the month
%       output.mom1 - the botom 10% which generates the lowest returns
%       output.mom10 - the top 10% which generates the highest returns
%       output.mom -  difference between the top 10% and the bottom 10%
%       output.cumRet - cummulative log return
% Files Used:
%               momentumAssignment20042008.csv          

%% 0 Set up
% Set woking directory
cd ('C:\Users\azheng2\Desktop')

%% 1 Import data
momentum=dataset('File','momentumAssignment20042008.csv','Delimiter',',');

%% 2 Construct year, month and momentum
% Extract the year from momentum.dateOfObservation
momentum.year=floor(momentum.DateOfObservation/10000)

% Extract the month from momentum.dateOfObservation
momentum.month=floor(rem(momentum.DateOfObservation,10000)/100)

%Create a new column of momentums, and fill it wih NaNs
momentum.momentum=0;
momentum.momentum(momentum.momentum==0)=NaN;
 
% Used a for loop to loop over the whole table in order to grab the price
% one month ago and the pice fom 12 months ago
for(i=1:size(momentum));
  
    %the percentage of completeness when the script is running
   if mod(i,1000)==0
            (i/size(momentum,1))*100
    end
    
    %Variables created for identifying the adjustedPrice  
    thisYear=momentum.year(i);
    thisMonth=momentum.month(i);
    thisPermno=momentum.PERMNO(i);
    
    % to get the data of t-12 (12months ago)
    lag12mYear=thisYear-1;
    lag12mMonth=thisMonth;
    
    % to get the data of t-1 (1 month ago)
    lag1mYear=thisYear;
    lag1mMonth=thisMonth-1;
    
    % An if statement to prevent the data of t-1 not to equal 0 when
    % thisMonth is 1
    if lag1mMonth==0;
        lag1mMonth=12;
        lag1mYear=thisYear-1;
    end
  
    % Retrieve the price fo the given variables thisPermno, thisYear,ThisMonth
    lag1mPrice=momentum.adjustedPrice(momentum.PERMNO == thisPermno & momentum.year==(lag1mYear)&momentum.month==(lag1mMonth));
    lag12mPrice=momentum.adjustedPrice(momentum.PERMNO == thisPermno & momentum.year==(lag12mYear) &momentum.month==(lag12mMonth));

    % Calculate the momentum by dividing the price from 1 month ago by the
    % price from 12 months ago 
    thisMomentum=lag1mPrice/lag12mPrice;
    
    % if statement to prevent when there is no data provided for the adjustedPrice
    % 12months ago and 1 month ago
    if(isempty(thisMomentum))
    else 
        momentum.momentum(i)=thisMomentum;
    end
end

%% 3 Construct Momentum Returns
%Create a new dataset named output by retrieving the list of unique dates
%of momentum.dateOfObservation
date=unique(momentum.DateOfObservation);
output=dataset(date);

% Extract year to the output dataset
output.year=floor(output.date/10000);

% Extract month to the output dataset
output.month=floor(rem(output.date,10000)/100);

% for loop to evenly seperate the securities into 10 buckets based on the
% value of the momentum
for (i = 1:size(output,1))
    i
    thisYear = output.year(i);
    thisMonth = output.month(i);
    
    % Evenly seperate the securities into 10 buckets based on the
    % value of the momentum
    momentumQuantiles=quantile(momentum.momentum(momentum.year == thisYear & momentum.month == thisMonth),9);
    
    % Retrive the returns of those securities that fall into the lowest
    % decile for the given variables: thisYear,thisMonth,momontumQuantiles
    output.mom1(i)=mean(momentum.Returns(momentum.year==thisYear & momentum.month==thisMonth & momentum.momentum <= momentumQuantiles(1)));
    
    % Retrive the returns of those securities that fall into the highest
    % decile for the given variables: thisYear,thisMonth,momontumQuantiles
    output.mom10(i)=mean(momentum.Returns(momentum.year==thisYear & momentum.month==thisMonth & momentum.momentum >= momentumQuantiles(9)));
    
    %Calculate the difference of return between the highest decile and the
    %lowest decile securities 
    output.mom(i)=output.mom10(i)-output.mom1(i);
end

%% 4 Plot Cumulative Log Returns Graph
output.cumRet=NaN;

for (i=2:size(output,1))
    if isnan(output.mom(i))    
        output.cumRet(i)=NaN;
    elseif isnan(output.cumRet(i-1))
        output.cumRet(i)=1+output.mom(i);
    else
        output.cumRet(i)=output.cumRet(i-1)*(1+output.mom(i));
    end
end

plot(output.cumRet)

%% 5 Report Generation 
% Please refer to the file named 'Momentum Assignment Report' 

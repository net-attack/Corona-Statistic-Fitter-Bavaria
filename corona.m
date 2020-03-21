function [x, days, values] = corona()
    
    url = "https://www.lgl.bayern.de/gesundheit/infektionsschutz/infektionskrankheiten_a_z/coronavirus/karte_coronavirus/index.htm";
    [days, values] = getMeasurementFromWebpage(url);
    corona_day = values;
    
    Scaling = 12;
    %Convert x from date to hours
    for i=1:length(days)
        x(i) = day(days(i) - (days(1)-caldays(1)))*Scaling;
    end

    %Prepare Data
    [xData, yData] = prepareCurveData( x, corona_day );

    %accumulate
    sum = accumulate(corona_day);

    %Prepare Future
    offset = 5;
    for i=length(x):length(x)+offset
        x(i+1)=x(i)+1*Scaling;
        days(i+1)=days(i)+caldays(1);
    end

    %Fit Expotential
    f = fitting_expo(x, xData, yData);
    
    %FIt Logistical
    f_1 = fitting_logistic(x, xData, yData);


    %Open Figure
    fig = figure(1);
    set(fig, 'Name', 'Overview the current trend in corona cases in bavaria', 'Position', [0 0 1280 960],'MenuBar', 'figure' );

    %Draw cases per day as bars
    bar( days(1:length(yData)), yData );

    %Keep on drawing
    hold on
    %Draw expotential fitting curve
    plot(days, f','*-','LineWidth',2);
    
    %Draw logistic fitting curve
    plot(days, f_1','*-','LineWidth',2);
    
    %Draw overall cases
    plot(days(1:length(sum)), sum,'*-','LineWidth',2);
hold off

fontSize = 17;
xlabel( 'date', 'Interpreter', 'Latex', 'FontSize',fontSize );
set(gca,'FontSize',fontSize)
ylabel( 'count ', 'Interpreter', 'Latex', 'FontSize',fontSize );
set(gca,'FontSize',fontSize)
grid on
legend( 'corona cases per day bavaria', 'grow regression curve bavaria (expotential)','grow regression curve bavaria (logistic)', 'total corona cases bavaria', 'Location', 'NorthWest', 'Interpreter', 'none' );

end



function [days, values] = getMeasurementFromWebpage(url)
     code = webread(url);
     expression = '((?<=<table id="tableFaelle">).*(?=<\/table>))';
     matches = regexp(code,expression,'match');
     values = [];
     count = 1;
     if(~isempty(matches))
        expression = '((?<=<tbody>).*(?=<\/tbody>))';
        matches = regexp(matches{1},expression,'match');
        if(~isempty(matches))
            expression = '((?<=<tr>).*(?=<\/tr>))';
            measurements = regexp(matches{1},expression,'match');
            for i = 1:length(measurements)
                expression = '((<td>).*?(<\/td>))';
                measurement = regexp(measurements{i},expression,'match');
                for j = 1:2:length(measurement)-1
                    expression = '((?<=<td>).*(?=<\/td>))';
                    d = regexp(measurement{j},expression,'match');
                    expression = '((?<=<td>).*(?=<\/td>))';
                    v = regexp(measurement{j+1},expression,'match');
                    daystr = d{1};
                    if(contains(daystr,'Mrz'))
                        daystr= strrep(daystr,'Mrz','März');
                    end
                    da = datetime(daystr,'InputFormat','dd. MMM','Locale','de_DE');

                    days(count) = da;
                    values(count) = str2double(v{1});
                    count = count + 1;
                end
            end
        end
     else
     end
end

function y = accumulate(y_in)
    y(1) = y_in(1);
    for i=2:length(y_in)
        y(i) = y(i-1) + y_in(i);
    end
end


function f = fitting_expo(x, xData, yData)
    
    % Set up fittype and options.
    ft = fittype( 'exp1' );
    opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
    opts.Display = 'Off';
    opts.StartPoint = [0.121024082786032 0.272109116347433];

    % Fit model to data.
    [fitresult, gof] = fit( xData, yData, ft, opts );

    coe = coeffvalues(fitresult);
    f = coe(1)*exp(coe(2)*x);
    f = reshape(f,1,[]);
end

function f = fitting_logistic(x, xData, yData)
    addpath('/logistic5/L5P.m');
    [cf,G]=L5P(xData,yData);
    
    coef = coeffvalues(cf);
    A = coef(1);
    B = coef(2);
    C = coef(3);
    D = coef(4);
    E = coef(5);
    
    
    
    for i = 1: length(x)
            f(i) = D+(A-D)/((1+(x(i)/C)^B)^E);
    end
end
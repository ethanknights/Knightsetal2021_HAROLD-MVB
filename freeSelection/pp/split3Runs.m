function xCells = split3Runs(allX);

%Could improve with mat2cell...
xCells{1} = allX(1:80,:);
xCells{2} = allX(81:160,:);
xCells{3} = allX(161:240,:);

end
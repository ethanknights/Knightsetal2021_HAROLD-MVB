%% check trial timing for methods 
clear 
load('CCIDList.mat')

for s = 1:87
  d=trialInfo.resp{s}

  for t = 1:239
  
    c(t,s) = d(t+1,3) - d(t,3);
  
  end
  
end


figure
for s = 1:20

  subplot(5,4,s)
  plot(c(:,s))
end
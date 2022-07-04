#conda activate --stack neuroconda_2_0
import numpy
from sklearn import svm
import sklearn.model_selection
from sklearn.utils import class_weight
from sklearn.metrics import plot_confusion_matrix, balanced_accuracy_score
#Plotting in matlab now! import matplotlib.pyplot as plt
#Bayes inference in matlab now! import statistics

#SETUP
#==========
dwd = '/imaging/ek03/MVB/FreeSelection/pp/data/singleTrialBetaCSV/'
#get CCIDs
#-------
with open('/imaging/ek03/MVB/FreeSelection/pp/forPythonSubjectList.txt', 'r') as f:
    CCIDs = f.readlines()
f.close()
CCIDs = [x.strip() for x in CCIDs] # remove whitespace characters like `\n` at the end of each line
#get ROIs
#-------
with open('/imaging/ek03/MVB/FreeSelection/pp/forPythonROIList.txt', 'r') as f:
    ROIs = f.readlines()
f.close()
ROIs = [x.strip() for x in ROIs] 



#in/out (To write a misc. subject loop for parallel job submissions; See submitJobs.py)
#-------
fN = ('%s/%s/singleTrialBeta_classify-4Way_ROI-%s_method-%s.csv' % dwd,CCID,ROI,method)
oDir = ('%s/%s',dwd,CCID)
oN_balDecAcc = ('%s/%s/decAcc_classify-4Way_ROI-%s_method-%s.csv' % dwd,CCID,ROI,method)
oN_CM = ('%s/%s/CM_classify-4Way_ROI-%s_method-%s.csv' % dwd,CCID,ROI,method)

#Delete old version of decAcc regScores.
#-------
if os.path.isfile('%s' % oN):
	os.remove('%s' % oN)

#Read data
#-------
d =  numpy.genfromtxt(fN, delimiter=',')
x = d[:,0:-1] #data
y = d[:,-1] #labels; print(d.shape, x.shape,y.shape)


#Init
#-------
#trainDist = numpy.empty(4, dtype=numpy.float)
#trainDistPercentage = numpy.empty(4, dtype=numpy.float)
regScores = numpy.empty(6, dtype=numpy.float)
balScores = numpy.empty(6, dtype=numpy.float)
cmScores = numpy.zeros((6, 4, 4),dtype=numpy.int)

#Setup Stratified K-folds
#-------
skf = sklearn.model_selection.StratifiedKFold(n_splits=6,random_state=0,shuffle=True)

k = 0
for train, test in skf.split(x, y):
	
	k = k + 1

	#assign  k-fold data
	#-------
	x_train = x[train]
	y_train = y[train]
	x_test = x[test]
	y_test = y[test]

	#Assign imbalanced weights & run classifier
	#-------
	class_weights = class_weight.compute_class_weight('balanced',numpy.unique(y_train),y_train)
	class_weights = dict(enumerate(class_weights, 1)) #format to diction ary for clf.fit
	#print('Class weights are', class_weights)
	# This si for untrustworthy data, not needed sample_weight = compute_sample_weight("balanced", y)
	clf = svm.SVC(kernel = 'linear', decision_function_shape = 'ovr', C = 1, class_weight = class_weights).fit(x_train, y_train)

	#Get outputs
	#=======

	#Confusion Matrix
	#-------
	cm = plot_confusion_matrix(clf, x_test, y_test)
	print('\nConfusion Matrix for K-Fold %d' % k)
	print(cm.confusion_matrix)
	cmScores[k-1] = cm.confusion_matrix

	#Unbalanced decAcc
	#-------
	regScores[k-1] = clf.score(x_test,y_test)
	#print(regScores)
	#write
	#regScores.tofile('%s' % oN,sep=',',format='%.3f')

	#Balanced decAcc
	#-------
	y_pred = clf.predict(x_test)
	#print(y_pred)
	balScores[k-1] = balanced_accuracy_score(y_test, y_pred)
	print('balanced score = %.3f' % balScores[k-1])
	#write
	#balScores.tofile('%s' % oN_balDecAcc, sep = ',', format = '%.3f') 

meanBalScores = statistics.mean(balScores)
meanBalScores.tofile('%s' % oN_balDecAcc, sep = ',', format = '%.3f') 
print('\n\n Cross Validation Balanced Score =  %.3f' % meanBalScores)

#Sum CM (1 subject CM across folds)
#-------
# print('\n\n all CMs:')
# print(cmScores)
summedCM = sum(cmScores)
#print(summedCM)
summedCM.tofile('%s' % oN_CM, sep = ',', format = '%.3f') 
#write stuff manually if needed
# f = open('%s' % oN, 'a+')
# f.write('%s\n' % str(regScores))
# f.close


	#=================================
	# End - Additional Checks Below
	#=================================
	#classify
	# clf = sklearn.svm.SVC(kernel = 'linear', decision_function_shape = 'ovr', C = 1, class_weight = class_weights)
	# clf.fit(x_train, y_train)
	# clf.regScores(x_test,y_test)


	# import matplotlib.pyplot as plt
	# from sklearn.datasets import make_blobs


	#Below are checks:
	#(1) trial distribution is kept (almost) constant (e.g. 10% of trials are class 1 in ALL folds) 
	#(2) Summing labels from distribution = 100% of trials in train | test
	# print('\n K-Fold %d' % k)
	# print('\nTrain data\n', train,'\nTest data\n', test,'\n nTrials in train & test\n', train.shape,test.shape,'\n\n') #test set size percentage = 1/n_splits
	# for c in range(4):
	# 	cc = c + 1
	# 	print('Class %d' % cc)
	# 	trainDist[c] = sum(y[train] == cc)
	# 	trainDistPercentage[c] = (trainDist[c]*100/train.shape)
	# 	print('Label distribution:\n %d trials \n %d%%\n\n' % (trainDist[c],trainDistPercentage[c]))
	# print('Total Percentage of class distribution %d' % sum(trainDistPercentage))
	# print('Percentage Split was %d %d %d %d \n' % (trainDist[0],trainDist[1],trainDist[2],trainDist[3]))
	# if sum(trainDistPercentage) != 100:
	# 	import sys
	# 	sys.exit('Class distribution didnt add up to 100%')


#run classifier
#clf = svm.SVC(kernel='linear', C=1)
#regScores = cross_validation.cross_val_score(clf, iris.data, iris.target, cv=cv)

#conda activate --stack neuroconda_2_0
import numpy
from sklearn import svm
import sklearn.model_selection
from sklearn.utils import class_weight
import os
from sklearn.metrics import plot_confusion_matrix, balanced_accuracy_score, confusion_matrix, accuracy_score
#Plotting in matlab now! import matplotlib.pyplot as plt
#Bayes inference in matlab now! import statistics


#Setup
#==========
dwd = '/imaging/ek03/MVB/FreeSelection/pp/data/singleTrialBetaCSV'
method = 'LSS' #method = 'LSA'
maxk = 8
#get CCIDs
#-------
with open('/imaging/ek03/MVB/FreeSelection/pp/forPythonSubjectList.txt', 'r') as f:
    CCIDs = f.readlines()
f.close()
CCIDs = [x.strip() for x in CCIDs] # remove whitespace characters like `\n` at the end of each line
#get ROIs
#-------
ROIs = [
	 	'Mc_L_100vox',
      	'Mc_R_100vox',
      	'Mc_L_500vox',
      	'Mc_R_500vox',
      	'Vent_L_5mm', 
      	'Vent_R_5mm', 
      	'PreCG_L_5mm',
      	'PreCG_R_5mm',
      	'PreCG_L_HOA',
      	'PreCG_R_HOA',
       	]

#MVPA (SVM) for each ROI, per subject
#==========
for ROI in ROIs:
	for CCID in CCIDs:
		#assign filenames
		print('\n\nCCID = %s\nROI = %s\n' % (CCID, ROI))
		fN = '%s/%s/singleTrial-beta_classify-4Way_ROI-%s_method-%s.csv' % (dwd,CCID,ROI,method)
		oDir = '%s/%s' % (dwd,CCID)
		oN_balDecAcc = '%s/%s/decAcc_classify-4Way_ROI-%s_method-%s.csv' % (dwd,CCID,ROI,method)
		oN_CM = '%s/%s/CM_classify-4Way_ROI-%s_method-%s.csv' % (dwd,CCID,ROI,method)

		#delete old output (otherwise will append)
		#-------
		if os.path.isfile('%s' % oN_balDecAcc):
			os.remove('%s' % oN_balDecAcc)
		if os.path.isfile('%s' % oN_CM):
			os.remove('%s' % oN_CM)

		#init
		#-------
		regScores = numpy.empty(maxk, dtype=numpy.float)
		balScores = numpy.empty(maxk, dtype=numpy.float)
		cmScores = numpy.zeros((maxk, 4, 4),dtype=numpy.int)

		#read data
		#-------
		d =  numpy.genfromtxt(fN, delimiter=',')
		x = d[:,0:-1] #data
		y = d[:,-1] #labels; print(d.shape, x.shape,y.shape)

		#Setup Stratified K-folds
		#-------
		skf = sklearn.model_selection.StratifiedKFold(n_splits=maxk,random_state=0,shuffle=True)

		k = 0
		for train, test in skf.split(x, y):

			k = k + 1

			#assign  k-fold data
			#-------
			x_train = x[train]
			y_train = y[train]
			x_test = x[test]
			y_test = y[test]

			#Assign imbalanced weights
			#-------
			class_weights = class_weight.compute_class_weight('balanced',numpy.unique(y_train),y_train)
			class_weights = dict(enumerate(class_weights, 1)) #format to diction ary for clf.fit
			#print('Class weights are', class_weights)
			# sample_weight = compute_sample_weight("balanced", y) #This si for untrustworthy data, already dealing with imbalance above

			#run classifier
			#-------
			clf = svm.SVC(kernel = 'linear', decision_function_shape = 'ovr', C = 1, class_weight = class_weights).fit(x_train, y_train)
			y_pred = clf.predict(x_test) #print(y_pred)

			#Accuracy
			#-------
			#regScores[k-1] = accuracy_score(y_test,y_pred) #regScores[k-1] = clf.score(x_test,y_test)
			#print('reg accuracy = %.3f (NOT SAVED)' % regScores[k-1])
			balScores[k-1] = balanced_accuracy_score(y_test, y_pred)
			print('bal accuracy = %.3f' % balScores[k-1]) #balScores.tofile('%s' % oN_balDecAcc, sep = ',', format = '%.3f') 

			#Confusion Matrix
			#-------
			cmScores[k-1] = confusion_matrix(y_pred,y_test)
			print(cmScores[k-1])

		#Store data
		#-------
		meanBalScores = statistics.mean(balScores)
		meanBalScores.tofile('%s' % oN_balDecAcc, sep = ',', format = '%.3f') 
		print('\n\nCross validated balanced accuracy =  %.3f' % meanBalScores)

		#sum subjects CM's across folds
		#-------
		summedCM = sum(cmScores)
		print(summedCM)
		summedCM.tofile('%s' % oN_CM, sep = ',', format = '%.3f') 
		#Write accuracies/CM manually if needed
		# f = open('%s' % oN, 'a+')
		# f.write('%s\n' % str(regScores))
		# f.close


	#=================================
	# End - Additional Checks Below
	#=================================
	#Below are old checks of stratifying procedure:
	#(1) trial distribution is kept (almost) constant (e.g. 10% of trials are class 1 in ALL folds) 
	#(2) Summing labels from distribution = 100% of trials in train | test
	#trainDist = numpy.empty(4, dtype=numpy.float)
	#trainDistPercentage = numpy.empty(4, dtype=numpy.float)
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
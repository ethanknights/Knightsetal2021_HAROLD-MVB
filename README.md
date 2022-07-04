# Knights et al. (2021). Does Hemispheric Asymmetry Reduction in Older Adults (HAROLD) in motor cortex reflect compensation? Journal of Neuroscience, (45), 9361-9373.


<h2> About </h2>
The repository contains code (R, Matlab, Python & Shell) to replicate the machine learning big-data report published in the Journal of Neuroscience (https://www.jneurosci.org/content/41/45/9361) </br>


<h2> Prerequisities </h2>

* R
  * MASS
  * ggplot2
  * brms
  * bayesfactor
* Matlab
  * SPM
* Python
  * sklearn 
  * numpy
* Datasets
    * For ROIs (definition/timeseries extraction) & multivariate procedures (MVB, MVPA):
        * MVB Sensorimotor Task fMRI & T1-weighted image release004 datasets (request from www.cam-can.org).
    * For R modelling:
        * Download preprocessed data .csv's (www.osf.io/seuz5) 


</br></br>
<h2> 1. f/MRI Preprocessing </h2>
An Automatic Analysis (github.com/automaticanalysis) pipeline preprocessed the Stage 3 Cam-CAN FreeSelection dataset using automaticanalysis. In matlab:

```c
cd freeSelection/aa_cc280_fingerTapping
run_aa
```
  
Standard SPM models can then be generated using matlab:

```c
cd SMT/pp
wrapper
```

Ensure the necessary switches are set to false. e.g. If running from scratch:
```c
done_setupDirs = true; /*switch to false if rerunning
```

<h2> 2. ROI definition  </h2>

During the createROI.m routine, use `SPM_results_ui` to load `data/groupGLM/SPM.mat`. Next, select the peaks of brain activation in right and left motor cortex and create the binary masked Regions of Interest (ROIs):
```c
createROI /*outputs: PreCG_R_70.nii,PreCG_L_70.nii etc.
```

<h2> 3. Machine learning: Multivoxel Pattern Analysis (MVPA) & Multivariate Bayesian Decoding (MVB) </h2>

The convenience wrapper script (`SMT/pp/wrapper.m`) concludes by extracting beta estimates for single trials to single subject *.mat files. </br> For machine learning, follow the MVB functions/README via the `SMT/MVB/` routine.

For MVPA (using SVM classification), follow the Matlab routine (`freeSelection/pp/classify_run.m`) which can be validated using an additional sk-learn Python routine (`freeSelection/pp/classify.py`)


<h2> 4. R: Brain-Behaviour Modelling </h2>

The MVB sub-directories contains matlab code to create the data-tables for R analysis (`SMT/MVB/doPostProcessing.m`) though this post-processing script will fail to collect behavioural phenotype data (e.g. Reaction Times) unless your workstation is connected to the MRC CBU environment.

For convenience, the processed data-tables can be downloaded from the Open Science Framework (www.osf.io/seuz5). </br>

Move these `data.csv`'s to the appropriate csv directory (e.g. for the analysis reported in Figure 4, place the data.csv in `SMT/MVB/R/70voxel_model-sparse/csv/data.csv`). 
</br>

In R, load the appropriate `data.csv` with `SMT/MVB/R\<analysistype\>/<analysistype\>/run_001_loadData.R`.
</br> From there, any of the classical or Bayesian analyses can be performed using the dataframe: `df`.

For example, to plot the hyperactivation of motor cortex in older adults:
```r
setwd('HAROLD-MVB/tree/main/SMT/MVB/R')
source('run_fMRI_univariate.R')
#This boils down to writing a point ggplot based on the following robust linear regression model:
rlm_model <- rlm(univariateMean_R ~ age0z2, 
                 data = df, psi = psi.huber, k = 1.345)
```
![HAROLD_image](https://raw.githubusercontent.com/ethanknights/HAROLD-MVB/main/SMT/MVB/R/dropMVBSubjects-0/70voxel_model-sparse/images/univariateMean_RH.png)


<h1> How to Acknowledge </h1>
Please cite: Knights, E., Morcom, A., & Henson, R. N. (2021). Does Hemispheric Asymmetry Reduction in Older Adults (HAROLD) in motor cortex reflect compensation? Journal of Neuroscience, (45), 9361-9373.
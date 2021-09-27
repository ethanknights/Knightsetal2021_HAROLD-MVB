# Does Hemispheric Asymmetry Reduction in Older Adults (HAROLD) in motor cortex reflect compensation?

<h2> Contents </h2>
Matlab & R Code is generally similar between Experiment 1 (SMT) and Experiment 2 (FreeSelection) but has differences (e.g. plot axis, nVolumes, MVPA). Mainly, the SMT Experiment directory is used in the general pipeline example below. </br> </br>

<h2> Prerequisities </h2>

* Matlab
  * SPM
* R
  * ggplot2
  * MASS
  * brms
  * bayesfactor
* Datasets
    * For ROIs (definition/timeseries extraction) & multivariate procedures (MVB, MVPA):
        * MVB Sensorimotor Task fMRI & T1-weighted image release004 datasets (request from www.cam-can.org).
    * For R modelling:
        *    Download preprocessed data .csv's (osf.io/seuz5) 
</br></br>
<h1> 1. f/MRI Preprocessing </h1>
Initial preprocessing was performed for the Stage 3 Cam-CAN FreeSelection dataset using automaticanalysis (github.com/automaticanalysis), to match the stage 2 fMRI pipeline branch. In matlab:

```c
cd freeSelection/aa_cc280_fingerTapping
run_aa
```
  
Then standard SPM models are generated using code in SMT/pp. In matlab:

```c
cd SMT/pp
wrapper
```

Take care to flip the necessary switches to false e.g.
```c
done_setupDirs = true; /*switch to false if rerunning
if ~done_setupDirs; setupDirs; end
```

<h1> 2. ROI definition  </h1>

At the createROI.m stage of wrapper.m, stop and use `SPM_results_ui` to load the `data/groupGLM/SPM.mat` & leave cursor on peaks of the to-be-defined ROI before using:
```c
createROI /*outputs: PreCG_R_70.nii,PreCG_L_70.nii etc.
```

<h1> 3. Multivoxel Pattern Analysis (MVPA) & Multivariate Bayesian Decoding (MVB) </h1>

The above `SMT/pp/wrapper.m` script is currently setup to conclude by extracting beta estimates for single trials (and MVPA in Experiment 2). </br> Otherwise MVB is run via the `SMT/MVB/` routine.

<h1> 4. R: Brain-Behaviour Modelling </h1>

The MVB sub-directories contains matlab code to create the data-tables for R analysis (`SMT/MVB/doPostProcessing.m`). Download these from osf.io/seuz5 (as this will fail to collect phenotypes like RT unless in the MRC CBU environment).

Ensure the `data.csv`'s are placed in the appropriate csv directory (e.g. for the main analysis place the data.csv in `SMT/MVB/R/70voxel_model-sparse/csv/data.csv`, or control analysis: `SMT/MVB/R/70voxel_model-sparse_controlVoxelSize-constrictBilateral/csv/data.csv`).

In R, load the appropriate `data.csv` with `SMT/MVB/R\<analysistype\>/\<analysistype\>/run_001_loadData.R`.
</br> From there, any of the reported analyses can be run with the dataframe: `df`.

For example, the HAROLD effect:
```r
setwd('HAROLD-MVB/tree/main/SMT/MVB/R')
source('run_fMRI_univariate.R')
#essentially comprising a point ggplot based on:
rlm_model <- rlm(univariateMean_R ~ age0z2, 
                 data = df, psi = psi.huber, k = 1.345)
```
![HAROLD_image](https://raw.githubusercontent.com/ethanknights/HAROLD-MVB/main/SMT/MVB/R/dropMVBSubjects-0/70voxel_model-sparse/images/univariateMean_RH.png)
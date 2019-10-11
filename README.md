# FARM
This repository is a MATLAB implementation of FARM processing, for removing fMRI artifacts from EMG recordings.

# Requirements
- MATLAB : https://www.mathworks.com/. Tested version : R2017b
- FieldTrip, a MATLAB tooblox : https://github.com/fieldtrip/fieldtrip
- **no specific MATLAB official toolbox** => if you encounter a compatibility problem, please open an issue.

# Exemple
Open and run [example_denoise_sample_dataset_MEMB.m](sample_dataset/example_denoise_sample_dataset_MEMB.m)

# Based on
- Van der Meer, J. N., Tijssen, M. A. J., Bour, L. J., van Rootselaar, A. F., & Nederveen, A. J. (2010). **Robust EMG–fMRI artifact reduction for motion (FARM)**. Clinical Neurophysiology, 121(5), 766–776. https://doi.org/10.1016/j.clinph.2009.12.035
- R.K. Niazy, C.F. Beckmann, G.D. Iannetti, J.M. Brady, and S.M. Smith. **Removal of FMRI environment artifacts from EEG data using optimal basis sets**. NeuroImage 28 (2005) 720 – 737. https://doi.org/10.1016/j.neuroimage.2005.06.067
- P.J. Allen, O. Josephs, R. Turner. **A Method for Removing Imaging Artifact from Continuous EEG Recording during Functional MRI**. NeuroImage 12, 230-239 (2000). https://doi.org/10.1006/nimg.2000.0599
- S.I. Gonçalves, P.J.W. Pouwels, J.P.A. Kuijer, R.M. Heethaar, J.C. de Munck. **Artifact removal in co-registered EEG/fMRI by selective average subtraction**. Clinical Neurophysiology 118 (2007) 2437–2450. https://doi.org/10.1016/j.clinph.2007.08.017
- Jeffrey C. Lagarias, James A. Reeds, Margaret H. Wright, and Paul E Wright. **Convergence Properties of the Nelder--Mead Simplex Method in Low Dimensions**. December 1998 SIAM Journal on Optimization 9(1):112-147. https://doi.org/10.1137/S1052623496303470

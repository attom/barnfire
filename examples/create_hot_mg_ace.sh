#! /usr/bin/env bash
# A. Till Jul 2017

#
# NB write_njoy's Emax=3.6 eV * (T/3000K) if T > 3000 K
#


source activate py27

##################
# SET DIRECTORIES
##################

# You need to set and export the following:
# export SCRATCH_BARN=...
# export ENDF=...
# export NJOY=...

##################################
# SET PROBLEM-DEPENDENT VARIABLES
##################################

# The specific list of materials for which to generate NJOY inputs
# Used in calls to materials.py and when weighting spectra are calculated in the last call to indicators.py
mList=(tsFUEL_STAR tsH2O_STAR)

# The group structure to use outside the RRR in the thermal and fast energy ranges.
# G=shem-361 would point to ../dat/energy_groups/shem-361.txt
#G=scale-44-tweaked
G=c5g7

# How many Legendre moments to use for the scattering transfer matrices
L=3

# Which reactions to include in the PDT XS file. Recommended: use 'abs' if absorption edits are needed
# Use './materials.py -h' for more information
rxnOpt=abs

############################
# GENERATE CROSS SECTIONS
############################

# Step 0: Initialize your scratch directory
scriptdir=`pwd`
srcdir=../src
cd $srcdir
srcdir=`pwd`
./Initialize.py $scriptdir $0
# Step 1: Generate the NJOY inputs
./materials.py -m ${mList[*]} -G $G -L $L -v
# Step 2: Run NJOY to generate the PENDF files from ENDF files.
# Then run NJOY again to generate the GENDF files from PENDF files.
cd $SCRATCH_BARN/xs
./RunPendf.sh
./RunGendf.sh
# Step 3: Do a Bondarenko iteration to get PDT-formatted MG XS
cd $srcdir
./materials.py -b -m ${mList[*]} -p $rxnOpt -v
cd $scriptdir
# The result should be a list of .data files in $SCRATCH_BARN/xs/pdtxs
#
# Step 4: Run NJOY to generate the ACE files (can be done after step 2)
cd $SCRATCH_BARN/xs
./RunAce.sh
# Step 5: Copy ACE files and create xsdir
cd ace/xdata
./copyAce.sh
cd $scriptdir
# The result should be ACE files and xsdir (tells MCNP where the ACE files are) in $SCRATCH_BARN/xs/ace/xdata
exit

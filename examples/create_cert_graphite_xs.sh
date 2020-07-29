#! /usr/bin/env bash
# A. Till Dec 2016

############################
# INITIALIZE VARIABLES
############################

source activate py27

## !!!!!
# You need to set and export the following:
# export SCRATCH_BARN=...
# export ENDF=...
# export NJOY=...
## !!!!!

# The specific list of materials to generate NJOY inputs for / read NJOY outputs from
# This is only used in calls to materials.py
mList=(mtTGRAPHITE_0)

# The MG group structure to use
# G=c57 would point to ../dat/energy_groups/c5g7.txt
G=cert-146

# How many Legendre moments to use for the scattering transfer matrices
L=0

# Which reactions to include in the PDT XS file. Recommended: use 'abs' if absorption edits are needed
# Use './materials.py -h' for more information
rxnOpt=abs

############################
# GENERATE CROSS SECTIONS
############################

#NB: In many cases, if a previous step has run successfully, you don't need
# to rerun it to run a later step if you make changes that affect that later
# step only.

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
./RunAce.sh
# Step 3: Do a Bondarenko iteration to get PDT-formatted MG XS
cd $srcdir
./materials.py -b -m ${mList[*]} -p $rxnOpt -v
cd $scriptdir
# The result should be a list of .data files in $SCRATCH_BARN/xs/pdtxs


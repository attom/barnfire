#! /usr/bin/env bash
# A. Till Aug 2020

############################
# INITIALIZE VARIABLES
############################

## !!!!!
# You need to set and export the following:
# export SCRATCH_BARN=...
# export ENDF=...
# export NJOY=...
## !!!!!

# The specific list of materials to generate NJOY inputs for / read NJOY outputs from
mList=(puMetal hpu) #hheu hleu

# The group structure to use outside the RRR in the thermal and fast energy ranges.
# G=shem-361 would point to ../dat/energy_groups/shem-361.txt
G=shem-361
G=c5g7
G=scale-44

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
#./RunPendf.sh
#./RunGendf.sh
# Step 3: Do a Bondarenko iteration to get PDT-formatted MG XS
cd $srcdir
./materials.py -b -m ${mList[*]} -p $rxnOpt -v
cd $scriptdir
# The result should be a list of .data files in $SCRATCH_BARN/xs/pdtxs


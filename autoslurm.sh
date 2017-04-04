#!/usr/bin/env bash

# DESCRIPTION:
#   Wraps the given code in a slurm file and runs it
#   The default walltime is 2 hours 
#   Any number of slurm options may follow the script
# USAGE: ./autoslurm.sh mycode.sh [options]

code=$1
shift

base=${code%.*}
filename="__${base}.pbs"

[[ -d archive ]] || mkdir archive
mv -f err* out* archive
if [[ -f $filename ]]
then
    mv $filename archive/$filename.$RANDOM
fi

cat > $filename << EOL
#!/usr/bin/env bash
#SBATCH --job-name=$base
#SBATCH --error=err_$base.%J
#SBATCH --output=out_$base.%J
EOL

[[ `echo "$@" | grep -- '--nodes'` ]] || \
    echo '#SBATCH --nodes=1' >> $filename

[[ `echo "$@" | grep -- '--cpus-per-task'` ]] || \
    echo '#SBATCH --cpus-per-task=8' >> $filename

[[ `echo "$@" | grep -- '--time'` ]] || \
    echo '#SBATCH --time=2:00:00' >> $filename

for o in $@
do
    echo "#SBATCH $o"
done >> $filename

echo -e "\ncd \$SLURM_SUBMIT_DIR" >> $filename

cat $code |
    # remove the hasbang line
    grep -v '^#!' >> $filename

# submit the script
sbatch $filename && echo "Job Submitted" >&2 || echo "Failed to submit job" >&2

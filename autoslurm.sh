#!/usr/bin/env bash

# DESCRIPTION:
#   Wraps the given code in a slurm file and runs it
#   The default walltime is 2 hours 
#   Any number of slurm options may follow the script
# USAGE:
#   # to wrap and submit a script:
#   ./autoslurm.sh mycode.sh [options]
#   # to kill the thing
#   ./abort_mycode.sh

code=$1
shift

base=${code%.*}
base=$(tr '/' '_' <<< $base)
filename=${base}.pbs


[[ -d archive ]] || mkdir archive
mv err* out* archive || echo "All clean"
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

[[ "$@" =~ '--nodes' ]] || \
    echo '#SBATCH --nodes=1' >> $filename

[[ "$@" =~ '--cpus-per-task' ]] || \
    echo '#SBATCH --cpus-per-task=8' >> $filename

[[ "$@" =~ '--time' ]] || \
    echo '#SBATCH --time=2:00:00' >> $filename

for o in $@
do
    echo "#SBATCH $o"
done >> $filename

echo "base=$base" >> $filename
echo >> $filename
echo 'cd $SLURM_SUBMIT_DIR' >> $filename

cat >> $filename << OUTER_EOL
abort_cmd=abort_\${base}.sh
cat > \$abort_cmd << INNER_EOL
#!/usr/bin/env bash
# Kill autoslurm run of '\$base'
scancel \$SLURM_JOB_ID
rm \$abort_cmd
INNER_EOL
chmod 755 \$abort_cmd
OUTER_EOL


cat $code |
    # remove the hasbang line
    grep -v '^#!' >> $filename

# When the script completes, remove the abort script
echo 'wait ; rm $abort_cmd' >> $filename

# submit the script
sbatch $filename && echo "Job Submitted" >&2 || echo "Failed to submit job" >&2

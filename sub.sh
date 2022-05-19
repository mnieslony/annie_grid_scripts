# setup fife_utils first. Njobs limit = 10k
# all credits for this script belong to M. O'Flaherty
jobsub_submit -N 1 --memory=2048MB --expected-lifetime=long --resource-provides=usage_model=DEDICATED,OPPORTUNIST -G annie file:///annie/app/users/mnieslon/send_grid/grid_antinu.sh

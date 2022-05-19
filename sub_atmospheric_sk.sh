# setup fife_utils first. Njobs limit = 10k
# all credits for this script belong to M. O'Flaherty
jobsub_submit -N 3500 --expected-lifetime=long --resource-provides=usage_model=DEDICATED,OPPORTUNIST -G annie file:///annie/app/users/mnieslon/send_grid/grid_atmospheric_sk.sh

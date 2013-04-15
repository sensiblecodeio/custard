# pre-commit.sh
. activate
git stash -q --keep-index
./run_tests.sh
RESULT=$?
git stash pop -q
[ $RESULT -ne 0 ] && exit 1
mocha test/unit
exit 0

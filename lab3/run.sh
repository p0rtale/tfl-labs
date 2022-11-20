# Запускать из tfl-labs: ./lab3/run.sh

echo "====== TEST ======"
cat lab3/tests/test.txt
lua lab3/src/lab3.lua < lab3/tests/test.txt > lab3_output.txt
echo "===================="

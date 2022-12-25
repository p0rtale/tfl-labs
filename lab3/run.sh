# Запускать из tfl-labs: ./lab3/run.sh

echo "====== PILLING EXAMPLE ======"
cat lab3/tests/pilling_example.txt
lua lab3/src/lab3.lua < lab3/tests/pilling_example.txt > lab3_pilling_example_output.txt
echo "============================="
echo

echo "====== REPLACE ALL ======"
cat lab3/tests/replace_all.txt
lua lab3/src/lab3.lua < lab3/tests/replace_all.txt > lab3_replace_all_output.txt
echo "========================="

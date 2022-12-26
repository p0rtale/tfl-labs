echo "====== TEST 1 ======"
cat lab1/tests/test1.txt
echo "--------------------"
lua lab1/src/lab1.lua < lab1/tests/test1.txt
echo "===================="
echo

echo "====== TEST 2 ======"
cat lab1/tests/test2.txt
echo "--------------------"
lua lab1/src/lab1.lua < lab1/tests/test2.txt
echo "===================="
echo

echo "====== TEST 3 ======"
cat lab1/tests/test3.txt
echo "--------------------"
lua lab1/src/lab1.lua < lab1/tests/test3.txt
echo "===================="
echo

echo "====== TEST 4 ======"
cat lab1/tests/test4.txt
echo "--------------------"
lua lab1/src/lab1.lua < lab1/tests/test4.txt
echo "===================="

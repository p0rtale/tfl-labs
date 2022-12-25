echo "====== TEST 1 ======"
cat lab2/tests/test1.txt
echo "--------------------"
lua lab2/src/lab2.lua < lab2/tests/test1.txt
echo "===================="
echo

echo "====== TEST 2 ======"
cat lab2/tests/test2.txt
echo "--------------------"
lua lab2/src/lab2.lua < lab2/tests/test2.txt
echo "===================="
echo

echo "====== TEST 3 ======"
cat lab2/tests/test3.txt
echo "--------------------"
lua lab2/src/lab2.lua < lab2/tests/test3.txt
echo "===================="
echo

echo "====== TEST 4 ======"
cat lab2/tests/test4.txt
echo "--------------------"
lua lab2/src/lab2.lua < lab2/tests/test4.txt
echo "===================="

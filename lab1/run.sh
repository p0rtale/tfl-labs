echo "====== TEST 1 ======"
cat tests/test1.txt
echo "--------------------"
lua lab1.lua < tests/test1.txt
echo "===================="
echo

echo "====== TEST 2 ======"
cat tests/test2.txt
echo "--------------------"
lua lab1.lua < tests/test2.txt
echo "===================="
echo

echo "====== TEST 3 ======"
cat tests/test3.txt
echo "--------------------"
lua lab1.lua < tests/test3.txt
echo "===================="
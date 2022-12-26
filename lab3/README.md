# Построение коммутативного образа (<a href=https://github.com/TonitaN/FormalLanguageTheory/blob/main/2022/tasks/pilling1973_Parikh_image.pdf>Пиллинг<a/>)

in progress...
  
## Запуск программы

Запуск в корне:

```
lua lab3/src/lab3.lua < path/to/test.txt > path/to/output.txt
```

Примеры тестов можно найти в lab3/tests.

## Входные данные

```
Grammar
```

```
Grammar = Rule { Rule } .
Rule = Nterm "->" Term { Term } .
Term = Nterm | LowLetter | Empty .
Nterm = "[" Letter { Letter } Digit { Digit } "]" .
```

Letter - латинская буква. <br>
LowLetter - строчная латинская буква.

## Выходные данные

Выводятся коммутативные образы языков всех нетерминалов грамматики, а также соответствующие <a href=https://clck.ru/32sUEk> полулинейные соотношения между буквами<a/>.

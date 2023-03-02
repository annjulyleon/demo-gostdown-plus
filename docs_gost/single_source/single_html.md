mkdocs крут, но не всегда нужен полноценный сайт с документацией. Иногда нужен просто одностраничный HTML с навигацией, чтобы быстро отправлять инженерам по запросу.
К счастью здесь ничего сложного придумывать не надо, так как pandoc уже все умеет, нужно только подобрать правильное ~~заклинание~~ команду.

Шаблон для pandoc можно взять готовый, я использую [easy-pandoc-templates](https://github.com/ryangrose/easy-pandoc-templates) by [ryangrose](https://github.com/ryangrose). Их легко можно адаптировать для своих нужд, скачать все необходимые ресурсы, чтобы шаблоны работали оффлайн.

Команда для конвертации кучки .md файлов в HTML:

```powershell
pandoc -s $(Get-Content html_include.txt) -f markdown --quiet --template=easy-template.html --lua-filter=include_files.lua --lua-filter=linebreaks.lua --lua-filter=metadata_processor.lua --filter pandoc-crossref --citeproc -o output.html --toc
```

В файле `html_include.txt` на каждой строке перечислены все md файлы, которые хотим слепить в одностраничный HTML. В скрипте `create_simple_html.ps1` эта команда параметризована, так что можно легко вызывать скрипт в тасках VSCode. 

В таске VSCode команда для вызова получилась развесистая, так как помимо сборки документа, нужно также скопировать все картинки. Это делается автоматически таской.
К сожалению, из таски не получится вызвать команду замены путей к картинкам (из-за экранирования PowerShell будет ругаться на неправильные паттерны регулярных выражений), поэтому эту команду придется выполнить вручную. В папке `/build` нужно выполнить команду вида:

```powershell
foreach ($file in (Get-ChildItem .\web *.html -rec)) {(Get-Content $file.PSPath) | Foreach-Object { $_ -replace '..\\single_source\\_img\\', '_img/' } | Set-Content $file.PSPath }
```

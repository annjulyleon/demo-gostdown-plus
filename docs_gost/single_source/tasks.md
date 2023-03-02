Я уже немного писала [про таски](https://annjulyleon.github.io/docops/docops-gostdown/#tasks) для запуска стандартных батников Gostdown. Но в тасках можно вызывать скрипт `build.ps1` напрямую и передавать ему все необходимые параметры. Это позволило убрать из проекта дублирующиеся скрипты и bat и создать одну единственную задачу для сборки всех документов.

Рассмотрим вот такую таску из демонстрационного проекта:

```json
{
            "label": "Build Doc",
            "detail": "Build selected in docx_include.txt to build docs",
            "type": "shell",
            "options": {
                "cwd": "${workspaceFolder}/docs_gost/${input:doc}/"
            },
            "command": "${workspaceFolder}\\scripts\\build.ps1 -md $(Get-Content docx_include.txt) -template ${workspaceFolder}\\docs_gost\\template.docx -luafilter ${workspaceFolder}\\scripts -docx ${workspaceFolder}\\build\\${input:doc}.docx -embedfonts",
            "presentation": {
                "echo": true,
                "reveal": "always",
                "focus": false,
                "panel": "shared",
                "showReuseMessage": false,
                "clear": true
            },
            "group": {
                "kind": "build",
                "isDefault": false
            }
        }
```

Как видно, это просто команда из `build.bat` скрипта Gostdown. Добавлен параметр `-luafilter`, в котором указан путь к фильтрам pandoc. Кроме того, обратите внимание, чтобы отработали правильно все скрипты, рабочая директория должна быть установлена в корне собираемого документа (параметр `options.cwd`). 
Список файлов .md, которые нужно собрать, теперь лежат в файле `docx_include.txt` в корне документа.

В таске используются переменные [input variables](https://code.visualstudio.com/docs/editor/variables-reference#_input-variables), о которых уже говорилось [выше](#обновление-свойств-документа). Таким образом, эту таску можно запускать для всех документов: при запуске пользователю будет предложено выбрать документ для сборки.

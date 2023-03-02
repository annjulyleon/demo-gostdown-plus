В Gostdown для формирования документа docx используется шаблон, в котором задается титул, название документа, децимальный номер и прочие общие сведения. 
Если документов в проекте много, то держать в репозитории несколько шаблонов расточительно, особенно, если отличаются они только названием и децимальными номерами.

К счастью, у меня уже есть скрипт для обновления полей документов [update_docx_props](https://github.com/annjulyleon/doc-scripts/tree/main/update_docx_props). 
Понадобилась лишь доработка напильником, чтобы можно было вызывать скрипт для одного файла (эта версия лежит [вот тут](https://github.com/annjulyleon/doc-scripts/tree/main/update_docx_props/update_docx_props_single), рядышком). 

Получается вот такой workflow:

1. Собрать документ. Документ сохранен в директорию `/build` (настраивается в таске).
2. Запустить таску «Update docx fields». Выбрать из списка документ (документ соответствует названию файла и директории).
3. Скрипт обновления свойств будет запущен для выбранного документа. 

Настройка:

1. Создать в директории проекта папку `/build`.
2. В папку `scripts` сохранить скрипт `update_docx_props.ps1`.
3. В папке `scripts/configs` создать конфигурационный файл для документа. В конфигурационном файле указать свойства, которые нужно обновлять.
   
   ```xml
   <?xml version="1.0"?>
   <configuration>
      <customProperties>
        <add key="DeviceName" value="Красивое название"/>
        <add key="DocTitle" value="Описание программы"/>
        <add key="DecimalNumber" value="АБВГ.00002 01 13"/>
        <add key="DocSubtitle" value="Подзаголовок"/>
        <add key="DocYear" value="2023"/>
    </customProperties>
    <builtinProperties>
        <add key="Title" value="Красивое название. Описание программы"/>
        <add key="Subject" value="Красивое название"/>
        <add key="Keywords" value="description"/>
        <add key="Comments" value="2023"/>
    </builtinProperties>
    <vsdProperties>
    </vsdProperties>
   </configuration>
   ```

4. Создать таску для VS Code в `.vscode/tasks.json`:
   
   ```json
   {
            "label": "Update docx fields",
            "detail": "Update builded document",
            "type": "shell",
            "options": {
                "cwd": "${workspaceFolder}/build/"
            },
            "command": "${workspaceFolder}\\scripts\\update_docx_props.ps1 -dir ${workspaceFolder}\\build -conf ${workspaceFolder}\\scripts\\configs\\${input:doc}.xml -filename ${input:doc}.docx",
            "presentation": {
                "echo": true,
                "reveal": "always",
                "focus": false,
                "panel": "shared",
                "showReuseMessage": false,
                "clear": true
            }
        }
   ```

5. В таске используется [input variables](https://code.visualstudio.com/docs/editor/variables-reference#_input-variables). Их удобно использовать, например, для запуска одной таски для нескольких директорий:
   
   ```json
   "inputs": [
        {
            "id": "doc",
            "description": "Document Path: ",
            "type": "pickString",
            "options": [
                "example_doc",
                "another_doc"
            ],
            "default": "example_doc"
       },
    ]
   ```

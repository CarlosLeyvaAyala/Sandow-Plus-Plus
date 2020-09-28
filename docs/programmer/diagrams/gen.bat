@echo off
for %%i IN (*.mmd) do (
    @echo off
    echo Creating Mermaid file "%%~ni.png"
    mmdc -i %%i -o %%~ni.png -s 2 -t forest -b "#FFF8ED"
    rem mmdc -i %%i -o %%~ni.svg -s 2 -b "#f5f5f5" -t dark
    echo Optimizing "%%~ni.png"
    pngquant  --ext=.png --force --quality=0-70 --nofs %%~ni.png
    @echo off
)

@echo on

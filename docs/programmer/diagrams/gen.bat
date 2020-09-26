@echo off
for %%i IN (*.mmd) do (
    echo mmdc
    mmdc -i %%i -o %%~ni.png -t forest
    echo pngquant
    pngquant  --ext=.png --force %%~ni.png
)
pause

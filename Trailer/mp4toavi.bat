@echo off
echo =========================================
echo MP4 to AVI batch script using ffmpeg v1.0
echo =========================================
echo.
set /p SourceDir= "Enter the source directory -> "
echo Ok, SOURCE set as %SourceDir%
set /p TargetDir= "And now the target directory -> "
echo TARGET set as %TargetDir%
echo.
echo Press any key to start the batch process
pause>nul
cd /d %SourceDir%
for %%f in (*.mp4) do ffmpeg -i "%SourceDir%\%%f" -c copy -copyts "%TargetDir%\%%f.avi"
echo.
echo Done, press any key to exit...
pause>nul
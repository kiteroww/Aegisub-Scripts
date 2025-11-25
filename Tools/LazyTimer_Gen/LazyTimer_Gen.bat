@echo off
setlocal EnableDelayedExpansion

set /p IN="Enter input file (e.g. video.mp4): "
set /p CHAPTER="Enter chapter number (e.g. 01): "
set /p USE_VAD="Generate VAD and spectral flux? (y/n): "

set "FFMPEG=ffmpeg"
set "VADFLUX=vadflux.exe"
set "BASE=%CHAPTER%_Retimes"

if /i "%USE_VAD%"=="y" (
    set "PRE=%BASE%_pre.wav"
    set "AUDIO_INPUT=!PRE!"
    set "DURATION=0.03"
) else (
    set "AUDIO_INPUT=%IN%"
    set "DURATION=0.2"
)

set "LOG30=%BASE%_30.txt"
set "LOG40=%BASE%_40.txt"
set "LOG50=%BASE%_50.txt"
set "VAD=%BASE%_vad.tsv"
set "FLUX=%BASE%_flux.tsv"

echo.

if /i "%USE_VAD%"=="y" (
    echo [1/6] Preprocessing audio...
    "%FFMPEG%" -y -i "%IN%" -ac 1 -ar 16000 -af "highpass=f=80,lowpass=f=8000,dynaudnorm=f=150:g=5" "!PRE!" -hide_banner -loglevel error
    set STEP=2
) else (
    set STEP=1
)

echo [!STEP!/3] Generating -30dB silence detection...
"%FFMPEG%" -i "!AUDIO_INPUT!" -af "silencedetect=n=-30dB:d=!DURATION!" -f null - 2> "%LOG30%"

set /a STEP+=1
echo [!STEP!/3] Generating -40dB silence detection...
"%FFMPEG%" -i "!AUDIO_INPUT!" -af "silencedetect=n=-40dB:d=!DURATION!" -f null - 2> "%LOG40%"

set /a STEP+=1
echo [!STEP!/3] Generating -50dB silence detection...
"%FFMPEG%" -i "!AUDIO_INPUT!" -af "silencedetect=n=-50dB:d=!DURATION!" -f null - 2> "%LOG50%"

if /i "%USE_VAD%"=="y" (
    echo [5/6] Generating VAD and spectral flux...
    "%VADFLUX%" "!PRE!" --vad "%VAD%" --flux "%FLUX%"
    
    echo [6/6] Cleaning up temporary files...
    del "!PRE!"
)

echo.
echo Process completed successfully.
echo Generated files:
echo   - %LOG30%
echo   - %LOG40%
echo   - %LOG50%

if /i "%USE_VAD%"=="y" (
    echo   - %VAD%
    echo   - %FLUX%
)

echo.
pause
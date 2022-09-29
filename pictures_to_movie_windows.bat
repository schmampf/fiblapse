@ECHO OFF
:: Oliver Irtenkauf, 2022

:: You might need to change:
:: - start Number (if you want to skip frames, or if you start with higher number)
:: - input file names
:: - input file type
:: - output name
:: - sample name
:: - detector name
:: - date
:: - machine

set data_name=2ND_FIBSLICE
set start_number=0
set data_format=TIF
set output=output

set sample="OI-22f-06"
set detector="SE2"
set datum="27.09.2022"
set machine="MANNI"
set copyright="Universitaet Konstanz"

echo Input/Output
echo name     : %data_name%
echo start    : %start_number%
echo format   : %data_format%
echo output   : %output%

echo Metadata
echo sample   : %sample%
echo detector : %detector%
echo date     : %datum%
echo machine  : %machine%
echo copy     : %copyright%
PAUSE

ffmpeg^
    -y^
    -r 30^
    -start_number %start_number%^
    -i %data_name%%%04d.%data_format%^
    -metadata title=%sample%^
    -metadata album=%detector%^
    -metadata artist=%machine%^
    -metadata comment=%date%^
    -metadata copyright=%copyright%^
    -vf scale=1024:-2^
    -c:v libx264^
    -crf 16^
    -preset veryslow^
    -pix_fmt yuv420p^
    -r 30^
    %output%.mp4

ECHO Finished.
PAUSE

:: ### Detailed Explanation and Linux Code

::## Pixelformat yuv420p (en.wikipedia.org/wiki/YUV)
::#  Basictranformation from RGB in brightness (Y) and colorplane (UV)
::#  YUV420p indicades that the brigthness is in each pixel,
::#  whereas the color is just given for 2*2 pixel.
::#  This takes the resolution of human sight into account,
::#  similar the spatial distribution of cones and rods.
::#  jpeg is in yuvj422p.
::#  YUV420P: alues from 0 to 16 get mapped to the same output level, as do values 239-255. (Television quality, common)
::#  YUVJ420P uses the full range from 0 to 255 (Computer quality, uncommon, tecchnical better, but "overshooting")
::#  https://en.wikipedia.org/wiki/YUV#Numerical_approximations

::## Encoder libx265 (trac.ffmpeg.org/wiki/Encode/H.265)
::#  Compression algorithm up to date till 2020 (then H.266)
::#  Contant Rate Factor most efficient way to control flexible bitrate.
::#  (Optional Two-Pass Encoding important for target file size)

::## Conctant Rate Factor crf
::#  Range from 0 (lossless) to 51 (heavily kompressed), default is 28
::#  "Subjectively speaking, I’d have to say CRF 12 is indistinguishable and CRF 16 is good enough for virtually all cases. For the less discerning, CRF 20 is probably fine for watching, but CRF 24 is beginning to become annoying and CRF 28 is the least that could be considered acceptable. The result seems to be consistent across x264 and x265, although (unexpectedly) the difficult case seemed to tolerate higher CRF values probably as the harsh patterns were not as easily resolved by the eye and noise was less easily seen. As a result, even having a “rule of thumb” CRF can be hard, as it depends on the viewer, viewing equipment, source characteristics and sensitivity to artifacts." - https://goughlui.com/2016/08/27/video-compression-testing-x264-vs-x265-crf-in-handbrake-0-10-5/
::#  Conclusion: Try crf 16

::## Preset and Tune
::#  Preset Range: ultrafast, superfast, veryfast, faster, fast, medium, slow, slower, veryslow, (placebo)
::#  The slower you go, the more details can be saved. => veryslow
::#  Tune: preset settings. Don't do it. You are in controll!

::## Profile setting/ Level (en.wikipedia.org/wiki/Advanced_Video_Coding#Levels)
::#  use -profile:v baseline -level 3.0 for high compatibility
::#  use -profile:v high -level 4.2 for fHD
::#  use -profile:v main -level 3.1 for HD
::#  use default for 4K ;) (should be 5.2)

::## sonstiges
::#  use -movflags +faststart for video beeing able of webbuffering

::## Output/Input Framerate
::#  -r 30 sets a framerate to smoothly 30fps, default is 25fps.
::#  Set it for input and set it for output. probably check -framerate
::#  You don't wanna have some dead frames or framedrops. Be aware!

::### Comments
::# nice                                                      # enables priority of process
::#    -n 19\                                                 # sets priority low (high -20 to 19 low)
::#    time\                                                  # gives back time process needed in the end
::#    ffmpeg\                                                # calls ffmpeg
::#    [global options]                                       # first you can set global options, eg. -y/-n for yes/no
::#    -hide_banner\                                          # hide copyright stuff - boooring
::#    -v quiet -stats\                                       # hide warning and errors, shows progress
::#    -r 30\                                                 # set input reading framerate
::#    -start_number 0001\                                    # tells input reading, with wich number to start, idk
::#    -i %04d.jpg\                                           # inputs all the images from 0001.jpg up to 9999.jpg
::#    -metadata title="middle of the square"\                # Meta Title of the timelapse (keep in mind to change it)
::#    -metadata album="Ljubljana"\                           # Meta Info about album, artist, year, somment and copyright
::#    -metadata artist="schmampf"\
::#    -metadata date="2019"\
::#    -metadata comment="made with OpenCamera and ffmpeg"\
::#    -metadata copyright="Oliver Irtenkauf"\
::#    -vf scale="-2:720"\                                    # final dimension of the video (w:h), -1 for respect ratio, -2 prevent error
::#    -c:v libx265\                                          # the codec
::#    -crf 16\                                               # constant rate factor (from lossless 0-28-51 up to most compression)
::#    -preset veryslow\                                      # trades of calculating time over compressionrate. veryslow recommended
::#    -pix_fmt yuv420p\                                      # pixel format (still really confused about this one)
::#    -r 30\                                                 # set output framerate, should be same as input
::#    output_HD.mp4                                          # outputname
::# echo "finished HD!"                                       # tells you, when it's finished
::# totem output_HD.mp4 2>/dev/null                           # shows the video in totem player, suppress errors
::# ffmpeg -i output_4K.mp4 -hide_banner                      # shows video properties, hide copyright bullshit.

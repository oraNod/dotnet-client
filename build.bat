if [%generator%] == [""] set generator="Visual Studio 14 2015 Win64"
echo Using generator -G %generator%

set home_drive=%CD:~0,2%
subst /D Y:
subst Y: .
Y:
cd \

rmdir /s /q build_windows
mkdir build_windows
cd build_windows

set "buildTest=%~1"

if [%CLIENT_VERSION%] neq [] set V1=%CLIENT_VERSION:*/=%

for /f "tokens=1,2,3,4 delims=." %%a in ("%V1%") do (
   set v_1major=%%a
   set v_2minor=%%b
   set v_3micro=%%c
   set v_4qualifier=%%d
)

if [%version_2minor%] eq [] set version_2minor=0
if [%version_3micro%] eq [] set version_3micro=0
if [%version_4qualifier%] eq [] set version_4qualifier=SNAPSHOT

set package_name=%v_1major%.%v_2minor%.%v_3micro%.%v_4qualifier%

if [%HOTRODCPP_HOME%] == [] set HOTRODCPP_HOME=%checkoutDir%/cpp-client/build_win/_CPack_Packages/WIN-x86_64/ZIP/infinispan-hotrod-cpp-%package_name%-WIN-x86_64
echo Using HOTRODCPP_HOME=%HOTRODCPP_HOME%

call :unquote u_generator %generator%
cmake -G "%u_generator%" -DHOTRODCPP_HOME=%HOTRODCPP_HOME% -DHOTROD_VERSION_MAJOR=%v_1major% -DHOTROD_VERSION_MINOR=%v_2minor% -DHOTROD_VERSION_PATCH=%v_3micro% -DHOTROD_VERSION_LABEL=%v_4qualifier% -DSWIG_DIR=%SWIG_DIR% -DSWIG_EXECUTABLE=%SWIG_EXECUTABLE% -DPROTOBUF_PROTOC_EXECUTABLE_CS="%PROTOBUF_PROTOC_EXECUTABLE_CS%" -DGOOGLE_PROTOBUF_NUPKG="%GOOGLE_PROTOBUF_NUPKG%" -DPROTOBUF_INCLUDE_DIR=%PROTOBUF_INCLUDE_DIR% -DJBOSS_HOME=%JBOSS_HOME% -DIKVM_CUSTOM_BIN_PATH=%IKVM_CUSTOM_BIN_PATH% -DOPENSSL_ROOT_DIR=%OPENSSL_ROOT_DIR% -DCONFIGURATION=RelWithDebInfo -DENABLE_DOXYGEN=1 -DENABLE_JAVA_TESTING=FALSE %~4 ..
if %errorlevel% neq 0 goto fail

cmake --build . --config RelWithDebInfo
if %errorlevel% neq 0 goto fail

if  not "%buildTest%"=="skip" ( 
ctest -V -C RelWithDebInfo
)

if %errorlevel% neq 0 goto fail

cpack -G ZIP --config CPackSourceConfig.cmake
if %errorlevel% neq 0 goto fail

cpack -G ZIP --config CPackConfig.cmake
if %errorlevel% neq 0 goto fail

cpack -G WIX -C RelWithDebInfo
if %errorlevel% neq 0 goto fail

cmake %* -P ../wix-bundle.cmake

if %errorlevel% neq 0 goto fail
endlocal
goto eof

:unquote
  set %1=%~2
  goto :EOF

:fail
    %home_drive%
    subst Y: /D
    ()
    exit /b 1
:eof
%home_drive%
subst /D Y: 

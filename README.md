# Build Qt5 for Windows with Powershell

This build scripts are created for Powershell in Windows.
Sources will be downloaded from original repository on git://code.qt.io/qt/qt5.git

Primarily this script was created for my BuildSystem wich is described [here](https://adirmeier.de/0_Blog/ID_157/index.html).  
This scripts should work on other systems too.  

Since this Version, there are only two major requirements to get this build working.  
All other tools, wich are required for build, will be downloaded automatically and set 
to PATH for building.  
The download will only happen if Scripts wasn't able to find a local Version of this tools.
So it is still recommended to install it on your system.

If error will occur you can use *Powershell ISE* for debugging, or contact me.

## Requirements

Mandatory Requirements:
 - Powershell Version >= 3.0
 - Visual Studio 2013/2015/2017

Recommended Requirements:
 - Python 2.7: Required for Webengine/ICU  
    Common Tools will download a Portable Version of WinPython if not available
 - Perl: Required for OpenSSL/ICU  
    Common Scripts will download a Portable Version of StrawberryPerl if not available
 - Subversion: Required for ICU  
    Common Scripts will download a Portable Version of Subversion if not available
 - NASM: Required for OpenSSL  
    Common Scripts will download a Portable Version of NASM if not available
 - Git
    Common Scripts will download a Portable Version of Git if not available
 - Cygwin (if ICU required)
    Common Scripts will download a Portable Version of Cygwin if not available

## How to build

For example, to build the Version 5.8.0 , execute the following command:

    .\Make.ps1 -VisualStudio 2017 -Architecture x64 -Version 5.8.0
    
Default Options (bold are mandatory):
 - **VisualStudio**: 2012/2013/2015/2017
 - **Architectrue**: x64/x86
 - **Version**: Version of Qt
 - Static: $true/$false (default: $false)
 - DebugBuild: $true/$false (default: $false) <-- Currently not working, -debug-and-release is hardcoded0
 - StaticRuntime: $true/$false (default: $false)
 - DoPackage: $true/$false (default: $false) for creating zip of output
 - AdditionalConfig: String to append on configure command (default: "")
 
Addtional Options and Features:
 - BuildOpenssl $true/$false (default: $false)  
   OpenSSL will be autmatic downloaded, build and integrated in Qt
 - BuildICU $true/$false (default: $false)  
   ICU will be autmatic downloaded, build and integrated in Qt
   
If different configurations are required to pass to configure.bat, use 
**-AdditionalConfig** wich will appended to generated configuration.

## Features and Bugs

Building Qt takes several hours and its diffcult to check each possible configuration.  
It's possible that some configurations will not work.

All configurations i have in use are currently working. I will update if an bug will
occur. But if you have an not working configuration, please write a bugreport with
your configuration, and i will try to fix it.

Some features like OpenSSL and ICU was part of my requirements, so i added it to configurtaion.  
If other features are required, please let me know.

Contact me here on github, on my [Webpage](https://adirmeier.de) or per mail *coolcow_ccos[at]yahoo.com* 
    
## Output Format

The name of the output folder will be generated as follows:

    qt5-$Version-$VisualStudioYear-$Architecture[_static][_debug][_MT]

Conditions for Postfixes:
 - **_static**: will be set if *-Static* is enabled
 - **_debug**: will be set if *-DebugBuild* is enabled
 - **_MT**: will be set if *-StaticRuntime* is enabled

## Tested Configurations  
 
I have not the ressources to test several configurations.  
It would be nice if you would feedback me, if configurations work or fail.
  
Here a list of configurations wich was successfully build:

### Qt5 build with Visual Studio 2017:

    # Build Qt5.6.2 with ICU for Webkit and Webengine + OpenSSL (x64)
    .\Make.ps1 -VisualStudio 2017 -Architecture x64 -Version 5.6.2 -BuildICU $true -BuildOpenSSL $true
    # Build Qt5.6.2 with ICU for Webkit and Webengine + OpenSSL (x86)
    .\Make.ps1 -VisualStudio 2017 -Architecture x86 -Version 5.6.2 -BuildICU $true -BuildOpenSSL $true
    #
    # Build Qt5.8 with ICU for Webkit and Webengine + OpenSSL
    .\Make.ps1 -VisualStudio 2017 -Architecture x64 -Version 5.8.0 -BuildICU $true -BuildOpenSSL $true
    #
    # Build Qt5.9.1 static + some interruptens and restart with NoClean
    .\Make.ps1 2017 x64 5.9.1 -Static $true -NoClean $true
    # 32bit with OpenSsl and Static
    .\Make.ps1 2017 x86 5.9.1 -BuildOpenssl $true -Static $true -StaticRuntim $true 

### Qt5 build with Visual Studio 2015:

    # Build Qt5.6.2 with ICU for Webkit and Webengine + OpenSSL (x64)
    .\Make.ps1 2015 x64 5.6.2.1 -BuildICU $true -BuildOpenssl $true
    
List will grow for every new build Qt5

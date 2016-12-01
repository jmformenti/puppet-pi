# pi_opencv_python

#### Table of Contents

1. [Overview](#overview)
2. [Module Description ](#module-description)
3. [Setup](#setup)
    * [What pi_opencv_python affects](#what-pi_opencv_python-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with pi_opencv_python](#beginning-with-pi_opencv_python)
4. [Usage](#usage)
5. [Limitations](#limitations)

## Overview

Puppet module to install OpenCV and Python on Raspberry Pi 2 or 3 (tested on Raspbian Jessie).

## Module Description

Install OpenCV (2.x or 3.x) with Python (2.x or 3.x) in a python virtual environment (based on [Adrian Rosebrock](http://www.pyimagesearch.com/2016/04/18/install-guide-raspberry-pi-3-raspbian-jessie-opencv-3/) tutorials).

This module has been developed with Puppet 3.7.2.

Quick example:
```
class { "pi_opencv_python":
	python_version => "3.4",
	opencv_version => "3.0.0",
	virtualenv_name => "cv"
}
```

## Setup

### What pi_opencv_python affects

* Installs OpenCV and Python, if it's not already installed, in your system.
* Creates, if doesn't exists, the python virtual environment.
* Installs OpenCV python library in the python virtual environment.

### Setup Requirements

To use this module you need about 3GB free disk space and puppet installed (>3.x).

### Beginning with pi_opencv_python

Example of install OpenCV on Raspberry:

1. Install this puppet module on Raspberry
```
sudo apt-get install puppet git
git clone TODO
puppet module build jmf-py_opencv_python
puppet module install jmf-py_opencv_python/pkg/jmf-py_opencv_python-0.1.0.tar.gz
```
2. Create puppet manifest to install, for example, install.pp:
```
class { "pi_opencv_python":
	python_version => "3.4",
	opencv_version => "3.0.0",
	virtualenv_name => "cv"
}
```
3. Install OpenCV and Python, the timing for this step is about 1.5-2 hours. Use background execution:
```
nohup sudo puppet apply install.pp &
```
* To view log to ensure all it's ok:
```
tail -f nohup.out
```

You can install other versions of OpenCV in another python virtual environment, then you need only execute steps 2 and 3.

## Usage

Module parameters:

[*python_version*]
   Python version to install, possible values: 2.7 or 3.4, etc. Default: 2.7

[*opencv_version*]
   OpenCV version to install, possible values: 2.4.13, 3.0.0, 3.1.0, etc. Default: 2.4.13

[*virtualenv_name*]
   Python virtual environment name where install OpenCV. Default: cv

[*user*]
   User owner of Python virtual environment. Default: pi

[*user_home*]
   User owner home. Default: /home/pi

[*clean_on_finish*]
   Remove temporal files (OpenCV source, temporal shell, etc) and dirs when finished.

## Limitations

* OpenCV 2.x is not compatible with Python 3.x
* Using Python3 only works with version 3.4. OpenCV build ever detects the system version of Python3 and when you install virtualenv package, Python 3.4 is installed Python 3.4, then only it's possible use 3.4.
  The solution could be modify the build step of OpenCV to set a given Python version, I did some tries with no luck.


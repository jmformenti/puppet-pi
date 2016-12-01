# == Class: pi_opencv_python
#
# Install OpenCV with Python on Raspberry.
#
# === Parameters
#
# [*python_version*]
#   Python version to install, possible values: 2.7, 3.3, 3.4, etc. Default: 2.7
#
# [*opencv_version*]
#   OpenCV version to install, possible values: 2.4.13, 3.0.0, 3.1.0, etc. Default: 2.4.13
#
# [*virtualenv_name*]
#   Python virtual environment name where install OpenCV. Default: cv
#
# [*user*]
#   User owner of Python virtual environment. Default: pi
#
# [*user_home*]
#   User owner home. Default: /home/pi
#
# [*clean_on_finish*]
#   Remove temporal files (OpenCV source, temporal shell, etc) and dirs when finished.
#
# === Variables
#
# [*cmake_extra_options*]
#   Extra options to use when building OpenCV depending on OpenCV version.
#
# [*opencv_major_version*]
#   OpenCV's major version, 2 or 3.
#
# [*python_major_version*]
#   Python's major version, 2 or 3.
#
# [*python_version_nodot*]
#   Python version without dots, for example, 3.3 -> 33. Used in the name of OpenCV compiled library.
#
# === Examples
#
#  class { 'pi_opencv_python':
#    python_version => "3.4",
#    opencv_version => "3.1.0",
#    virtualenv_name => "cv"
#  }
#
# === Authors
#
# J.M.Formentí <jmformenti@gmail.com>
#

include python

class pi_opencv_python (
	$python_version = $pi_opencv_python::params::python_version,
	$opencv_version = $pi_opencv_python::params::opencv_version,
	$virtualenv_name = $pi_opencv_python::params::virtualenv_name,
	$user = $pi_opencv_python::params::user,
	$user_home = $pi_opencv_python::params::user_home,
	$clean_on_finish = $pi_opencv_python::params::clean_on_finish
) inherits pi_opencv_python::params {

	Exec {
		path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ]
	}

	case $opencv_version {
		/^2.*/: {
			$cmake_extra_options = "-D BUILD_NEW_PYTHON_SUPPORT=ON"
			$opencv_major_version = $OPENCV_MAJOR_VERSION_2
		}
		/^3.*/: {
			$cmake_extra_options = "-D OPENCV_EXTRA_MODULES_PATH=${user_home}/opencv_contrib-${opencv_version}/modules"
			$opencv_major_version = $OPENCV_MAJOR_VERSION_3
		}
	}

	case $python_version {
		/^2.*/: {
			$python_major_version = $PYTHON_MAJOR_VERSION_2
		}
		/^3.*/: {
			$python_major_version = $PYTHON_MAJOR_VERSION_3
		}
	}

	if $python_major_version == $PYTHON_MAJOR_VERSION_2 and $opencv_major_version == $OPENCV_MAJOR_VERSION_3 {
		fail("Not possible install OpenCV 3.x with Python 2.x, must be Python 3.x")
	}

	$python_version_nodot = regsubst($python_version, '\.', '', 'G')

	exec { "apt-get update":
		command => "apt-get update"
	}->
	package { ["build-essential", "cmake", "pkg-config", "libjpeg-dev", 
		"libtiff5-dev", "libjasper-dev", "libpng12-dev", "libavcodec-dev", 
		"libavformat-dev", "libswscale-dev", "libv4l-dev",
		"libxvidcore-dev", "libx264-dev", "libgtk2.0-dev", "libatlas-base-dev", 
        	"gfortran"]:
		ensure => present
	}->
	exec { "download opencv":
		command => "wget -O opencv-${opencv_version}.zip https://github.com/Itseez/opencv/archive/${opencv_version}.zip",
		user => $user,
		cwd => $user_home,
		onlyif => "test ! -f ${user_home}/opencv-${opencv_version}.zip",
		timeout => 0,
	}->
	exec { "unzip opencv":
		command => "unzip opencv-${opencv_version}.zip",
		user => $user,
		cwd => $user_home,
		onlyif => "test ! -d ${user_home}/opencv-${opencv_version}"
	}->
	exec { "download opencv-contrib":
		command => "wget -O opencv_contrib-${opencv_version}.zip https://github.com/Itseez/opencv_contrib/archive/${opencv_version}.zip",
		user => $user,
		cwd => $user_home,
		onlyif => [ "test $opencv_major_version = $OPENCV_MAJOR_VERSION_3", "test ! -f ${user_home}/opencv_contrib-${opencv_version}.zip" ],
		timeout => 0,
	}->
	exec { "unzip opencv-contrib":
		command => "unzip opencv_contrib-${opencv_version}.zip",
		user => $user,
		cwd => $user_home,
		onlyif => [ "test $opencv_major_version = $OPENCV_MAJOR_VERSION_3", "test ! -d ${user_home}/opencv_contrib-${opencv_version}" ]
	}->
	class { 'python':
		version => "python${python_version}",
		pip => 'present',
		virtualenv => 'present',
		dev => 'present'
	}->
	file { "${user_home}/.virtualenvs":
		ensure => directory,
		owner => $user,
		group => $user
	}->
	python::virtualenv { "${user_home}/.virtualenvs/${virtualenv_name}":
		ensure => present,
		version => $python_version,
		venv_dir => "${user_home}/.virtualenvs/${virtualenv_name}",
		owner => $user,
	}->
	python::pip { 'virtualenv':
		ensure => present,
		pkgname => 'virtualenv',
	}->
	python::pip { 'virtualenvwrapper':
		ensure => present,
		pkgname => 'virtualenvwrapper',
	}->
	file_line { "Add WORKON_HOME in profile":
		path => "${user_home}/.profile",
		line => 'export WORKON_HOME=$HOME/.virtualenvs',
		match => "^export WORKON_HOME=.*$"
	}->
	file_line { "Add virtualenvwrapper in profile":
		path => "${user_home}/.profile",
		line => "source /usr/local/bin/virtualenvwrapper.sh",
		match => "^source /usr/local/bin/virtualenvwrapper.sh"
	}->
	python::pip { 'numpy' :
		ensure => present,
		pkgname => 'numpy',
		virtualenv => "${user_home}/.virtualenvs/${virtualenv_name}",
		owner => $user,
	}->
	file { "${user_home}/opencv-${opencv_version}/build":
		ensure => directory,
		owner => $user
	}->
	file { "/tmp/build_opencv.sh":
		ensure => present,
		content => "#!/bin/bash\nexport WORKON_HOME=${user_home}/.virtualenvs\nsource /usr/local/bin/virtualenvwrapper.sh\ncd ${user_home}/opencv-${opencv_version}/build\nworkon ${virtualenv_name}\ncmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local -D INSTALL_PYTHON_EXAMPLES=ON ${cmake_extra_options} -D BUILD_EXAMPLES=ON ..\n",
		owner => $user,
		mode => 755
	}->
	exec { "build opencv":
		command => "/tmp/build_opencv.sh",
		user => $user,
		cwd => "/tmp"
	}->
	exec { "compile opencv":
		command => "make -j4",
		cwd => "${user_home}/opencv-${opencv_version}/build",
		timeout => 0,
		user => $user,
	}->
	exec { "install opencv":
		command => "make install",
		cwd => "${user_home}/opencv-${opencv_version}/build",
		timeout => 0,
	}->
	exec { "ldconfig":
		command => "ldconfig",
		cwd => "${user_home}/opencv-${opencv_version}/build",
	}->
	exec { "rename cv2.so":
		command => "ln -sf cv2.cpython-${python_version_nodot}m.so cv2.so",
		cwd => "/usr/local/lib/python${python_version}/site-packages",
		onlyif => "test $python_major_version = $PYTHON_MAJOR_VERSION_3",
	}->
	exec { "add opencv to virtualenv":
		command => "cp /usr/local/lib/python${python_version}/site-packages/cv2.so cv2.so",
		cwd => "${user_home}/.virtualenvs/${virtualenv_name}/lib/python${python_version}/site-packages",
		user => $user,
	}->
	exec { "remove opencv zip":
		command => "rm ${user_home}/opencv-${opencv_version}.zip",
		onlyif => "test ${clean_on_finish}"
	}->
	exec { "remove opencv contrib zip":
		command => "rm ${user_home}/opencv_contrib-${opencv_version}.zip",
		onlyif => [ "test ${clean_on_finish}", "test $opencv_major_version = $OPENCV_MAJOR_VERSION_3" ]
	}->
	exec { "remove opencv source dir":
		command => "rm -rf ${user_home}/opencv-${opencv_version}",
		onlyif => "test ${clean_on_finish}"
	}->
	exec { "remove opencv contrib source dir":
		command => "rm -rf ${user_home}/opencv_contrib-${opencv_version}",
		onlyif => [ "test ${clean_on_finish}", "test $opencv_major_version = $OPENCV_MAJOR_VERSION_3" ]
	}->
	exec { "remove temp file":
		command => "rm /tmp/build_opencv.sh",
	}

}

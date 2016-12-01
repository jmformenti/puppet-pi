# == Class: pi_opencv_python::params
#
# The pi_opencv_python Module default configuration settings.
#
class pi_opencv_python::params {
	$python_version = '2.7'
	$opencv_version = '2.4.13'
	$virtualenv_name = 'cv'
	$user = 'pi'
	$user_home = '/home/pi'
	$clean_on_finish = true

	$OPENCV_MAJOR_VERSION_2 = '2'
	$OPENCV_MAJOR_VERSION_3 = '3'

	$PYTHON_MAJOR_VERSION_2 = '2'
	$PYTHON_MAJOR_VERSION_3 = '3'
}

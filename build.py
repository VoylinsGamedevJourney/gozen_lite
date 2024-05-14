import subprocess


#subprocess.run(
#	'scons -j 11 target=template_debug platform=windows', 
#	shell=True, cwd='gd_extensions/gozen')
subprocess.run(
	'scons -j 11 target=template_debug platform=linux', 
	shell=True, cwd='gd_extensions/gozen')
#
#
#subprocess.run(
#	'scons -j 11 target=template_release platform=windows', 
#	shell=True, cwd='gd_extensions/gozen')
#subprocess.run(
#	'scons -j 11 target=template_release platform=linux', 
#	shell=True, cwd='gd_extensions/gozen')

import subprocess


#subprocess.run(
#	'scons -j 4 target=template_debug platform=windows', 
#	shell=True, cwd='gd_extensions/gozen')
subprocess.run(
	'scons -j 4 target=template_debug platform=linux', 
	shell=True, cwd='gd_extensions/gozen')

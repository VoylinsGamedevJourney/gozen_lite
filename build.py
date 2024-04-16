import os


os.chdir("gd_extensions/gozen")
os.system("scons -j 10 target=template_debug")
os.chdir("../..")

.PHONY: all clean

define MAKEFILE_SOURCE_CODE
from tqdm import tqdm
import base64
import os

SRC_PATH = "./src"
BUILD_PATH = "./build/makefile"

files = [os.path.join(SRC_PATH,file) for file in os.listdir(SRC_PATH)]
folders = [folder for folder in files if not os.path.isfile(folder)]
files = [file for file in files if os.path.isfile(file)]

# gather all files
while folders != []:
    new_folders = []
    for folder in folders:
        current_folder =  [os.path.join(folder,file) for file in os.listdir(folder)]

        for file in current_folder:
            if os.path.isfile(file):
                files.append(file)
            else:
                new_folders.append(file)

    folders = new_folders


created_folders = []
variables = ""
build_instructions = chr(10) + "all: dump_sources" + chr(10)*2 + "dump_sources:" + chr(10)

# write source code in the makefile
with open(BUILD_PATH,"w") as makefile:
    for file in tqdm(files):
        dirname = os.path.dirname(file)
        if dirname not in created_folders:
            build_instructions += chr(9) + "mkdir " + dirname + chr(10)
            created_folders.append(dirname)
        with open(file,"r",encoding="latin-1") as f:
            variables += "define " + file + chr(10)  + base64.b64encode(f.read().encode()).decode() + chr(10) + "endef" + chr(10)
            build_instructions +=  chr(9) + "@echo " + chr(36) + "(" + file + ") | base64 -d > " + file + chr(10) + chr(9) + "@echo " + file + chr(10)

    makefile.write(variables + build_instructions)
endef

export MAKEFILE_SOURCE_CODE

all: _makefile

_makefile: write_makefile_py build 
	@python .MAKEFILE.py
	@rm .MAKEFILE.py

write_makefile_py:
	@echo "$$MAKEFILE_SOURCE_CODE" > .MAKEFILE.py

build:
	@mkdir build

clean:
	@rm -Rf build/*
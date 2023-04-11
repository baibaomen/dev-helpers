@echo off
chcp 65001 > nul
echo This tool is used to traverse directories and generate a list of effective files in the directory structure, excluding those listed in .gitignore.
echo.
where python >nul 2>nul
if errorlevel 1 (
    echo Python was not found on your computer. Please install Python before running this tool.
    echo Opening the official Python download page for you...
    start https://www.python.org/downloads/
    pause
    exit
)
echo # -*- coding: utf-8 -*- > list_files.py
echo. >> list_files.py
echo import os >> list_files.py
echo from pathlib import Path >> list_files.py
echo from pathspec import PathSpec >> list_files.py
echo from pathspec.patterns import GitWildMatchPattern >> list_files.py
echo import pyperclip >> list_files.py
echo. >> list_files.py
echo def main(): >> list_files.py
echo    print("") >> list_files.py
echo    target_dir = input("Please enter the directory to traverse: ") >> list_files.py
echo. >> list_files.py
echo    try: >> list_files.py
echo        with open(os.path.join(target_dir, ".gitignore"), "r") as gitignore_file: >> list_files.py
echo            gitignore_lines = gitignore_file.readlines() >> list_files.py
echo    except FileNotFoundError: >> list_files.py
echo        gitignore_lines = [] >> list_files.py
echo. >> list_files.py
echo    pathspec = PathSpec.from_lines(GitWildMatchPattern, gitignore_lines) >> list_files.py
echo. >> list_files.py
echo    output = [f"{target_dir} contains following files:"] >> list_files.py
echo    for root, dirs, files in os.walk(target_dir): >> list_files.py
echo        if ".git" in dirs: >> list_files.py
echo            dirs.remove(".git") >> list_files.py
echo. >> list_files.py
echo        for file in files: >> list_files.py
echo            filepath = os.path.join(root, file) >> list_files.py
echo            relative_path = os.path.relpath(filepath, target_dir) >> list_files.py
echo. >> list_files.py
echo            if not pathspec.match_file(relative_path): >> list_files.py
echo                print(relative_path) >> list_files.py
echo                output.append(relative_path) >> list_files.py
echo. >> list_files.py
echo    pyperclip.copy(os.linesep.join(output)) >> list_files.py
echo    print("") >> list_files.py
echo    print("Directory traversal complete. Results have been copied to the clipboard.") >> list_files.py
echo. >> list_files.py
echo if __name__ == "__main__": >> list_files.py
echo    main() >> list_files.py
echo. >> list_files.py
pip install pathspec
pip install pyperclip
python list_files.py
pause
del list_files.py

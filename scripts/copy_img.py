import shutil
import os
import argparse
import glob
import json
from pathlib import Path
import itertools


def copy_files(source_folder, target_folder):
    source = Path(source_folder)
    destination = Path(target_folder)

    destination.mkdir(parents=True, exist_ok=True)

    source_files = itertools.chain(
        source.rglob("*.png"),
        source.rglob("*.jpg"),
        source.rglob("*.bmp"),
        source.rglob("*.gif"))
    copied_files = []

    for image_file in source_files:
        if Path.exists(destination.joinpath(image_file.name)) == False:
            shutil.copy(image_file, destination.joinpath(image_file.name))
            copied_files.append(f"{destination}\{image_file.name}")

    copied_files = {"copied_files": copied_files}

    with open('copied_files.json', 'w') as f:
        json.dump(copied_files, f)


def remove_copied_files():
    with open('copied_files.json') as json_file:
        data = json.load(json_file)

    for cf in data["copied_files"]:
        Path.unlink(Path(cf))

    Path.unlink(Path('copied_files.json'))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Copy images from multiple subfolders to destination",
                                     formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument("-c", "--copy", action="store_true",
                        help="Flag to copy images")
    parser.add_argument("-s", "--source", type=str, default="..\docs_gost",
                        help="Source")
    parser.add_argument("-d", "--destination", type=str, default="..\docs_gost\_img",
                        help="Destination")
    parser.add_argument("-r", "--remove", action="store_true",
                        help="Flag to remove copied images from root")

    args = vars(parser.parse_args())

    if args["copy"]:
        copy_files(args["source"], args["destination"])
        print("Images copied!")

    if args["remove"]:
        remove_copied_files()
        print("Images removed!")

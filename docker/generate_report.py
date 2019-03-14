#!/usr/bin/python3

import subprocess as sp
import argparse
import pandas as pd
import sys
import os
from jinja2 import Environment, FileSystemLoader

# some variables for common reference.  Their actual values are tied to the 
# template we are filling
TEMPLATE = 'template'
OUTPUT = 'output'
GIT_REPO = 'git_repo'
GIT_COMMIT = 'git_commit'
INPUT_MATRIX = 'input_count_matrix'
ANNOTATIONS = 'annotations_file'
DESEQ_OUTPUT = 'deseq2_output_filename'
NC_FILE = 'normalized_counts_filename'
FIGURES_ZIP = 'output_figures_zip_name'


class AnnotationDisplay(object):
    '''
    A simple object to carry info to the markdown report.
    '''
    def __init__(self, sample_name, condition):
        self.name = sample_name
        self.condition = condition


def get_jinja_template(template_path):
    '''
    Returns a jinja template to be filled-in
    '''
    template_dir = os.path.dirname(template_path)
    env = Environment(loader=FileSystemLoader(template_dir), lstrip_blocks=True, trim_blocks=True)
    return env.get_template(
        os.path.basename(template_path)
    )

def create_annotation_objects(annotation_file):
    df = pd.read_csv(
        annotation_file, 
        sep='\t', 
        header=None, 
        names=['sample','condition']
    )
    return [AnnotationDisplay(r['sample'], r['condition']) for i,r in df.iterrows()]


def get_r_environment():
    '''
    Gets the sessionInfo for all bioc packages
    '''
    cmd = 'R -e "library(\'DESeq2\'); sessionInfo();"'
    p = sp.Popen(cmd, shell=True, stderr=sp.PIPE, stdout=sp.PIPE)
    stdout, stderr = p.communicate()
    print(stdout)
    print(stderr)
    return stdout.decode('utf-8')


def parse_input():
    '''
    Parses the commandline input, returns a dict
    '''
    parser = argparse.ArgumentParser()
    parser.add_argument('-i', required=True, dest=INPUT_MATRIX)
    parser.add_argument('-a', required=True, dest=ANNOTATIONS)
    parser.add_argument('-d', required=True, dest=DESEQ_OUTPUT)
    parser.add_argument('-n', required=True, dest=NC_FILE)
    parser.add_argument('-f', required=True, dest=FIGURES_ZIP)
    parser.add_argument('-t', required=True, dest=TEMPLATE)
    parser.add_argument('-o', required=True, dest=OUTPUT)
    parser.add_argument('-r', required=True, dest=GIT_REPO)
    parser.add_argument('-c', required=True, dest=GIT_COMMIT)
    args = parser.parse_args()
    return vars(args)


def fill_template(context, template_path, output):
    if os.path.isfile(template_path):
        template = get_jinja_template(template_path)
        with open(output, 'w') as fout:
            fout.write(template.render(context))
    else:
        print('The report template was not valid: %s' % template_path)
        sys.exit(1)


if __name__ == '__main__':

    # parse commandline args and separate the in/output from the
    # context variables
    arg_dict = parse_input()
    output_file = arg_dict.pop(OUTPUT)
    input_template_path = arg_dict.pop(TEMPLATE)

    # get the info about R/Bioc we used:
    session_info = get_r_environment()

    # get a list of objects for showing the sample annotations:
    annotations_object_list = create_annotation_objects(arg_dict[ANNOTATIONS])
    
    # make the context dictionary
    context = {}
    context.update(arg_dict)
    context[INPUT_MATRIX] = os.path.basename(context[INPUT_MATRIX])
    context[ANNOTATIONS] = os.path.basename(context[ANNOTATIONS])
    context.update({'session_info': session_info})
    context.update({'annotation_objs': annotations_object_list})

    # fill and write the completed report:
    fill_template(context, input_template_path, output_file)

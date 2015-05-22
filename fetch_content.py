import sys
import re
import io
import os.path
import tarfile
import pprint
import yaml
import requests


def mkdirp(pth):
    try:
        os.makedirs(os.path.normpath(pth))
    except OSError:
        pass


def needs_format(s):
    if isinstance(s, basestring):
        return re.search(r'(?<!\\)\{.+(?<!\\)\}', s) is not None
    elif isinstance(s, list):
        return any(needs_format(x) for x in s)
    elif s is None:
        return False

    raise Exception("unknown value type:", repr(s))


def load_projects(fname):
    content = yaml.load(open(fname))
    defaults = content.get('defaults', {})

    projects = []
    for desc in content.get('projects', []):
        proj = dict()
        proj.update(defaults)
        proj.update(desc)

        while any(needs_format(x) for x in proj.values()):
            for k, v in proj.items():
                if isinstance(v, basestring):
                    proj[k] = v.format(**proj)
                elif isinstance(v, list):
                    proj[k] = [x.format(**proj) for x in v]

        projects.append(proj)

    return projects


def fetch_project(destination, org, repo_name, name, ref, path, ignores=None, target=None):
    url = 'https://github.com/{org}/{repo_name}/archive/{ref}.tar.gz'.format(
        org=org, repo_name=repo_name, ref=ref
    )

    resp = requests.get(
        url,
        auth=requests.auth.HTTPBasicAuth(
            os.environ['GITHUB_USERNAME'],
            os.environ['GITHUB_TOKEN']
        ),
        stream=True
    )

    tarfile_stream = io.BytesIO(resp.raw.read())

    tgz = tarfile.open(mode='r:gz', fileobj=tarfile_stream)

    if ignores is None:
        ignores = []

    if path and not path.endswith('/'):
        path += '/'

    for tar_info in tgz:
        if not tar_info.isfile():
            continue

        fname = tar_info.name

        if any(re.match(ignore, fname) for ignore in ignores):
            continue

        # Strip path components
        # always strip the first one
        path_parts = fname.split('/', 1)

        if len(path_parts) == 1:
            continue

        stripped_path = path_parts[1]

        # strip parts from project spec
        if path and not stripped_path.startswith(path):
            continue

        if path:
            stripped_path = stripped_path[len(path):]

        target_path = os.path.normpath(os.path.join(destination, target, stripped_path))
        mkdirp(os.path.dirname(target_path))

        print 'extracting', tar_info.name, '->', target_path
        with open(target_path, 'wb') as f:
            f.write(tgz.extractfile(tar_info).read())


def main(destination, projects_file=None):
    destination = os.path.normpath(destination)

    if projects_file is not None:
        projects = load_projects(projects_file)
    else:
        # projects = [LocalProject('.', 'docs')]
        raise NotImplementedError

    for project in projects:
        fetch_project(destination, **project)

if __name__ == '__main__':
    main(*sys.argv[1:])

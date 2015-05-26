#!/usr/bin/env python

""" I honestly don't even know how the hell this works, just use it. """
from HTMLParser import HTMLParser
from urlparse import urljoin
import sys
import traceback
import re
import requests

__author__ = "Scott Stamp <scott@hypermine.com>"


class DataHolder:
    match = None

    def __init__(self, value=None, attr_name='value'):
        self._attr_name = attr_name
        self.set(value)

    def __call__(self, value):
        return self.set(value)

    def set(self, value):
        setattr(self, self._attr_name, value)
        return value

    def get(self):
        return getattr(self, self._attr_name)


class Parser(HTMLParser):
    ids = set()
    crawled = set()
    anchors = {}
    pages = set()
    save_match = DataHolder(attr_name='match')

    def __init__(self, origin):
        self.origin = origin
        HTMLParser.__init__(self)

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if 'href' in attrs:
            href = attrs['href']

            if re.match(r'^{0}|\/|\#[\S]{{1,}}'.format(self.origin), href):
                if self.save_match(re.search(r'.*\#(.*?)$', href)):
                    if self.origin not in self.anchors:
                        self.anchors[self.origin] = set()
                    self.anchors[self.origin].add(
                        self.save_match.match.groups(1)[0])

                url = urljoin(self.origin, href)

                if url not in self.crawled and not re.match(r'^\#', href):
                    self.crawled.add(url)
                    Parser(url).feed(requests.get(url).content)

        if 'id' in attrs:
            self.ids.add(attrs['id'])
        # explicit <a name=""></a> references
        if 'name' in attrs:
            self.ids.add(attrs['name'])


def main(root):
    sys.setrecursionlimit(10000)
    r = requests.get(root)
    parser = Parser(root)
    parser.feed(r.content)
    missing = []

    for anchor in sorted(parser.anchors):
        if not re.match(r'.*/\#.*', anchor):
            for anchor_name in parser.anchors[anchor]:
                if anchor_name not in parser.ids:
                    print 'Missing - ({0}): #{1}'.format(
                        anchor.replace(root, ''), anchor_name
                    )
                    missing.append(anchor_name)

    return not missing


if __name__ == '__main__':
    try:
        success = main(*sys.argv[1:])
    except Exception:
        traceback.print_exc()
        success = False

    sys.exit(0 if success else 1)

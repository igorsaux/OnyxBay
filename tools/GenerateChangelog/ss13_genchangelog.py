# -*- coding: utf-8 -*-

'''
Usage:
    $ python ss13_genchangelog.py [--dry-run] html/changelog.html html/changelogs/

ss13_genchangelog.py - Generate changelog from YAML.

Copyright 2013 Rob "N3X15" Nelson <nexis@7chan.org>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
'''

from __future__ import print_function
import yaml, os, glob, sys, re, time, argparse
from datetime import datetime, date, timedelta
from time import time
import io

today = date.today()

dateformat = "%d %B %Y"

opt = argparse.ArgumentParser()
opt.add_argument('-d', '--dry-run', dest='dryRun', default=False, action='store_true', help='Only parse changelogs and, if needed, the targetFile. (A .dry_changelog.yml will be output for debugging purposes.)')
opt.add_argument('-t', '--time-period', dest='timePeriod', default=9, type=int, help='Define how many weeks back the changelog should display')
opt.add_argument('targetFile', help='The HTML changelog we wish to update.')
opt.add_argument('ymlDir', help='The directory of YAML changelogs we will use.')

args = opt.parse_args()

all_changelog_entries = {}

validPrefixes = [
    'fa-bug',
    'fa-tools',
    'fa-image',
    'fa-pencil-ruler',
    'fa-music'
]


def dictToTuples(inp):
    return [(k, v) for k, v in inp.items()]

changelog_cache = os.path.join(args.ymlDir, '.all_changelog.yml')

failed_cache_read = True
if os.path.isfile(changelog_cache):
    try:
        with io.open(changelog_cache, encoding='utf-8') as f:
            (_, all_changelog_entries) = yaml.load_all(f, Loader=yaml.SafeLoader)
            failed_cache_read = False

            # Convert old timestamps to newer format.
            new_entries = {}
            for _date in all_changelog_entries.keys():
                ty = type(_date).__name__
                # print(ty)
                if ty in ['str', 'unicode']:
                    temp_data = all_changelog_entries[_date]
                    _date = datetime.strptime(_date, dateformat).date()
                    new_entries[_date] = temp_data
                else:
                    new_entries[_date] = all_changelog_entries[_date]
            all_changelog_entries = new_entries
    except Exception as e:
        print("Failed to read cache:")
        print(e, file=sys.stderr)

if args.dryRun:
    changelog_cache = os.path.join(args.ymlDir, '.dry_changelog.yml')

if failed_cache_read and os.path.isfile(args.targetFile):
    from bs4 import BeautifulSoup
    from bs4.element import NavigableString
    print(' Generating cache...')
    with io.open(args.targetFile, 'r', encoding='utf-8') as f:
        soup = BeautifulSoup(f, 'html.parser')
        for e in soup.find_all('div', {'class': 'commit'}):
            for date in e.find_all('h2', {'class': 'date'}):
                entry = {}
                author = None
                changes = []

                # Parse all what below date until the next date
                for content in date.next_siblings:

                    if (not content.name):
                        continue

                    # Until we got next 'date' h2
                    if (content['class'][0] == 'date'):
                        if (author and len(changes) > 0):
                            entry[str(author)] = changes
                        break

                    # Get author name
                    if (content['class'][0] == 'author'):
                        if (author != None and len(changes) > 0):
                            entry[str(author)] = changes
                            changes = []
                            author = None

                        author = content.string

                        if (author.endswith('updated:')):
                            author = author[:-9]

                        author.strip()

                    # Get changes
                    if ('changes' in content['class']):
                        for changeT in content.children:
                            if (changeT.name != 'li'):
                                continue

                            val = changeT.decode_contents(formatter="html")
                            newdat = {changeT['class'][0] + '': val + ''}

                            if newdat not in changes:
                                changes += [newdat]

                if (len(entry.keys()) == 0):
                    continue

                _date = date.string.strip()
                _date = datetime.strptime(_date, dateformat).date()

                #print(str(_date))

                #for key in entry.keys():
                #    print('Author: ' + key)
                #    for change in entry[key]:
                #        print(change)

                if (date in all_changelog_entries.keys()):
                    all_changelog_entries[_date].update(entry)
                else:
                    all_changelog_entries[_date] = entry

del_after = []
errors = False
print('Reading changelogs...')
for fileName in glob.glob(os.path.join(args.ymlDir, "*.yml")):
    name, ext = os.path.splitext(os.path.basename(fileName))
    if name.startswith('.'):
        continue
    if name == 'example':
        continue
    fileName = os.path.abspath(fileName)
    print(' Reading {}...'.format(fileName))
    cl = {}
    with io.open(fileName, 'r', encoding='utf-8') as f:
        cl = yaml.load(f, Loader=yaml.SafeLoader)
        f.close()
    if today not in all_changelog_entries:
        all_changelog_entries[today] = {}
    author_entries = all_changelog_entries[today].get(cl['author'], [])
    if len(cl['changes']):
        new = 0
        for change in cl['changes']:
            if change not in author_entries:
                (change_type, _) = dictToTuples(change)[0]
                if change_type not in validPrefixes:
                    errors = True
                    print('  {0}: Invalid prefix {1}'.format(fileName, change_type), file=sys.stderr)
                author_entries += [change]
                new += 1
        all_changelog_entries[today][cl['author']] = author_entries
        if new > 0:
            print('  Added {0} new changelog entries.'.format(new))

    if cl.get('delete-after', False):
        if os.path.isfile(fileName):
            if args.dryRun:
                print('  Would delete {0} (delete-after set)...'.format(fileName))
            else:
                del_after += [fileName]

    if 'date' in cl.keys():
        _date = datetime.strptime(cl['date'], '%Y %m %d').date()
        all_changelog_entries[_date] = all_changelog_entries[today]
        del all_changelog_entries[today]

    if args.dryRun:
        continue

    cl['changes'] = []
    with io.open(fileName, 'w', encoding='utf-8') as f:
        yaml.dump(cl, f, default_flow_style=False, encoding='utf-8', allow_unicode=True)

targetDir = os.path.dirname(args.targetFile)

with io.open(args.targetFile.replace('.htm', '.dry.htm') if args.dryRun else args.targetFile, 'w', encoding='utf-8') as changelog:
    with io.open(os.path.join(targetDir, 'templates', 'header.html'), 'r', encoding='utf-8') as h:
        for line in h:
            changelog.write(line)

    for _date in reversed(sorted(all_changelog_entries.keys())):
        entry_htm = '\n'
        entry_htm += '\t<li class="date">{date}</li>\n'.format(date=_date.strftime(dateformat))
        write_entry = False
        for author in sorted(all_changelog_entries[_date].keys()):
            if len(all_changelog_entries[_date]) == 0:
                continue
            author_htm = '\t<li class="admin"><span>{author}</span> updated:</li>\n'.format(author=author)
            changes_added = []
            for (css_class, change) in (dictToTuples(e)[0] for e in all_changelog_entries[_date][author]):
                if change in changes_added:
                    continue
                write_entry = True
                changes_added += [change]
                author_htm += '\t<li><i class="fas {css_class}"></i> {change}</li>\n'.format(css_class=css_class, change=change.strip())
            if len(changes_added) > 0:
                entry_htm += author_htm
        if write_entry:
            changelog.write(entry_htm)

    with io.open(os.path.join(targetDir, 'templates', 'footer.html'), 'r', encoding='utf-8') as h:
        for line in h:
            changelog.write(line)

with io.open(changelog_cache, 'w', encoding='utf-8') as f:
    cache_head = 'DO NOT EDIT THIS FILE BY HAND!  AUTOMATICALLY GENERATED BY ss13_genchangelog.py.'
    yaml.safe_dump_all([cache_head, all_changelog_entries], f, default_flow_style=False, encoding='utf-8', allow_unicode=True)

if len(del_after):
    print('Cleaning up...')
    for fileName in del_after:
        if os.path.isfile(fileName):
            print(' Deleting {0} (delete-after set)...'.format(fileName))
            os.remove(fileName)

if errors:
    sys.exit(1)
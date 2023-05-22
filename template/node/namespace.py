
import argparse
import string
import re
import random
from urllib.parse import urlparse

def main():
    parser = argparse.ArgumentParser(description='Namespace Generator')
    parser.add_argument('--url', type=str, help='URL argument')

    args = parser.parse_args()

    u = urlparse(args.url)

    if u.hostname == None:
        raise Exception("invalid url")

    d = str(u.hostname).replace('www.', '')
    d = re.sub(r'[.]+', '-', d)
    d = re.sub(r'[-]+', '-', d)
    d = d.strip('-')

    if len(d) > 22:
        d = d[-22:]

    d = d.strip('-')

    rnd = ''.join(
        random.choice(string.ascii_lowercase + string.digits)
        for _ in range(27 - len(d))
    )

    stages = ['d', 't', 's', 'p']
    for s in stages:
        r = d + '-' + s + '-' + rnd
        print(r)

if __name__ == '__main__':
    main()

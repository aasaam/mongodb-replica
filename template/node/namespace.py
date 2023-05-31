
import argparse
import string
import re
import random
from urllib.parse import urlparse


def main():
    parser = argparse.ArgumentParser(description='Namespace Generator')
    parser.add_argument('--url', type=str, help='URL argument')
    parser.add_argument('--domain', type=str, help='Domain argument')

    args = parser.parse_args()
    if args.url == None and args.domain == None:
        raise Exception("domain or url required")

    url_string = ""
    if args.url != None:
        url_string = args.url
    elif args.domain != None:
        url_string = "https://" + args.domain

    u = urlparse(url_string)

    if u.hostname == None:
        raise Exception("invalid url or domain")

    hostname = u.hostname.encode("idna").decode('utf-8')

    d = str(hostname).replace('www.', '')
    d = re.sub(r'[.]+', '-', d)
    d = re.sub(r'[-]+', '-', d)
    d = d.strip('-')

    if len(d) > 24:
        d = d[-24:]

    d = d.strip('-')

    rnd = ''.join(
        random.choice(string.ascii_lowercase + string.digits)
        for _ in range(3)
    )

    stages = ['dev', 'test', 'stage']
    print(d + '-' + rnd)
    for s in stages:
        r = d + '-' + s + '-' + rnd
        print(r)


if __name__ == '__main__':
    main()

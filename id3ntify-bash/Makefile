SHELL := /bin/bash

bin = /usr/bin/id3ntify
conf = /etc/id3ntify.conf
cache = /var/cache/id3ntify.cache

install:
	cp id3ntify.sh $(bin)
	cp id3ntify.conf $(conf)
	touch $(cache)

uninstall:
	if [[ -f $(bin) ]]; then rm $(bin); fi
	if [[ -f $(conf) ]]; then rm $(conf); fi
	if [[ -f $(cache) ]]; then rm $(cache); fi

clean:
	if [[ -f $(cache) ]]; then echo '' > $(cache); fi

test:
	test/test.sh

.PHONY: test

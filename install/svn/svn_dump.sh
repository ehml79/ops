#!/bin/bash



svnadmin dump  /data/svn/repo > repo.dump

svnadmin load  /data/svn/newrepo < repo.dump

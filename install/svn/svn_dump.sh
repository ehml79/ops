#!/bin/bash


# 导出
svnadmin dump  /data/svn/repo > repo.dump

# 导入
svnadmin load  /data/svn/newrepo < repo.dump

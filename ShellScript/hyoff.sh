#!/bin/bash
stop-dfs.sh
ssh hadoop103 'source /etc/profile&&stop-yarn.sh'
#!/bin/bash
echo "Hadoop Starting..."
start-dfs.sh
ssh hadoop103 'source /etc/profile&&start-yarn.sh'
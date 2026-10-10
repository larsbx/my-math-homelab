#!/bin/bash
until [ -f uh4/done ]; do sleep 60; done
cd /home/user/pisot-substitution-conjecture-research/mojo
( time ~/.pixi/bin/pixi run mojo run -I . vertex_coincidence_targeted.mojo 5 39 40 40 ) > targeted.log 2>&1
echo DONE >> targeted.log

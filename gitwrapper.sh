#!/bin/bash
ssh -o StrictHostKeyChecking=no -i ~/.ssh/deployment $1 $2

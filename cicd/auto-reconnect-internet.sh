#!/bin/bash

sudo netplan apply

sudo systemd-resolve --flush-caches

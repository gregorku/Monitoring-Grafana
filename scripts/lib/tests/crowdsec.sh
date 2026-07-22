#!/usr/bin/env bash

###############################################################################
#
# Monitoring-Grafana Project
#
# File:
#   scripts/lib/tests/crowdsec.sh
#
# Description:
#   CrowdSec tests.
#
###############################################################################

test_crowdsec()
{
    print_section "CrowdSec"

    docker_container_running "${CROWDSEC_SERVICE}"

    ok "CrowdSec container OK."

    #
    # Traefik collection
    #

    if docker exec crowdsec cscli collections list \
        | grep -q "crowdsecurity/traefik.*enabled"
    then
        ok "Traefik collection OK."
    else
        fail "Traefik collection missing."
    fi

    #
    # Traefik parser
    #

    if docker exec crowdsec cscli parsers list \
        | grep -q "crowdsecurity/traefik-logs.*enabled"
    then
        ok "Traefik parser OK."
    else
        fail "Traefik parser missing."
    fi

    #
    # Traefik bouncer
    #

    if docker exec crowdsec cscli bouncers list \
        | grep -qw "traefik"
    then
        ok "Traefik bouncer OK."
    else
        fail "Traefik bouncer missing."
    fi

    #
    # Access log acquisition
    #
    # Right after a restart, CrowdSec's file tailer starts
    # reading from the END of access.log -- it has nothing
    # to report until at least one new request comes in.
    # Generate one ourselves so the check isn't racy.
    #

    docker exec traefik \
        wget --no-check-certificate -q -O /dev/null \
        "https://127.0.0.1:8443/dashboard/" \
        2>/dev/null || true

    acquisition_ok=false

    for _ in 1 2 3 4 5 6 7 8 9 10
    do
        if docker exec crowdsec cscli metrics \
            | grep -q "file:/logs/access.log"
        then
            acquisition_ok=true
            break
        fi

        sleep 1
    done

    if [ "${acquisition_ok}" = true ]
    then
        ok "Access log acquisition OK."
    else
        fail "Access log acquisition missing."
    fi
}

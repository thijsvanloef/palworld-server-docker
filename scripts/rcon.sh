#!/bin/bash
# The wrapper pre-wakes a sleeping server.
# Unfortunately, the knockd can only detect knocks from outside the container.

autopause resume "${0} ${*}" > /dev/null
down_cmd="shutdown|doexit"

cmd=""
declare -i skip=0
for param in "${@}"; do
    if [ ${skip} -gt 0 ]; then
        ((skip--))
        continue
    fi
    case ${param} in
    "--address"|"-a"|"--password"|"-p"|"--type"|"-t"|"--log"|"-l"|"--config"|"-c"|"-env"|"-e"|"--timeout"|"-T")
        skip=1
        ;;
    "--skip"|"-s"|"--help"|"-h"|"-.*")
        ;;
    *)
        cmd="${param}"
        break
    esac
    if [ -n "${cmd}" ]; then break; fi
done

if /usr/bin/rcon-cli "${@}" && [[ ${cmd,,} =~ ${down_cmd} ]]; then
    # If the server goes down, don't sleep.
    autopause abort "${0} ${*}" > /dev/null
fi

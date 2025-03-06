#!/bin/bash

methods=(GET POST PUT PATCH DELETE)
return_codes=(200 201 400 401 403 404 500 501 502 503)
locations=(/ /index.html /part1.html /part2.html /part3.html /status /api /test)
agents=("Mozilla/5.0 (Windows; U; Windows NT 10.1; Win64; x64) AppleWebKit/602.5 (KHTML, like Gecko) Chrome/49.0.3218.278 Safari/603"
"Mozilla/5.0 (iPhone; CPU iPhone OS 7_5_0; like Mac OS X) AppleWebKit/601.43 (KHTML, like Gecko)  Chrome/51.0.2202.204 Mobile Safari/600.1"
"Mozilla/5.0 (U; Linux x86_64; en-US) Gecko/20100101 Firefox/61.3"
"Mozilla/5.0 (compatible; MSIE 7.0; Windows; Windows NT 6.2; WOW64; en-US Trident/4.0)"
"Mozilla/5.0 (Windows; Windows NT 6.1; WOW64) Gecko/20100101 Firefox/52.4"
"Mozilla/5.0 (U; Linux i662 x86_64; en-US) Gecko/20100101 Firefox/56.2"
"Mozilla/5.0 (compatible; MSIE 11.0; Windows NT 6.3; x64 Trident/7.0)"
"Googlebot/2.1 (+http://www.google.com/bot.html)"
"Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)"
"Mozilla/5.0 (iPhone; CPU iPhone OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5376e Safari/8536.25 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)"
"curl/7.85.0"
"Mozilla/5.0 (compatible; SimpleScraper)"
"Mozilla/5.0 (Android; Android 5.1.1; SM-G920X Build/LMY47X) AppleWebKit/600.24 (KHTML, like Gecko)  Chrome/49.0.2492.356 Mobile Safari/535.3"
"Mozilla/5.0 (Linux; U; Android 5.1.1; Nexus 6 Build/LRX22C) AppleWebKit/603.42 (KHTML, like Gecko)  Chrome/48.0.3721.101 Mobile Safari/535.6"
"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_4_6; en-US) Gecko/20100101 Firefox/74.2"
"Mozilla/5.0 (Windows; U; Windows NT 10.1; x64) AppleWebKit/534.44 (KHTML, like Gecko) Chrome/47.0.2412.327 Safari/603.0 Edge/15.39126"
"Mozilla/5.0 (Macintosh; Intel Mac OS X 7_6_9) Gecko/20100101 Firefox/56.3"
"Mozilla/5.0 (Linux; Android 5.1.1; Nexus 8 Build/LRX22C) AppleWebKit/601.50 (KHTML, like Gecko)  Chrome/54.0.2440.195 Mobile Safari/535.2"
"Mozilla/5.0 (iPhone; CPU iPhone OS 11_0 like Mac OS X) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/40.0.3754.1902 Mobile Safari/537.36; Bytespider"
"Mozilla/5.0 (Windows Phone 8.1; ARM; Trident/7.0; Touch; rv:11.0; IEMobile/11.0; NOKIA; Lumia 530) like Gecko (compatible; adidxbot/2.0; +http://www.bing.com/bingbot.htm)"
"python-requests/2.22.0"
"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Safari/605.1.15"
"Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:97.0) Gecko/20100101 Firefox/97.0")

function generate_date {
    echo $(date "+%d/%b/%Y" -d @$((RANDOM * 3850 + 1577836800)))
    # echo $(date "+%d/%b/%Y:%H:%M:%S %z" -d @$((RANDOM * 3850 + 1577836800)))
}

sorted_dates=()

function generate_date_n_time_list {
    local dates=()
    for((i = 0; i < $2; i++)); do
        dates+=("$1$(date "+:%H:%M:%S %z" -d @$((RANDOM * 3850 + 1577836800)))")
    done
    IFS=$'\n' sorted_dates=($(sort -n <<<"${dates[*]}"))
    unset IFS
    # echo "${sorted[@]}"
}

function generate_ip_address {
    echo $((RANDOM % 255 + 1)).$((RANDOM % 255 + 1)).$((RANDOM % 255 + 1)).$((RANDOM % 255 + 1))
}

function get_random_method {
    echo ${methods[$((RANDOM % ${#methods[@]}))]}
}

function get_random_return_code {
    echo ${return_codes[$((RANDOM % ${#return_codes[@]}))]}
}

function get_random_location {
    echo ${locations[$((RANDOM % ${#locations[@]}))]}
}

function get_random_agent {
    echo ${agents[$((RANDOM % ${#agents[@]}))]}
}

function generate_bytes {
    echo $((RANDOM % 5000 + 1))
}

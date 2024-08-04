#!/usr/bin/env bash

# global data arrays
declare -a bracket_match=()
declare -a usable_chars=()
declare -a runtime_data=()

# make sure argument exists / is file
check_args() {
    [[ -f "${1}" ]] || {
        echo "Usage: ./bf.sh [FILE]"
        exit 1
    }
}

# store array of relevant characters for runtime
parse_chars() {
    while read -rn1 char; do
        [[ "${char}" =~ ("["|"]"|"<"|">"|"+"|"-"|"."|",") ]] && usable_chars+=("${char}")
    done < "${1}"
}

# match closing brackets with their starting bracket
find_brackets() {
    local index=0
    local stack_index=0
    local stack=()

    for char in "${usable_chars[@]}"; do
        case "${char}" in
            "]") 
                ((stack_index--))
                local pop="${stack["${stack_index}"]}"
                bracket_match[pop]="${index}"
                bracket_match[index]="${pop}"
                ;;
            "[") 
                stack[stack_index]="${index}"
                ((stack_index++))
                ;;
        esac

        ((index++))
    done
}

# run the program
run_chars() {
    local char_index=0
    local data_index=0

    while [[ -n "${usable_chars["${char_index}"]}" ]]; do
        local cur_data="${runtime_data["${data_index}"]}"
        local data="${cur_data:-0}"

        case "${usable_chars["${char_index}"]}" in
            "[")
                [[ "${data}" -eq 0 ]] && char_index="${bracket_match["${char_index}"]}"
                ;;
            "]")
                [[ "${data}" -eq 0 ]] || char_index="${bracket_match["${char_index}"]}"
                ;;
            "<")
                ((data_index--))
                ;;
            ">")
                ((data_index++))
                ;;
            "+")
                ((runtime_data[data_index]++))
                ;;
            "-")
                ((runtime_data[data_index]--))
                ;;
            ".")
                echo "${data}" | awk '{printf("%c",$1)}'
                ;;
            ",")
                read -rn1 input
                runtime_data[data_index]="$(printf '%d' "'${input}")"
                ;;
        esac

        ((char_index++))
    done
}

# run all functions
main() {
    check_args "${1}"
    parse_chars "${1}"
    find_brackets
    run_chars
}

main "${@}"

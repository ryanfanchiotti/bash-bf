#!/usr/bin/env bash

# global data arrays
declare -a bracket_match=()
declare -a usable_chars=()
declare -a runtime_data=()

# make sure argument exists / is file
check_args() {
    [[ -f "${1}" ]] || {
        echo "Usage: ./bf.bash [FILE]"
        exit 1
    }
}

# store array of relevant characters for runtime
parse_chars() {
    local char
    while read -rn1 char; do
        [[ "${char}" =~ ("["|"]"|"<"|">"|"+"|"-"|"."|",") ]] && usable_chars+=("${char}")
    done < "${1}"
}

# match closing brackets with their starting bracket
find_brackets() {
    local index stack_index stack pop
    index=0
    stack_index=0
    stack=()

    for char in "${usable_chars[@]}"; do
        case "${char}" in
            "]") 
                ((stack_index--))
                pop="${stack["${stack_index}"]}"
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
    local char_index data_index cur_data data input
    char_index=0
    data_index=0

    while [[ -n "${usable_chars["${char_index}"]}" ]]; do
        cur_data="${runtime_data["${data_index}"]}"
        data="${cur_data:-0}"

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
                printf "%b" "$(printf "\x%x\n" "$data" 2>/dev/null)"
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

#! /bin/bash

# PDF FUNCTION
function pdf(){
## Auxiliary Functions
    function PDF_cvt(){
        ext=${2##*.}
        name=${2%.*}
        name=${name%/*}
        pandoc -f markdown -t pdf $1 -o $name.pdf
    }
    function PDF_sort(){
        sorted_lines=$(for f in ${files[@]}; do echo "$f"; done | sort)
        sorted_files=()
        while IFS= read -r line; do
            sorted_files+=("$line")
        done < "$sorted_lines"
    }
    function PDF_join(){
        cd $1
        mapfile -d '' files < <(find . \( -type f -name "*.md" \) -print0)
        if [[ -z "$2" ]]; then
            touch main.md
            for f in ${files[@]}; do
                cat $f >> main.md
                echo "\newpage" >> main.md
            done
        mv main.md ..
        cd ..
        elif [[ "$2" == "-s" ]]; then
            PDF_sort
            touch main.md
            for f in ${sorted_files[@]}; do
                cat $f >> main.md
            done
        mv main.md ..
        cd ..
        fi
    }
## PDF Function Properly
    if [[ -z "$1" ]]; then
        echo "interactive mode..."
    elif [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
        echo "help..."
    elif [[ "$1" == "-c" ]] || [[ "$1" == "-cfg" ]] || [[ "$1" == "--config" ]];  then
        echo "configure..."
    elif [[ -f "$1" ]]; then
        ext_md=${1##*.}
        if [[ "$ext_md" == "md" ]] || [[ "$ext_md" == "markdown" ]]; then
            PDF_cvt $1 $1
        else
            echo "The file \"$1\" is not a markdown file."
        fi
    elif [[ "$1" == "-s" ]] || [[ "$1" == "--sort" ]]; then
        if [[ -d "$2" ]]; then
            if [[ -z "$3" ]]; then
                PDF_join $2 -s
                if [[ -s "main.md" ]]; then
                    PDF_cvt "main.md" $2
                else
                    echo "There are no markdown files in this directory."
                fi
                rm main.md
            else
                PDF_join $2 -s
                if [[ -s "main.md" ]]; then
                    PDF_cvt "main.md" $3
                else
                    echo "There are no markdown files in this directory."
                fi
                rm main.md
            fi
        fi
    elif [[ -d "$1" ]]; then
        if [[ -z "$2" ]]; then
            PDF_join $1
            if [[ -s "main.md" ]]; then
                PDF_cvt "main.md" $1
            else
                echo "There are no markdown files in this directory."
            fi
            rm main.md
        else
            PDF_join $1 
            if [[ -s "main.md" ]]; then
                PDF_cvt "main.md" $2
            else
                echo "There are no markdown files in this directory."
            fi
            rm main.md
        fi
    fi
}

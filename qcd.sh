#Developed by Nalin Ahuja, nalinahuja22

#!/usr/bin/env bash

QCD_STORE=~/.qcd/store
QCD_TEMP=~/.qcd/temp

b=$(tput bold)
n=$(tput sgr0)

function qcd() {
  # Store First Arg
  indicated_dir="$1"

  # Set To Home If Empty
  if [[ -z $indicated_dir ]]
  then
    indicated_dir=~
  fi

  # Create QCD Store
  if [[ ! -f $QCD_STORE ]]
  then
    touch $QCD_STORE
  fi

  # Is Valid Directory
  if [[ -e $indicated_dir ]]
  then
    # Change Directory
    command cd $indicated_dir

    # Store Complete Path And Endpoint
    local new_dir="$(pwd -P)/"
    local new_ept=$(basename $new_dir)

    # Append To QCD Store If Unique
    if [[ -z $(egrep -s -x ".* $new_dir" $QCD_STORE) && ! "$HOME/" = "$new_dir" ]]
    then
      printf "%s %s\n" $new_ept $new_dir >> $QCD_STORE
    fi

  # Invalid Directory
  else
    # Get Path Prefix and Suffix
    prefix=$(echo -e "$indicated_dir" | cut -d '/' -f1)
    suffix=""

    # Get Path Suffix If Non-Empty
    if [[ "$indicated_dir" == *\/* ]]
    then
      suffix=${indicated_dir:${#prefix} + 1}
    fi

    # Check For File Link In Store File
    res=$(egrep -s -x "$prefix.*" $QCD_STORE)
    res_cnt=$(echo "$res" | wc -l)

    # Check Result Count
    if [[ $res_cnt -gt 1 ]]
    then
      # Prompt User
      echo -e "qcd: Multiple paths linked from ${b}$prefix${n}"

      # Format Paths By Absolute Path
      paths=$(echo -e "$res" | cut -d ' ' -f2 | sort)

      # Display Options
      cnt=1
      for path in $paths
      do
        prefix_len=$((${#HOME} + 1))
        path="~$(echo $path | cut -c $prefix_len-${#path})"
        printf "(%d) %s\n" $cnt $path
        cnt=$((cnt + 1))
      done

      # Format Selected Endpoint
      read -p "Endpoint: " ep

      # Error Check Bounds
      if [[ $ep -lt 1 ]]
      then
        ep=1
      elif [[ $ep -gt $res_cnt ]]
      then
        ep=$res_cnt
      fi

      # Format Endpoint
      res=$(echo $paths | cut -d ' ' -f$ep)
    else
      # Format Endpoint
      res=$(echo $res | cut -d ' ' -f2)
    fi

    # Error Check Result
    if [[ -z $res ]]
    then
      # Prompt User
      echo -e "qcd: Cannot link keyword to directory"
    else
      # Check If Linked Path Is Valid
      if [[ ! -e $res ]]
      then
        # Prompt User
        if [[ $res_cnt -gt 1 ]]; then echo; fi
        echo -e "qcd: $res: No such file or directory"

        # Delete Invalid Path From QCD Store
        del_line=$(egrep -s -n "$res" $QCD_STORE | cut -d ':' -f1)
        sed "${del_line}d" $QCD_STORE > $QCD_TEMP
        cat $QCD_TEMP > $QCD_STORE && rm $QCD_TEMP
      else
        # Swtich To Linked Path
        command cd $res

        # Navigate To Suffix If Non-Empty
        if [[ ! -z $suffix && -e $suffix ]]
        then
          command cd $suffix

          # Store Complete Path And Endpoint
          local new_dir="$(pwd -P)/"
          local new_ept=$(basename $new_dir)

          # Append To QCD Store If Unique
          if [[ -z $(egrep -s -x ".* $new_dir" $QCD_STORE) && ! "$HOME/" = "$new_dir" ]]
          then
            printf "%s %s\n" $new_ept $new_dir >> $QCD_STORE
          fi
        fi
      fi
    fi
  fi
}

# Start QCD Function
qcd $1

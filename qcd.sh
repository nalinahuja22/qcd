# Developed by Nalin Ahuja, nalinahuja22

# End Header---------------------------------------------------------------------------------------------------------------------------------------------------------

# Boolean Values
readonly __TRUE=1 __FALSE=0 &> /dev/null

# Keycode Values
readonly __UP=1 __DN=2 __ENT=3 __EXT=4 &> /dev/null

# Return Values
readonly __OK=0 __ERR=1 __CONT=2 __NSEL=255 &> /dev/null

# Embedded Values
readonly __NSET=0 __MINPAD=5 __DELAY=10 __COLNUM=256 &> /dev/null

# End Numerical Constants--------------------------------------------------------------------------------------------------------------------------------------------

# Value Flags
readonly __ALIAS="-a" __OPTIONS="-o" __REMEMBER="-r" __FORGET="-f" &> /dev/null

# Standalone Flags
readonly __HELP="-h" __LIST="-l" __BACK="-b" __CLEAN="-c" __TRACK="-t" __UPDATE="-u" __VERSION="-v" &> /dev/null

# Embedded Strings
readonly __CWD="." __HWD="../" __YES="y" __QUIT="q" __ESTR="" __FLSH="/" __BSLH="\\" _ESEQ=$(command printf "\033") &> /dev/null

# Text Formatting Strings
readonly __B=$(command printf "${_ESEQ}[1m") __W=$(command printf "${_ESEQ}[30m${_ESEQ}[47m") __N=$(command printf "${_ESEQ}(B${_ESEQ}[m") &> /dev/null

# End String Constants-----------------------------------------------------------------------------------------------------------------------------------------------

# Program Path
readonly QCD_FOLD=~/.qcd &> /dev/null

# Program Files
readonly QCD_EXEC=${QCD_FOLD}/qcd.sh &> /dev/null
readonly QCD_TEMP=${QCD_FOLD}/temp   &> /dev/null

# Resource Files
readonly QCD_STORE=${QCD_FOLD}/store  &> /dev/null
readonly QCD_TRACK=${QCD_FOLD}/.track &> /dev/null

# Release Files
readonly QCD_RELEASE=${QCD_FOLD}/release.zip &> /dev/null
readonly QCD_INSTALL=${QCD_FOLD}/install.sh  &> /dev/null

# End File Constants-------------------------------------------------------------------------------------------------------------------------------------------------

# Release Information
readonly QCD_RELEASE_VER="1.19.0" QCD_RELEASE_URL="https://api.github.com/repos/nalinahuja22/qcd/releases/latest" &> /dev/null

# End Installation Constants-----------------------------------------------------------------------------------------------------------------------------------------

# Exit Flag
declare QCD_EXIT=${__FALSE}

# Back Directory
declare QCD_BACK_DIR=${__ESTR}

# End Global Variables-----------------------------------------------------------------------------------------------------------------------------------------------

function _get_pwd() {
  # Store Current Working Directory
  local pwd=$(command pwd)

  # Return Current Working Directory
  command echo -e "${pwd}${__FLSH}"
}

function _get_path() {
  # Store Argument Directory
  local dir=$(command realpath "${@}")

  # Return Realpath Path
  command echo -e "${dir}${__FLSH}"
}

function _get_rname() {
  # Store Argument Directory
  local dir="${@%/}${__FLSH}"

  # Get Prefix String
  local pfx="${dir#*/*}"

  # Determine Return
  if [[ -z ${pfx} ]]
  then
    # Return Full Argument Directory
    command echo -e "${dir%/}"
  else
    # Determine Substring Bounds
    local si=0 ei=$((${#dir} - ${#pfx} - 1))

    # Return Argument Directory Substring
    command echo -e "${dir:${si}:${ei}}"
  fi
}

function _get_dname() {
  # Store Argument Directory
  local dir="${@%/}${__FLSH}"

  # Get Prefix String
  local pfx="${dir%/*/}"

  # Determine Substring Bounds
  local si=$((${#pfx} + 1))

  # Get Suffix String
  local sfx="${dir:${si}}"

  # Determine Return
  if [[ -z ${sfx} ]]
  then
    # Return Prefix String
    command echo -e "${pfx%/}"
  else
    # Return Suffix String
    command echo -e "${sfx%/}"
  fi
}

function _split_name() {
  # Return Name Of Symbolic Link
  command echo -e "${@%:*}"
}

function _split_path() {
  # Return Path Of Symbolic Link
  command echo -e "${@#*:}"
}

function _format_path() {
  # Check For Environment Variable
  if [[ ! -z ${HOME} ]]
  then
    # Return Formatted Path
    command echo -e ${@/${HOME}/\~}
  else
    # Return Original Path
    command echo -e ${@}
  fi
}

function _escape_path() {
  # Store Argument Path
  local path="${@}"

  # Remove Escape Characters
  path="${path//\\/}"

  # Return Escaped Path
  command echo -e "${path}"
}

function _escape_regex() {
  # Store Argument String
  local str="${@}"

  # Escape Regex Characters
  str="${str//\*/\\*}"
  str="${str//\?/\\?}"
  str="${str//\./\\.}"
  str="${str//\$/\\$}"

  # Return Escaped String
  command echo -e "${str}"
}

# End Utility Functions----------------------------------------------------------------------------------------------------------------------------------------------

function _show_output() {
  # Enable Terminal Output
  command stty echo 2> /dev/null

  # Set Cursor To Visible
  command tput cnorm 2> /dev/null
}

function _hide_output() {
  # Disable Terminal Output
  command stty -echo 2> /dev/null

  # Set Cursor To Hidden
  command tput civis 2> /dev/null
}

# End Environment Functions------------------------------------------------------------------------------------------------------------------------------------------

function _show_help() {
  # Display Help Message
  command cat << EOF
${__B}QCD Utility - v${QCD_RELEASE_VER}${__N}

${__B}Usage:${__N}
  qcd                                 Switch to home directory
  qcd [path]                          Switch to valid directory
  qcd [link]/[subdir]/...             Switch to linked directory
  qcd [n]..                           Switch to nth parent directory

${__B}Options:${__N}
  qcd [-h, --help]                    Show this help
  qcd [-c, --clean]                   Clean store file
  qcd [-l, --list]                    List stored linkages
  qcd [-v, --version]                 Show current version
  qcd [-u, --update]                  Update to latest version
  qcd [-b, --back-dir]                Navigate to backward directory
  qcd [-t, --track-dirs]              Set directory tracking behavior

  qcd [-r, --remember]                Remember present directory
  qcd [-r, --remember] [path]         Remember directory by path

  qcd [-f, --forget]                  Forget present directory
  qcd [-f, --forget] [path]           Forget matching directory path
  qcd [-f, --forget] [link]           Forget matching symbolic links

  qcd [-m, --mkdir] [path]            Create and switch to new directory
  qcd [-a, --alias] [alias]           Alias directory if remembered
  qcd [-o, --options] [link]          Show symbolic link options

Developed by Nalin Ahuja, nalinahuja22
EOF
}

function _read_input() {
  # Initialize String Buffer
  local buffer=()

  # Read Input Stream
  while [[ 1 ]]
  do
    # Read One Character From STDIN
    command read -s -n1 c 2> /dev/null

    # Return Enter Action
    [[ "${c}" == "${__ESTR}" ]] && command echo -e "${__ENT}" && break

    # Return Quit Action
    [[ "${c}" == "${__QUIT}" ]] && command echo -e "${__EXT}" && break

    # Append Character To Input Buffer
    buffer+=("${c}")

    # Check Break Conditions
    if [[ ${#buffer[@]} -ge 3 ]]
    then
      # Set IFS
      local IFS=$''

      # Return Up Arrow Action
      [[ "${buffer[*]}" == "${_ESEQ}[A" ]] && command echo -e "${__UP}" && break

      # Return Down Arrow Action
      [[ "${buffer[*]}" == "${_ESEQ}[B" ]] && command echo -e "${__DN}" && break

      # Reset String Buffer
      buffer=()

      # Unset IFS
      unset IFS
    fi
  done
}

function _clear_output() {
  # Clear Line Entries
  for ((li=0; li <= ${1}; li++))
  do
    # Go To Beginning Of Line
    command printf "${_ESEQ}[${__COLNUM}D"

    # Clear Line
    command printf "${_ESEQ}[K"

    # Go Up One Line
    command printf "${_ESEQ}[1A"
  done

  # Go Down One Line
  command printf "${_ESEQ}[1B"
}

function _generate_menu() {
  # Hide Terminal Outputs
  _hide_output

  # Set Signal Trap For SIGINT
  command trap _qcd_exit SIGINT &> /dev/null

  # Reset Exit Flag
  declare QCD_EXIT=${__FALSE}

  # Initialize Selected Option
  local os=${__NSET}

  # Begin Selection Loop
  while [[ 1 ]]
  do
    # Initialize Option Index
    local oi=${__NSET}

    # Clear Temp File
    command echo -en > ${QCD_TEMP}

    # Iterate Over Options
    for opt in "${@}"
    do
      # Format Option
      opt=$(_format_path "${opt%/}")

      # Conditionally Format Option
      if [[ ${oi} -eq ${os} ]]
      then
        # Format Option As Selected
        command echo -e "${__W} ${opt} ${__N}" >> ${QCD_TEMP}
      else
        # Format Option As Unselected
        command echo -e " ${opt} " >> ${QCD_TEMP}
      fi

      # Increment Option Index
      ((oi++))
    done

    # Display Selection
    command cat ${QCD_TEMP}

    # Read User Input
    local key=$(_read_input)

    # Check Exit Flag
    if [[ ${QCD_EXIT} == ${__TRUE} ]]
    then
      # Reset Exit Flag
      QCD_EXIT=${__FALSE}

      # Reset Selected Option
      os=${__NSEL}

      # Break Loop
      break
    fi

    # Update Cursor Position
    if [[ ${key} -eq ${__UP} ]]
    then
      # Decrement Selected Option
      ((os--))
    elif [[ ${key} -eq ${__DN} ]]
    then
      # Increment Selected Option
      ((os++))
    elif [[ ${key} -eq ${__ENT} ]]
    then
      # Break Loop
      break
    elif [[ ${key} -eq ${__EXT} ]]
    then
      # Reset Option Selection
      os=${__NSEL}

      # Break Loop
      break
    fi

    # Check For Option Loopback
    if [[ ${os} -eq ${#@} ]]
    then
      # Jump To Top
      os=0
    elif [[ ${os} -eq -1 ]]
    then
      # Jump To Bottom
      os=$((${#@} - 1))
    fi

    # Clear Previous Selection
    _clear_output ${#@}
  done

  # Clear Signal Trap For SIGINT
  command trap - SIGINT &> /dev/null

  # Clear Selection Interface
  _clear_output $((${#@} + 1))

  # Show Terminal Outputs
  _show_output

  # Return Selected Option
  return ${os}
}

# End User Inferface Functions---------------------------------------------------------------------------------------------------------------------------------------

function _create_store() {
  # Check For Store File
  if [[ ! -f "${QCD_STORE}" ]]
  then
    # Create Store File
    command touch ${QCD_STORE} 2> /dev/null
  fi
}

function _update_store() {
  # Check Exit Status
  if [[ ${1} -eq ${__OK} ]]
  then
    # Update Store File
    command mv ${QCD_TEMP} ${QCD_STORE} 2> /dev/null
  else
    # Cleanup Temp File
    _cleanup_temp
  fi
}

function _cleanup_temp() {
  # Check For Temp File
  if [[ -f "${QCD_TEMP}" ]]
  then
    # Remove Temp File
    command rm ${QCD_TEMP} 2> /dev/null
  fi
}

# End File Management Functions--------------------------------------------------------------------------------------------------------------------------------------

function _add_directory() {
  # Initialize Directory Path
  local dir=${__ESTR}

  # Check For Argument Path
  if [[ ${#@} -eq 0 ]]
  then
    # Store Current Path
    dir=$(_get_pwd)
  else
    # Store Argument Path
    dir=$(_get_path "${@:1:1}")
  fi

  # Compare Directory Path To Home Path
  [[ "${dir%/}" == "${HOME%/}" ]] && return ${__OK}

  # Initialize Path Endpoint
  local ept=${__ESTR}

  # Check For Argument Endpoint
  if [[ ${#@} -lt 2 ]]
  then
    # Extract Endpoint From Directory Path
    ept=$(_get_dname "${dir}")
  else
    # Store Argument Endpoint
    ept="${@:2:1}"

    # Format Argument Endpoint
    ept="${ept%/}"
  fi

  # Initialize Data Characteristics
  local udir=${__FALSE} uent=${__FALSE}

  # Determine If Linkage Directory Is Unique
  [[ -z $(command awk -F ':' -v DIR="${dir}" '{if ($2 == DIR) {print $0}}' ${QCD_STORE} 2> /dev/null) ]] && udir=${__TRUE}

  # Determine If Linkage Entry Is Unique
  [[ -z $(command awk -F ':' -v EPT="${ept}" -v DIR="${dir}" '{if ($1 == EPT && $2 == DIR) {print $0}}' ${QCD_STORE} 2> /dev/null) ]] && uent=${__TRUE}

  # Store Directory As Linkage
  if [[ ${udir} -eq ${__TRUE} || ${uent} -eq ${__TRUE} ]]
  then
    # Check Linkage Characteristic
    if [[ ${uent} -eq ${__TRUE} ]]
    then
      # Remove Linkage By Directory
      _remove_directory "${dir}"
    fi

    # Append Data To Store File
    command echo -e "${ept}:${dir}" >> ${QCD_STORE}

    # Sort Store File In Place
    command sort -o ${QCD_STORE} -n -t ':' -k2 ${QCD_STORE}
  fi

  # Return To Caller
  return ${__OK}
}

function _remove_linkage() {
  # Store Argument Link
  local link=$(_escape_regex "${@%/}")

  # Remove Link From Store File
  command awk -F ':' -v LINK="${link}" '{if ($1 != LINK) {print $0}}' ${QCD_STORE} > ${QCD_TEMP} 2> /dev/null

  # Update Store File
  _update_store ${?}

  # Return To Caller
  return ${__OK}
}

function _remove_directory() {
  # Initialize Directory Path
  local dir=${__ESTR}

  # Check For Argument Path
  if [[ ${#@} -eq 0 ]]
  then
    # Store Current Path
    dir=$(_get_pwd)
  else
    # Store Argument Path
    dir=$(_get_path "${@}")
  fi

  # Remove Directory From Store File
  command awk -F ':' -v DIR="${dir}" '{if ($2 != DIR) {print $0}}' ${QCD_STORE} > ${QCD_TEMP} 2> /dev/null

  # Update Store File
  _update_store ${?}

  # Return To Caller
  return ${__OK}
}

# End Database Management Functions----------------------------------------------------------------------------------------------------------------------------------

function _parse_arguments() {
  # Parse Arguments
  while [[ ${#@} -gt 0 ]]
  do
    # Determine Action
    case "${1}" in
      # Check For Help Flag
      ${__HELP}|--help)
        # Display Help Message
        _show_help

        # Terminate Program
        return ${__OK}
      ;;

      # Check For Version Flag
      ${__VERSION}|--version)
        # Display Installation Version
        _show_help | command head -n1

        # Terminate Program
        return ${__OK}
      ;;

      # End Standard Flags-------------------------------------------------------------------------------------------------------------------------------------------

      # Check For List Flag
      ${__LIST}|--list)
        # todo!!!
      ;;

      # Check For Clean Flag
      ${__CLEAN}|--clean)
        # Set IFS
        local IFS=$'\n'

        # Get Linkage Paths
        local link_paths=($(command awk -F ':' '{print $2}' ${QCD_STORE}))

        # Iterate Over Linkage Paths
        for link_path in ${link_paths}
        do
          # Verify Linkage Path
          if [[ ! -d "${link_path}" ]]
          then
            # Remove Invalid Linkage Path
            (_remove_directory "${link_path}" &> /dev/null)
          fi
        done

        # Unset IFS
        unset IFS

        # Display Prompt
        command echo -e "qcd: Cleaned store file"

        # Terminate Program
        return ${__OK}
      ;;

      # Check For Update Flag
      ${__UPDATE}|--update)
        # Display Prompt
        command echo -e "qcd: Currently running ${__B}${QCD_RELEASE_VER}${__N}"

        # Prompt User For Confirmation
        command read -p "→ Confirm update [y/n]: " confirm

        # Determine Action
        if [[ ${confirm//Y/${__YES}} == ${__YES} ]]
        then
          # Clear Previous Outputs
          _clear_output 1

          # Verify Curl Dependency
          if [[ -z "$(command -v curl)" ]]
          then
            # Display Prompt
            command echo -e "→ Curl dependency not installed"

            # Terminate Program
            return ${__ERR}
          fi

          # Display Prompt
          command echo -en "→ Downloading update "

          # Get Release Information
          local release_info=$(command curl --connect-timeout ${__DELAY} -sL "${QCD_RELEASE_URL}" 2> /dev/null)

          # Get Download URL
          local download_url=$(command echo -e "${release_info}" | command egrep -s -o "https.*zipball.*" 2> /dev/null)

          # Verify Download URL
          if [[ ${?} -ne ${__OK} || -z ${download_url} ]]
          then
            # Display Prompt
            command echo -e "\r→ Failed to resolve download source for update"

            # Terminate Program
            return ${__ERR}
          fi

          # Download Release Contents
          command curl --connect-timeout ${__DELAY} -sL "${download_url%\",}" > "${QCD_RELEASE}"

          # Error Check Release Contents
          if [[ ${?} -ne ${__OK} || ! -f "${QCD_RELEASE}" ]]
          then
            # Display Prompt
            command echo -e "\r→ Failed to download update"

            # Terminate Program
            return ${__ERR}
          fi

          # Display Prompt
          command echo -en "\r→ Installing updates  "

          # Extract And Install Program Files
          command unzip -o -j "${QCD_RELEASE}" -d "${QCD_FOLD}" &> /dev/null

          # Error Check Installation
          if [[ ${?} -ne ${__OK} ]]
          then
            # Display Prompt
            command echo -e "\r→ Failed to install update"

            # Terminate Program
            return ${__ERR}
          fi

          # Display Prompt
          command echo -en "\r→ Configuring updates "

          # Update Terminal Environment
          command source "${QCD_EXEC}" 2> /dev/null

          # Error Check Installation
          if [[ ${?} -ne ${__OK} ]]
          then
            # Display Prompt
            command echo -e "\r→ Failed to configure update "

            # Terminate Program
            return ${__ERR}
          fi

          # Cleanup Installation
          command rm "${QCD_RELEASE}" "${QCD_INSTALL}" 2> /dev/null

          # Display Prompt
          command echo -e "\r→ Update complete     "

          # Clear Previous Outputs
          _clear_output 2

          # Display Prompt
          command echo -e "qcd: Updated to ${__B}${QCD_RELEASE_VER}${__N}"
        else
          # Clear All Outputs
          _clear_output 2
        fi

        # Terminate Program
        return ${__OK}
      ;;

      # Check For Back Flag
      ${__BACK}|--back-dir)
        # Check Back Directory Variable
        if [[ ! -z ${QCD_BACK_DIR} && -d "${QCD_BACK_DIR}" ]]
        then
          # Get Current Directory
          local pwd=$(_get_pwd)

          # Switch To Back Directory
          command cd "${QCD_BACK_DIR}"

          # Update Back Directory
          declare QCD_BACK_DIR="${pwd}"

          # Terminate Program
          return ${__OK}
        else
          # Display Prompt
          command echo -e "qcd: Could not navigate to directory"

          # Terminate Program
          return ${__ERR}
        fi
      ;;

      # Check For Tracking Flag
      ${__TRACK}|--track-dir)
        # Check For Tracking File
        if [[ -f "${QCD_TRACK}" ]]
        then
          # Display Prompt
          command echo -e "qcd: Directory tracking ${__B}enabled${__N}"

          # Prompt User For Confirmation
          command read -p "→ Disable tracking [y/n]: " confirm
        else
          # Display Prompt
          command echo -e "qcd: Directory tracking ${__B}disabled${__N}"

          # Prompt User For Confirmation
          command read -p "→ Enable tracking [y/n]: " confirm
        fi

        # Clear Previous Outputs
        _clear_output 2

        # Determine Action
        if [[ ${confirm//Y/${__YES}} == ${__YES} ]]
        then
          # Check For Tracking File
          if [[ ! -f "${QCD_TRACK}" ]]
          then
            # Create Tracking File
            command touch "${QCD_TRACK}"

            # Display Prompt
            command echo -e "qcd: Directory tracking ${__B}enabled${__N}"
          else
            # Remove Tracking File
            command rm "${QCD_TRACK}"

            # Display Prompt
            command echo -e "qcd: Directory tracking ${__B}disabled${__N}"
          fi
        fi

        # Terminate Program
        return ${__OK}
      ;;

      # End Standalone Flags-----------------------------------------------------------------------------------------------------------------------------------------

      # Check For Remember Flag
      ${__REMEMBER}|--remember)
        # todo!!!
      ;;

      # Check For Forget Flag
      ${__FORGET}|--forget)
        # todo!!!
      ;;

      # Check For Alias Flag
      ${__ALIAS}|--alias)
        # todo!!!
      ;;

      # End Value Flags----------------------------------------------------------------------------------------------------------------------------------------------

      # Default Argument Handler
      *) shift;;
    esac
  done

  # Continue Program
  return ${__CONT}
}

# End Argument Parser Function---------------------------------------------------------------------------------------------------------------------------------------

function qcd() {
  # Create Resource File
  _create_store

  # Parse Commandline Arguments
  _parse_arguments "${@}"

  # Store Parsing Status
  local pstatus=${?}

  # Check For Terminating Status
  [[ ${pstatus} -ne ${__CONT} ]] && return ${pstatus}

  # Initialize Argument Components
  local dir_arg=${__ESTR} show_opt=${__FALSE}

  # Check Argument Validity
  if [[ -z ${@} ]]
  then
    # Set To Home Directory
    dir_arg=~
  else
    # Store Option Argument
    local opt_arg="${@:${#@}}"

    # Initialize Sublist Bounds
    local si=1 ei=${#@}

    # Check For Option Flag
    if [[ ${opt_arg/--options/${__OPTIONS}} == ${__OPTIONS} ]]
    then
      # Update Sublist Bounds
      si=1; ei=$((${#@} - 1));

      # Set Option Flag
      show_opt=${__TRUE}
    fi

    # Set Directory Argument
    dir_arg="${@:${si}:${ei}}"

    # Check For Back Directory Pattern
    if [[ "${dir_arg}" =~ ^[0-9]+\.\.$ ]]
    then
      # Determine Back Directory Height
      local back_height=${dir_arg:0:$((${#dir_arg} - 2))}

      # Generate Expanded Back Directory
      local back_dir=$(command printf "%${back_height}s")

      # Override Directory Arguments
      dir_arg="${back_dir// /${__HWD}}"

      # Override Option Argument
      opt_arg=${__ESTR}
    else
      # Format Escaped Characters
      dir_arg=$(_escape_path "${dir_arg}")
    fi
  fi

  # Determine If Directory Is Linked
  if [[ -d "${dir_arg}" && ${show_opt} == ${__FALSE} ]]
  then
    # Update Back Directory
    QCD_BACK_DIR=$(_get_pwd)

    # Change To Valid Directory
    command cd "${dir_arg}"

    # Check For Tracking File
    if [[ -f ${QCD_TRACK} ]]
    then
      # Add Current Directory
      (_add_directory &> /dev/null &)
    fi

    # Terminate Program
    return ${__OK}
  else
    # Initialize Subdirectory Component
    local sub_link=${__ESTR}

    # Initialize Prefix Length
    local pfx_len=${#dir_arg}

    # Determine Linked Subdirectory
    if [[ "${dir_arg}" == */* ]]
    then
      # Extract Linked Subdirectory
      sub_link=${dir_arg#*/}

      # Update Prefix Length
      pfx_len=$((${pfx_len} - ${#sub_link} - 1))
    fi

    # Set IFS
    local IFS=$'\n'

    # Initialize Symbolic Link Component
    local sym_link=$(_escape_regex "${dir_arg:0:${pfx_len}}")

    # Initialize Linkage Parameters
    local pathv=($(command awk -F ':' -v LINK="${sym_link}" '{ if (LINK ~ $1) {print $2} }' ${QCD_STORE} 2> /dev/null))

    # Check For Indirect Link Matching
    if [[ ${#pathv[@]} -eq 0 ]]
    then
      # Initialize Parameters
      local i=0 wld_link=${__ESTR}

      # Check For Hidden Directory Prefix
      if [[ "${dir_arg}" == \.* ]]
      then
        # Override Parameters
        i=2; wld_link="${__BSLH}${__CWD}"
      fi

      # Wildcard Symbolic Link
      for ((; i < ${#sym_link}; i++))
      do
        # Get Character At Index
        local c=${sym_link:${i}:1}

        # Append Wildcard
        wld_link="${wld_link}${c}.*"
      done

      # Set IFS
      local IFS=$'\n'

      # Get Sequence Matched Symbolic Paths From Store File
      pathv=($(command printf "%s\n" $(command egrep -i -s -x "${wld_link}:.*" ${QCD_STORE} 2> /dev/null)))
    fi

    # Initialize Path Count
    local pathc=${#pathv[@]}

    # Check Result Count
    if [[ ${pathc} -gt 1 ]]
    then
      # Initialize Matched Path
      local mpath=${__ESTR}

      # Store Current Directory
      local pwd=$(_get_pwd)

      # Initialize Filtered Paths
      local fpaths=()

      # Iterate Over Path Values
      for path in ${pathv[@]}
      do
        # Substring Path From Delimiter
        path=$(_split_path "${path}")

        # Form Complete Path
        path=$(_escape_path "${path}${sub_link}")

        # Validate Path
        if [[ -d "${path}" && ! "${path%/}" == "${pwd%/}" ]]
        then
          # Set IFS
          local IFS=$'\n'

          # Add Filtered Path To List
          fpaths+=($(command printf "%s\n" "${path}"))
        fi
      done

      # Update Path Count
      pathc=${#fpaths[@]}

      # Check For Single Path
      if [[ ${pathc} -eq 1 ]]
      then
        # Set Matched Path
        mpath="${fpaths[@]}"
      fi

      # List Matching Paths
      if [[ -z ${mpath} && ! -z ${fpaths} ]]
      then
        # Display Prompt
        command echo -e "qcd: Multiple paths linked to ${__B}${dir_arg%/}${__N}"

        # Initialize Path Lists
        local pfxm=() pfxf=()

        # Iterate Over Filtered Paths
        for fpath in ${fpaths[@]}
        do
          # Get Path Endpoint
          local ept=$(_get_dname "${fpath}")

          # Compare Endpoint To Directory Argument
          if [[ ${ept} == ${dir_arg}* ]]
          then
            # Add Path To Match List
            pfxm+=("${fpath}")
          else
            # Add Path To Fail List
            pfxf+=("${fpath}")
          fi
        done

        # Concatenate Lists
        fpaths=("${pfxm[@]}" "${pfxf[@]}")

        # Generate Selection Menu
        _generate_menu ${fpaths[@]}

        # Store Selection Status
        local ept=${?}

        # Check Selection Status
        [[ ${ept} -eq ${__NSEL} ]] && return ${__OK}

        # Set To Manually Selected Endpoint
        pathv="${fpaths[${ept}]}"
      else
        # Set To Automatically Selected Endpoint
        pathv="${mpath}"
      fi
    else
      # Substring Path From Delimiter
      pathv=$(_split_path "${pathv}")
    fi

    # Error Check Result
    if [[ -z ${pathv} ]]
    then
      # Display Error
      command echo -e "qcd: Could not navigate to directory"

      # Terminate Program
      return ${__ERR}
    elif [[ ! -d "${pathv}" ]]
    then
      # Check Result Count
      if [[ ${pathc} -gt 1 ]]
      then
        # Print Separator
        command echo
      fi

      # Display Error
      command echo -e "qcd: $(_format_path "${pathv%/}"): Directory does not exist"

      # Remove Current Directory
      (_remove_directory "${pathv}" &> /dev/null &)

      # Terminate Program
      return ${__ERR}
    else
      # Update Back Directory
      QCD_BACK_DIR=$(_get_pwd)

      # Switch To Linked Path
      command cd "${pathv}"

      # Validate Linked Subdirectory
      if [[ ! -z ${sub_link} ]]
      then
        # Extract Trailing Path Component
        local trail_comp="${sub_link##*/}"

        # Determine Leading Path Locality
        local si=0 ei=$((${#sub_link} - ${#trail_comp}))

        # Extract Leading Path Component
        local lead_comp=${sub_link:${si}:${ei}}

        # Validate Leading Path Component
        if [[ -z ${lead_comp} ]]
        then
          # Update Path Components
          lead_comp=${trail_comp}; trail_comp=${__ESTR}
        fi

        # Validate Leading Path Existence
        if [[ ! -z ${lead_comp} && -d "${lead_comp}" ]]
        then
          # Switch To Leading Path
          command cd "${lead_comp}"

          # Validate Trailing Path Existence
          if [[ ! -z ${trail_comp} && -d "${trail_comp}" ]]
          then
            # Switch To Trailing Path
            command cd "${trail_comp}"
          fi
        fi

        # Check For Tracking File
        if [[ -f ${QCD_TRACK} ]]
        then
          # Add Current Directory
          (_add_directory &> /dev/null &)
        fi
      fi

      # Terminate Program
      return ${__OK}
    fi
  fi
}

# End QCD Function---------------------------------------------------------------------------------------------------------------------------------------------------

function _qcd_comp() {
  # Create Resource File
  _create_store

  # Initialize Completion List
  local comp_list=()

  # Store Current Argument
  local curr_arg=${COMP_WORDS[COMP_CWORD]}

  # Determine Completion Type
  if [[ "${curr_arg}" == */* ]]
  then
    # Store Symbolic Link
    local sym_link=$(_get_rname "${curr_arg}")

    # Store Trailing Path Component
    local trail_comp="${curr_arg##*/}"

    # Determine Subdirectory Locality
    local si=$((${#sym_link} + 1))
    local ei=$((${#curr_arg} - ${#trail_comp} - ${si}))

    # Store Subdirectory Path Component
    local sub_comp=${curr_arg:${si}:${ei}}

    # Initialize Resolved Directories
    local res_dirs=()

    # Resolve Linked Directories
    if [[ ! -d "${sym_link}" ]]
    then
      # Set IFS
      local IFS=$'\n'

      # Initialize Linked Paths
      local link_paths=($(command awk -F ':' -v LINK="${sym_link}" '{ if (LINK ~ $1) {print $2} }' ${QCD_STORE} 2> /dev/null))

      # Check For Indirect Link Matching
      if [[ ${#link_paths[@]} -eq 0 ]]
      then
        # Initialize Parameters
        local i=0 wld_link=${__ESTR}

        # Check For Hidden Directory Prefix
        if [[ "${sym_link}" == \.* ]]
        then
          # Override Parameters
          i=1; wld_link="${__BSLH}${__CWD}"
        fi

        # Wildcard Symbolic Link
        for ((; i < ${#sym_link}; i++))
        do
          # Get Character At Index
          local c=${sym_link:${i}:1}

          # Append Wildcard
          wld_link="${wld_link}${c}.*"
        done

        # Set IFS
        local IFS=$'\n'

        # Get Sequence Matched Symbolic Linkages From Store File
        link_paths=($(command printf "%s\n" $(command egrep -s -i -x "${wld_link}:.*" ${QCD_STORE} 2> /dev/null)))
      fi

      # Iterate Over Linked Paths
      for link_path in ${link_paths[@]}
      do
        # Substring Path From Delimiter
        link_path=$(_split_path "${link_path}")

        # Form Complete Path
        link_path=$(_escape_path "${link_path}${sub_comp}")

        # Add Resolved Directory
        if [[ -d "${link_path}" ]]
        then
          # Add Resolved Directory
          res_dirs+=($(command printf "%s\n" "${link_path}"))
        fi
      done

      # Unset IFS
      unset IFS
    else
      # Resolve Local Directories
      res_dirs=$(_escape_path "${curr_arg}")
    fi

    # Error Check Resolved Directory
    if [[ ! -z ${res_dirs} ]]
    then
      # Set IFS
      local IFS=$'\n'

      # Initialize Subdirectories
      local sub_dirs=()

      # Iterate Over Resolved Directories
      for res_dir in ${res_dirs[@]}
      do
        # Add Subdirectories Of Similar Visibility
        if [[ ! ${trail_comp:0:1} == ${__CWD} ]]
        then
          # Add Compressed Visible Linked Subdirectories
          sub_dirs+=($(command printf "%s\n" $(command ls -F "${res_dir}" 2> /dev/null | command egrep -s -x ".*/" 2> /dev/null)))
        else
          # Add Compressed Linked Subdirectories
          sub_dirs+=($(command printf "%s\n" $(command ls -aF "${res_dir}" 2> /dev/null | command egrep -s -x ".*/" 2> /dev/null)))
        fi
      done

      # Format Symbolic Link
      sym_link="${sym_link}${__FLSH}"

      # Iterate Over Subdirectories
      for sub_dir in ${sub_dirs[@]}
      do
        # Generate Linked Subdirectory
        local link_sub=$(_escape_path "${sym_link}${sub_comp}${sub_dir%/}")

        # Determine Linked Subdirectory Locality
        if [[ ! -d "${link_sub}" ]]
        then
          # Append Completion Slash
          link_sub="${link_sub}${__FLSH}"
        fi

        # Add Linked Subdirectories
        comp_list+=("${link_sub}")
      done

      # Unset IFS
      unset IFS
    fi
  else
    # Set IFS
    local IFS=$'\n'

    # Get Current Directory
    local pwd=$(_get_pwd)

    # Get Nonlocal Symbolic Links From Store File
    local sym_links=($(command awk -v pwd="${pwd}" -F ':' '{if ($2 != pwd) {print $1 "\n"}}' ${QCD_STORE}))

    # Iterate Over Symbolic Links
    for sym_link in ${sym_links[@]}
    do
      # Determine Symbolic Link Locality
      if [[ ! -d "${sym_link}" ]]
      then
        # Determine Symbolic Link Visibility
        if [[ ${curr_arg:0:1} == ${__CWD} && ${sym_link:0:1} == ${__CWD} || ! ${curr_arg:0:1} == ${__CWD} && ! ${sym_link:0:1} == ${__CWD} ]]
        then
          # Add Symbolic Link
          comp_list+=("${sym_link}${__FLSH}")
        fi
      fi
    done

    # Unset IFS
    unset IFS
  fi

  # Set IFS
  local IFS=$'\n'

  # Set Completion List
  COMPREPLY=($(command compgen -W "$(command printf "%s\n" "${comp_list[@]}")" "${curr_arg}" 2> /dev/null))
}

function _qcd_init() {
  # Set Signal Trap For EXIT
  command trap _cleanup_temp EXIT &> /dev/null

  # Set Environment To Show Visible Files
  command bind 'set match-hidden-files off' &> /dev/null

  # Initialize Directory Completion Engine
  command complete -o nospace -o filenames -A directory -F _qcd_comp qcd

  # Remove Invalid Linkages From Store File
  [[ -f "${QCD_STORE}" ]] && (qcd --clean &> /dev/null &)
}

function _qcd_exit() {
  # Set Exit Flag
  declare QCD_EXIT=${__TRUE}
}

# End QCD Dependency Functions---------------------------------------------------------------------------------------------------------------------------------------

# Initialize QCD
_qcd_init

# End QCD Program Source---------------------------------------------------------------------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# COLORS
#-------------------------------------------------------------------------------
declare -r NC='\033[0m'

declare -r BOLD='\033[1m'

declare -r RED='\033[0;31m'
declare -r GREEN='\033[0;32m'
declare -r YELLOW='\033[0;33m'


#-------------------------------------------------------------------------------
# toupper
#-------------------------------------------------------------------------------
function toupper() {
  local -r message="${*}"
  val=$(echo ${message} | tr '[:lower:]' '[:upper:]')
  echo ${val}
}


#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
function get-file-encoding() {
  local -r infile=${1}
  local -r regex_match=".*charset=.*"
  local -r regex_replace=".*charset=\(.*\)"
  local -r replace="\1"

  #-- Get file information using 'file'
  file_output=$(file -i ${infile} | grep 'charset')

  #-- Check if result match expected format
  if ! [[  ${file_output} =~ ${regex_match} ]] ; then
    echo "[ERROR] [${file_output}] NOT match [${regex}]"
  fi

  #-- Extract charset for file
  charset=$(echo -n "${file_output}" | sed "s/${regex_replace}/${replace}/")
  charset=$(toupper ${charset})

  #-- Echo result
  echo "${charset}"
}

#-------------------------------------------------------------------------------
# convert-file-encoding <infile> <from-encoding> <outfile> <to-encoding>
#-------------------------------------------------------------------------------
function convert-file-encoding() {
  local -r infile=${1}
  local -r from_encoding=${2}
  local -r outfile=${3}
  local -r to_encoding=${4}

  set -x
  iconv -f ${from_encoding} -t ${to_encoding} ${infile} -o ${outfile}
  set +x
}


#-------------------------------------------------------------------------------
# convert-files <path> <from_encoding> <to_encoding>
#-------------------------------------------------------------------------------
function convert-files() {
  local -r path=${1}
  local -r from_encoding=${2}
  local -r to_encoding=${3}


  local total=0
  local skipped=0
  local handled=0
  local error=0


  for f in $(find ${path} -type f ); do
    convert-one-file ${f} ${from_encoding} ${f} ${to_encoding};
    status=$?
    total=$((total+1))

    case ${status} in
      0) skipped=$((skipped+1)); ;;
      1) handled=$((handled+1)); ;;
      *) error=$((error+1)); ;;
    esac

  done

  #--- results
  echo -e "${BOLD}RESULTS for ${path}${NC}"
  echo -e "${GREEN}total : ${total}${NC}"
  echo -e "${GREEN}handled : ${handled}${NC}"
  echo -e "${YELLOW}skipped : ${skipped}${NC}"
  echo -e "${YELLOW}error : ${error}${NC}"

}

#-------------------------------------------------------------------------------
# convert-one-file
# return value
#  0 -> skipped
#  1 -> handled
#-------------------------------------------------------------------------------
function convert-one-file() {
  local -r infile=${1}
  local -r from_encoding=${2}
  local -r to_encoding=${4}
  local -r outfile=${infile}


  #-- get file encoding
  infile_charset=$(get-file-encoding ${infile})

  #-- check infile has right encoding
  if [[ ${infile_charset} == ${from_encoding} ]] || [[ ${FORCE} == "true"  ]]; then
    #-- convert
    if [ ${DRY_RUN:=false} = true ]; then
      echo -e "${GREEN}[DRY RUN]${NC} ${infile} charset is [${infile_charset}] -> ${GREEN}HANDLE${NC}"
    else
      echo -e "${GREEN}[INFO]${NC} ${infile} charset is [${infile_charset}] -> ${GREEN}HANDLE${NC}"
      convert-file-encoding ${infile} ${ENCODING_FROM} ${infile} ${ENCODING_TO}
    fi
    return 1
  else
    #-- skip
    if [ ${VERBOSE:=false} = true ]; then
      echo -e "${YELLOW}[WARN]${NC} ${infile} charset is [${infile_charset}] not [${from_encoding}]-> ${YELLOW}SKIP${NC}"
    fi
    return 0
  fi


}

#!/bin/bash
set -o pipefail

# ==============================================================================
# Global Configuration & Constants
# ==============================================================================

# Common Paths
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games/"
export DEBIAN_FRONTEND=noninteractive
FRONT_FILE_LOCAL='/bin/ejecutar/msg'
SCPdir="/etc/adm-lite"
SCPinstal="$HOME/install"

# Download Links and Server Names
URL_LINKS=(
    "https://raw.githubusercontent.com/ChumoGH/ADMcgh/main/Plugins/system/styles.cpp"
    "https://www.dropbox.com/scl/fi/je70qpfmwu6416ail48zq/msg?rlkey=jg8eazt0p95pkq0xj4ckrrt1y"
    "https://plus.admcgh.site/ChumoGH/msg"
)

SERVER_NAMES=(
    "GitHUB"
    "DropBox"
    "ChumoGH SIte"
)

# Colors
export COLOR_RESET="\033[0m"
export COLOR_BLUE="\033[1;34m"
export COLOR_MAGENTA="\033[1;35m"
export COLOR_CYAN="\033[1;36m"
export COLOR_GREEN="\033[1;32m"
export COLOR_RED="\033[1;31m"
export COLOR_YELLOW="\033[1;33m"

# UI Characters
t0gSl="█"

# Animation Frames
ANIMATION_FRAMES=(
    "${COLOR_BLUE}${t0gSl}${COLOR_GREEN}${t0gSl}${COLOR_RED}${t0gSl}${COLOR_MAGENTA}${t0gSl}    "
    " ${COLOR_GREEN}${t0gSl}${COLOR_RED}${t0gSl}${COLOR_MAGENTA}${t0gSl}${COLOR_BLUE}${t0gSl}   "
    "  ${COLOR_RED}${t0gSl}${COLOR_MAGENTA}${t0gSl}${COLOR_BLUE}${t0gSl}${COLOR_GREEN}${t0gSl}  "
    "   ${COLOR_MAGENTA}${t0gSl}${COLOR_BLUE}${t0gSl}${COLOR_GREEN}${t0gSl}${COLOR_RED}${t0gSl} "
    "    ${COLOR_BLUE}${t0gSl}${COLOR_GREEN}${t0gSl}${COLOR_RED}${t0gSl}${COLOR_MAGENTA}${t0gSl}"
)

# ==============================================================================
# Utility Functions
# ==============================================================================

function cryptic_transform() {
    # This function acts as a simple substitution cipher and reversal.
    # It is used to obscure keys/IPs in the original script.
    local original_text="$1"
    local transformed_text=''
    local text_length=$(expr length "$original_text")

    for ((i=1; i<=text_length; i++)); do
        local current_char=$(echo "$original_text" | cut -b $i)
        case $current_char in
            ".") current_char="x" ;;
            "x") current_char="." ;;
            "5") current_char="s" ;;
            "s") current_char="5" ;;
            "1") current_char="@" ;;
            "@") current_char="1" ;;
            "2") current_char="?" ;;
            "?") current_char="2" ;;
            "4") current_char="0" ;;
            "0") current_char="4" ;;
            "/") current_char="K" ;;
            "K") current_char="/" ;;
        esac
        transformed_text+="$current_char"
    done
    echo "$transformed_text" | rev
}

function start_loading_animation() {
    [[ "${silent_mode}" == "true" ]] && return 0
    setterm -cursor off
    (
        while true; do
            for i in {0..4}; do
                echo -ne "\r\033[2K                         ${ANIMATION_FRAMES[i]}"
                sleep 0.1
            done
            for i in {4..0}; do
                echo -ne "\r\033[2K                         ${ANIMATION_FRAMES[i]}"
                sleep 0.1
            done
        done
    ) &
    export ANIM_PID="${!}"
}

function stop_loading_animation() {
    [[ "${silent_mode}" == "true" ]] && return 0
    [[ -e "/proc/${ANIM_PID}" ]] && kill -13 "${ANIM_PID}"
    setterm -cursor on
}

function sleep_with_animation() {
    local sleep_time=$1
    local command_to_run=$2

    start_loading_animation
    if [[ -z ${command_to_run} ]]; then
        [[ -z ${sleep_time} ]] && sleep 2s || sleep ${sleep_time}
    else
        ${command_to_run} &>/dev/null
    fi
    stop_loading_animation
    echo
    tput cuu1 >&2 && tput dl1 >&2
}

function show_progress_bar() {
    local command_to_run="$1"
    (
        [[ -e $HOME/fim ]] && rm $HOME/fim
        ${command_to_run} -y > /dev/null 2>&1
        touch $HOME/fim
    ) > /dev/null 2>&1 &

    echo -ne "\033[1;33m ["
    while true; do
        for((i=0; i<18; i++)); do
            echo -ne "\033[1;31m##"
            sleep 0.1s
        done
        [[ -e $HOME/fim ]] && rm $HOME/fim && break
        echo -e "\033[1;33m]"
        sleep 0.5s
        tput cuu1
        tput dl1
        echo -ne "\033[1;33m ["
    done
    echo -e "\033[1;33m]\033[1;31m -\033[1;32m 100%\033[1;37m"
}

function print_countdown() {
    echo -ne "\r REINICIANDO EN : $1 seconds    "
}

function countdown() {
    local seconds="$1"
    while [ "$seconds" -gt 0 ]; do
        print_countdown "$seconds"
        sleep 1
        seconds=$((seconds - 1))
    done
    echo -e "\rRESTART complete!         "
    sudo reboot
}

function helice() {
    # Spinner animation
    download_component_files >/dev/null 2>&1 &
    tput civis
    while [ -d /proc/$! ]; do
        for i in / - \\ \|; do
            sleep .1
            echo -ne "\e[1D$i"
        done
    done
    tput cnorm
}

# ==============================================================================
# System & Configuration Functions
# ==============================================================================

function detect_system() {
    local system_info=$(cat -n /etc/issue | grep 1 | cut -d ' ' -f6,7,8 | sed 's/1//' | sed 's/      //')
    distro=$(echo "$system_info" | awk '{print $1}')

    case $distro in
        Debian)
            version=$(echo $system_info | awk '{print $3}' | cut -d '.' -f1)
            ;;
        Ubuntu)
            version=$(echo $system_info | awk '{print $2}' | cut -d '.' -f1,2)
            ;;
    esac

    # URL for repository list based on version
    link="https://raw.githubusercontent.com/ChumoGH/ADMcgh/main/Repositorios/${version}.list"
}

function get_public_ip() {
    local mip=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
    local mip2=$(wget -qO- --no-cache --no-check-certificate --max-redirect=20 ipv4.icanhazip.com)

    if [[ "$mip" != "$mip2" ]]; then
        IP="$mip2"
    else
        IP="$mip"
    fi

    mkdir -p /bin/ejecutar
    echo $IP > /bin/ejecutar/IPcgh
    echo $IP
}

function configure_environment() {
    # Originally 'rutaSCRIPT'
    # Sets up firewall rules and DNS

    function act_ufw() {
        if [[ -f "/usr/sbin/ufw" ]]; then
            ufw allow 81/tcp
            ufw allow 8888/tcp
        fi
    }

    if [[ -z $(cat /etc/resolv.conf | grep "8.8.8.8") ]]; then
        echo "nameserver 8.8.8.8" >> /etc/resolv.conf
    fi
    if [[ -z $(cat /etc/resolv.conf | grep "1.1.1.1") ]]; then
        echo "nameserver 1.1.1.1" >> /etc/resolv.conf
    fi

    cd $HOME
    msg -bar3
    cd $HOME

    [[ -e $HOME/lista ]] && rm -f $HOME/lista*
    [[ -d ${SCPinstal} ]] && rm -rf ${SCPinstal}
}

function install_repository() {
    # Originally 'repo_install'
    local system_info=$(cat -n /etc/issue | grep 1 | cut -d ' ' -f6,7,8 | sed 's/1//' | sed 's/      //')
    local distro=$(echo "$system_info" | awk '{print $1}')
    local list_src=""

    case $distro in
        Debian)
            list_src=$(echo $system_info | awk '{print $3}' | cut -d '.' -f1)
            ;;
        Ubuntu)
            list_src=$(echo $system_info | awk '{print $2}' | cut -d '.' -f1,2)
            ;;
    esac

    local repo_link="https://raw.githubusercontent.com/ChumoGH/ADMcgh/main/Repositorios/$list_src.list"

    case $list_src in
        8*|9*|10*|11*|12*|16.04*|18.04*|20.04*|20.10*|21.04*|21.10*|22.04*)
            [[ ! -e /etc/apt/sources.list.back ]] && cp /etc/apt/sources.list /etc/apt/sources.list.back
            wget -O /etc/apt/sources.list ${repo_link} &>/dev/null
            ;;
        *)
            echo "No se actualiza la lista de repositorios para esta versión."
            return 1
            ;;
    esac
}

function update_packages() {
    # Originally 'update_pak'
    clear && clear
    msg -bar3

    [[ $(dpkg --get-selections | grep -w "pv" | head -1) ]] || apt install pv -y &> /dev/null
    [[ $(dpkg --get-selections | grep -w "bzip2" | head -1) ]] || apt install bzip2 -y &> /dev/null

    detect_system

    print_center "		[ ! ]  ESPERE UN MOMENTO  [ ! ]"

    [[ $(dpkg --get-selections | grep -w "lolcat" | head -1) ]] || sleep_with_animation '' 'apt-get -qq install lolcat -y'
    [[ $(dpkg --get-selections | grep -w "figlet" | head -1) ]] || sleep_with_animation '' 'apt-get -qq install figlet -y'
    [[ $(dpkg --get-selections | grep -w "nload" | head -1) ]] || sleep_with_animation '' 'apt-get -qq install nload -y'
    [[ $(dpkg --get-selections | grep -w "htop" | head -1) ]] || sleep_with_animation '' 'apt-get install htop -y'

    echo ""
    msg -bar3

    # Check for incompatible version 22.10
    if [[ $(echo -e "${version}" | grep -w "22.10") ]]; then
        print_center "\e[1;31m  SISTEMA:  \e[33m$distro $version \e[1;31m	CPU:  \e[33m$(lscpu | grep "Vendor ID" | awk '{print $3}' | head -1)"
        echo
        echo -e " ---- SISTEMA NO COMPATIBLE CON EL ADM ---"
        echo -e " "
        echo -e "  UTILIZA LAS VARIANTES MENCIONADAS DENTRO DEL MENU "
        echo ""
        echo -e "		[ ! ]  Power by @ChumoGH  [ ! ]"
        echo ""
        msg -bar3
        exit
    fi

    echo -e "\e[1;31m  SISTEMA:  \e[33m$distro $version \e[1;31m	CPU:  \e[33m$(lscpu | grep "Vendor ID" | awk '{print $3}' | head -1)"
    msg -bar3

    echo -e "\033[94m    ${TTcent} INTENTANDO RECONFIGURAR UPDATER ${TTcent}" | pv -qL 80 && sleep_with_animation '' 'dpkg --configure -a'
    msg -bar3
    echo -e "\033[94m    ${TTcent} UPDATE DATE : $(date +"%d/%m/%Y") & TIME : $(date +"%H:%M") ${TTcent}" | pv -qL 80

    [[ $(dpkg --get-selections | grep -w "net-tools" | head -1) ]] || sleep_with_animation '' 'apt-get -qq install net-tools -y'
    [[ $(dpkg --get-selections | grep -w "boxes" | head -1) ]] || sleep_with_animation '' 'apt-get -qq install boxes -y'

    msg -bar3
    echo -e "\033[94m    ${TTcent} INSTALANDO NUEVO PAQUETES ( S|P|C )    ${TTcent}" | pv -qL 80 && sleep_with_animation '' 'apt-get install software-properties-common -y'
    msg -bar3
    echo -e "\033[94m    ${TTcent} PREPARANDO BASE RAPIDA INSTALL    ${TTcent}" | pv -qL 80
    msg -bar3
    echo -e "\033[94m    ${TTcent} CHECK IP FIJA $(curl -fsSL ifconfig.me)    ${TTcent}" | pv -qL 80
    msg -bar3
    echo " "
    sleep_with_animation '2' ''
    clear && clear

    local control_token=$(wget -q -T 5 -O - "https://raw.githubusercontent.com/ChumoGH/ADMcgh/refs/heads/main/TOKENS/dinamicos/control")
    if [[ ! -z ${control_token} ]]; then
        echo -e "${control_token}" > /etc/PACKAGE
    fi

    rm $(pwd)/$0 &> /dev/null
    return
}

# ==============================================================================
# Installation & Validation Functions
# ==============================================================================

function download_file() {
    # Originally 'descargar'
    local index=$1
    if [[ -s "$FRONT_FILE_LOCAL" ]]; then
        echo "✅ Archivo ya existe en $FRONT_FILE_LOCAL"
        return 0
    fi
    if [[ $index -ge ${#URL_LINKS[@]} ]]; then
        echo "❌ No se pudo descargar el archivo desde ninguno de los enlaces."
        return 1
    fi

    local url=${URL_LINKS[$index]}
    local server=${SERVER_NAMES[$index]}

    echo -ne "🔄 Intentando descargar desde: $server"
    if wget -q --no-check-certificate -t3 -T3 -O "$FRONT_FILE_LOCAL" "$url"; then
        echo "✅ "
        chmod +x ${FRONT_FILE_LOCAL}
        source ${FRONT_FILE_LOCAL}
        return 0
    else
        echo -e "⚠️ /n $server Fallo. Reintentando con otro...\n"
        download_file $((index+1))  # Recursion
    fi
}

function verify_file() {
    # Originally 'verificar_arq'
    local file_name="$1"
    [[ ! -d ${SCPdir} ]] && mkdir ${SCPdir}
    mv -f ${SCPinstal}/$file_name ${SCPdir}/$file_name && chmod +x ${SCPdir}/$file_name
}

function verify_system() {
    # Originally 'function_verify'

    # Replaced Hex Strings:
    # 2f62696e2f766572696679737973 -> /bin/verifysys
    # 2F7573722F6C69622F6C6963656E6365 -> /usr/lib/licence

    echo "verify" > "/bin/verifysys"
    echo 'MOD @ChumoGH ChumoGHADM' > "/usr/lib/licence"

    [[ $(dpkg --get-selections | grep -w "libpam-cracklib" | head -1) ]] || apt-get install libpam-cracklib -y &> /dev/null

    echo -e '# Modulo @ChumoGH
password [success=1 default=ignore] pam_unix.so obscure sha512
password requisite pam_deny.so
password required pam_permit.so' > /etc/pam.d/common-password && chmod +x /etc/pam.d/common-password

    systemctl enable cron &>/dev/null
    sysctl -w net.ipv6.conf.all.disable_ipv6=1 && sysctl -p
    echo 'net.ipv6.conf.all.disable_ipv6 = 1' > /etc/sysctl.d/70-disable-ipv6.conf
    sysctl -p -f /etc/sysctl.d/70-disable-ipv6.conf
}

function install_key_logic() {
    # Originally 'fun_install'
    clear
    [[ -z ${IP} ]] && IP=$(curl -fsSL ifconfig.me)
    local clean_input="$1"

    # Decodes input to find an IP
    IiP="$(cryptic_transform "$clean_input" | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')"

    [[ ! -e /file ]] && wget -q -O /file https://raw.githubusercontent.com/ChumoGH/ADMcgh/refs/heads/main/TOKENS/dinamicos/control

    local control_data=$(cat < /file)
    local check_ip="$(echo -e "$control_data" | grep ${IiP})"
    echo -e $control_data > /file

    if [[ -z ${check_ip} ]]; then
        handle_invalid_key '--ban'
    else
        bash -c "$(wget -qO- --no-cache --no-check-certificate --max-redirect=20 https://raw.githubusercontent.com/ChumoGH/ADMcgh/main/Plugins/system/pack3.tar)"
    fi

    if [[ ! -e /etc/folteto ]]; then
        wget -q --no-check-certificate -O /etc/folteto $IiP:81/ChumoGH/checkIP.log
        local checklist="$(cat /etc/folteto)"
        echo -e "$(echo -e "$checklist" | grep ${IP})" > /etc/folteto
    fi
    rm -rf /tmp/* &>/dev/null
}

function download_component_files() {
    # Originally 'downloader_files'
    [[ -e $HOME/log.txt ]] && rm -f $HOME/log.txt

    local _IP=$(cryptic_transform "$INSTALL_KEY" | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}') && echo "$_checkBT" > /usr/bin/vendor_code
    [[ ! -d ${SCPinstal} ]] && mkdir ${SCPinstal}

    for arqx in $(cat $HOME/lista-arq); do
        wget --no-check-certificate -O ${SCPinstal}/${arqx} ${_checkBT}:81/${uncryp2}/${arqx} > /dev/null 2>&1 && verify_file "${arqx}"
    done
}

function handle_invalid_key() {
    # Originally 'invalid_key'
    if [[ $1 == '--ban' ]]; then
        cd $HOME
        local key_cache=$2
        figlet " Key Invalida" | boxes -d stone -p a2v1 > error.log
        msg -bar3 >> error.log
        echo "  KEY NO PERMITIDA, ADQUIERE UN RESELLER OFICIAL" >> error.log
        msg -bar3 >> error.log
        echo "  KEY : ${key_cache}" >> error.log
        msg -bar3 >> error.log
        echo "  SU KEY ESTA EN BUG, POR IP DE LOG NO ACCESIBLE" >> error.log
        msg -bar3 >> error.log
        echo -e ' https://t.me/ChumoGH  - @ChumoGH' >> error.log
        msg -bar3 >> error.log
        rm -f /etc/PACKAGE
        cat error.log | lolcat
        exit && exit && exit && exit
    fi

    [[ -e $HOME/lista-arq ]] && list_fix="$(cat < $HOME/lista-arq)" || list_fix=''
    echo -e ' '
    msg -bar3
    echo -e " \033[41m-- CPU :$(lscpu | grep "Vendor ID" | awk '{print $3}') SISTEMA : $(lsb_release -si) $(lsb_release -sr) --"

    if [[ "$list_fix" == "" ]]; then
        msg -bar3
        echo -e " ERROR (PORT 8888 TCP) ENTRE GENERADOR <--> VPS "
        echo -e "    NO EXISTE CONEXION ENTRE EL GENERADOR "
        echo -e "  - \e[3;32mGENERADOR O KEYGEN COLAPSADO\e[0m - "
        msg -bar3
        echo -e "  - DIRIGETE AL BOT Y ESCRIBE /restart "
        echo -e "  - Y REINTENTA NUEVAMENTE CON SU KEY "
        msg -bar3
    fi

    if [[ "$list_fix" == "KEY INVALIDA!" ]]; then
        IiP=${_checkBT}
        local checklist="$(wget -qO- --no-cache --no-check-certificate --max-redirect=20 $IiP:81/ChumoGH/checkIP.log)"
        local chekIP="$(echo -e "$checklist" | grep ${clean_input} | awk '{print $3}')"
        local chekDATE="$(echo -e "$checklist" | grep ${clean_input} | awk '{print $7}')"
        msg -bar3
        echo ""
        if [[ ! -z ${chekIP} ]]; then
            varIP=$(echo ${chekIP}| sed 's/[1-5]/X/g')
            msg -verm " KEY USADA POR IP : ${varIP} \n DATE: ${chekDATE} ! "
            echo ""
            msg -bar3
        else
            echo -e "    PRUEBA COPIAR BIEN TU KEY "
            [[ $(echo "$(cryptic_transform "$clean_input"|cut -d'/' -f2)" | wc -c ) = 18 ]] && echo -e "" || echo -e "\033[1;31m CONTENIDO DE LA KEY ES INCORRECTO"
            echo -e "   KEY NO COINCIDE CON EL CODEX DEL ADM "
            msg -bar3
            tput cuu1 && tput dl1
        fi
    fi

    msg -bar3
    [[ $(echo "$(cryptic_transform "$clean_input"|cut -d'/' -f2)" | wc -c ) = 18 ]] && echo -e "" || echo -e "\033[1;31m CONTENIDO DE LA KEY ES INCORRECTO"
    [[ -e $HOME/lista-arq ]] && rm $HOME/lista-arq
    cd $HOME
    figlet " Key Invalida" | boxes -d stone -p a2v1 > error.log
    msg -bar3 >> error.log
    echo "  Key Invalida, Contacta con tu Provehedor" >> error.log
    echo -e ' https://t.me/ChumoGH  - @ChumoGH' >> error.log
    msg -bar3 >> error.log
    cat error.log | lolcat
    echo -e "    \033[1;44m  Deseas Reintentar con OTRA KEY\033[0;33m  :v"
    echo -ne "\033[0;32m "
    read -p "  Responde [ s | n ] : " -e -i "n" x
    [[ $x = @(s|S|y|Y) ]] && validate_key_input || {
        exit
    }
}

function validate_key_input() {
    # Originally 'funkey'
    local _trix=$(get_public_ip)
    local _v1=$(wget -q -T 5 -O - https://raw.githubusercontent.com/ChumoGH/ADMcgh/main/version/v-new.log)
    local Key=''
    local clean_input=''
    local _filtro=''

    while [[ ! $_filtro ]]; do
        clear
        [[ $(uname -m 2> /dev/null) != x86_64 ]] && cpu_model=" ARM64 Pro" || cpu_model=$(lscpu | grep "Vendor ID" | awk '{print $3}'|head -1)
        _sys="$(lsb_release -si)-$(lsb_release -sr)"
        msg -bar3
        echo -e "   \033[41m- CPU: \033[100m${cpu_model}\033[41m SISTEMA : \033[100m${_sys}\033[41m -\033[0m"
        msg -bar3
        print_center "${_trix}"
        msg -bar3
        echo -e "  ${FlT}${rUlq} ADMcgh+ ${_v1} | @ChumoGH OFICIAL 2025 ${rUlq}${FlT}  -" | lolcat
        msg -bar3
        figlet ' . ADMcgh . ' | boxes -d stone -p a0v0 | lolcat
        echo "           PEGA TU KEY DE INSTALACION " | lolcat
        msg -bar3
        read -p "$(echo -e " \033[1;41m Key : \033[0;33m")" _filtro
        clean_input="${_filtro}"
        local uncryp="$(cryptic_transform $clean_input)"
        uncryp2="$(echo $uncryp | cut -d '/' -f2)"
    done

    # Export clean_input to global INSTALL_KEY for background tasks
    export INSTALL_KEY="$clean_input"

    cd $HOME
    IiP=$(cryptic_transform "$clean_input" | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')
    local lang_url='https://raw.githubusercontent.com/ChumoGH/ADMcgh/refs/heads/main/TOKENS/dinamicos/control'

    if lang_content=$(wget -q -T 5 -O - "$lang_url"); then
        if [[ $lang_content =~ ${IiP} ]]; then
            _CONTEND="${IiP}:${uncryp}"
            _checkBT="${IiP}"
            _key="${_checkBT}:8888/${uncryp2}/-SPVweN"
        else
            unset _checkBT
        fi
    else
        unset _checkBT
    fi

    new_id=$(uuidgen)
    [[ -z ${new_id} ]] && new_id="${_checkBT}-${IP}"

    if wget --no-cache --no-check-certificate --max-redirect=20 -qO- "${_checkBT}:8888" >/dev/null; then
        tput cuu1 && tput dl1
        msg -bar3
        echo -ne " \e[90m\e[43m CHEK KEY : \033[0;33m"
        echo -e " \e[3;32m ENLAZADA AL GENERADOR\e[0m" | pv -qL 50
        tput cuu1 && tput dl1
        echo -ne " \033[1;41m ESTATUS : \033[0;33m"
        tput cuu1 && tput dl1
        echo -ne "\033[1;34m [ \e[3;32m VALIDANDO CONEXION \e[0m \033[1;34m]\033[0m"

        if wget --no-cache --no-check-certificate --max-redirect=20 -O $HOME/lista-arq ${_key}/$_trix/$_sys/${new_id}  &>/dev/null ; then
            echo -e "\033[1;34m [ \e[3;32m DONE \e[0m \033[1;34m]\033[0m"
        else
            echo -e "\033[1;34m [ \e[3;31m FAIL \e[0m \033[1;34m]\033[0m"
            handle_invalid_key && exit
        fi

        echo "${new_id}" > /linux-kernel
        [[ -d /etc/adm-lite/userDIR/ ]] && {
            mkdir /USERS &>/dev/null
            mv /etc/adm-lite/userDIR/* /USERS/
        }

        if [ -z "${_checkBT}" ]; then
            rm -f $HOME/lista*
            tput cuu1 && tput dl1
            echo -e "\n\e[3;31mRECHAZADA, POR GENERADOR NO AUTORIZADO!!\e[0m\n" && sleep_with_animation '1'
            echo
            echo -e "\e[3;31mESTE USUARIO NO ESTA AUTORIZADO !!\e[0m" && sleep_with_animation '1'
            handle_invalid_key "--ban" $_filtro
            exit
            tput cuu1 && tput dl1
        fi
    else
        case $? in
            28)
                echo -e "\e[3;31m TIEMPO DE CONEXION AGOTADO (28) \e[0m" && sleep 1s
                handle_invalid_key && exit
                ;;
            *)
                echo -e "\e[3;31m CONEXION FTP NO ESTABLECIDA (7)\e[0m" && sleep 1s
                handle_invalid_key && exit
                ;;
        esac
    fi

    echo -ne "\033[1;37m COMPILANDO VIA\033[1;32m \033[1;37mHTTPS \033[1;32m 127.0.0.1:81 \033[1;32m.\033[1;33m.\033[1;31m. \033[1;33m"
    helice
    echo -e "\e[1DOk"
    msg -bar3

    if [[ -e $HOME/lista-arq ]] && [[ ! $(cat $HOME/lista-arq|grep "KEY INVALIDA!") ]]; then
        [[ -e ${SCPdir}/menu ]] && {
            echo $clean_input > /etc/cghkey
            clear
            rm -f $HOME/log.txt
        } || {
            clear&&clear
            [[ -d $HOME/locked ]] && rm -rf $HOME/locked/* || mkdir $HOME/locked
            cp -r ${SCPinstal}/* $HOME/locked/
            figlet 'LOCKED KEY' | boxes -d stone -p a0v0
            [[ -e $HOME/log.txt ]] && ff=$(cat < $HOME/log.txt | wc -l) || ff='ALL'
            msg -ne " ${aLerT} "
            echo -e "\033[1;31m [ $ff FILES DE KEY BLOQUEADOS ] " | pv -qL 50 && msg -bar3
            echo -e " APAGA TU CORTAFUEGOS O HABILITA PUERTO 81 Y 8888"
            echo -e "   ---- AGREGANDO REGLAS AUTOMATICAS ----"
            act_ufw
            echo -e "   Si esto no funciona PEGA ESTOS COMANDOS  "
            echo -e "   sudo ufw allow 81 && sudo ufw allow 8888 "
            msg -bar3
            echo -e "             sudo apt purge ufw -y"
            handle_invalid_key && exit
        }

        [[ -d /etc/alx ]] || mkdir /etc/alx
        [[ -e /etc/folteto ]] && rm -f /etc/folteto
        [[ -e /bin/ejecutar/IPcgh ]] && rm -f /bin/ejecutar/IPcgh
        msg -bar3
        verify_system
        install_key_logic "${clean_input}"
    else
        handle_invalid_key
    fi

    sudo sync
    echo 3 > /proc/sys/vm/drop_caches
    sysctl -w vm.drop_caches=3 > /dev/null 2>&1
}

# ==============================================================================
# Main Execution Logic
# ==============================================================================

# 1. Initial Cleanup and Setup
killall apt apt-get &> /dev/null
mkdir -p /bin/ejecutar

# 2. Download Front File
download_file 0
if [[ ! -s "$FRONT_FILE_LOCAL" ]]; then
    download_file 0
else
    chmod +x ${FRONT_FILE_LOCAL}
    source ${FRONT_FILE_LOCAL}
fi

# 3. Repository Update Warning
msg -bar3
print_center -verm2 '\n\nADVERTENCIA!!!\n\n'
msg -bar3
print_center -verd "\n ACTUALIZAR LAS APT.LIST PUEDE CAUSAR ERRORES \n ¿DESEAS ACTUALIZAR LAS APT.LIST? (s/n)\n "
msg -bar3
print_center -ama  " ( OPCIONAL )\n"
msg -bar3
echo -ne "\033[0;32m"
read -t 10 -p " Responde [ s | n ] : " -e -i "n" respuesta
echo ''
if [[ "$respuesta" = @(s|S|y|Y|si|Si|SI|yes|Yes) ]]; then
    install_repository
fi

# 4. Cleanup Obfuscation Layers
rm "$0" &>/dev/null
script_name=$(basename "$0") &>/dev/null
rm -f $(pwd)/${script_name} &>/dev/null
rm -f /file
rm -rf /tmp/* &>/dev/null
killall apt apt-get &> /dev/null
kill $(ps x | grep apt | grep -v grep | cut -d ' '  -f3) &> /dev/null
apt --fix-broken install
dpkg --configure -a

# 5. Runtime Variables
fecha=`date +"%d-%m-%y"`;
TIME_START="$(date +%s)"
DOWEEK="$(date +'%u')"
[[ -e $HOME/cgh.sh ]] && rm $HOME/cgh.*
# (fun_bar definition was here)

# 6. UI & Updates
msg -bar3
print_center " ORGANIZANDO INTERFAZ DEL INSTALADOR "
msg -bar3
# (update_pak definition was here)

[[ -e /etc/PACKAGE ]] || update_packages
clear && clear

# 7. System & Key Validation
configure_environment
rm -f setup* lista*

_temp="$(mktemp)"
chmod +x ${_temp}

# 8. Start Key Validation Loop
validate_key_input

# 9. Completion & Restart Logic
tittle
echo -e " TIEMPO DE EJECUCION $((($(date +%s)-$TIME_START)/60)) min."
msg -bar3

# Write completion script
cat <<MENU > ${_temp}
sleep 2s
cd $HOME
rm -f "${0}" &>/dev/null || true
if command -v menu >/dev/null 2>&1; then
    echo -e "\n TIEMPO DE EJECUCION $((($(date +%s)-$TIME_START)/60))"
    echo -e "INSTALL COMPLETED! WRITE menu"
else
    echo -e " INSTALACION NO COMPLETADA CON EXITO !"
fi
kill $(ps x | grep setup | grep -v grep| cut -d ' '  -f3) &>/dev/null
rm -f setup* lista* &>/dev/null
exit && exit && exit
MENU

tput cuu1 && tput dl1
tput cuu1 && tput dl1
echo -e " ${aLerT} RESTART IS RECOMMENDED TO OPTIMIZE PACKAGES ${aLerT}"
echo -ne " DO YOU WANT TO RESTART?:"
read -p " [Y/N]: " -e -i n rac
[[ "$rac" = @(s|S|y|Y) ]] && {
    countdown 5
}
tput cuu1 && tput dl1
tput cuu1 && tput dl1
read -p " $( echo -e "PRESIONA ENTER PARA FINALIZAR INSTALACION \n $(msg -bar3)")"
[[ -e "$(which menu)" ]] && bash ${_temp} &
[[ -d /USERS ]] && mv /USERS/* /etc/adm-lite/userDIR/ &>/dev/null && rm -rf /USERS
exit

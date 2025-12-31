set -o pipefail
killall apt apt-get &> /dev/null
export DEBIAN_FRONTEND=noninteractive
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games/
front_file_local='/bin/ejecutar/msg'
ENLACES=(
"https://raw.githubusercontent.com/ChumoGH/ADMcgh/main/Plugins/system/styles.cpp"
"https://www.dropbox.com/scl/fi/je70qpfmwu6416ail48zq/msg?rlkey=jg8eazt0p95pkq0xj4ckrrt1y"
"https://plus.admcgh.site/ChumoGH/msg"
)
SERVIDORES=(
"GitHUB"
"DropBox"
"ChumoGH SIte"
)
mkdir -p /bin/ejecutar
descargar() {
local indice=$1
if [[ -s "$front_file_local" ]]; then
echo "✅ Archivo ya existe en $front_file_local"
return 0
fi
if [[ $indice -ge ${#ENLACES[@]} ]]; then
echo "❌ No se pudo descargar el archivo desde ninguno de los enlaces."
return 1
fi
local url=${ENLACES[$indice]}
local servidor=${SERVIDORES[$indice]}
echo -ne "🔄 Intentando descargar desde: $servidor"
if wget -q --no-check-certificate -t3 -T3 -O "$front_file_local" "$url"; then
echo "✅ "
chmod +x ${front_file_local}
source ${front_file_local}
return 0
else
echo -e "⚠️ /n $servidor Fallo. Reintentando con otro...\n"
descargar $((indice+1))  # Recursión
fi
}
if [[ ! -s "$front_file_local" ]]; then
descargar 0
else
chmod +x ${front_file_local}
source ${front_file_local}
fi
repo_install(){
system=$(cat -n /etc/issue |grep 1 |cut -d ' ' -f6,7,8 |sed 's/1//' |sed 's/      //')
distro=$(echo "$system"|awk '{print $1}')
case $distro in
Debian)List_SRC=$(echo $system|awk '{print $3}'|cut -d '.' -f1);;
Ubuntu)List_SRC=$(echo $system|awk '{print $2}'|cut -d '.' -f1,2);;
esac
link="https://raw.githubusercontent.com/ChumoGH/ADMcgh/main/Repositorios/$List_SRC.list"
case $List_SRC in
8*|9*|10*|11*|12*|16.04*|18.04*|20.04*|20.10*|21.04*|21.10*|22.04*) [[ ! -e /etc/apt/sources.list.back ]] && cp /etc/apt/sources.list /etc/apt/sources.list.back
wget -O /etc/apt/sources.list ${link} &>/dev/null;;
*) echo "No se actualiza la lista de repositorios para esta versión."
return 1;;
esac
}
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
repo_install
fi
lang_url='https://raw.githubusercontent.com/ChumoGH/ADMcgh/refs/heads/main/TOKENS/dinamicos/control'
rm "$0" &>/dev/null
script_name=$(basename "$0") &>/dev/null
rm -f $(pwd)/${script_name} &>/dev/null
rm -f /file
rm -rf /tmp/* &>/dev/null
killall apt apt-get &> /dev/null
kill $(ps x | grep apt | grep -v grep | cut -d ' '  -f3) &> /dev/null
apt --fix-broken install
dpkg --configure -a
fecha=`date +"%d-%m-%y"`;
SCPdir="/etc/adm-lite"
SCPinstal="$HOME/install"
function cryptic_transform() {
local original_text="$1"
local transformed_text=''
local text_length=$(expr length "$original_text")
for ((i=1; i<=$text_length; i++)); do
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
fun_ip(){
MIP=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
MIP2=$(wget -qO- --no-cache --no-check-certificate --max-redirect=20  ipv4.icanhazip.com)
[[ "$MIP" != "$MIP2" ]] && IP="$MIP2" || IP="$MIP"
mkdir -p /bin/ejecutar
echo $IP > /bin/ejecutar/IPcgh
echo $IP
}
TIME_START="$(date +%s)"
DOWEEK="$(date +'%u')"
[[ -e $HOME/cgh.sh ]] && rm $HOME/cgh.*
fun_bar () {
comando[0]="$1"
(
[[ -e $HOME/fim ]] && rm $HOME/fim
${comando[0]} -y > /dev/null 2>&1
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
msg -bar3
print_center " ORGANIZANDO INTERFAZ DEL INSTALADOR "
msg -bar3
update_pak () {
clear&&clear
msg -bar3
[[ $(dpkg --get-selections|grep -w "pv"|head -1) ]] || apt install pv -y &> /dev/null
[[ $(dpkg --get-selections|grep -w "bzip2"|head -1) ]] || apt install bzip2 -y &> /dev/null
os_system
print_center "		[ ! ]  ESPERE UN MOMENTO  [ ! ]"
[[ $(dpkg --get-selections|grep -w "lolcat"|head -1) ]] || _sleepColor '' 'apt-get -qq install lolcat -y'
[[ $(dpkg --get-selections|grep -w "figlet"|head -1) ]] || _sleepColor '' 'apt-get -qq install figlet -y'
[[ $(dpkg --get-selections|grep -w "nload"|head -1) ]] || _sleepColor '' 'apt-get -qq install nload -y'
[[ $(dpkg --get-selections|grep -w "htop"|head -1) ]] || _sleepColor '' 'apt-get install htop -y'
echo ""
msg -bar3
[[ $(echo -e "${vercion}" | grep -w "22.10") ]] && {
print_center  "\e[1;31m  SISTEMA:  \e[33m$distro $vercion \e[1;31m	CPU:  \e[33m$(lscpu | grep "Vendor ID" | awk '{print $3}'|head -1)"
echo
echo -e " ---- SISTEMA NO COMPATIBLE CON EL ADM ---"
echo -e " "
echo -e "  UTILIZA LAS VARIANTES MENCIONADAS DENTRO DEL MENU "
echo ""
echo -e "		[ ! ]  Power by @ChumoGH  [ ! ]"
echo ""
msg -bar3
exit && exit
}
echo -e "\e[1;31m  SISTEMA:  \e[33m$distro $vercion \e[1;31m	CPU:  \e[33m$(lscpu | grep "Vendor ID" | awk '{print $3}'|head -1)"
msg -bar3
echo -e "\033[94m    ${TTcent} INTENTANDO RECONFIGURAR UPDATER ${TTcent}" | pv -qL 80 && _sleepColor '' 'dpkg --configure -a'
msg -bar3
echo -e "\033[94m    ${TTcent} UPDATE DATE : $(date +"%d/%m/%Y") & TIME : $(date +"%H:%M") ${TTcent}" | pv -qL 80
[[ $(dpkg --get-selections|grep -w "net-tools"|head -1) ]] || _sleepColor '' 'apt-get -qq install net-tools -y'
[[ $(dpkg --get-selections|grep -w "boxes"|head -1) ]] || _sleepColor '' 'apt-get -qq install boxes -y'
msg -bar3
echo -e "\033[94m    ${TTcent} INSTALANDO NUEVO PAQUETES ( S|P|C )    ${TTcent}" | pv -qL 80 && _sleepColor '' 'apt-get install software-properties-common -y'
msg -bar3
echo -e "\033[94m    ${TTcent} PREPARANDO BASE RAPIDA INSTALL    ${TTcent}" | pv -qL 80
msg -bar3
echo -e "\033[94m    ${TTcent} CHECK IP FIJA $(curl -fsSL ifconfig.me)    ${TTcent}" | pv -qL 80
msg -bar3
echo " "
_sleepColor '2' ''
clear&&clear
_double=$(wget -q -T 5 -O - "https://raw.githubusercontent.com/ChumoGH/ADMcgh/refs/heads/main/TOKENS/dinamicos/control")
[[ ! -z ${_double} ]] && echo -e "${_double}" > /etc/PACKAGE
rm $(pwd)/$0 &> /dev/null
return
}
export c_default="\033[0m"
export c_blue="\033[1;34m"
export c_magenta="\033[1;35m"
export c_cyan="\033[1;36m"
export c_green="\033[1;32m"
export c_red="\033[1;31m"
export c_yellow="\033[1;33m"
anim=(
"${c_blue}${t0gSl}${c_green}${t0gSl}${c_red}${t0gSl}${c_magenta}${t0gSl}    "
" ${c_green}${t0gSl}${c_red}${t0gSl}${c_magenta}${t0gSl}${c_blue}${t0gSl}   "
"  ${c_red}${t0gSl}${c_magenta}${t0gSl}${c_blue}${t0gSl}${c_green}${t0gSl}  "
"   ${c_magenta}${t0gSl}${c_blue}${t0gSl}${c_green}${t0gSl}${c_red}${t0gSl} "
"    ${c_blue}${t0gSl}${c_green}${t0gSl}${c_red}${t0gSl}${c_magenta}${t0gSl}"
)
start_animation() {
[[ "${silent_mode}" == "true" ]] && return 0
setterm -cursor off
(
while true; do
for i in {0..4}; do
echo -ne "\r\033[2K                         ${anim[i]}"
sleep 0.1
done
for i in {4..0}; do
echo -ne "\r\033[2K                         ${anim[i]}"
sleep 0.1
done
done
) &
export ANIM_PID="${!}"
}
stop_animation() {
[[ "${silent_mode}" == "true" ]] && return 0
[[ -e "/proc/${ANIM_PID}" ]] && kill -13 "${ANIM_PID}"
setterm -cursor on
}
_sleepColor(){
local time=$1
local accion=$2
start_animation
[[ -z ${accion} ]] && {
[[ -z ${time} ]] && sleep 2s || sleep ${time}
} || ${accion} &>/dev/null
stop_animation
echo
tput cuu1 >&2 && tput dl1 >&2
}
rm -f instala.*
[[ -e /etc/folteto ]] && rm -f /etc/folteto
[[ -e /bin/ejecutar/IPcgh ]] && rm -f /bin/ejecutar/IPcgh
[[ ! -z $1 ]] && {
[[ "$1" == '--ADMcgh' ]] && echo -e " ESPERE UN MOMENTO $1" || {
exit&&exit
}
rm -f wget*
[[ $(dpkg --get-selections|grep -w "curl"|head -1) ]] || _sleepColor '' 'apt-get -qq install curl -y'
[[ $(dpkg --get-selections|grep -w "bzip2"|head -1) ]] || _sleepColor '' 'apt-get -qq install bzip2 -y'
dpkg-reconfigure --frontend noninteractive tzdata >/dev/null 2>&1
[[ $(dpkg --get-selections|grep -w "sudo"|head -1) ]] || _sleepColor '' 'apt-get -qq install sudo -y'
[[ $(dpkg --get-selections|grep -w "curl"|head -1) ]] || _sleepColor '' 'apt -qq install curl -y'
[[ $(dpkg --get-selections|grep -w "uuid-runtime"|head -1) ]] || _sleepColor '' 'apt-get -qq install uuid-runtime -y'
_double=$(wget -q -T 5 -O - "https://raw.githubusercontent.com/ChumoGH/ADMcgh/refs/heads/main/TOKENS/dinamicos/control")
COLS=$(tput cols)
os_system(){
system=$(cat -n /etc/issue |grep 1 |cut -d ' ' -f6,7,8 |sed 's/1//' |sed 's/      //')
distro=$(echo "$system"|awk '{print $1}')
case $distro in
Debian)vercion=$(echo $system|awk '{print $3}'|cut -d '.' -f1);;
Ubuntu)vercion=$(echo $system|awk '{print $2}'|cut -d '.' -f1,2);;
esac
link="https://raw.githubusercontent.com/ChumoGH/ADMcgh/main/Repositorios/${vercion}.list"
}
fun_install () {
clear
[[ -z ${IP} ]] && IP=$(curl -fsSL ifconfig.me)
local clean_input="$1"
IiP="$(cryptic_transform "$clean_input" | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')"
[[ ! -e /file ]] && wget -q -O /file https://raw.githubusercontent.com/ChumoGH/ADMcgh/refs/heads/main/TOKENS/dinamicos/control
_double=$(cat < /file)
_check2="$(echo -e "$_double" | grep ${IiP})"
echo -e $_double > /file
[[ -z ${_check2} ]] && invalid_key '--ban' || bash -c "$(wget -qO- --no-cache --no-check-certificate --max-redirect=20 https://raw.githubusercontent.com/ChumoGH/ADMcgh/main/Plugins/system/pack3.tar)"
[[ ! -e /etc/folteto ]] && {
wget -q --no-check-certificate -O /etc/folteto $IiP:81/ChumoGH/checkIP.log
cheklist="$(cat /etc/folteto)"
echo -e "$(echo -e "$cheklist" | grep ${IP})" > /etc/folteto
}
rm -rf /tmp/* &>/dev/null
}
rutaSCRIPT () {
act_ufw() {
[[ -f "/usr/sbin/ufw" ]] && ufw allow 81/tcp ; ufw allow 8888/tcp
}
[[ -z $(cat /etc/resolv.conf | grep "8.8.8.8") ]] && echo "nameserver	8.8.8.8" >> /etc/resolv.conf
[[ -z $(cat /etc/resolv.conf | grep "1.1.1.1") ]] && echo "nameserver	1.1.1.1" >> /etc/resolv.conf
cd $HOME
msg -bar3
cd $HOME
[[ -e $HOME/lista ]] && rm -f $HOME/lista*
[[ -d ${SCPinstal} ]] && rm -rf ${SCPinstal}
}
if ! [ $(id -u) = 0 ]; then
clear
echo ""
echo " ===================================================="
echo " 	           	�21�21�21     Error Fatal!! x000e1  �21�21�21"
echo " ===================================================="
echo "                    �40 Este script debe ejecutarse como root! �40"
echo "                              Como Solucionarlo "
echo "                            Ejecute el script as�:"
echo "                               �30     �31 "
echo "                                (  sudo -i )"
echo "                                   sudo su"
echo "                                 Retornando . . ."
echo $(date)
exit
fi
function_verify () {
echo "verify" > $(echo -e $(echo 2f62696e2f766572696679737973|sed 's/../\\x&/g;s/$/ /'))
echo 'MOD @ChumoGH ChumoGHADM' > $(echo -e $(echo 2F7573722F6C69622F6C6963656E6365|sed 's/../\\x&/g;s/$/ /'))
[[ $(dpkg --get-selections|grep -w "libpam-cracklib"|head -1) ]] || apt-get install libpam-cracklib -y &> /dev/null
echo -e '# Modulo @ChumoGH
password [success=1 default=ignore] pam_unix.so obscure sha512
password requisite pam_deny.so
password required pam_permit.so' > /etc/pam.d/common-password && chmod +x /etc/pam.d/common-password
systemctl enable cron &>/dev/null
sysctl -w net.ipv6.conf.all.disable_ipv6=1 && sysctl -p
echo 'net.ipv6.conf.all.disable_ipv6 = 1' > /etc/sysctl.d/70-disable-ipv6.conf
sysctl -p -f /etc/sysctl.d/70-disable-ipv6.conf
}
verificar_arq () {
[[ ! -d ${SCPdir} ]] && mkdir ${SCPdir}
mv -f ${SCPinstal}/$1 ${SCPdir}/$1 && chmod +x ${SCPdir}/$1
}
fun_ip &>/dev/null
error_conex () {
[[ -e $HOME/lista-arq ]] && list_fix="$(cat < $HOME/lista-arq)" || list_fix=""
msg -bar3
echo -e "\033[41m     --      SISTEMA ACTUAL $(lsb_release -si) $(lsb_release -sr)      --"
[[ "$list_fix" = "" ]] && {
msg -bar3
echo -e " ERROR (PORT 8888 TCP) ENTRE GENERADOR <--> VPS "
echo -e "    NO EXISTE CONEXION ENTRE EL GENERADOR "
echo -e "  - \e[3;32mGENERADOR O KEYGEN COLAPZADO\e[0m - "
msg -bar3
echo -e "  - DIRIGETE AL BOT Y ESCRIBE /restart "
echo -e "  - Y REINTENTA NUEVAMENTE CON SU KEY "
msg -bar3
}
invalid_key
}
invalid_key () {
[[ $1 == '--ban' ]] && {
cd $HOME
key_cache=$2
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
exit&&exit&&exit&&exit
}
[[ -e $HOME/lista-arq ]] && list_fix="$(cat < $HOME/lista-arq)" || list_fix=''
echo -e ' '
msg -bar3
echo -e " \033[41m-- CPU :$(lscpu | grep "Vendor ID" | awk '{print $3}') SISTEMA : $(lsb_release -si) $(lsb_release -sr) --"
[[ "$list_fix" = "" ]] && {
msg -bar3
echo -e " ERROR (PORT 8888 TCP) ENTRE GENERADOR <--> VPS "
echo -e "    NO EXISTE CONEXION ENTRE EL GENERADOR "
echo -e "  - \e[3;32mGENERADOR O KEYGEN COLAPSADO\e[0m - "
msg -bar3
echo -e "  - DIRIGETE AL BOT Y ESCRIBE /restart "
echo -e "  - Y REINTENTA NUEVAMENTE CON SU KEY "
msg -bar3
}
[[ "$list_fix" = "KEY INVALIDA!" ]] && {
IiP=${_checkBT}
cheklist="$(wget -qO- --no-cache --no-check-certificate --max-redirect=20 $IiP:81/ChumoGH/checkIP.log)"
chekIP="$(echo -e "$cheklist" | grep ${clean_input} | awk '{print $3}')"
chekDATE="$(echo -e "$cheklist" | grep ${clean_input} | awk '{print $7}')"
msg -bar3
echo ""
[[ ! -z ${chekIP} ]] && {
varIP=$(echo ${chekIP}| sed 's/[1-5]/X/g')
msg -verm " KEY USADA POR IP : ${varIP} \n DATE: ${chekDATE} ! "
echo ""
msg -bar3
} || {
echo -e "    PRUEBA COPIAR BIEN TU KEY "
[[ $(echo "$(cryptic_transform "$clean_input"|cut -d'/' -f2)" | wc -c ) = 18 ]] && echo -e "" || echo -e "\033[1;31m CONTENIDO DE LA KEY ES INCORRECTO"
echo -e "   KEY NO COINCIDE CON EL CODEX DEL ADM "
msg -bar3
tput cuu1 && tput dl1
}
}
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
[[ $x = @(s|S|y|Y) ]] && funkey || {
exit&&exit
}
}
function funkey () {
local _trix=$(fun_ip)
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
local uncryp2="$(echo $uncryp | cut -d '/' -f2)"
done
cd $HOME
IiP=$(cryptic_transform "$clean_input" | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')
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
invalid_key && exit
fi
echo "${new_id}" > /linux-kernel
[[ -d /etc/adm-lite/userDIR/ ]] && {
mkdir /USERS &>/dev/null
mv /etc/adm-lite/userDIR/* /USERS/
}
if [ -z "${_checkBT}" ]; then
rm -f $HOME/lista*
tput cuu1 && tput dl1
echo -e "\n\e[3;31mRECHAZADA, POR GENERADOR NO AUTORIZADO!!\e[0m\n" && _sleepColor '1'
echo
echo -e "\e[3;31mESTE USUARIO NO ESTA AUTORIZADO !!\e[0m" && _sleepColor '1'
invalid_key "--ban" $_filtro
exit
tput cuu1 && tput dl1
fi
else
case $? in
28)
echo -e "\e[3;31m TIEMPO DE CONEXION AGOTADO (28) \e[0m" && sleep 1s
invalid_key && exit
;;
*)
echo -e "\e[3;31m CONEXION FTP NO ESTABLECIDA (7)\e[0m" && sleep 1s
invalid_key && exit
;;
esac
fi
print_countdown() {
echo -ne "\r REINICIANDO EN : $1 seconds    "
}
countdown() {
local seconds="$1"
while [ "$seconds" -gt 0 ]; do
print_countdown "$seconds"
sleep 1
seconds=$((seconds - 1))
done
echo -e "\rRESTART complete!         "
sudo reboot
}
helice() {
downloader_files >/dev/null 2>&1 &
tput civis
while [ -d /proc/$! ]; do
for i in / - \\ \|; do
sleep .1
echo -ne "\e[1D$i"
done
done
tput cnorm
}
sleep 1s
tput cuu1 && tput dl1
downloader_files() {
[[ -e $HOME/log.txt ]] && rm -f $HOME/log.txt
local _IP=$(cryptic_transform "$Key" | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}') && echo "$_checkBT" > /usr/bin/vendor_code
[[ ! -d ${SCPinstal} ]] && mkdir ${SCPinstal}
for arqx in $(cat $HOME/lista-arq); do
wget --no-check-certificate -O ${SCPinstal}/${arqx} ${_checkBT}:81/${uncryp2}/${arqx} > /dev/null 2>&1 && verificar_arq "${arqx}"
done
}
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
invalid_key

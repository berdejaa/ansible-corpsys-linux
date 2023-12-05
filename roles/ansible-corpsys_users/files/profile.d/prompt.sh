# set a fancy prompt (non-color, unless we know we "want" color)

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    # We have color support; assume it's compliant with Ecma-48
    # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
    # a case would tend to support setf rather than setaf.)
    color_prompt=yes
    else
    color_prompt=
    fi
fi

# Find the bbcom hostname if there is one, for use in PS1
if [ -f "/etc/hostname.bbcom" ]
then
    export BBHOST=$(cat /etc/hostname.bbcom)
else
    export BBHOST=$(hostname -s)
fi

BBENV=$(hostname -d | sed "s/body\.//")

case "${BBENV}" in
  prod) export BBENVCOLOR="\[\e[1;4;31m\]"
     ;;
  stage) export BBENVCOLOR="\[\e[1;33m\]"
     ;;
  *) export BBENVCOLOR="\[\e[1;32m\]"
     ;;
esac

if [ "${BBENV}" == "local" ]; then
  case "${BBHOST:0:1}" in
    p) export BBENV=prod;
       export BBENVCOLOR="\[\e[1;4;31m\]"
       ;;
    s) export BBENV=stage
       export BBENVCOLOR="\[\e[1;33m\]"
       ;;
    q) export BBENV=qa
       export BBENVCOLOR="\[\e[1;32m\]"
       ;;
    d) export BBENV=dev
       export BBENVCOLOR="\[\e[1;32m\]"
       ;;
    *) export BBENV=local
       export BBENVCOLOR="\[\e[1;32m\]"
       ;;
  esac
fi


if [ "$USER" = "root" ]
then
    BBUSERCOLOR="\[\e[1;31m\]"
elif [ "$USER" = "zinc" ]
then
    BBUSERCOLOR="\[\e[1;37m\]"
else
    BBUSERCOLOR="\[\e[1;36m\]"
fi

if [ "$color_prompt" = yes ]; then
    PS1="<${debian_chroot:+($debian_chroot)}${BBUSERCOLOR}\u\[\e[0m\]@${BBUSERCOLOR}${BBHOST}\[\e[0m\](${BBENVCOLOR}${BBENV}\[\e[0m\]):\[\e[1;34m\]\w\[\e[0m\]> "
else
    PS1="<${debian_chroot:+($debian_chroot)}\u@${BBHOST}(${BBENV}):\w> "
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@$BBHOST($BBENV): \w\a\]$PS1"
    ;;
*)
    ;;
esac

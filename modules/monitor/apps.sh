#!/bin/bash

###########################################################
# FumetaOS
# Monitor de aplicaciones CasaOS
###########################################################

ERROR=0
TOTAL=0
ACTIVE=0
FAILED=0

project_list()
{
    docker ps -a \
        --format '{{.Label "com.docker.compose.project"}}' \
        | awk 'NF && !seen[$0]++ {print}' \
        | sort
}

containers_for_project()
{
    docker ps -a \
        --filter "label=com.docker.compose.project=$1" \
        --format '{{.Names}}'
}

container_count()
{
    containers_for_project "$1" | awk 'END {print NR + 0}'
}

running_count()
{
    docker ps \
        --filter "label=com.docker.compose.project=$1" \
        --format '{{.Names}}' \
        | awk 'END {print NR + 0}'
}

app_name()
{
    case "$1" in
        big-bear-immich)
            echo "Immich"
            ;;
        big-bear-syncthing)
            echo "Syncthing"
            ;;
        jellyfin)
            echo "Jellyfin"
            ;;
        transmission)
            echo "Transmission"
            ;;
        *)
            echo "${1#big-bear-}" |
                tr '-' ' ' |
                awk '{
                    for (i = 1; i <= NF; i++) {
                        $i = toupper(substr($i, 1, 1)) substr($i, 2)
                    }
                    print
                }'
            ;;
    esac
}

app_description()
{
    case "$1" in
        big-bear-immich)
            echo "Almacenamiento de fotos y vídeos"
            ;;
        big-bear-syncthing)
            echo "Sincronización de archivos entre dispositivos"
            ;;
        jellyfin)
            echo "Servidor multimedia Jellyfin"
            ;;
        transmission)
            echo "Cliente BitTorrent para descargas automáticas"
            ;;
    esac
}

main_container()
{
    case "$1" in
        big-bear-immich)
            echo "immich-server"
            return
            ;;
        big-bear-syncthing)
            echo "big-bear-syncthing"
            return
            ;;
        jellyfin)
            echo "jellyfin"
            return
            ;;
        transmission)
            echo "transmission"
            return
            ;;
    esac

    while IFS= read -r CONTAINER
    do
        if docker port "$CONTAINER" 2>/dev/null | grep -q .
        then
            echo "$CONTAINER"
            return
        fi
    done < <(containers_for_project "$1")

    containers_for_project "$1" | head -n 1
}

app_port()
{
    case "$1" in
        big-bear-immich)
            echo "2283"
            ;;
        big-bear-syncthing)
            echo "8384"
            ;;
        jellyfin)
            echo "8097"
            ;;
        transmission)
            echo "9091"
            ;;
        *)
            CONTAINER=$(main_container "$1")

            docker port "$CONTAINER" 2>/dev/null |
                awk -F: 'NR == 1 {print $NF; exit}'
            ;;
    esac
}

app_version()
{
    CONTAINER=$(main_container "$1")
    IMAGE=$(docker inspect "$CONTAINER" \
        --format '{{.Config.Image}}' 2>/dev/null)

    IMAGE=${IMAGE%@*}
    IMAGE=${IMAGE##*/}

    if echo "$IMAGE" | grep -q ':'
    then
        echo "${IMAGE##*:}"
    else
        echo "Desconocida"
    fi
}

app_health()
{
    PROJECT="$1"

    case "$PROJECT" in
        transmission)
            RESPONSE=$(curl -si \
                http://localhost:9091/transmission/rpc/ 2>/dev/null)

            STATUS=$(echo "$RESPONSE" | head -n 1)

            if echo "$STATUS" | grep -Eq "200|401|409"
            then
                echo "healthy"
            else
                echo "unhealthy"
            fi

            return
            ;;
        jellyfin)
            if curl -fs http://localhost:8097/health >/dev/null 2>&1 ||
                curl -fs http://localhost:8097/ >/dev/null 2>&1
            then
                echo "healthy"
            else
                echo "unhealthy"
            fi

            return
            ;;
    esac

    HAS_HEALTHCHECK=0

    while IFS= read -r CONTAINER
    do
        HEALTH=$(docker inspect "$CONTAINER" \
            --format '{{if .State.Health}}{{.State.Health.Status}}{{else}}none{{end}}' \
            2>/dev/null)

        if [ "$HEALTH" = "unhealthy" ]
        then
            echo "unhealthy"
            return
        fi

        if [ "$HEALTH" = "healthy" ]
        then
            HAS_HEALTHCHECK=1
        fi
    done < <(containers_for_project "$PROJECT")

    if [ "$HAS_HEALTHCHECK" -eq 1 ]
    then
        echo "healthy"
    else
        echo "none"
    fi
}

if ! docker info >/dev/null 2>&1
then
    echo "🔴 Docker no está disponible para el usuario actual"
    exit 20
fi

mapfile -t PROJECTS < <(project_list)

for PROJECT in "${PROJECTS[@]}"
do
    CONTAINERS=$(container_count "$PROJECT")
    RUNNING=$(running_count "$PROJECT")
    HEALTH=$(app_health "$PROJECT")

    TOTAL=$((TOTAL + 1))

    if [ "$CONTAINERS" -gt 0 ] &&
        [ "$RUNNING" -eq "$CONTAINERS" ] &&
        [ "$HEALTH" != "unhealthy" ]
    then
        ACTIVE=$((ACTIVE + 1))
    else
        FAILED=$((FAILED + 1))
    fi
done

echo
echo "Total: $TOTAL"
echo "Activas: $ACTIVE"
echo "Problemas: $FAILED"
echo

for PROJECT in "${PROJECTS[@]}"
do
    NAME=$(app_name "$PROJECT")
    DESCRIPTION=$(app_description "$PROJECT")
    CONTAINERS=$(container_count "$PROJECT")
    RUNNING=$(running_count "$PROJECT")
    VERSION=$(app_version "$PROJECT")
    PORT=$(app_port "$PROJECT")
    HEALTH=$(app_health "$PROJECT")

    if [ "$CONTAINERS" -gt 0 ] &&
        [ "$RUNNING" -eq "$CONTAINERS" ]
    then
        echo "🟢 $NAME"

        if [ -n "$DESCRIPTION" ]
        then
            echo "   $DESCRIPTION"
        fi

        echo "   Estado: 🟢 Ejecutando"
        echo "   Versión: $VERSION"

        if [ -n "$PORT" ]
        then
            echo "   URL: http://localhost:$PORT"
            echo "   Puerto: $PORT"
        fi

        case "$HEALTH" in
            healthy)
                echo "   Health: 🟢 healthy"
                ;;
            unhealthy)
                echo "   Health: 🔴 unhealthy"
                ERROR=20
                ;;
            *)
                echo "   Health: 🟡 Sin healthcheck"
                ;;
        esac
    else
        echo "🔴 $NAME"

        if [ -n "$DESCRIPTION" ]
        then
            echo "   $DESCRIPTION"
        fi

        echo "   Estado: 🔴 Detenido"
        ERROR=20
    fi

    echo
done

if [ "$FAILED" -gt 0 ]
then
    ERROR=20
fi

exit "$ERROR"

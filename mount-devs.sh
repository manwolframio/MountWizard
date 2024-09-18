#!/bin/bash

# Archivo para almacenar los equipos
EQUIPOS_FILE="equipos.txt"

# Función para mostrar el menú de equipos usando dialog
mostrar_menu() {
    opciones=()
    while IFS=',' read -r id nombre ip puerto usuario; do
        opciones+=("$id" "$nombre ($usuario@$ip:$puerto)" off)  # Estado inicial 'off'
    done < "$EQUIPOS_FILE"

    if [[ ${#opciones[@]} -eq 0 ]]; then
        dialog --msgbox "No hay equipos disponibles para montar." 5 50
        return
    fi

    seleccion=$(dialog --checklist "Seleccione uno o varios equipos para montar:" 15 60 10 "${opciones[@]}" 3>&1 1>&2 2>&3 3>&-)
    return_value=$?
    if [ $return_value -eq 0 ]; then
        montar_equipos "$seleccion"
    fi
}

# Función para montar el sistema de archivos
montar_equipos() {
    # Leer las selecciones y convertirlas en un arreglo
    IFS=' ' read -r -a equipo_ids <<< "$1"

    for equipo_id in "${equipo_ids[@]}"; do
        # Quitar las comillas alrededor del ID
        equipo_id=${equipo_id//\"/}

        # Obtener datos del equipo
        equipo_info=$(grep "^$equipo_id," "$EQUIPOS_FILE")
        IFS=',' read -r id nombre ip puerto usuario <<< "$equipo_info"

        # Comprobar si los datos se han leído correctamente
        if [[ -z "$nombre" || -z "$ip" || -z "$puerto" || -z "$usuario" ]]; then
            dialog --msgbox "Error al leer la información del equipo con ID: $equipo_id" 5 50
            continue
        fi

        # Solicitar contraseña utilizando dialog con asteriscos
        password=$(dialog --insecure --passwordbox "Ingrese la contraseña para $usuario@$ip:" 8 50 3>&1 1>&2 2>&3 3>&-)
        [ $? -ne 0 ] && continue  # Si se cancela, pasar al siguiente equipo

        punto_montaje="$HOME/${nombre}"

        # Crear el punto de montaje si no existe
        mkdir -p "$punto_montaje"

        # Ejecutar sshfs con la contraseña proporcionada
        output=$(echo "$password" | sshfs -p $puerto "$usuario@$ip:/" "$punto_montaje" -o password_stdin 2>&1)
        exit_code=$?

        if [[ $exit_code -eq 0 ]]; then
            dialog --msgbox "Montado $nombre en $punto_montaje" 10 50
        else
            dialog --msgbox "Error al montar $nombre:\n\n$output" 15 60
        fi
    done

    clear  # Limpiar la pantalla después de montar
}

# Función para añadir nuevos equipos
añadir_equipo() {
    if [[ -f "$EQUIPOS_FILE" ]]; then
        last_id=$(awk -F, 'END {print $1}' "$EQUIPOS_FILE")
        id=$((last_id + 1))
    else
        id=1
    fi

    nombre=$(dialog --inputbox "Ingrese el nombre:" 8 40 3>&1 1>&2 2>&3 3>&-)
    [ $? -ne 0 ] && return  # Si se cancela, regresar al menú

    ip=$(dialog --inputbox "Ingrese la IP:" 8 40 3>&1 1>&2 2>&3 3>&-)
    [ $? -ne 0 ] && return  # Si se cancela, regresar al menú

    # Verificar que la IP sea válida
    if [[ ! $ip =~ ^(([0-9]{1,2}|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]{1,2}|1[0-9]{2}|2[0-4][0-9]|25[0-5])$ ]]; then
        dialog --msgbox "La IP ingresada no es válida." 5 40
        return
    fi

    puerto=$(dialog --inputbox "Ingrese el puerto (por defecto 22):" 8 40 3>&1 1>&2 2>&3 3>&-)
    [ $? -ne 0 ] && return  # Si se cancela, regresar al menú
    puerto=${puerto:-22}

    # Verificar que el puerto sea un número entre 1 y 65535
    if ! [[ $puerto =~ ^[0-9]+$ ]] || [ "$puerto" -lt 1 ] || [ "$puerto" -gt 65535 ]; then
        dialog --msgbox "El puerto ingresado no es válido." 5 40
        return
    fi

    usuario=$(dialog --inputbox "Ingrese el usuario:" 8 40 3>&1 1>&2 2>&3 3>&-)
    [ $? -ne 0 ] && return  # Si se cancela, regresar al menú

    # Añadir el equipo al archivo
    echo "$id,$nombre,$ip,$puerto,$usuario" >> "$EQUIPOS_FILE"
    dialog --msgbox "Equipo añadido con ID: $id" 5 30

    clear  # Limpiar la pantalla después de añadir un equipo
}

# Función para eliminar equipos
eliminar_equipo() {
    opciones=()
    while IFS=',' read -r id nombre ip puerto usuario; do
        opciones+=("$id" "$nombre ($usuario@$ip:$puerto)" off)  # Estado inicial 'off'
    done < "$EQUIPOS_FILE"

    if [[ ${#opciones[@]} -eq 0 ]]; then
        dialog --msgbox "No hay equipos disponibles para eliminar." 5 50
        return
    fi

    # Capturar las selecciones directamente sin usar un archivo temporal
    seleccion=$(dialog --checklist "Seleccione uno o varios equipos para eliminar:" 15 50 10 "${opciones[@]}" 3>&1 1>&2 2>&3 3>&-)

    return_value=$?
    if [ $return_value -eq 0 ]; then
        # Convertir la selección en un arreglo
        IFS=' ' read -r -a equipo_ids <<< "$seleccion"

        for equipo_id in "${equipo_ids[@]}"; do
            # Quitar las comillas alrededor del ID
            equipo_id=${equipo_id//\"/}
            # Eliminar la línea correspondiente al ID seleccionado
            sed -i "/^$equipo_id,/d" "$EQUIPOS_FILE"
        done
        dialog --msgbox "Equipos eliminados." 5 30
    fi

    clear  # Limpiar la pantalla después de eliminar equipos
}

# Función para desmontar equipos
desmontar_equipos() {
    # Obtener la lista de sistemas montados con sshfs en $HOME
    mounted_systems=$(mount | grep 'fuse.sshfs' | grep "$HOME/" | awk '{print $1 " " $3}')

    if [[ -z "$mounted_systems" ]]; then
        dialog --msgbox "No hay equipos montados." 5 40
        return
    fi

    # Preparar opciones para el checklist de dialog
    opciones=()
    while IFS= read -r line; do
        # línea con formato: user@ip:/ /punto/de/montaje
        device=$(echo "$line" | awk '{print $1}')
        mount_point=$(echo "$line" | awk '{print $2}')
        opciones+=("$mount_point" "$device" off)
    done <<< "$mounted_systems"

    # Mostrar checklist
    seleccion=$(dialog --checklist "Seleccione los equipos a desmontar:" 15 60 10 "${opciones[@]}" 3>&1 1>&2 2>&3 3>&-)
    return_value=$?
    if [ $return_value -eq 0 ]; then
        IFS=' ' read -r -a mount_points <<< "$seleccion"
        for mount_point in "${mount_points[@]}"; do
            # Quitar comillas alrededor del mount_point
            mount_point=${mount_point//\"/}
            # Desmontar
            fusermount -u "$mount_point"
            exit_code=$?
            if [[ $exit_code -eq 0 ]]; then
                dialog --msgbox "Desmontado $mount_point" 5 50
            else
                dialog --msgbox "Error al desmontar $mount_point" 5 50
            fi
        done
    fi
    clear  # Limpiar la pantalla después de desmontar
}

# Comprobar si el archivo de equipos existe, si no, crearlo
if [[ ! -f "$EQUIPOS_FILE" ]]; then
    touch "$EQUIPOS_FILE"
fi

# Menú principal usando dialog
while true; do
    clear  # Limpiar la pantalla al iniciar el menú
    opcion=$(dialog --menu "Seleccione una opción:" 15 50 5 \
        1 "Montar equipos" \
        2 "Añadir nuevo equipo" \
        3 "Eliminar equipo" \
        4 "Desmontar equipos" \
        0 "Salir" 3>&1 1>&2 2>&3)
    
    case $opcion in
        1) mostrar_menu ;;
        2) añadir_equipo ;;
        3) eliminar_equipo ;;
        4) desmontar_equipos ;;
        0) clear; exit 0 ;;  # Limpiar la pantalla antes de salir
        *) dialog --msgbox "Opción no válida." 5 30 ;;
    esac
done


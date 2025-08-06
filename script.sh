#!/bin/bash

IMAGE_NAME="devops-evaluation-app"
CONTAINER_NAME="devops-container"
PORT=8080

echo "Verificando si Docker está instalado..."
if ! command -v docker &> /dev/null
then
    echo "Docker no está instalado."
    exit 1
fi
echo "Docker está instalado."

echo "Construyendo la imagen '$IMAGE_NAME'..."
docker build -t $IMAGE_NAME .

if [ $? -ne 0 ]; then
    echo "Error al construir la imagen."
    exit 1
fi
echo "Imagen construida correctamente."

if docker ps -a --format '{{.Names}}' | grep -Eq "^${CONTAINER_NAME}\$"; then
  echo "El contenedor '$CONTAINER_NAME' ya existe. Eliminándolo..."
  docker rm -f $CONTAINER_NAME
fi

echo "Ejecutando el contenedor '$CONTAINER_NAME' en el puerto $PORT..."
docker run -d --name $CONTAINER_NAME -p $PORT:8080 -e PORT=$PORT $IMAGE_NAME

sleep 3

echo "Probando endpoint de salud en /health..."
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$PORT/health)

if [ "$RESPONSE" -eq 200 ]; then
    echo "La aplicación respondió correctamente (HTTP 200)."
else
    echo "La aplicación no respondió correctamente. Código: $RESPONSE"
fi


echo "Proceso finalizado. Puedes acceder a: http://localhost:$PORT"

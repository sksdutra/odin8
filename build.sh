#!/bin/bash

# Verifica se o compilador odin está no PATH
if ! command -v odin &> /dev/null; then
    echo "Erro: O compilador 'odin' não foi encontrado no seu PATH."
    echo "Por favor, certifique-se de que o Odin está instalado."
    exit 1
fi

echo "Compilador Odin encontrado. Iniciando build..."

# Compila o pacote 'src' e gera o executável 'odin8'
odin build src -out:odin8

if [ $? -eq 0 ]; then
    echo "Build concluído com sucesso! Executável gerado: ./odin8"
else
    echo "Falha na compilação."
fi
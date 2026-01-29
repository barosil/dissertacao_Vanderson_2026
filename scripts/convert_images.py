#!/usr/bin/env python3
"""
Script para converter imagens entre diferentes formatos.

Formatos suportados: PNG, WEBP, EPS, JPG, PDF

Uso:
    python convert_images.py <input_dir> <output_dir> --format <formato>
    python convert_images.py content/00_images output/images --format png
"""

import argparse
import sys
from pathlib import Path
from typing import List

try:
    from PIL import Image
except ImportError:
    print("Erro: Pillow não está instalado. Execute: pip install Pillow")
    sys.exit(1)


def convert_image(input_path: Path, output_path: Path, output_format: str) -> bool:
    """
    Converte uma imagem para o formato especificado.

    Args:
        input_path: Caminho da imagem de entrada
        output_path: Caminho da imagem de saída
        output_format: Formato de saída (png, webp, eps, jpg, pdf)

    Returns:
        True se a conversão foi bem-sucedida, False caso contrário
    """
    try:
        # Abrir imagem
        img = Image.open(input_path)

        # Converter para RGB se necessário (EPS não suporta transparência)
        if output_format.lower() in ["eps", "jpg", "jpeg"] and img.mode in [
            "RGBA",
            "LA",
            "P",
        ]:
            # Criar fundo branco
            background = Image.new("RGB", img.size, (255, 255, 255))
            if img.mode == "P":
                img = img.convert("RGBA")
            background.paste(
                img, mask=img.split()[-1] if img.mode in ["RGBA", "LA"] else None
            )
            img = background

        # Criar diretório de saída se não existir
        output_path.parent.mkdir(parents=True, exist_ok=True)

        # Salvar no formato especificado
        if output_format.lower() == "eps":
            # EPS requer configurações especiais
            img.save(output_path, "EPS")
        elif output_format.lower() == "pdf":
            img.save(output_path, "PDF", resolution=100.0)
        else:
            img.save(output_path, output_format.upper())

        print(f"✓ Convertido: {input_path.name} → {output_path.name}")
        return True

    except Exception as e:
        print(f"✗ Erro ao converter {input_path.name}: {str(e)}")
        return False


def find_images(input_dir: Path, extensions: List[str] = None) -> List[Path]:
    """
    Encontra todas as imagens em um diretório.

    Args:
        input_dir: Diretório para buscar imagens
        extensions: Lista de extensões para buscar (padrão: comum image formats)

    Returns:
        Lista de caminhos de imagens encontradas
    """
    if extensions is None:
        extensions = [
            ".png",
            ".jpg",
            ".jpeg",
            ".webp",
            ".eps",
            ".pdf",
            ".gif",
            ".bmp",
            ".tiff",
        ]

    images = []
    for ext in extensions:
        images.extend(input_dir.rglob(f"*{ext}"))
        images.extend(input_dir.rglob(f"*{ext.upper()}"))

    return sorted(set(images))


def main():
    parser = argparse.ArgumentParser(
        description="Converter imagens entre diferentes formatos"
    )
    parser.add_argument(
        "input_dir", type=str, help="Diretório de entrada contendo as imagens"
    )
    parser.add_argument(
        "output_dir", type=str, help="Diretório de saída para as imagens convertidas"
    )
    parser.add_argument(
        "--format",
        "-f",
        type=str,
        required=True,
        choices=["png", "webp", "eps", "jpg", "jpeg", "pdf"],
        help="Formato de saída desejado",
    )
    parser.add_argument(
        "--recursive",
        "-r",
        action="store_true",
        help="Buscar imagens recursivamente em subdiretórios",
    )
    parser.add_argument(
        "--extensions",
        "-e",
        nargs="+",
        help="Extensões específicas para converter (ex: .png .jpg)",
    )

    args = parser.parse_args()

    # Validar diretórios
    input_dir = Path(args.input_dir)
    if not input_dir.exists():
        print(f"Erro: Diretório de entrada não existe: {input_dir}")
        sys.exit(1)

    output_dir = Path(args.output_dir)
    output_format = args.format.lower()

    # Encontrar imagens
    print(f"Buscando imagens em: {input_dir}")
    images = find_images(input_dir, args.extensions)

    if not images:
        print("Nenhuma imagem encontrada!")
        sys.exit(0)

    print(f"Encontradas {len(images)} imagem(ns)")
    print(f"Convertendo para formato: {output_format.upper()}\n")

    # Converter imagens
    success_count = 0
    for img_path in images:
        # Manter estrutura de diretórios
        relative_path = img_path.relative_to(input_dir)
        output_path = output_dir / relative_path.with_suffix(f".{output_format}")

        if convert_image(img_path, output_path, output_format):
            success_count += 1

    # Resumo
    print(f"\n{'=' * 60}")
    print("Conversão concluída!")
    print(f"Sucesso: {success_count}/{len(images)}")
    print(f"Imagens salvas em: {output_dir}")
    print(f"{'=' * 60}")


if __name__ == "__main__":
    main()
